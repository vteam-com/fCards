# Card Detector Model Assets

Place the following two files in this directory before building:

## `card_detector.tflite`

Your trained YOLOv8 model exported for TFLite:

```bash
yolo export model=best.pt format=tflite imgsz=640
```

Rename the output (`best_float32.tflite`) to `card_detector.tflite`.

## `card_detector.onnx`

Web inference model used by `tflite_service_web.dart`:

```bash
yolo export model=best.pt format=onnx imgsz=640
```

The current bundled web model is a 52-card detector (ranks + suits) and does
not include a Joker class.

## `labels.txt`

One class name per line, in the **exact order** used during training. Example:

```text
Ace of Spades
Two of Spades
...
King of Hearts
```

## `labels_web_52.txt`

Web-only label list for `card_detector.onnx`. Keep this in exact class order of
the ONNX model. The current file contains 52 classes (`10C`..`QS`).

## Training steps (summary)

1. Gather 15–50 photos per card class at varied angles and lighting.
2. Label with [Roboflow](https://roboflow.com/) and export in YOLO format.
3. Train: `yolo train model=yolov8n.pt data=data.yaml epochs=100 imgsz=640`
4. Export: `yolo export model=runs/detect/train/weights/best.pt format=tflite`
