import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:aiims_heartcare/local/preference.dart';
import 'package:aiims_heartcare/utils/utility.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class CustomCacheInterceptor extends Interceptor {
  static const String _cacheKeyPrefix = 'custom_cache_';

  @override
  Future onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Initialize Hive
      final directory = await getApplicationDocumentsDirectory();
      Hive.init(directory.path);
      await Hive.openBox('content');
      await Hive.openBox('analytics');
      await Hive.openBox('trainings');
      await Hive.openBox('theme');
    } catch (error) {
      log("Error initializing Hive: $error", name: "dio_cache");
    }

    bool isConnected = await Utility.checkNetwork();

    // Use cache for GET and POST requests when offline
    if (!isConnected) {
      if (options.method == 'GET' || options.method == 'POST') {
        String cacheKey = _generateCacheKey(options);
        dynamic cachedData = await _getFromCache(cacheKey);
        if (cachedData != null) {
          return handler.resolve(
            Response(
              requestOptions: options,
              data: cachedData,
              statusCode: 200,
            ),
          );
        }
      }
    }

    return handler.next(options);
  }

  @override
  Future onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    // Save response to cache for GET requests only
    if (response.requestOptions.method == 'GET') {
      String cacheKey = _generateCacheKey(response.requestOptions);
      await _saveToCache(cacheKey, response.data);
    }

    return handler.next(response);
  }

  String _generateCacheKey(RequestOptions options) {
    return '$_cacheKeyPrefix${options.uri.toString()}';
  }

  Future<dynamic> _getFromCache(String key) async {
    String? jsonData = Preference.getString(key);
    log("cache get $jsonData", name: "dio_cache");
    return jsonData != null ? json.decode(jsonData) : null;
  }

  Future<void> _saveToCache(String key, dynamic data) async {
    try {
      Preference.setString(key, json.encode(data));
      log("cache store success", name: "dio_cache");
    } catch (e) {
      log("cache store error $e", name: "dio_cache");
    }
  }

  @override
  Future onError(DioError err, ErrorInterceptorHandler handler) async {
    return handler.next(err);
  }
}
