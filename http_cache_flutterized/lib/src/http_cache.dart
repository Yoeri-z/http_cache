import 'dart:typed_data';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http_cache_flutterized/src/response_converter.dart'
    as converter;

class HttpCache {
  late final Box<Uint8List> responseBox;
  late final Box<Map<String, dynamic>> metaDataBox;
  bool initialized = false;
  static final HttpCache _instance = HttpCache();

  ///Wrap this function around any request that returns a [http.Response] object
  ///to cache the response
  ///if the response is already cached, it will return the cached response instead.
  ///You can disable caching by setting the [cache] parameter to false,
  ///it will still store the url but not attempt to get it from the cache
  static Future<http.Response> cacheGet(http.Request request,
      {bool cache = true}) async {
    assert(_instance.initialized,
        'You must call HttpCache.init() before using HttpCache in any other way');

    if (request.method != 'GET') {
      print(
          'WARNING: you used a ${request.method} request, which may not return meaningful data depending on the API design. If it does, you can ignore this warning');
    }
    //get the string to access the hive box later
    final url = request.url.toString();
    //check if the url is already cached
    if (_instance.responseBox.containsKey(url) &&
        _instance.metaDataBox.containsKey(url) &&
        cache) {
      //get the cached responsebody
      final cachedResponseBody = _instance.responseBox.get(url);
      //get the cached response metadata
      final cachedResponse = converter.responseMetaDataFromJson(
          cachedResponseBody!, request, _instance.metaDataBox.get(url)!);
      //return the cached response
      return cachedResponse;
    }
    //if the url is not cached, make the request and cache the response
    final response = await request.send();

    final responseBytes = await response.stream.toBytes();
    //if the url is not cached, make the request and cache the response
    if (response.statusCode == 200) {
      _instance.responseBox.put(url, responseBytes);
      _instance.metaDataBox
          .put(url, converter.responseMetaDataToJson(response));
    }
    //send back the response
    return http.Response.bytes(
      responseBytes,
      response.statusCode,
      request: request,
      headers: response.headers,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
    );
  }

  ///remove a url from the cache, this will remove the response data from that url cache completely
  static Future<void> removeCache(String url) async {
    await _instance.responseBox.delete(url);
  }

  ///Call this function to initialize the cache, you must await this function before using any other HttpCache function
  static Future<void> init() async {
    Hive.initFlutter('./http_cache/');
    _instance.responseBox = await Hive.openBox('http_store');
    _instance.metaDataBox = await Hive.openBox('http_meta');
    _instance.initialized = true;
  }
}
