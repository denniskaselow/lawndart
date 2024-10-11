// ignore_for_file: avoid_print

import 'dart:html';

import 'package:lawndart/lawndart.dart';

void main() async {
  await window.indexedDB?.deleteDatabase('temptestdb');
  final Store store = await Store.open('temptestdb', 'store1');
  print('opened 1');
  await Store.open('temptestdb', 'store2');
  print('opened 2');
  await store.all().toList();
  print('all done');
  querySelector('#text')?.text = 'all done';
}
