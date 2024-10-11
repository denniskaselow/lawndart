import 'dart:js_interop';

import 'package:lawndart/lawndart.dart';
import 'package:web/web.dart';

Future<void> runThrough(Store store, String id) async {
  if (document.querySelector('#$id') case final HTMLParagraphElement elem?) {
    try {
      await store.nuke();
      await store.save(id, 'hello');
      await store.save('is fun', 'dart');
      await for (final value in store.all()) {
        elem.append('$value, '.toJS);
      }
      elem.append('all done'.toJS);
    // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      elem.text = e.toString();
    }
  }
}

void main() async {
  final store = await IndexedDbStore.open('test', 'test');
  await runThrough(store, 'indexeddb');
}
