import 'dart:typed_data';

import 'package:http/http.dart' as http;

Map<String, dynamic> responseMetaDataToJson(http.BaseResponse response) {
  return {
    'headers': response.headers,
    'isRedirect': response.isRedirect,
    'persistentConnection': response.persistentConnection,
    'reasonPhrase': response.reasonPhrase,
    'statusCode': response.statusCode,
  };
}

http.Response responseMetaDataFromJson(
    Uint8List body, http.Request request, Map<String, dynamic> metaJson) {
  return http.Response.bytes(
    body,
    metaJson['statusCode'],
    request: request,
    headers: metaJson['headers'],
    isRedirect: metaJson['isRedirect'],
    persistentConnection: metaJson['persistentConnection'],
    reasonPhrase: metaJson['reasonPhrase'],
  );
}
