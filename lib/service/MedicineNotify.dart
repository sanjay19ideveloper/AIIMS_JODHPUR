import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      // Initialize time zones
      tz.initializeTimeZones();

      // Android initialization settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings with explicit permission requests
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        requestCriticalPermission: false,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      // Initialize the plugin with a callback for notification taps
      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          debugPrint('Notification tapped: ${details.payload}');
        },
      );

      // Create notification channels for Android
      await _createNotificationChannels();

      // Request permissions explicitly for iOS
      if (Platform.isIOS) {
        await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
      }
    } catch (e) {
      debugPrint('Notification initialization error: $e');
    }
  }

  Future<void> _createNotificationChannels() async {
    try {
      // Channel for general reminders
      const AndroidNotificationChannel channel1 = AndroidNotificationChannel(
        'heartcare_notifications',
        'HeartCare Reminders',
        description: 'Channel for HeartCare reminder notifications',
        importance: Importance.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('alarm_sound'),
      );

      // Channel for medication reminders
      const AndroidNotificationChannel channel2 = AndroidNotificationChannel(
        'medication_reminders',
        'Medication Reminders',
        description: 'Channel for medication reminder notifications',
        importance: Importance.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('alarm_sound'),
      );

      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidPlugin?.createNotificationChannel(channel1);
      await androidPlugin?.createNotificationChannel(channel2);
    } catch (e) {
      debugPrint('Notification channel creation error: $e');
    }
  }

  Future<bool> _checkAndRequestPermissions(BuildContext? context) async {
    try {
      bool allPermissionsGranted = true;

      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          final androidPlugin = _notificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();
          final permissionGranted =
              await androidPlugin?.requestNotificationsPermission();
          if (permissionGranted != true) {
            allPermissionsGranted = false;
            if (context != null) {
              await _showPermissionDialog(
                context,
                'Notification Permission Required',
                'Please enable notifications in system settings to receive reminders.',
              );
            }
          }
        }
        // Request exact alarm permission for Android 12+
        if (androidInfo.version.sdkInt >= 31) {
          final alarmPermissionGranted =
              await _notificationsPlugin
                  .resolvePlatformSpecificImplementation<
                      AndroidFlutterLocalNotificationsPlugin>()
                  ?.requestExactAlarmsPermission();
          if (alarmPermissionGranted != true) {
            allPermissionsGranted = false;
            if (context != null) {
              await _showPermissionDialog(
                context,
                'Exact Alarm Permission Required',
                'Please allow exact alarms in system settings for scheduled reminders.',
              );
            }
          }
        }
      } else if (Platform.isIOS) {
        final iosPlugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        final iosPermissionGranted = await iosPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        if (iosPermissionGranted != true) {
          allPermissionsGranted = false;
          if (context != null) {
            await _showPermissionDialog(
              context,
              'Notification Permission Required',
              'Please enable notifications in system settings to receive reminders.',
            );
          }
        }
      }

      return allPermissionsGranted;
    } catch (e) {
      debugPrint('Permission check error: $e');
      return false; // Return false to indicate permission issues
    }
  }

  Future<void> _showPermissionDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          if (Platform.isAndroid || Platform.isIOS)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Optionally, use a package like `app_settings` to open settings
                // AppSettings.openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
        ],
      ),
    );
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
    BuildContext? context,
  }) async {
    try {
      final hasPermissions = await _checkAndRequestPermissions(context);
      if (!hasPermissions) return;

      await Future.delayed(const Duration(milliseconds: 500));

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'heartcare_notifications',
        'HeartCare Reminders',
        channelDescription: 'Channel for HeartCare notifications',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('alarm_sound'),
      );

      const DarwinNotificationDetails iosPlatformChannelSpecifics =
          DarwinNotificationDetails(
        sound: 'alarm_sound.mp3',
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iosPlatformChannelSpecifics,
      );

      await _notificationsPlugin.show(
        0,
        title,
        body,
        platformChannelSpecifics,
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  Future<void> scheduleDailyReminder({
    required TimeOfDay time,
    required String title,
    required String body,
    BuildContext? context,
  }) async {
    try {
      final hasPermissions = await _checkAndRequestPermissions(context);
      if (!hasPermissions) return;

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notificationsPlugin.zonedSchedule(
        5,
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'heartcare_notifications',
            'HeartCare Reminders',
            channelDescription: 'Channel for HeartCare reminder notifications',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            sound: RawResourceAndroidNotificationSound('alarm_sound'),
            timeoutAfter: 120000,
            ongoing: false,
          ),
          iOS: DarwinNotificationDetails(
            sound: 'alarm_sound.mp3',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  Future<void> scheduleMedicationReminder({
    required String medicineName,
    required String dosage,
    required String time,
    required int notificationId,
    BuildContext? context,
  }) async {
    try {
      final hasPermissions = await _checkAndRequestPermissions(context);
      if (!hasPermissions) return;

      final timeParts = time.split(':');
      if (timeParts.length != 2) {
        debugPrint('Invalid time format: $time');
        return;
      }

      final hour = int.tryParse(timeParts[0]);
      final minute = int.tryParse(timeParts[1]);

      if (hour == null || minute == null) {
        debugPrint('Invalid time values: $time');
        return;
      }

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final title = 'Time to take your medication';
      final body = '$medicineName ($dosage)';

      await _notificationsPlugin.zonedSchedule(
        notificationId,
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medication_reminders',
            'Medication Reminders',
            channelDescription: 'Channel for medication reminder notifications',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            sound: RawResourceAndroidNotificationSound('alarm_sound'),
            timeoutAfter: 120000,
            ongoing: false,
          ),
          iOS: DarwinNotificationDetails(
            sound: 'alarm_sound.mp3',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      debugPrint('Scheduled medication reminder for $scheduledDate');
    } catch (e) {
      debugPrint('Error scheduling medication reminder: $e');
    }
  }

  Future<void> cancelNotification(int notificationId) async {
    try {
      await _notificationsPlugin.cancel(notificationId);
      debugPrint('Cancelled notification with id: $notificationId');
    } catch (e) {
      debugPrint('Error cancelling notification $notificationId: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      debugPrint('Cancelled all notifications');
    } catch (e) {
      debugPrint('Error canceling notifications: $e');
    }
  }
}
