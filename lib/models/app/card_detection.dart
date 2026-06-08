/// A single card detection result produced by the TFLite model.
class CardDetection {
  const CardDetection({
    required this.label,
    required this.confidence,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  /// The detected card label (e.g. "Ace of Spades").
  final String label;

  /// Detection confidence in the range [0, 1].
  final double confidence;

  /// Normalised bounding box left edge in the range [0, 1].
  final double left;

  /// Normalised bounding box top edge in the range [0, 1].
  final double top;

  /// Normalised bounding box width in the range [0, 1].
  final double width;

  /// Normalised bounding box height in the range [0, 1].
  final double height;
}
