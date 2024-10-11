//Copyright 2012 Google
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.

part of '../lawndart.dart';

/// Wraps the IndexedDB API and exposes it as a [Store].
/// IndexedDB is generally the preferred API if it is available.
class IndexedDbStore extends Store {
  IndexedDbStore._(this.dbName, this.storeName) : super._();
  static final _databases = <String, IDBDatabase>{};

  final String dbName;
  final String storeName;

  static Future<IndexedDbStore> open(String dbName, String storeName) async {
    final store = IndexedDbStore._(dbName, storeName);
    await store._open();
    return store;
  }

  Future<bool> _open() async {
    final existingDb = _databases[dbName];
    if (existingDb != null) {
      existingDb.close();
    }

    final indexedDB = window.indexedDB;
    final request = indexedDB.open(dbName);
    final completer = Completer<bool>();
    request.onsuccess = () {
      final db = request.result! as IDBDatabase;
      // print("Newly opened db $dbName has version ${db.version}
      // and stores ${db.objectStoreNames}");
      final objectStoreNames = db.objectStoreNames;
      if (!objectStoreNames.contains(storeName)) {
        db.close();
        // print('Attempting upgrading $storeName from ${db.version}');
        final upgradeRequest = indexedDB.open(dbName, db.version + 1);
        upgradeRequest
          ..onupgradeneeded = (() {
            // print('Upgrading db $dbName to ${db.version ?? 0 + 1}');
            (upgradeRequest.result! as IDBDatabase)
                .createObjectStore(storeName);
          }).toJS
          ..onsuccess = () {
            final upgradedDb = upgradeRequest.result! as IDBDatabase;
            _databases[dbName] = upgradedDb;
            completer.complete(true);
          }.toJS;
      } else {
        _databases[dbName] = db;
        completer.complete(true);
      }
    }.toJS;
    return completer.future;
  }

  IDBDatabase get _db => _databases[dbName]!;

  @override
  Future<void> removeByKey(String key) =>
      _runInTxn((store) => store.delete(key.toJS));

  @override
  Future<String> save(String obj, String key) =>
      _runInTxn<String>((store) => store.put(obj.toJS, key.toJS));

  @override
  Future<String?> getByKey(String key) =>
      _runInTxn<String?>((store) => store.get(key.toJS), 'readonly');

  @override
  Future<void> nuke() => _runInTxn((store) => store.clear());

  Future<T> _runInTxn<T>(
    IDBRequest Function(IDBObjectStore store) requestCommand, [
    String txnMode = 'readwrite',
  ]) async {
    final trans = _db.transaction(storeName.toJS, txnMode);
    final store = trans.objectStore(storeName);
    final request = requestCommand(store);
    final completer = Completer<T>();
    trans.oncomplete = () {
      completer.complete(request.result.dartify() as T);
    }.toJS;
    return completer.future;
  }

  Stream<String> _doGetAll(
    String Function(IDBCursorWithValue cursor) onCursor,
  ) {
    final trans = _db.transaction(storeName.toJS, 'readonly');
    final store = trans.objectStore(storeName);
    final request = store.openCursor();
    // ignore: close_sinks
    final controller = StreamController<String>();
    request.onsuccess = () {
      if (request.result case final IDBCursorWithValue cursor) {
        final key = onCursor(cursor);
        controller.add(key);
        cursor.continue_();
      } else {
        unawaited(controller.sink.close());
      }
    }.toJS;
    return controller.stream;
  }

  @override
  Stream<String> all() =>
      _doGetAll((cursor) => (cursor.value! as JSString).toDart);

  @override
  Stream<String> getByKeys(Iterable<String> keys) async* {
    for (final key in keys) {
      final v = await getByKey(key);
      if (v != null) {
        yield v;
      }
    }
  }

  @override
  Future<bool> exists(String key) async {
    final value = await getByKey(key);
    return value != null;
  }

  // works as long as nothing else writes non-String keys
  @override
  Stream<String> keys() =>
      _doGetAll((cursor) => (cursor.key! as JSString).toDart);
}
