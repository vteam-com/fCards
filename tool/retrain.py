#!/usr/bin/env python3
"""retrain.py — Download approved correction samples from Firebase RTDB and fine-tune.

The script:
  1. Fetches records under training_corrections/{uid}/* from Firebase RTDB.
  2. Filters to include only records with review_status == 'approved'.
  3. Decodes the base64 image and writes it to a temp dataset directory.
  4. Generates YOLO-format labels (corrected class, full-image bbox).
  5. Fine-tunes the base model on those samples (transfer learning).
  6. Exports to TFLite (float32) and ONNX, then copies to assets/models/.
"""

import argparse
import base64
import json
import os
import shutil
import sys
import tempfile
from pathlib import Path

# Ground-truth for benchmark images: filename -> {(row, col): expected rank token}
_BENCHMARKS: dict[str, dict[tuple[int, int], str]] = {
    "cards_grid_open_a.jpeg": {
        (0, 0): "j", (0, 1): "10", (0, 2): "a",
        (1, 0): "6", (1, 1): "9",  (1, 2): "joker",
        (2, 0): "k", (2, 1): "4",  (2, 2): "5",
    },
    "cards_grid_open_b.jpeg": {
        (0, 0): "a",  (0, 1): "2",  (0, 2): "3",
        (1, 0): "4",  (1, 1): "10", (1, 2): "j",
        (2, 0): "q",  (2, 1): "k",  (2, 2): "joker",
    },
    "cards_grid_open_c.jpeg": {
        (0, 0): "q",  (0, 1): "2",  (0, 2): "3",
        (1, 0): "q",  (1, 1): "10", (1, 2): "j",
        (2, 0): "q",  (2, 1): "k",  (2, 2): "joker",
    },
    "cards_grid_1_to_9.jpeg": {
        (0, 0): "a",  (0, 1): "2",  (0, 2): "3",
        (1, 0): "4",  (1, 1): "5",  (1, 2): "6",
        (2, 0): "7",  (2, 1): "8",  (2, 2): "9",
    },
    "cards_grid_2_kings.jpeg": {
        (0, 0): "3",  (0, 1): "k",      (0, 2): "k",
        (1, 0): "3",  (1, 1): "joker",  (1, 2): "10",
        (2, 0): "3",  (2, 1): "6",      (2, 2): "5",
    },
    "cards_grid_all_aces.jpeg": {
        (0, 0): "a",  (0, 1): "a",      (0, 2): "a",
        (1, 0): "a",  (1, 1): "joker",  (1, 2): "a",
        (2, 0): "a",  (2, 1): "a",      (2, 2): "a",
    },
    "cards_grid_zero.jpeg": {
        (0, 0): "k",  (0, 1): "k",  (0, 2): "k",
        (1, 0): "j",  (1, 1): "j",  (1, 2): "j",
        (2, 0): "6",  (2, 1): "6",  (2, 2): "6",
    },
}


def _benchmark(tflite_path: str, image_path: str, labels: list[str],
               expected: dict[tuple[int, int], str], threshold: float = 0.15) -> int:
    """Run inference on a benchmark image and return number of correct cells (max 9)."""
    try:
        import numpy as np
        import tensorflow as tf
        from PIL import Image
    except ImportError:
        print("  (benchmark skipped — PIL/tensorflow not available)")
        return -1

    interp = tf.lite.Interpreter(tflite_path)
    interp.allocate_tensors()
    inp = interp.get_input_details()[0]
    out = interp.get_output_details()[0]

    img = Image.open(image_path).convert("RGB").resize((640, 640))
    arr = np.array(img, dtype=np.float32)[np.newaxis] / 255.0
    interp.set_tensor(inp["index"], arr)
    interp.invoke()
    r = interp.get_tensor(out["index"])[0]

    d1, d2 = r.shape[0], r.shape[1]
    if d1 < d2:  # features-first [features, anchors]
        class_scores = r[4:, :]
        bbox = r[:4, :]
    else:  # anchors-first [anchors, features]
        class_scores = r[:, 4:].T
        bbox = r[:, :4].T

    max_per_anchor = class_scores.max(axis=0)
    anchors = np.where(max_per_anchor > threshold)[0]
    detections = []
    for a in anchors:
        cls = int(class_scores[:, a].argmax())
        score = float(class_scores[cls, a])
        cx, cy = float(bbox[0, a]), float(bbox[1, a])
        detections.append((score, cls, cx, cy))
    detections.sort(reverse=True)

    grid: dict[tuple[int, int], tuple[float, str]] = {}
    for score, cls, cx, cy in detections:
        col = min(int(cx * 3), 2)
        row = min(int(cy * 3), 2)
        cell = (row, col)
        if cell not in grid:
            grid[cell] = (score, labels[cls])

    correct = 0
    rows = []
    for row in range(3):
        cells = []
        for col in range(3):
            exp = expected.get((row, col), "?")
            got_label = grid.get((row, col), (0.0, "?"))[1].lower()
            hit = exp != "?" and (exp in got_label or got_label.startswith(exp))
            correct += int(hit)
            cells.append(f"{grid.get((row,col),(0,'?'))[1]:<4} {'✓' if hit else '✗'}")
        rows.append("  " + " | ".join(cells))
    print("\n".join(rows))
    return correct


def _parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Retrain card detector from Firebase corrections.")
    p.add_argument("--project", required=True, help="Firebase project ID (e.g. vteam-cards)")
    p.add_argument("--model", required=True, help="Base .pt model path")
    p.add_argument("--labels", required=True, help="labels.txt path (one label per line)")
    p.add_argument("--out-dir", default="/tmp/retrain_output", help="Working directory")
    p.add_argument("--epochs", type=int, default=20)
    p.add_argument("--imgsz", type=int, default=640)
    p.add_argument("--tflite", required=True, help="Destination .tflite path")
    p.add_argument("--onnx", required=True, help="Destination .onnx path")
    p.add_argument("--benchmark-dir", default="test/assets/benchmarks",
                   help="Directory containing benchmark images")
    return p.parse_args()


def _rank_value_to_class_indices(corrected_value: int, labels: list[str]) -> list[int]:
    """Return all label indices that match the corrected rank value (any suit)."""
    rank_map = {
        -2: ["joker"],
        0: ["kc", "kd", "kh", "ks"],
        1: ["ac", "ad", "ah", "as"],
        2: ["2c", "2d", "2h", "2s"],
        3: ["3c", "3d", "3h", "3s"],
        4: ["4c", "4d", "4h", "4s"],
        5: ["5c", "5d", "5h", "5s"],
        6: ["6c", "6d", "6h", "6s"],
        7: ["7c", "7d", "7h", "7s"],
        8: ["8c", "8d", "8h", "8s"],
        9: ["9c", "9d", "9h", "9s"],
        10: ["10c", "10d", "10h", "10s"],
        11: ["jc", "jd", "jh", "js"],
        12: ["qc", "qd", "qh", "qs"],
    }
    targets = rank_map.get(corrected_value, [])
    lower_labels = [lb.lower() for lb in labels]
    return [lower_labels.index(t) for t in targets if t in lower_labels]


def _fetch_samples(project_id: str) -> list[dict]:
    """Fetch approved training correction records from Firebase RTDB.
    
    Only includes records with review_status == 'approved'.
    """
    try:
        import firebase_admin
        from firebase_admin import credentials, db as rtdb
    except ImportError:
        sys.exit("firebase-admin not installed. Run: pip install firebase-admin")

    if not firebase_admin._apps:  # noqa: SLF001
        cred_path = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS")
        if cred_path:
            cred = credentials.Certificate(cred_path)
        else:
            # Fall back to gcloud Application Default Credentials
            cred = credentials.ApplicationDefault()
        firebase_admin.initialize_app(
            cred,
            {"databaseURL": f"https://{project_id}-default-rtdb.europe-west1.firebasedatabase.app"},
        )

    ref = rtdb.reference("training_corrections")
    data = ref.get()
    if not data:
        return []

    records = []
    total_fetched = 0
    approved_count = 0
    for _uid, entries in data.items():
        if not isinstance(entries, dict):
            continue
        for _key, record in entries.items():
            if isinstance(record, dict):
                total_fetched += 1
                # Only include records with review_status == 'approved'
                if record.get("review_status") == "approved":
                    records.append(record)
                    approved_count += 1
    
    if total_fetched > approved_count:
        filtered_out = total_fetched - approved_count
        print(f"    Filtered: {filtered_out} non-approved records excluded")
    
    return records


def _build_dataset(records: list[dict], labels: list[str], dataset_dir: Path) -> int:
    """Write YOLO dataset from records. Returns number of valid samples written."""
    images_dir = dataset_dir / "images" / "train"
    labels_dir = dataset_dir / "labels" / "train"
    images_dir.mkdir(parents=True, exist_ok=True)
    labels_dir.mkdir(parents=True, exist_ok=True)

    written = 0
    for record in records:
        corrected_value = record.get("corrected_value")
        image_b64 = record.get("image_base64")
        filename = record.get("filename", f"sample_{written}.jpg")

        if corrected_value is None or not image_b64:
            continue

        class_indices = _rank_value_to_class_indices(int(corrected_value), labels)
        if not class_indices:
            print(f"  Warning: no class for corrected_value={corrected_value}, skipping")
            continue

        # Use the first matching class index (suit-agnostic: any suit works)
        class_idx = class_indices[0]

        # Write image
        img_path = images_dir / filename
        img_path.write_bytes(base64.b64decode(image_b64))

        # Write YOLO label: class cx cy w h (full-image bbox)
        label_path = labels_dir / (Path(filename).stem + ".txt")
        label_path.write_text(f"{class_idx} 0.5 0.5 1.0 1.0\n")

        written += 1

    return written


def _write_data_yaml(dataset_dir: Path, labels: list[str]) -> Path:
    yaml_path = dataset_dir / "data.yaml"
    names_list = "\n".join(f"  {i}: {lb}" for i, lb in enumerate(labels))
    yaml_path.write_text(
        f"path: {dataset_dir}\n"
        f"train: images/train\n"
        f"val: images/train\n"
        f"nc: {len(labels)}\n"
        f"names:\n{names_list}\n"
    )
    return yaml_path


def main() -> None:
    args = _parse_args()

    labels = Path(args.labels).read_text().strip().splitlines()
    print(f"Labels loaded: {len(labels)}")

    benchmark_dir = Path(args.benchmark_dir)
    active_benchmarks = {
        name: gt for name, gt in _BENCHMARKS.items()
        if (benchmark_dir / name).exists()
    }

    def _run_all_benchmarks(label: str) -> int:
        if not active_benchmarks:
            return -1
        print(f"\n--- Benchmark {label}:")
        total_correct = total_cells = 0
        for name, gt in active_benchmarks.items():
            correct = _benchmark(args.tflite, str(benchmark_dir / name), labels, gt)
            cells = len(gt)
            total_correct += correct
            total_cells += cells
            print(f"    {name}: {correct}/{cells}")
        print(f"    Total: {total_correct}/{total_cells}")
        return total_correct

    before = _run_all_benchmarks("BEFORE training")

    print("--- Fetching samples from Firebase...")
    records = _fetch_samples(args.project)
    print(f"    Found {len(records)} records")

    if not records:
        print("No correction samples found. Exiting.")
        sys.exit(0)

    out_dir = Path(args.out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    dataset_dir = out_dir / "dataset"
    if dataset_dir.exists():
        shutil.rmtree(dataset_dir)

    print("--- Building YOLO dataset...")
    count = _build_dataset(records, labels, dataset_dir)
    print(f"    {count} samples written")

    if count == 0:
        print("No valid samples. Exiting.")
        sys.exit(0)

    data_yaml = _write_data_yaml(dataset_dir, labels)

    print("--- Fine-tuning model...")
    try:
        from ultralytics import YOLO
    except ImportError:
        sys.exit("ultralytics not installed. Run: pip install ultralytics")

    model = YOLO(args.model)
    model.train(
        data=str(data_yaml),
        epochs=args.epochs,
        imgsz=args.imgsz,
        project=str(out_dir / "runs"),
        name="retrain",
        exist_ok=True,
        freeze=10,      # freeze backbone, only tune head
        batch=4,
        patience=10,
    )

    best_pt = out_dir / "runs" / "retrain" / "weights" / "best.pt"
    if not best_pt.exists():
        sys.exit(f"Training failed — best.pt not found at {best_pt}")

    print("--- Exporting TFLite...")
    fine_tuned = YOLO(str(best_pt))
    tflite_path = fine_tuned.export(format="tflite", imgsz=args.imgsz)
    saved_model_dir = Path(str(best_pt).replace(".pt", "_saved_model"))
    src_tflite = saved_model_dir / "best_float32.tflite"
    shutil.copy(src_tflite, args.tflite)
    print(f"    TFLite → {args.tflite}")

    print("--- Exporting ONNX...")
    onnx_path = fine_tuned.export(format="onnx", imgsz=args.imgsz, opset=12)
    shutil.copy(str(onnx_path), args.onnx)
    print(f"    ONNX   → {args.onnx}")

    after = _run_all_benchmarks("AFTER training")
    if before >= 0 and after >= 0:
        delta = after - before
        sign = "+" if delta >= 0 else ""
        print(f"    Change: {sign}{delta} cells correct")

    print("--- Retrain complete!")


if __name__ == "__main__":
    main()
