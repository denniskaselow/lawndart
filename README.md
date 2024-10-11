# Lawndart

Lawndart uses Futures and Streams to provide an asynchronous interface to IndexedDB.

This library is designed for simple key-value usage, and is not designed
for complex transactional queries.

This library prefers simplicity and uniformity over expressiveness.

# Example
	  
```dart
var db = await Store.open('simple-run-through', 'test');

await db.open();
await db.nuke();
await db.save('world', 'hello');
await db.save('is fun', 'dart');

var value = await db.getByKey('hello');

document.querySelector('#text').text = value;
```
	  
See the example/ directory for more sample code.
	  
# Choosing the best storage option

This is now made easy for you. Simply create a new instance of Store:

```dart
var store = await Store.open('dbName', 'storeName');
```

# API

`Future Store.open()`
Opens the database and makes it available for reading and writing.

`Future nuke()`
Wipes the database clean. All records are deleted.

`Future save(value, key)`
Stores a value accessible by a key.

`Future getByKey(key)`
Retrieves a value, given a key.

`Stream keys()`
Returns all keys.

`Stream all()`
Returns all values.

`Stream getByKeys(keys)`
Returns all values, given keys.

`Future exists(key)`
Returns true if the key exists, or false.

`Future removeByKey(key)`
Removes the value for the key.

# Usage

Most methods return a Future, like `open` and `save`.
Methods that would return many things, like `all`, return a Stream.
	  
# Supported storage mechanisms

* Indexed DB - Great choice for modern browsers

You can consult [Can I Use?](http://caniuse.com) for a breakdown of browser
support for the various storage technologies.

# Original Author

* Seth Ladd (sethladd@gmail.com)

# License

```no-highlight
Copyright 2015 Google

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
