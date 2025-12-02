import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> requestNotificationPermission() async {
  if (!Platform.isAndroid) return;

  try {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    if (androidInfo.version.sdkInt >= 33) {
      final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      final granted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      debugPrint("Notification Permission Granted: $granted");
    }
  } catch (e) {
    debugPrint("Permission Request Error: $e");
  }
}
