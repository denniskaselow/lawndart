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


/// A unified, asynchronous, easy-to-use library for offline-enabled
/// browser-based web apps. Kinda sorta a port of Lawnchair to Dart,
/// but with Futures and Streams.
///
/// Lawndart uses Futures to provide an asynchronous, yet consistent,
/// interface to local storage, indexed db, and websql. This library is designed
/// for simple key-value usage, and is not designed for complex transactional
/// queries. This library prefers simplicity and uniformity over expressiveness.
///
/// You can use this library to help deal with the wide array of client-side
/// storage options. You should be able to write your code against the Lawndart
/// interface and have it work across browsers that support at least one of the
/// following: local storage, indexed db, and websql.
///
/// # Example
///
///     var db = new IndexedDbStore('simple-run-through', 'test');
///     db.open()
///       .then((_) => db.nuke())
///       .then((_) => db.save("world", "hello"))
///       .then((_) => db.save("is fun", "dart"))
///       .then((_) => db.getByKey("hello"))
///       .then((value) => query('#text').text = value);
///
/// See the `example/` directory for more sample code.
library;

import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart';


part 'src/indexeddb_store.dart';

/// Represents a Store that can hold key/value pairs. No order
/// is guaranteed for either keys or values.
abstract class Store {
  // For subclasses
  Store._();

  /// Finds the best implementation. In order: IndexedDB, WebSQL, LocalStorage.
  static Future<Store> open(
    String dbName,
    String storeName,
  ) async {
    final Store store = IndexedDbStore._(dbName, storeName);

    await store._open();

    return store;
  }

  /// Opens and initializes the database.
  Future<void> _open();

  /// Returns all the keys as a stream. No order is guaranteed.
  Stream<String> keys();

  /// Stores an [obj] accessible by [key].
  /// The returned Future completes with the key when the objects
  /// is saved in the store.
  Future<String> save(String obj, String key);

  /// Returns a Future that completes with the value for a key,
  /// or null if the key does not exist.
  Future<String?> getByKey(String key);

  /// Returns a Stream of all values for the keys.
  /// If a particular key is not found,
  /// no value will be returned, not even null.
  Stream<String> getByKeys(Iterable<String> keys);

  /// Returns a Future that completes with true if the key exists, or false.
  Future<bool> exists(String key);

  /// Returns a Stream of all values in no particular order.
  Stream<String> all();

  /// Returns a Future that completes when the key's value is removed.
  Future<void> removeByKey(String key);

  /// Returns a Future that completes when all values and keys
  /// are removed.
  Future<void> nuke();
}
