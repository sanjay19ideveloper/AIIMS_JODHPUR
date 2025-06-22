import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:android_intent_plus/android_intent.dart';

class SizeUtils {
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
}
// lib/utils/alarm_utils.dart



Future<void> requestExactAlarmPermission() async {
  if (Platform.isAndroid) {
    const platform = MethodChannel('exact_alarm_permission');
    try {
      final bool isGranted =
          await platform.invokeMethod('checkExactAlarmPermission');
      if (!isGranted) {
        const intent = AndroidIntent(
          action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
        );
        await intent.launch();
      }
    } on PlatformException catch (e) {
      print("Error requesting exact alarm permission: $e");
    }
  }
}
