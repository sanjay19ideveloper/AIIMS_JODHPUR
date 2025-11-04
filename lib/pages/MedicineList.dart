// import 'dart:async';
// import 'dart:math';
// import 'package:aiims_heartcare/blocs/bloc_manager.dart';
// import 'package:aiims_heartcare/blocs/home_bloc.dart';
// import 'package:aiims_heartcare/data/api/api_service.dart';
// import 'package:aiims_heartcare/data/model/medicineModel.dart';
// import 'package:aiims_heartcare/data/model/medicineSaveStatusResponse.dart';
// import 'package:aiims_heartcare/service/NotificationsService.dart';
// import 'package:aiims_heartcare/utils/loading.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';

// class AddReminderScreen extends StatefulWidget {
//   const AddReminderScreen({super.key});

//   @override
//   State<AddReminderScreen> createState() => _AddReminderScreenState();
// }

// class _AddReminderScreenState extends State<AddReminderScreen> {
//   bool _isLoading = false;
//   MedicineResponse? medicineList;
//   MedicineSaveStatusResp? medicineSaveStatus;
//   final NotificationService _notificationService = NotificationService();
//   Timer? _timeCheckTimer;
//   final Random _random = Random();

//   @override
//   void initState() {
//     super.initState();
//     _notificationService.initialize();
//     _startTimeChecker();
//   }

//   @override
//   void dispose() {
//     _timeCheckTimer?.cancel();
//     super.dispose();
//   }

//   void _startTimeChecker() {
//     _timeCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
//       _checkForMedicationTimes();
//     });
//   }

//   String formatTime(TimeOfDay time) {
//     // Adds leading zero to single-digit minutes
//     final hour = time.hour.toString().padLeft(2, '0');
//     final minute = time.minute.toString().padLeft(2, '0');
//     return '$hour:$minute';
//   }

//   void _checkForMedicationTimes() {
//     if (medicineList?.medications == null) return;
//     final now = TimeOfDay.now();
//     // Format current time with leading zeros
//     final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
//     print('Checking time: $currentTime');
//     for (final medication in medicineList!.medications!) {
//       // Ensure medication time is properly formatted
//       final medTime = _formatTimeString(medication.time ?? '');
//       print('medication time $medTime');
//       print('current time  $currentTime');
//       if (medTime == currentTime) {
//         _showMedicationReminder(medication);
//       }
//     }
//   }

//   /// Helper function to standardize time strings to HH:mm format
//   String _formatTimeString(String time) {
//     try {
//       final parts = time.split(':');
//       if (parts.length != 2) return time; // return original if invalid format
//       final hour = parts[0].padLeft(2, '0');
//       final minute = parts[1].padLeft(2, '0');
//       return '$hour:$minute';
//     } catch (e) {
//       return time; // return original if parsing fails
//     }
//   }

//   void _showMedicationReminder(Medication medication) {
//     final medicine = medication.medicine;
//     _notificationService.showInstantNotification(
//       title: 'Time to take your medication',
//       body: '${medicine?.name ?? 'Medicine'} (${medicine?.dosage ?? ''})',
//     );
//   }

//   void _scheduleAllMedicationReminders() {
//     if (medicineList?.medications == null) return;
//     for (final medication in medicineList!.medications!) {
//       if (medication.time != null) {
//         _scheduleMedicationReminder(medication);
//       }
//     }
//   }

//   // Generate a unique notification ID based on medicine name and time
//   int _generateNotificationId(Medication medication) {
//     final medicine = medication.medicine;
//     final time = medication.time ?? '';
//     return (medicine?.name?.hashCode ?? 0) + time.hashCode;
//   }

//   void _scheduleMedicationReminder(Medication medication) {
//     final medicine = medication.medicine;
//     final notificationId = _generateNotificationId(medication);
//     _notificationService.scheduleMedicationReminder(
//       medicineName: medicine?.name ?? 'Unknown Medicine',
//       dosage: medicine?.dosage ?? '',
//       time: medication.time!,
//       notificationId: notificationId,
//       context: context,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocManager(
//       initState: (BuildContext context) {
//         fetchMedicineList();
//       },
//       child: BlocListener<HomeBloc, HomeState>(
//         listener: (context, state) {
//           if (state is MedicineState) {
//             handleMedicineResponse(state);
//           }
//           if (state is MedicineStatusSaveState) {
//             handleMedicineStatusResponse(state);
//           }
//         },
//         child: Scaffold(
//           backgroundColor: const Color(0xFF0D3B3F),
//           appBar: AppBar(
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back, color: Colors.white),
//               onPressed: () => Navigator.pop(context),
//             ),
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.access_alarm, color: Colors.white),
//                 onPressed: () {
//                   _notificationService.scheduleDailyReminder(
//                     time: TimeOfDay.now(),
//                     title: 'Scheduled Notification',
//                     body: 'This was scheduled by button click',
//                     context: context,
//                   );
//                 },
//               ),
//             ],
//             title: const Text(
//               'Medicine Reminder',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             centerTitle: true,
//           ),
//           body: ScreenWithLoader(
//             isLoading: _isLoading,
//             body: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [_buildHeader(), _buildMedicationsList()],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
//       decoration: BoxDecoration(
//         color: const Color(0xFF0D3B3F),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           RichText(
//             text: const TextSpan(
//               children: [
//                 TextSpan(
//                   text: 'Medicine',
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 TextSpan(
//                   text: 'Reminder',
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.teal,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 5),
//           const Text(
//             'Track your medication schedule',
//             style: TextStyle(fontSize: 16, color: Colors.white70),
//           ),
//           const SizedBox(height: 20),
//           Row(
//             children: [
//               _buildStatusCard(
//                 'Pending',
//                 _getPendingCount(),
//                 Colors.orange,
//                 Icons.pending_actions,
//               ),
//               const SizedBox(width: 15),
//               _buildStatusCard(
//                 'Taken',
//                 _getTakenCount(),
//                 Colors.green,
//                 Icons.check_circle_outline,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusCard(String title, int count, Color color, IconData icon) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(15),
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(icon, color: color, size: 24),
//             ),
//             const SizedBox(width: 12),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   count.toString(),
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 Text(
//                   title,
//                   style: const TextStyle(fontSize: 14, color: Colors.white70),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMedicationsList() {
//     if (medicineList?.medications == null ||
//         medicineList!.medications!.isEmpty) {
//       return Container(
//         height: 300,
//         alignment: Alignment.center,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.medication_outlined,
//               size: 70,
//               color: Colors.white.withOpacity(0.5),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'No medications found',
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.white70,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//     return Padding(
//       padding: const EdgeInsets.all(20.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'YOUR MEDICATIONS',
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color: Colors.white70,
//               letterSpacing: 1,
//             ),
//           ),
//           const SizedBox(height: 15),
//           ListView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: medicineList!.medications!.length,
//             itemBuilder: (context, index) {
//               final medication = medicineList!.medications![index];
//               return _buildMedicineCard(medication);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMedicineCard(Medication medication ) {
//     final medicine = medication.medicine;
//     final isTaken = medication.status ?? false;
//     final interval = medication.interval ?? 'No interval set';
//     final timing = medication.medicationTiming ?? 'No timing specified';
//     final notes = medication.notes ?? '';
//     final startDate = _formatDate(medication.startedAt);
//     final endDate = _formatDate(medication.endedAt);
//     final time = medication.time ?? 'Not set';

//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: isTaken
//                 ? [Colors.white, Colors.green.withOpacity(0.1)]
//                 : [Colors.white, Colors.blue.withOpacity(0.1)],
//           ),
//         ),
//         child: Column(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: isTaken ? Colors.green.withOpacity(0.1) : Colors.teal.withOpacity(0.1),
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(16),
//                   topRight: Radius.circular(16),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                             color: isTaken ? Colors.green.withOpacity(0.2) : Colors.teal.withOpacity(0.2),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Icon(
//                             Icons.medication,
//                             color: isTaken ? Colors.green : Colors.teal,
//                             size: 24,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 medicine?.name ?? 'Unknown Medicine',
//                                 style: const TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(0xFF0D3B3F),
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 medicine?.dosage ?? 'No dosage specified',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 6,
//                     ),
//                     decoration: BoxDecoration(
//                       color: isTaken ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       isTaken ? 'TAKEN' : 'PENDING',
//                       style: TextStyle(
//                         color: isTaken ? Colors.green : Colors.orange,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   _buildInfoRow(Icons.access_time, time, Colors.blue),
//                   const SizedBox(height: 12),
//                   _buildInfoRow(Icons.repeat, 'Every $interval', Colors.purple),
//                   const SizedBox(height: 12),
//                   _buildInfoRow(Icons.restaurant, timing, Colors.orange),
//                   const SizedBox(height: 12),
//                   _buildInfoRow(
//                     Icons.calendar_today,
//                     '$startDate to $endDate',
//                     Colors.teal,
//                   ),
//                   if (notes.isNotEmpty) ...[
//                     const SizedBox(height: 12),
//                     _buildInfoRow(Icons.note, notes, Colors.grey),
//                   ],
//                   const SizedBox(height: 16),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       if (!isTaken && time != 'Not set')
//                         InkWell(
//                           onTap: () {
//                             _scheduleMedicationReminder(medication);
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(content: Text('Reminder set for $time')),
//                             );
//                           },
//                           borderRadius: BorderRadius.circular(30),
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 8,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.blue.withOpacity(0.2),
//                               borderRadius: BorderRadius.circular(30),
//                             ),
//                             child: const Row(
//                               children: [
//                                 Icon(
//                                   Icons.notifications_active,
//                                   color: Colors.blue,
//                                   size: 20,
//                                 ),
//                                 SizedBox(width: 8),
//                                 Text(
//                                   'Set Reminder',
//                                   style: TextStyle(
//                                     color: Colors.blue,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       InkWell(
//                         onTap: () {
//                           setState(() {
//                             medication.status = !isTaken; // Toggle the status
//                             final newStatus = medication.status == true ? 'taken' : 'missed'; // Determine the status string
//                             final medicineId = medication.id; // Get the medicine ID

//                             if (medication.status == true) {
//                               _notificationService.cancelNotification(_generateNotificationId(medication));
//                             }

//                             // Call the saveMedicineStatus function
//                             if (medication.status == true) {
//                               saveMedicineStatus(medicineId: medicineId, status: newStatus);
//                             }
//                           });
//                         },
//                         borderRadius: BorderRadius.circular(30),
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 8,
//                           ),
//                           decoration: BoxDecoration(
//                             color: isTaken ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2),
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                           child: Row(
//                             children: [
//                               Icon(
//                                 isTaken ? Icons.undo : Icons.check_circle,
//                                 color: isTaken ? Colors.orange : Colors.green,
//                                 size: 20,
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 isTaken ? 'Undo' : 'Taken',
//                                 style: TextStyle(
//                                   color: isTaken ? Colors.orange : Colors.green,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String value, Color color) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(icon, color: color, size: 20),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Text(
//             value,
//             style: const TextStyle(fontSize: 14, color: Color(0xFF0D3B3F)),
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }

//   String _formatDate(String? dateString) {
//     if (dateString == null || dateString.isEmpty) return 'Not specified';
//     try {
//       DateTime? date = DateTime.tryParse(dateString);
//       if (date != null) return DateFormat('MMM dd, yyyy').format(date);
//       final parts = dateString.split('-');
//       if (parts.length == 3) {
//         final day = int.tryParse(parts[0]);
//         final month = int.tryParse(parts[1]);
//         final year = int.tryParse(parts[2]);
//         if (day != null && month != null && year != null) {
//           date = DateTime(year, month, day);
//           return DateFormat('MMM dd, yyyy').format(date);
//         }
//       }
//       return dateString;
//     } catch (e) {
//       return dateString;
//     }
//   }

//   int _getPendingCount() {
//     final medications = medicineList?.medications;
//     if (medications == null) return 0;
//     return medications.where((med) => med.status != true).length;
//   }

//   int _getTakenCount() {
//     final medications = medicineList?.medications;
//     if (medications == null) return 0;
//     return medications.where((med) => med.status == true).length;
//   }

//   void fetchMedicineList() {
//     BlocProvider.of<HomeBloc>(context).add(MedicineEvent());
//   }

//   void saveMedicineStatus({String? medicineId, String? status}) {
//     BlocProvider.of<HomeBloc>(context).add(MedicineStatusSaveEvent(medicineId: medicineId, status: status));
//   }

//   void handleMedicineResponse(MedicineState state) {
//     switch (state.apiState) {
//       case ApiStatus.LOADING:
//         setState(() => _isLoading = true);
//         break;
//       case ApiStatus.SUCCESS:
//         setState(() {
//           _isLoading = false;
//           medicineList = state.response;
//         });
//         _scheduleAllMedicationReminders();
//         break;
//       case ApiStatus.ERROR:
//         setState(() => _isLoading = false);
//         break;
//       case ApiStatus.INITIAL:
//         break;
//     }
//   }

//   void handleMedicineStatusResponse(MedicineStatusSaveState state) {
//     switch (state.apiState) {
//       case ApiStatus.LOADING:
//         setState(() => _isLoading = true);
//         break;
//       case ApiStatus.SUCCESS:
//         setState(() {
//           _isLoading = false;
//           medicineSaveStatus = state.response;
//         });
//         // Re-fetch or update the local list to reflect the status change from the server
//         fetchMedicineList(); 
//         break;
//       case ApiStatus.ERROR:
//         setState(() => _isLoading = false);
//         break;
//       case ApiStatus.INITIAL:
//         break;
//     }
//   }
// }
import 'dart:async';
import 'dart:math';
import 'package:aiims_heartcare/blocs/bloc_manager.dart';
import 'package:aiims_heartcare/blocs/home_bloc.dart';
import 'package:aiims_heartcare/data/api/api_service.dart';
import 'package:aiims_heartcare/data/model/medicineModel.dart';
import 'package:aiims_heartcare/data/model/medicineSaveStatusResponse.dart';
import 'package:aiims_heartcare/service/NotificationsService.dart';
import 'package:aiims_heartcare/utils/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AddReminderScreen extends StatefulWidget {
  const AddReminderScreen({super.key});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  bool _isLoading = false;
  MedicineResponse? medicineList;
  MedicineSaveStatusResp? medicineSaveStatus;
  final NotificationService _notificationService = NotificationService();
  Timer? _timeCheckTimer;
  String? takenStatus ;
  final Random _random = Random();

  // Map intervals to their corresponding times
  final Map<String, List<String>> _intervalTimes = {
    'od': ['08:00'], // Once daily at 8am
    'bd': ['08:00', '20:00'], // Twice daily at 8am and 8pm
    'tds': ['08:00', '14:00', '20:00'], // Three times daily at 8am, 2pm, 8pm
    'qid': ['08:00', '14:00', '15:00', '20:00'], // Four times daily at 8am, 2pm, 3pm, 8pm
    'sos': ['17:00'], // As needed at 5pm
    'hs': ['22:00'], // At bedtime at 10pm
  };

  @override
  void initState() {
    super.initState();
    _notificationService.initialize();
    _startTimeChecker();
  }

  @override
  void dispose() {
    _timeCheckTimer?.cancel();
    super.dispose();
  }

  void _startTimeChecker() {
    _timeCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkForMedicationTimes();
    });
  }

  String formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _checkForMedicationTimes() {
    if (medicineList?.medications == null) return;
    
    final now = TimeOfDay.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    print('Checking time: $currentTime');
    
    for (final medication in medicineList!.medications!) {
      if (medication.status == true) continue; // Skip if already taken
      
      final interval = medication.interval ?? '';
      if (interval.isEmpty) continue;
      
      // Get all times for this medication's interval
      final times = _getTimesForInterval(interval);
      
      // Check if current time matches any of the scheduled times
      if (times.contains(currentTime)) {
        _showMedicationReminder(medication);
      }
    }
  }

  List<String> _getTimesForInterval(String interval) {
    // Handle combined intervals like "BD, TDS" or "BD, QID"
    if (interval.contains(',')) {
      final intervals = interval.split(',').map((e) => e.trim()).toList();
      final allTimes = <String>[];
      
      for (final i in intervals) {
        if (_intervalTimes.containsKey(i)) {
          allTimes.addAll(_intervalTimes[i]!);
        }
      }
      
      // Remove duplicates and sort
      return allTimes.toSet().toList()..sort();
    }
    
    // Single interval
    return _intervalTimes[interval] ?? [];
  }

  void _showMedicationReminder(Medication medication) {
    final medicine = medication.medicine;
    _notificationService.showInstantNotification(
      title: 'Time to take your medication',
      body: '${medicine?.name ?? 'Medicine'} (${medicine?.dosage ?? ''}) - ${medication.interval}',
    );
  }

  void _scheduleAllMedicationReminders() {
    if (medicineList?.medications == null) return;
    
    for (final medication in medicineList!.medications!) {
      if (medication.status == true) continue; // Skip if already taken
      
      final interval = medication.interval ?? '';
      if (interval.isEmpty) continue;
      
      _scheduleMedicationRemindersForInterval(medication, interval);
    }
  }

  void _scheduleMedicationRemindersForInterval(Medication medication, String interval) {
    final times = _getTimesForInterval(interval);
    
    for (final time in times) {
      _scheduleSingleMedicationReminder(medication, time);
    }
  }

  void _scheduleSingleMedicationReminder(Medication medication, String time) {
    final medicine = medication.medicine;
    final notificationId = _generateNotificationId(medication, time);
    
    // Parse the time string (format: HH:mm)
    final parts = time.split(':');
    if (parts.length != 2) return;
    
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return;
    
    final scheduledTime = TimeOfDay(hour: hour, minute: minute);
    
    _notificationService.scheduleMedicationReminder(
      medicineName: medicine?.name ?? 'Unknown Medicine',
      dosage: medicine?.dosage ?? '',
      time: scheduledTime.toString(),
      notificationId: notificationId,
      context: context,
    );
  }

  int _generateNotificationId(Medication medication, String time) {
    final medicine = medication.medicine;
    return (medicine?.name?.hashCode ?? 0) + time.hashCode;
  }

  @override
  Widget build(BuildContext context) {
    return BlocManager(
      initState: (BuildContext context) {
        fetchMedicineList();
      },
      child: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is MedicineState) {
            handleMedicineResponse(state);
          }
          if (state is MedicineStatusSaveState) {
            handleMedicineStatusResponse(state);
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF0D3B3F),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.access_alarm, color: Colors.white),
                onPressed: () {
                  _notificationService.scheduleDailyReminder(
                    time: TimeOfDay.now(),
                    title: 'Scheduled Notification',
                    body: 'This was scheduled by button click',
                    context: context,
                  );
                },
              ),
            ],
            title: const Text(
              'Medicine Reminder',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            centerTitle: true,
          ),
          body: ScreenWithLoader(
            isLoading: _isLoading,
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_buildHeader(), _buildMedicationsList()],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
      decoration: BoxDecoration(
        color: const Color(0xFF0D3B3F),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Medicine',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: 'Reminder',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Track your medication schedule',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatusCard(
                'Pending',
                _getPendingCount(),
                Colors.orange,
                Icons.pending_actions,
              ),
              const SizedBox(width: 15),
              _buildStatusCard(
                'Taken',
                _getTakenCount(),
                Colors.green,
                Icons.check_circle_outline,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String title, int count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationsList() {
    if (medicineList?.medications == null ||
        medicineList!.medications!.isEmpty) {
      return Container(
        height: 300,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medication_outlined,
              size: 70,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            const Text(
              'No medications found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR MEDICATIONS',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 15),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: medicineList!.medications!.length,
            itemBuilder: (context, index) {
              final medication = medicineList!.medications![index];
              return _buildMedicineCard(medication);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineCard(Medication medication) {
    final medicine = medication.medicine;
    final isTaken = takenStatus == 'taken';
    final interval = medication.interval ?? 'No interval set';
    final timing = medication.medicationTiming ?? 'No timing specified';
    final notes = medication.notes ?? '';
    final startDate = _formatDate(medication.startedAt);
    final endDate = _formatDate(medication.endedAt);
    
    // Get times for this medication's interval
    final times = _getTimesForInterval(interval);
    final timeDisplay = times.isNotEmpty ? times.join(', ') : 'Not set';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isTaken
                ? [Colors.white, Colors.green.withOpacity(0.1)]
                : [Colors.white, Colors.blue.withOpacity(0.1)],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isTaken ? Colors.green.withOpacity(0.1) : Colors.teal.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isTaken ? Colors.green.withOpacity(0.2) : Colors.teal.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.medication,
                            color: isTaken ? Colors.green : Colors.teal,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                medicine?.name ?? 'Unknown Medicine',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D3B3F),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                medicine?.dosage ?? 'No dosage specified',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Container(
                  //   padding: const EdgeInsets.symmetric(
                  //     horizontal: 12,
                  //     vertical: 6,
                  //   ),
                  //   decoration: BoxDecoration(
                  //     color: isTaken ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                  //     borderRadius: BorderRadius.circular(20),
                  //   ),
                  //   child: Text(
                  //     isTaken ? 'TAKEN' : 'PENDING',
                  //     style: TextStyle(
                  //       color: isTaken ? Colors.green : Colors.orange,
                  //       fontWeight: FontWeight.bold,
                  //       fontSize: 12,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoRow(Icons.access_time, timeDisplay, Colors.blue),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.repeat, 'Interval: $interval', Colors.purple),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.restaurant, timing, Colors.orange),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.calendar_today,
                    '$startDate to $endDate',
                    Colors.teal,
                  ),
                  if (notes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.note, notes, Colors.grey),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // if (!isTaken && times.isNotEmpty)
                      //   InkWell(
                      //     onTap: () {
                      //       _scheduleMedicationRemindersForInterval(medication, interval);
                      //       ScaffoldMessenger.of(context).showSnackBar(
                      //         SnackBar(content: Text('Reminders set for $interval at $timeDisplay')),
                      //       );
                      //     },
                      //     borderRadius: BorderRadius.circular(30),
                      //     child: Container(
                      //       padding: const EdgeInsets.symmetric(
                      //         horizontal: 16,
                      //         vertical: 8,
                      //       ),
                      //       decoration: BoxDecoration(
                      //         color: Colors.blue.withOpacity(0.2),
                      //         borderRadius: BorderRadius.circular(30),
                      //       ),
                      //       child: const Row(
                      //         children: [
                      //           Icon(
                      //             Icons.notifications_active,
                      //             color: Colors.blue,
                      //             size: 20,
                      //           ),
                      //           SizedBox(width: 8),
                      //           Text(
                      //             'Set Reminders',
                      //             style: TextStyle(
                      //               color: Colors.blue,
                      //               fontWeight: FontWeight.bold,
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      InkWell(
                        onTap: () {
                          setState(() {
                          
                            final newStatus = 'taken';
                            final medicineId = medication.id;

                         
                              // Cancel all scheduled notifications for this medication
                              for (final time in times) {
                                _notificationService.cancelNotification(
                                  _generateNotificationId(medication, time));
                              }
                              saveMedicineStatus(medicineId: medicineId, status: newStatus);
                           
                          });
                        },
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              isTaken ?  Icon(
                             Icons.check_circle,
                                color: isTaken ? Colors.blue: Colors.green,
                                size: 20,
                              ) : 
                              Icon(
                             Icons.add,
                                color: isTaken ? Colors.blue: Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                              isTaken ? 'Medication already taken today' : 'Have you taken your medicine?',
                                style: TextStyle(
                                  color:isTaken ? Colors.blue : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Color(0xFF0D3B3F)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Not specified';
    try {
      DateTime? date = DateTime.tryParse(dateString);
      if (date != null) return DateFormat('MMM dd, yyyy').format(date);
      final parts = dateString.split('-');
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);
        if (day != null && month != null && year != null) {
          date = DateTime(year, month, day);
          return DateFormat('MMM dd, yyyy').format(date);
        }
      }
      return dateString;
    } catch (e) {
      return dateString;
    }
  }

  int _getPendingCount() {
    final medications = medicineList?.medications;
    if (medications == null) return 0;
    return medications.where((med) => med.status != true).length;
  }

  int _getTakenCount() {
    final medications = medicineList?.medications;
    if (medications == null) return 0;
    return medications.where((med) => med.status == true).length;
  }

  void fetchMedicineList() {
    BlocProvider.of<HomeBloc>(context).add(MedicineEvent());
  }

  void saveMedicineStatus({String? medicineId, String? status}) {
    BlocProvider.of<HomeBloc>(context).add(MedicineStatusSaveEvent(medicineId: medicineId, status: status));
  }

  void handleMedicineResponse(MedicineState state) {
    switch (state.apiState) {
      case ApiStatus.LOADING:
        setState(() => _isLoading = true);
        break;
      case ApiStatus.SUCCESS:
        setState(() {
          _isLoading = false;
          medicineList = state.response;
        });
        _scheduleAllMedicationReminders();
        break;
      case ApiStatus.ERROR:
        setState(() => _isLoading = false);
        break;
      case ApiStatus.INITIAL:
        break;
    }
  }

  void handleMedicineStatusResponse(MedicineStatusSaveState state) {
    switch (state.apiState) {
      case ApiStatus.LOADING:
        setState(() => _isLoading = true);
        break;
      case ApiStatus.SUCCESS:
        setState(() {
          _isLoading = false;
          medicineSaveStatus = state.response;
          takenStatus = state.response?.medicationLog?.status;
        });
        fetchMedicineList();
        break;
      case ApiStatus.ERROR:
        setState(() => _isLoading = false);
        break;
      case ApiStatus.INITIAL:
        break;
    }
  }
}
