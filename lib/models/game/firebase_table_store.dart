import 'package:cards/models/game/backend_model.dart';
import 'package:cards/models/game/table_store.dart';
import 'package:firebase_database/firebase_database.dart';

/// [TableStore] backed by the Firebase Realtime Database.
class FirebaseTableStore implements TableStore {
  @override
  Future<Object?> read(String path) async {
    await _ready();
    return (await FirebaseDatabase.instance.ref(path).get()).value;
  }

  @override
  Future<void> write(String path, Object value) async {
    await _ready();
    await FirebaseDatabase.instance.ref(path).set(value);
  }

  @override
  Future<Object?> createIfAbsent(String path, Object value) async {
    await _ready();
    final TransactionResult result = await FirebaseDatabase.instance
        .ref(path)
        .runTransaction(
          (Object? current) => current == null
              ? Transaction.success(value)
              : Transaction.abort(),
        );
    return result.snapshot.value;
  }

  @override
  Future<Map<String, Object?>> whereEquals(
    String path,
    String child,
    String value,
  ) async {
    await _ready();
    return _children(
      await FirebaseDatabase.instance
          .ref(path)
          .orderByChild(child)
          .equalTo(value)
          .get(),
    );
  }

  @override
  Future<Map<String, Object?>> latest(
    String path,
    String child,
    int limit,
  ) async {
    await _ready();
    return _children(
      await FirebaseDatabase.instance
          .ref(path)
          .orderByChild(child)
          .limitToLast(limit)
          .get(),
    );
  }

  @override
  Stream<Object?> watch(String path) => FirebaseDatabase.instance
      .ref(path)
      .onValue
      .map((DatabaseEvent event) => event.snapshot.value);

  static Map<String, Object?> _children(DataSnapshot snapshot) {
    final Object? value = snapshot.value;
    if (value is! Map) {
      return <String, Object?>{};
    }
    return value.map(
      (Object? key, Object? child) => MapEntry<String, Object?>('$key', child),
    );
  }

  static Future<void> _ready() async {
    await useFirebase();
    if (!backendReady) {
      throw StateError('Firebase backend not ready');
    }
  }
}
