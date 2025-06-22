import 'dart:convert';
import 'package:dio/dio.dart';

class CurlLoggerDioInterceptor extends Interceptor {
  final bool printOnSuccess;

  CurlLoggerDioInterceptor({this.printOnSuccess = true});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      final curl = _getCurlCommand(options);
      print('🌀 cURL:\n$curl\n');
    } catch (e, stackTrace) {
      print('🌀 cURL Error: Failed to generate cURL command: $e\n$stackTrace');
    }
    handler.next(options);
  }

  String _getCurlCommand(RequestOptions options) {
    final method = options.method.toUpperCase();
    final url = options.uri.toString().replaceAll(
      '"',
      '\\"',
    ); // Escape quotes in URL

    List<String> components = ['curl -i'];

    // Method
    components.add('-X $method');

    // Headers
    if (options.headers.isNotEmpty) {
      options.headers.forEach((key, value) {
        final escapedValue = value.toString().replaceAll('"', '\\"');
        components.add('-H "$key: $escapedValue"');
      });
    }

    // Data
    if (options.data != null) {
      String dataString = '';
      if (options.data is FormData) {
        final formData = options.data as FormData;
        final formDataMap = Map.fromEntries(formData.fields);
        dataString = formDataMap.entries
            .map(
              (e) =>
                  '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}',
            )
            .join('&');
        components.add('-d "$dataString"');
      } else if (options.data is Map) {
        dataString = jsonEncode(options.data).replaceAll('"', '\\"');
        components.add('-d "$dataString"');
      } else {
        dataString = options.data.toString().replaceAll('"', '\\"');
        components.add('-d "$dataString"');
      }
    }

    // URL (add at the end to ensure proper formatting)
    components.add('"$url"');

    return components.join(' \\\n\t');
  }
}
