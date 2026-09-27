/// The few database operations tables and lobbies need.
///
/// Implemented by Firebase for real play and in memory for the offline demo
/// and tests.
abstract class TableStore {
  /// Reads the value at [path], or null.
  Future<Object?> read(String path);

  /// Replaces the value at [path].
  Future<void> write(String path, Object value);

  /// Writes [value] at [path] unless a value is already there.
  ///
  /// Returns the value stored afterwards, so concurrent callers agree.
  Future<Object?> createIfAbsent(String path, Object value);

  /// Children of [path] whose [child] equals [value], by key.
  Future<Map<String, Object?>> whereEquals(
    String path,
    String child,
    String value,
  );

  /// The [limit] children of [path] with the highest [child] values, by key.
  Future<Map<String, Object?>> latest(String path, String child, int limit);

  /// Emits the value at [path] now and whenever it changes.
  Stream<Object?> watch(String path);
}
