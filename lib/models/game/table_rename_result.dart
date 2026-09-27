/// Outcome of renaming a table or lobby.
enum TableRenameResult {
  /// The new name was saved.
  renamed,

  /// Another table already uses that name.
  taken,

  /// The name was empty.
  invalid,
}
