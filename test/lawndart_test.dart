//Copyright 2014 Google
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

import 'dart:async';

import 'package:lawndart/lawndart.dart';
import 'package:test/test.dart';

typedef StoreGenerator = Future<Store> Function();

void run(StoreGenerator generator) {
  late Store store;

  group('with no values', () {
    setUp(() async {
      store = await generator();
      await store.nuke();
    });

    test('keys is empty', () async {
      final keys = await store.keys().toList();
      expect(keys, hasLength(0));
    });

    test('get by key return null', () async {
      final value = await store.getByKey('foo');
      expect(value, isNull);
    });

    test('get by keys return empty collection', () async {
      final list = await store.getByKeys(['foo']).toList();
      expect(list, hasLength(0));
    });

    test('save completes', () async {
      final value = await store.save('value', 'key');
      expect(value, equals('key'));
    });

    test('exists returns false', () async {
      final value = await store.exists('foo');
      expect(value, isFalse);
    });

    test('all is empty', () async {
      final future = store.all().toList();
      expect(future, completion(hasLength(0)));
    });

    test('remove by key completes', () async {
      final future = store.removeByKey('foo');
      expect(future, completes);
    });

    test('nuke completes', () async {
      final future = store.nuke();
      expect(future, completes);
    });
  });

  group('with a few values', () {
    setUp(() async {
      store = await generator();

      await store.nuke();
      await store.save('world', 'hello');
      await store.save('is fun', 'dart');
    });

    test('keys has them', () async {
      final Iterable<String> keys = await store.keys().toList();

      expect(keys, hasLength(2));
      expect(keys, contains('hello'));
      expect(keys, contains('dart'));
    });

    test('get by key', () async {
      final value = await store.getByKey('hello');

      expect(value, equals('world'));
    });

    test('get by keys', () async {
      final values = await store.getByKeys(['hello', 'dart']).toList();
      expect(values, hasLength(2));
      expect(values.contains('world'), true);
      expect(values.contains('is fun'), true);
    });

    test('exists is true', () async {
      final exists = await store.exists('hello');

      expect(exists, true);
    });

    test('all has everything', () async {
      final all = await store.all().toList();

      expect(all, hasLength(2));
      expect(all.contains('world'), true);
      expect(all.contains('is fun'), true);
    });

    test('remove by key', () async {
      final remaining =
          await store.removeByKey('hello').then((_) => store.all().toList());

      expect(remaining, hasLength(1));
      expect(remaining.contains('world'), false);
      expect(remaining.contains('is fun'), true);
    });
  });
}

void main() {
  group('indexed db store0', () {
    run(() async => IndexedDbStore.open('test-db', 'test-store0'));
  });
  group('indexed db store1', () {
    run(() async => IndexedDbStore.open('test-db', 'test-store1'));
  });
}
