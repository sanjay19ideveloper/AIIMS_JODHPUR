// import 'package:aiims_heartcare/service/AlramService.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class AlarmScreen extends StatefulWidget {
//   @override
//   _AlarmScreenState createState() => _AlarmScreenState();
// }

// class _AlarmScreenState extends State<AlarmScreen> {
//   final int alarmId = 1;
//   DateTime? selectedTime;

//   @override
//   void initState() {
//     super.initState();
//     _setupAlarmListener();
//   }

//   void _setupAlarmListener() {
//     AlarmService.alarmStream.listen((alarmSettings) {
//       if (alarmSettings != null) {
//         AlarmService.showAlarmNotification(
//           context: context,
//           title: alarmSettings.notificationTitle,
//           message: alarmSettings.notificationBody,
//         );
//       }
//     });
//   }

//   Future<void> _pickTime() async {
//     final time = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//     if (time != null) {
//       final now = DateTime.now();
//       setState(() {
//         selectedTime = DateTime(
//           now.year,
//           now.month,
//           now.day,
//           time.hour,
//           time.minute,
//         );
//       });
//     }
//   }

//   Future<void> _setAlarm() async {
//     if (selectedTime == null) return;

//     await AlarmService.setAlarm(
//       dateTime: selectedTime!,
//       assetAudioPath: 'assets/alarm.mp3', // Make sure to add this file
//       notificationTitle: 'Alarm',
//       notificationBody: 'Your alarm is ringing!',
//       alarmId: alarmId,
//     );

//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text('Alarm set successfully!')));
//   }

//   Future<void> _stopAlarm() async {
//     await AlarmService.stopAlarm(alarmId);
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text('Alarm stopped')));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Alarm Demo')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: _pickTime,
//               child: Text(
//                 selectedTime == null
//                     ? 'Select Time'
//                     : 'Selected: ${DateFormat('hh:mm a').format(selectedTime!)}',
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _setAlarm,
//               child: const Text('Set Alarm'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _stopAlarm,
//               child: const Text('Stop Alarm'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
