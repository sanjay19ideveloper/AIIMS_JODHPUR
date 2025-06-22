import 'dart:io';
import 'package:flutter/services.dart';
import 'package:timezone/timezone.dart' as tz;

class Utility {
  static Future<bool> checkNetwork() async {
    bool isConnected = false;
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isConnected = true;
      }
    } on SocketException catch (_) {
      isConnected = false;
    }
    return isConnected;
  }

  static void hideKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  static String getCurrentTimeInTimeZone(String location) {
    final timeZone = tz.getLocation('$location');
    return _formatOffset(
      timeZone.timeZone(DateTime.now().millisecondsSinceEpoch).offset,
    );
  }

  static String _formatOffset(int offset) {
    final hours = offset ~/ 3600000;
    final minutes = (offset % 3600000) ~/ 60000;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
}
