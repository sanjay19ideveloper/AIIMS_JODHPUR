// import 'package:alarm/alarm.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class AlarmService {
//   static Future<void> initAlarm() async {
//     await Alarm.init();
//   }

//   static Future<void> setAlarm({
//     required int id,
//     required DateTime dateTime,
//     required String assetAudioPath,
//     bool loopAudio = true,
//     bool vibrate = true,
//     bool fadeDuration = true,
//     double? volumeMax,
//     bool enableNotificationOnKill = true,
//     bool warningNotificationOnKill = false,
//     bool androidFullScreenIntent = true,
//     VolumeSettings? volumeSettings,
//     required NotificationSettings notificationSettings,
//   }) async {
//     final alarmSettings = AlarmSettings(
//       id: id,
//       dateTime: dateTime,
//       assetAudioPath: assetAudioPath,
//       loopAudio: loopAudio,
//       vibrate: vibrate,
//       fadeDuration: fadeDuration,
//       volumeMax: volumeMax,
//       enableNotificationOnKill: enableNotificationOnKill,
//       warningNotificationOnKill: warningNotificationOnKill,
//       androidFullScreenIntent: androidFullScreenIntent,
//       volumeSettings: volumeSettings,
//       notificationSettings: notificationSettings,
//     );

//     await Alarm.set(alarmSettings: alarmSettings);
//   }

//   static Future<void> setAlarmWithDefaults({
//     required int id,
//     required DateTime dateTime,
//     String assetAudioPath = 'assets/alarm.mp3',
//     String notificationTitle = 'Alarm',
//     String notificationBody = 'Your alarm is ringing!',
//     String stopButtonText = 'Stop',
//   }) async {
//     final alarmSettings = AlarmSettings(
//       id: id,
//       dateTime: dateTime,
//       assetAudioPath: assetAudioPath,
//       loopAudio: true,
//       vibrate: true,
//       fadeDuration: true,
//       volumeMax: 0.8,
//       enableNotificationOnKill: true,
//       notificationSettings: NotificationSettings(
//         title: notificationTitle,
//         body: notificationBody,
//         stopButton: stopButtonText,
//       ),
//     );

//     await Alarm.set(alarmSettings: alarmSettings);
//   }

//   static Future<void> stopAlarm(int alarmId) async {
//     await Alarm.stop(alarmId);
//   }

//   static Future<bool> checkAlarm(int alarmId) async {
//     return await Alarm.isRinging(alarmId);
//   }

//   static Stream<AlarmSettings?> get alarmStream => Alarm.onAlarmStream();

//   static Future<void> showAlarmNotification({
//     required BuildContext context,
//     required String title,
//     required String message,
//   }) async {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('$title: $message'),
//         duration: const Duration(seconds: 5),
//       ),
//     );
//   }

//   static Future<List<AlarmSettings>> getAlarms() async {
//     return await Alarm.getAlarms();
//   }

//   static Future<void> stopAllAlarms() async {
//     final alarms = await getAlarms();
//     for (final alarm in alarms) {
//       await Alarm.stop(alarm.id);
//     }
//   }
// }
