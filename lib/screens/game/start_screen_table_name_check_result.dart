/// Result of checking whether a table name already exists.
class StartScreenTableNameCheckResult {
  /// Creates a [StartScreenTableNameCheckResult].
  const StartScreenTableNameCheckResult({
    required this.exists,
    required this.rooms,
  });

  /// Whether the table name already exists.
  final bool exists;

  /// Current room list returned from lookup.
  final List<String> rooms;
}
