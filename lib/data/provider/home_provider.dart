import 'dart:convert';
import 'dart:developer';
import 'package:aiims_heartcare/data/api/api_constants.dart';
import 'package:aiims_heartcare/data/api/api_response.dart';
import 'package:aiims_heartcare/data/api/api_service.dart';
import 'package:aiims_heartcare/data/model/request/AttemptSaveRequest.dart';
import 'package:aiims_heartcare/data/model/request/login_request.dart';
import 'package:aiims_heartcare/utils/user_sessions.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class HomeProvider {
  HomeProvider({@required this.api});

  ApiService? api;

  Map<String, dynamic> get defaultParams => {"key": api!.env.apiKey};

  Future<ApiResponse?> login({LoginRequest? request}) async {
    try {
      debugPrint('Login request body: ${json.encode(request!.toJson())}');

      final response = await api!.dio.post(
        ApiConstants.login,
        data: json.encode(request.toJson()),
        options: Options(
          method: 'POST',
          contentType: "application/json",
          responseType: ResponseType.json,
        ),
      );

      debugPrint('Login API response status: ${response.statusCode}');
      debugPrint('Login API response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data.containsKey('error') &&
            (response.data["error"] as List).isNotEmpty) {
          return ApiResponse.error(response.data);
        } else {
          return ApiResponse.success(response);
        }
      }
    } on DioError catch (dioError) {
      debugPrint('DioError occurred: ${dioError.message}');
      if (dioError.response != null) {
        debugPrint('DioError response data: ${dioError.response!.data}');
        debugPrint(
          'DioError response status: ${dioError.response!.statusCode}',
        );
      }
      return ApiResponse.error(
        dioError.response?.data ?? {'message': 'Unknown error'},
      );
    } catch (e, stackTrace) {
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      return ApiResponse.error({'message': 'Unexpected error occurred'});
    }
    return null;
  }

  Future<ApiResponse?> getSaveResponse({AttemptSaveRequest? request}) async {
    try {
      debugPrint('Login request body: ${json.encode(request!.toJson())}');

      final response = await api!.dio.post(
        ApiConstants.saveAttempt,
        data: json.encode(request.toJson()),
        options: Options(
          headers: {
            "Authorization": "Bearer ${UserSession.userToken}",
            // ApiConstants.API_KEY: ApiConstants.API_KEY_VALUE
          },
          method: 'POST',
          contentType: "application/json",
          responseType: ResponseType.json,
        ),
      );

      debugPrint('attempt save API response status: ${response.statusCode}');
      debugPrint('attempt save API response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data.containsKey('error') &&
            (response.data["error"] as List).isNotEmpty) {
          return ApiResponse.error(response.data);
        } else {
          return ApiResponse.success(response);
        }
      }
    } on DioError catch (dioError) {
      debugPrint('DioError occurred: ${dioError.message}');
      if (dioError.response != null) {
        debugPrint('DioError response data: ${dioError.response!.data}');
        debugPrint(
          'DioError response status: ${dioError.response!.statusCode}',
        );
      }
      return ApiResponse.error(
        dioError.response?.data ?? {'message': 'Unknown error'},
      );
    } catch (e, stackTrace) {
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      return ApiResponse.error({'message': 'Unexpected error occurred'});
    }
    return null;
  }

  Future<ApiResponse?> myLearning() async {
    try {
      final response = await api!.dio.get(
        ApiConstants.learning,

        options: Options(
          headers: {
            "Authorization": "Bearer ${UserSession.userToken}",
            // ApiConstants.API_KEY: ApiConstants.API_KEY_VALUE
          },
          method: 'GET',
          contentType: "application/json",
          responseType: ResponseType.json,
        ),
      );

      debugPrint('learning API response status: ${response.statusCode}');
      debugPrint('learning API response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(response);
      }
    } on DioError catch (dioError) {
      debugPrint('DioError occurred: ${dioError.message}');
      if (dioError.response != null) {
        debugPrint('DioError response data: ${dioError.response!.data}');
        debugPrint(
          'DioError response status: ${dioError.response!.statusCode}',
        );
      }
      return ApiResponse.error(
        dioError.response?.data ?? {'message': 'Unknown error'},
      );
    } catch (e, stackTrace) {
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      return ApiResponse.error({'message': 'Unexpected error occurred'});
    }
    return null;
  }

  Future<ApiResponse?> getLearningContent({required String slug}) async {
    try {
      // Ensure the base URL is correct
      const baseUrl = 'https://heartcare.prakashsolanki.tech/api/learning';
      // Build URL: if slug exists, append it to path
      // final url =
      //     (slug != null && slug.isNotEmpty) ? '$baseUrl/$slug' : baseUrl;

      // ignore: unnecessary_null_comparison
      final url = slug != null ? '$baseUrl/$slug' : baseUrl;

      final response = await api!.dio.get(
        url,
        options: Options(
          headers: {"Authorization": "Bearer ${UserSession.userToken}"},
          method: 'GET',
          contentType: "application/json",
          responseType: ResponseType.json,
        ),
      );

      debugPrint('Slug status: $slug');
      debugPrint('Final URL called: $url');
      debugPrint('Learning API response status: ${response.statusCode}');
      debugPrint('Learning API response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(response);
      }
    } on DioError catch (dioError) {
      debugPrint('DioError occurred: ${dioError.message}');
      if (dioError.response != null) {
        debugPrint('DioError response data: ${dioError.response!.data}');
        debugPrint(
          'DioError response status: ${dioError.response!.statusCode}',
        );
      }
      return ApiResponse.error(
        dioError.response?.data ?? {'message': 'Unknown error'},
      );
    } catch (e, stackTrace) {
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      return ApiResponse.error({'message': 'Unexpected error occurred'});
    }
    return null;
  }

  Future<ApiResponse?> myReminder() async {
    try {
      final response = await api!.dio.get(
        ApiConstants.dailyLog,

        options: Options(
          headers: {
            "Authorization": "Bearer ${UserSession.userToken}",
            // ApiConstants.API_KEY: ApiConstants.API_KEY_VALUE
          },
          method: 'GET',
          contentType: "application/json",
          responseType: ResponseType.json,
        ),
      );

      debugPrint('learning API response status: ${response.statusCode}');
      debugPrint('learning API response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(response);
      }
    } on DioError catch (dioError) {
      debugPrint('DioError occurred: ${dioError.message}');
      if (dioError.response != null) {
        debugPrint('DioError response data: ${dioError.response!.data}');
        debugPrint(
          'DioError response status: ${dioError.response!.statusCode}',
        );
      }
      return ApiResponse.error(
        dioError.response?.data ?? {'message': 'Unknown error'},
      );
    } catch (e, stackTrace) {
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      return ApiResponse.error({'message': 'Unexpected error occurred'});
    }
    return null;
  }

  Future<ApiResponse?> getAttemptList() async {
    try {
      final response = await api!.dio.get(
        ApiConstants.attempt,

        options: Options(
          headers: {
            "Authorization": "Bearer ${UserSession.userToken}",
            // ApiConstants.API_KEY: ApiConstants.API_KEY_VALUE
          },
          method: 'GET',
          contentType: "application/json",
          responseType: ResponseType.json,
        ),
      );

      debugPrint('attempt API response status: ${response.statusCode}');
      debugPrint('attempt API response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(response);
      }
    } on DioError catch (dioError) {
      debugPrint('DioError occurred: ${dioError.message}');
      if (dioError.response != null) {
        debugPrint('DioError response data: ${dioError.response!.data}');
        debugPrint(
          'DioError response status: ${dioError.response!.statusCode}',
        );
      }
      return ApiResponse.error(
        dioError.response?.data ?? {'message': 'Unknown error'},
      );
    } catch (e, stackTrace) {
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      return ApiResponse.error({'message': 'Unexpected error occurred'});
    }
    return null;
  }

  Future<ApiResponse?> getAttemptCreate() async {
    try {
      final response = await api!.dio.get(
        ApiConstants.createAttempt,

        options: Options(
          headers: {
            "Authorization": "Bearer ${UserSession.userToken}",
            // ApiConstants.API_KEY: ApiConstants.API_KEY_VALUE
          },
          method: 'GET',
          contentType: "application/json",
          responseType: ResponseType.json,
        ),
      );

      debugPrint('attempt API response status: ${response.statusCode}');
      debugPrint('attempt API response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(response);
      }
    } on DioError catch (dioError) {
      debugPrint('DioError occurred: ${dioError.message}');
      if (dioError.response != null) {
        debugPrint('DioError response data: ${dioError.response!.data}');
        debugPrint(
          'DioError response status: ${dioError.response!.statusCode}',
        );
      }
      return ApiResponse.error(
        dioError.response?.data ?? {'message': 'Unknown error'},
      );
    } catch (e, stackTrace) {
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      return ApiResponse.error({'message': 'Unexpected error occurred'});
    }
    return null;
  }

  Future<ApiResponse?> getQuestionList() async {
    try {
      final response = await api!.dio.get(
        ApiConstants.symptoms,

        options: Options(
          headers: {
            "Authorization": "Bearer ${UserSession.userToken}",
            // ApiConstants.API_KEY: ApiConstants.API_KEY_VALUE
          },
          method: 'GET',
          contentType: "application/json",
          responseType: ResponseType.json,
        ),
      );

      debugPrint('attempt API response status: ${response.statusCode}');
      debugPrint('attempt API response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(response);
      }
    } on DioError catch (dioError) {
      debugPrint('DioError occurred: ${dioError.message}');
      if (dioError.response != null) {
        debugPrint('DioError response data: ${dioError.response!.data}');
        debugPrint(
          'DioError response status: ${dioError.response!.statusCode}',
        );
      }
      return ApiResponse.error(
        dioError.response?.data ?? {'message': 'Unknown error'},
      );
    } catch (e, stackTrace) {
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      return ApiResponse.error({'message': 'Unexpected error occurred'});
    }
    return null;
  }

  Future<ApiResponse?> getLabReport() async {
    try {
      final response = await api!.dio.get(
        ApiConstants.labReport,

        options: Options(
          headers: {
            "Authorization": "Bearer ${UserSession.userToken}",
            // ApiConstants.API_KEY: ApiConstants.API_KEY_VALUE
          },
          method: 'GET',
          contentType: "application/json",
          responseType: ResponseType.json,
        ),
      );

      debugPrint('attempt API response status: ${response.statusCode}');
      debugPrint('attempt API response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(response);
      }
    } on DioError catch (dioError) {
      debugPrint('DioError occurred: ${dioError.message}');
      if (dioError.response != null) {
        debugPrint('DioError response data: ${dioError.response!.data}');
        debugPrint(
          'DioError response status: ${dioError.response!.statusCode}',
        );
      }
      return ApiResponse.error(
        dioError.response?.data ?? {'message': 'Unknown error'},
      );
    } catch (e, stackTrace) {
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      return ApiResponse.error({'message': 'Unexpected error occurred'});
    }
    return null;
  }

  Future<ApiResponse?> myProfile() async {
    try {
      final response = await api!.dio.get(
        ApiConstants.profile,

        options: Options(
          headers: {
            "Authorization": "Bearer ${UserSession.userToken}",
            // ApiConstants.API_KEY: ApiConstants.API_KEY_VALUE
          },
          method: 'GET',
          contentType: "application/json",
          responseType: ResponseType.json,
        ),
      );

      debugPrint('learning API response status: ${response.statusCode}');
      debugPrint('learning API response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(response);
      }
    } on DioError catch (dioError, stacktrace) {
      debugPrint('DioError occurred: ${dioError.message}');
      debugPrint('stackrace: ${stacktrace}');
      if (dioError.response != null) {
        debugPrint('DioError response data: ${dioError.response!.data}');
        debugPrint(
          'DioError response status: ${dioError.response!.statusCode}',
        );
      }
      return ApiResponse.error(
        dioError.response?.data ?? {'message': 'Unknown error'},
      );
    } catch (e, stackTrace) {
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      return ApiResponse.error({'message': 'Unexpected error occurred'});
    }
    return null;
  }

  Future<ApiResponse?> getMedicineList({int? medicineId}) async {
    try {
      final response = await api!.dio.get(
        ApiConstants.medicine,

        options: Options(
          headers: {
            "Authorization": "Bearer ${UserSession.userToken}",
            // ApiConstants.API_KEY: ApiConstants.API_KEY_VALUE
          },
          method: 'GET',
          contentType: "application/json",
          responseType: ResponseType.json,
        ),
      );

      debugPrint('learning API response status: ${response.statusCode}');
      debugPrint('learning API response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(response);
      }
    } on DioError catch (dioError) {
      debugPrint('DioError occurred: ${dioError.message}');
      if (dioError.response != null) {
        debugPrint('DioError response data: ${dioError.response!.data}');
        debugPrint(
          'DioError response status: ${dioError.response!.statusCode}',
        );
      }
      return ApiResponse.error(
        dioError.response?.data ?? {'message': 'Unknown error'},
      );
    } catch (e, stackTrace) {
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      return ApiResponse.error({'message': 'Unexpected error occurred'});
    }
    return null;
  }
  

   Future<ApiResponse?> saveMedicineStatus({String? medicineId, String? status}) async {
    try {
      final response = await api!.dio.post(
        ApiConstants.medicationStatusSave,
        data: {
          "medication_id": medicineId,
          "status": status,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer ${UserSession.userToken}",
            // ApiConstants.API_KEY: ApiConstants.API_KEY_VALUE
          },
          method: 'POST',
          contentType: "application/json",
          responseType: ResponseType.json,
        ),
      );

      debugPrint('learning API response status: ${response.statusCode}');
      debugPrint('learning API response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(response);
      }
    } on DioError catch (dioError) {
      debugPrint('DioError occurred: ${dioError.message}');
      if (dioError.response != null) {
        debugPrint('DioError response data: ${dioError.response!.data}');
        debugPrint(
          'DioError response status: ${dioError.response!.statusCode}',
        );
      }
      return ApiResponse.error(
        dioError.response?.data ?? {'message': 'Unknown error'},
      );
    } catch (e, stackTrace) {
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      return ApiResponse.error({'message': 'Unexpected error occurred'});
    }
    return null;
  }

  Future<ApiResponse?> weightSave({String? weight}) async {
    try {
      // Validate input
      if (weight == null || weight.isEmpty) {
        debugPrint('Error: Weight is null or empty');
        return ApiResponse.error({'message': 'Weight cannot be null or empty'});
      }

      // Build request data
      final Map<String, dynamic> requestData = {"weight": weight};
      debugPrint('Request weight is ${requestData['weight']}');

      // Make POST request with the full requestData map
      final response = await ApiService().dio.post(
        ApiConstants.weight,
        data: requestData, // Pass the full map to send {"weight": "57"}
        options: Options(
          headers: {"Authorization": "Bearer ${UserSession.userToken}"},
          contentType: "application/json",
          responseType: ResponseType.json,
        ),
      );

      debugPrint('Weight POST response status: ${response.statusCode}');
      debugPrint('Weight POST response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(response);
      } else {
        debugPrint('Unexpected status code: ${response.statusCode}');
        return ApiResponse.error(
          response.data ?? {'message': 'Unexpected response'},
        );
      }
    } on DioError catch (dioError) {
      debugPrint('DioError occurred: ${dioError.message}');
      if (dioError.response != null) {
        debugPrint('DioError response data: ${dioError.response!.data}');
        debugPrint(
          'DioError response status: ${dioError.response!.statusCode}',
        );
        return ApiResponse.error(
          dioError.response!.data ?? {'message': 'Unknown error'},
        );
      }
      return ApiResponse.error({'message': 'Network error occurred'});
    } catch (e, stackTrace) {
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      return ApiResponse.error({'message': 'Unexpected error occurred'});
    }
  }


  // Future<ApiResponse?> getZoneSave({String? zone}) async {
  //   try {
  //     // Validate input
  //     if (zone == null || zone.isEmpty) {
  //       debugPrint('Error: Weight is null or empty');
  //       return ApiResponse.error({'message': 'Weight cannot be null or empty'});
  //     }

  //     // Build request data
  //     final Map<String, dynamic> requestData = {"zone": zone};
  //     debugPrint('Request zone is ${requestData['zone']}');

  //     // Make POST request with the full requestData map
  //     final response = await ApiService().dio.post(
  //       ApiConstants.zoneSave,
  //       data: requestData, // Pass the full map to send {"weight": "57"}
  //       options: Options(
  //         headers: {"Authorization": "Bearer ${UserSession.userToken}"},
  //         contentType: "application/json",
  //         responseType: ResponseType.json,
  //       ),
  //     );

  //     debugPrint('zone POST response status: ${response.statusCode}');
  //     debugPrint('zone POST response data: ${response.data}');

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       return ApiResponse.success(response);
  //     } else {
  //       debugPrint('Unexpected status code: ${response.statusCode}');
  //       return ApiResponse.error(
  //         response.data ?? {'message': 'Unexpected response'},
  //       );
  //     }
  //   } on DioError catch (dioError) {
  //     debugPrint('DioError occurred: ${dioError.message}');
  //     if (dioError.response != null) {
  //       debugPrint('DioError response data: ${dioError.response!.data}');
  //       debugPrint(
  //         'DioError response status: ${dioError.response!.statusCode}',
  //       );
  //       return ApiResponse.error(
  //         dioError.response!.data ?? {'message': 'Unknown error'},
  //       );
  //     }
  //     return ApiResponse.error({'message': 'Network error occurred'});
  //   } catch (e, stackTrace) {
  //     debugPrint('Unexpected error: $e');
  //     debugPrint('Stack trace: $stackTrace');
  //     return ApiResponse.error({'message': 'Unexpected error occurred'});
  //   }
  // }

 Future<ApiResponse?> getZoneSave({String? zone}) async {
  try {
    FormData formData = FormData.fromMap({
      'zone': zone,
    });

    final startTime = DateTime.now().millisecondsSinceEpoch;

    final response = await ApiService().dio.post(
      ApiConstants.zoneSave,
      data: formData,
      options: Options(
        method: 'POST',
        headers: {
          "Authorization": "Bearer ${UserSession.userToken}",
        },
        responseType: ResponseType.json,
      ),
    );

    final endTime = DateTime.now().millisecondsSinceEpoch;
    final duration = endTime - startTime;
    log('LOG: duration: $duration ms and url is ${response.requestOptions.uri}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.data.containsKey('error') &&
          (response.data["error"] as List).isNotEmpty) {
        return ApiResponse.error(response.data);
      } else {
        return ApiResponse.success(response);
      }
    }
  } catch (e, stacktrace) {
    log('LOG: error occurred $e');
    log('LOG: stacktrace $stacktrace');
  }

  return null;
}

  Future<ApiResponse?> logSave({String? howMuch}) async {
    try {
      // Build request data only if weight is provided
      final Map<String, dynamic> requestData = {};
      if (howMuch != null && howMuch.isNotEmpty) {
        requestData['how_much'] = howMuch;
      }

      final response = await api!.dio.post(
        ApiConstants.dailyLog,
        data: requestData, // Pass raw JSON body here
        options: Options(
          headers: {"Authorization": "Bearer ${UserSession.userToken}"},
          contentType: "application/json",
          responseType: ResponseType.json,
        ),
      );

      debugPrint('Weight POST response status: ${response.statusCode}');
      debugPrint('Weight POST response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(response);
      }
    } on DioError catch (dioError) {
      debugPrint('DioError occurred: ${dioError.message}');
      if (dioError.response != null) {
        debugPrint('DioError response data: ${dioError.response!.data}');
        debugPrint(
          'DioError response status: ${dioError.response!.statusCode}',
        );
      }
      return ApiResponse.error(
        dioError.response?.data ?? {'message': 'Unknown error'},
      );
    } catch (e, stackTrace) {
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      return ApiResponse.error({'message': 'Unexpected error occurred'});
    }

    return null;
  }

  Future<ApiResponse?> getWeightList() async {
    try {
      final response = await api!.dio.get(
        ApiConstants.weight,

        options: Options(
          headers: {
            "Authorization": "Bearer ${UserSession.userToken}",
            // ApiConstants.API_KEY: ApiConstants.API_KEY_VALUE
          },
          method: 'GET',
          contentType: "application/json",
          responseType: ResponseType.json,
        ),
      );

      debugPrint('learning API response status: ${response.statusCode}');
      debugPrint('learning API response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(response);
      }
    } on DioError catch (dioError) {
      debugPrint('DioError occurred: ${dioError.message}');
      if (dioError.response != null) {
        debugPrint('DioError response data: ${dioError.response!.data}');
        debugPrint(
          'DioError response status: ${dioError.response!.statusCode}',
        );
      }
      return ApiResponse.error(
        dioError.response?.data ?? {'message': 'Unknown error'},
      );
    } catch (e, stackTrace) {
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      return ApiResponse.error({'message': 'Unexpected error occurred'});
    }
    return null;
  }
}
