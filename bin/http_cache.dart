import 'package:http_cache/src/http_chache.dart';
import 'package:http/http.dart' as http;

const url = 'https://jsonplaceholder.typicode.com/users';
void main(List<String> args) async {
  await HttpCache.init();

  final request = http.Request('GET', Uri.parse(url));

  // This will call the api
  final regularStart = DateTime.now();
  await HttpCache.cacheGet(request);
  final regularEnd = DateTime.now();
  //usually takes around 100ms
  print(
      'Regular call took: ${regularEnd.difference(regularStart).inMilliseconds} ms');

  // This will get the response from the cache
  final storeStart = DateTime.now();
  await HttpCache.cacheGet(request);
  final storeEnd = DateTime.now();
  //usually takes around 4ms
  print(
      'Store call took: ${storeEnd.difference(storeStart).inMilliseconds} ms');

  HttpCache.removeCache(url);
}
