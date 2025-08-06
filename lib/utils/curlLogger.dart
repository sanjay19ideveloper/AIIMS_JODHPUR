import 'dart:convert';
import 'package:dio/dio.dart';

class CurlLoggerDioInterceptor extends Interceptor {
  final bool printOnSuccess;

  CurlLoggerDioInterceptor({this.printOnSuccess = true});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      final curl = _getCurlCommand(options);
      print('🌀 cURL (ready for Postman):\n$curl\n');
    } catch (e, stackTrace) {
      print('🌀 cURL Error: Failed to generate cURL command: $e\n$stackTrace');
    }
    handler.next(options);
  }

  String _getCurlCommand(RequestOptions options) {
    final method = options.method.toUpperCase();
    final url = options.uri.toString();

    List<String> components = ['curl'];

    // Method
    components.add('-X $method');

    // Headers
    if (options.headers.isNotEmpty) {
      options.headers.forEach((key, value) {
        if (key.toLowerCase() != 'content-length') { // Skip content-length header
          components.add('-H "$key: $value"');
        }
      });
    }

    // Data
    if (options.data != null) {
      String dataString = '';
      if (options.data is FormData) {
        final formData = options.data as FormData;
        final formDataMap = Map.fromEntries(formData.fields);
        dataString = formDataMap.entries
            .map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
            .join('&');
        components.add('--data-raw "$dataString"');
      } else if (options.data is Map) {
        dataString = jsonEncode(options.data);
        components.add('--data-raw \'$dataString\'');
      } else {
        dataString = options.data.toString();
        components.add('--data-raw "$dataString"');
      }
    }

    // URL (add at the end to ensure proper formatting)
    components.add('"$url"');

    return components.join(' ');
  }
}