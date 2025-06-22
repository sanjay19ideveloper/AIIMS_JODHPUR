// // lib/pages/notification_test_page.dart
// import 'package:aiims_heartcare/service/NotificationsService.dart';
// import 'package:flutter/material.dart';


// class NotificationTestPage extends StatelessWidget {
//   const NotificationTestPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Test Notifications')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () => NotificationService().showInstantNotification(
//                 title: 'Test Notification',
//                 body: 'You clicked the button!',
//               ),
//               child: const Text('Show Notification Now'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () => NotificationService().scheduleDailyReminder(
//                 time: TimeOfDay.now(),
//                 title: 'Scheduled Notification',
//                 body: 'This was scheduled by button click',
//                 context: context,
//               ),
//               child: const Text('Schedule Notification'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }