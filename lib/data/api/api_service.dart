import 'package:aiims_heartcare/utils/curlLogger.dart';
import 'package:aiims_heartcare/utils/dioCache.dart';
import 'package:aiims_heartcare/utils/log.dart';
import 'package:dio/dio.dart';

import 'api_constants.dart';
import 'environment.dart';
import 'interceptors.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  ApiService._internal() {
    _dio = _createDio();
  }

  static const String USER_AGENT = "user-agent";
  static const _timeout = 600000;

  late Dio _dio;
  Dio get dio => _dio;

  Environment _env = _Prod();
  Environment get env => _env;

  Dio _createDio() {
    final options = BaseOptions(
      baseUrl: _env.baseUrl,
      connectTimeout: Duration(milliseconds: _timeout),
      receiveTimeout: Duration(milliseconds: _timeout),
    );

    final dio = Dio(options);

    // ✅ Add interceptors only once
    dio.interceptors.add(requestInterceptor(dio, _env));
    dio.interceptors.add(CustomCacheInterceptor());

    // ✅ This will print clean curl logs
    dio.interceptors.add(CurlLoggerDioInterceptor(printOnSuccess: true));

    return dio;
  }

  void setEnvironment(EnvironmentType type) {
    Log.v("Setting environment to $type");
    switch (type) {
      case EnvironmentType.DEV:
        _env = _Dev();
        break;
      default:
        _env = _Prod();
    }

    // 🔄 Recreate Dio when environment switches
    _dio = _createDio();
  }
}

class _Prod extends Environment {
  @override
  EnvironmentType get type => EnvironmentType.PROD;

  @override
  String get baseUrl => ApiConstants.BASE_URL;

  @override
  String get apiKey => "For api key";
}

class _Dev extends Environment {
  @override
  EnvironmentType get type => EnvironmentType.DEV;

  @override
  String get baseUrl => ApiConstants.BASE_URL;

  @override
  String get apiKey => "For api key";
}

enum ApiStatus { INITIAL, LOADING, SUCCESS, ERROR }
