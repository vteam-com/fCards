import 'dart:async';

import 'package:cards/models/game/table_store.dart';

/// In-memory [TableStore] for the offline demo and tests.
class MemoryTableStore implements TableStore {
  final Map<String, Object?> _root = <String, Object?>{};
  final StreamController<String> _changes =
      StreamController<String>.broadcast();

  @override
  Future<Object?> read(String path) async => _node(path);

  @override
  Future<void> write(String path, Object value) async {
    final List<String> parts = _parts(path);
    Map<String, Object?> parent = _root;
    for (final String part in parts.take(parts.length - 1)) {
      final Object? child = parent[part];
      if (child is Map<String, Object?>) {
        parent = child;
      } else {
        final Map<String, Object?> created = <String, Object?>{};
        parent[part] = created;
        parent = created;
      }
    }
    parent[parts.last] = _copy(value);
    _changes.add(path);
  }

  @override
  Future<Object?> createIfAbsent(String path, Object value) async {
    if (_node(path) == null) {
      await write(path, value);
    }
    return _node(path);
  }

  @override
  Future<Map<String, Object?>> whereEquals(
    String path,
    String child,
    String value,
  ) async => <String, Object?>{
    for (final MapEntry<String, Object?> entry in _childrenOf(path).entries)
      if (entry.value is Map && (entry.value! as Map)[child] == value)
        entry.key: entry.value,
  };

  @override
  Future<Map<String, Object?>> latest(
    String path,
    String child,
    int limit,
  ) async {
    num order(Object? value) {
      final Object? field = value is Map ? value[child] : null;
      return field is num ? field : 0;
    }

    final List<MapEntry<String, Object?>> entries =
        _childrenOf(path).entries.toList()
          ..sort((a, b) => order(b.value).compareTo(order(a.value)));
    return Map<String, Object?>.fromEntries(entries.take(limit));
  }

  @override
  Stream<Object?> watch(String path) async* {
    yield _node(path);
    await for (final String changed in _changes.stream) {
      if (changed.startsWith(path) || path.startsWith(changed)) {
        yield _node(path);
      }
    }
  }

  Map<String, Object?> _childrenOf(String path) {
    final Object? node = _node(path);
    return node is Map<String, Object?> ? node : <String, Object?>{};
  }

  /// Walks [path] from the root; null when any segment is missing.
  Object? _node(String path) {
    Object? node = _root;
    for (final String part in _parts(path)) {
      if (node is! Map) {
        return null;
      }
      node = node[part];
    }
    return node;
  }

  static List<String> _parts(String path) =>
      path.split('/').where((String part) => part.isNotEmpty).toList();

  /// Deep-copies maps and lists so stored values can't be mutated from outside.
  static Object? _copy(Object? value) {
    if (value is Map) {
      return <String, Object?>{
        for (final MapEntry<Object?, Object?> entry in value.entries)
          '${entry.key}': _copy(entry.value),
      };
    }
    if (value is List) {
      return value.map(_copy).toList();
    }
    return value;
  }
}
