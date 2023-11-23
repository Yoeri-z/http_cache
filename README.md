# A convienience package for caching http requests

http_cache is a small package that makes it a little bit easier to cache http requests. To use it you also need the http package.

Using it is very easy:

```dart
import 'package:http_cache/src/http_chache.dart';
import 'package:http/http.dart' as http;

//jsonplaceholder is an api that returns jsonplaceholders
const url = 'https://jsonplaceholder.typicode.com/users';

void main(List<String> args) async {
  // first we initialize the cache
  await HttpCache.init();
  
  //we define the httpRequest
  final request = http.Request('GET', Uri.parse(url));
  //cacheGet returns a http.Response so you cant treat it like a regular http request
  final response = await HttpCache.cacheGet(request);
  //for me this call takes around 100 ms

  //if it is called a second time in your app it will get the cached response instead
  await HttpCache.cacheGet(request);
  //for me this call finished in 4 ms

  //to remove cached data associated with a url call [removeCache]
  HttpCache.removeCache(url);
}
```

The package uses the [hive](https://pub.dev/packages/hive) package to store and retrieve data. 

