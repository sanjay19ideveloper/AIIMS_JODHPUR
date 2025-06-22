import 'package:aiims_heartcare/utils/log.dart';
import 'package:dio/dio.dart';

class ApiResponse<T> {
  int? code;
  int? status;
  T? body;
  bool success = true;

  ApiResponse.success(Response<T> response) {
    code = response.statusCode ?? 0;
    body = response.data ?? "" as T?;
    success = true;
  }

  ApiResponse.failure(DioException e, {String? message = ""}) {
    code = e.response!.statusCode;
    success = false;
    // ignore: unnecessary_type_check
    if (e is DioException) {
      body = message as T?;
      Log.v("Error = ${e.response!.data}");
    }
    Log.v("Error ${e.toString()}");
  }

  ApiResponse.error(dynamic data) {
    Log.v("====> ${data}");
    status = data['status'];
    body = data['error'];
    success = false;
  }
}

