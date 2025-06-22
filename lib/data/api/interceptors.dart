import 'dart:developer';
import 'package:aiims_heartcare/utils/log.dart';
import 'package:aiims_heartcare/utils/utility.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'environment.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

InterceptorsWrapper requestInterceptor(Dio dio, Environment env) {
  dynamic startTime;
  return InterceptorsWrapper(
    onRequest: (RequestOptions options, handler) {
      final uri = options.uri.toString();
      Log.v("➡️ Api - URL: $uri");

      // Headers log
      Log.v("➡️ Api - Headers:");
      options.headers.forEach((key, value) {
        Log.v('  $key: $value');
      });

      // Timezone region
      try {
      } catch (e) {
        Log.v("Exception in timezone retrieval: $e");
      }

      // Append timezone to request
      if (options.data is FormData) {
        FormData formData = options.data;
        // formData.fields.add(MapEntry('created_timezone', region));
        options.data = formData;
        Log.v("➡️ Api - Request Body (FormData): ${formData.fields}");
      } else {
        Log.v("➡️ Api - Request Body: ${options.data}");
      }

      log('LOG: API CALL MADE');
      startTime = DateTime.now().millisecondsSinceEpoch;

      // ✅ Network check
      Utility.checkNetwork();

      handler.next(options);
    },
    onResponse: (Response response, handler) {
      Log.v("✅ Api - Response headers:");
      response.headers.forEach((k, v) {
        v.forEach((s) {
          Log.v("  $k: $s");
          if (k.toLowerCase() == 'date') {
            try {
              final dateString = s;
              final format = DateFormat("EEE, dd MMM yyyy HH:mm:ss");
              final dateTime = format.parseUtc(dateString);
              tz.initializeTimeZones();
              final indiaTimeZone = tz.getLocation('Asia/Kolkata');
              final indiaNow = tz.TZDateTime.fromMillisecondsSinceEpoch(
                indiaTimeZone,
                dateTime.millisecondsSinceEpoch,
              );
              final formattedIndianTime = DateFormat(
                'yyyy-MM-dd HH:mm:ss.SSS',
              ).format(indiaNow);
              Log.v("🇮🇳 Indian Time: $formattedIndianTime");
            } catch (e) {
              Log.v("Error parsing date header: $e");
            }
          }
        });
      });

      Log.v("✅ Api - Response Data: ${response.data}");

      final endTime = DateTime.now().millisecondsSinceEpoch;
      final duration = endTime - startTime;
      log('LOG: Response time: $duration ms');

      log(
        'LOG: API Response time: $duration ms (timeout: ${response.requestOptions.sendTimeout})',
      );

      return handler.next(response);
    },
    onError: (DioError e, handler) {
      Log.v("❌ Api - Error: ${e.message}");
      return handler.next(e);
    },
  );
}
