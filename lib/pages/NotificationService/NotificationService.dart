// // ignore_for_file: avoid_print, unused_local_variable, unused_element

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:aiims_heartcare/data/model/medicineModel.dart';
// import 'package:aiims_heartcare/service/NotificationsService.dart';

// class MedicationReminderService {
//   final NotificationService _notificationService;
//   Timer? _timeCheckTimer;
//   final Set<String> _shownNotifications = {};
//   static final GlobalKey<NavigatorState> navigatorKey =
//       GlobalKey<NavigatorState>();

//   static const Map<String, List<String>> _productionTimes = {
//     'od': ['07:55'],
//     'bd': ['07:55', '19:55'],
//     'tds': ['07:55', '13:55', '8:55'],
//     'qid': ['07:55', '13:55', '17:55', '20:55'],
//     'sos': ['16:55'],
//     'hs': ['21:55'],
//   };

//   MedicineResponse? _medicineList;
//   BuildContext? _context;
//   bool _isInitialized = false;

//   MedicationReminderService() : _notificationService = NotificationService();

//   Future<void> initialize() async {
//     if (_isInitialized) return;

//     await _notificationService.initialize();

//     print('');
//     print('🔔 ========================================');
//     print('🔔 MedicationReminderService initialized');
//     print('📱 Mode: Production');
//     print('⏰ Current device time: ${getCurrentTime24()}');
//     print('');
//     print('📋 PRODUCTION TIMES:');
//     _productionTimes.forEach((key, value) {
//       print('   $key: $value');
//     });
//     print('🔔 ========================================');
//     print('');

//     _isInitialized = true;
//     _startTimeChecker();
//   }

//   /// Get current device time in 24-hour format
//   static String getCurrentTime24() {
//     final now = DateTime.now();
//     return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
//   }

//   void updateContext(BuildContext? context) {
//     if (context != null && context.mounted) {
//       _context = context;
//       print('📱 Context updated');
//     }
//   }

//   BuildContext? _getSafeContext() {
//     if (_context != null && _context!.mounted) {
//       return _context;
//     }
//     if (navigatorKey.currentContext != null) {
//       return navigatorKey.currentContext;
//     }

//     return null;
//   }

//   void updateMedicineList(MedicineResponse? medicineList) {
//     _medicineList = medicineList;
//     if (medicineList?.medications != null) {
//       print(
//         '📋 Updated medication list with ${medicineList!.medications!.length} medications',
//       );
//       scheduleAllMedicationReminders();
//     }
//   }

//   void _startTimeChecker() {
//     _timeCheckTimer?.cancel();

//     _timeCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
//       _checkForMedicationTimes();
//     });

//     Timer(const Duration(seconds: 5), () {
//       _checkForMedicationTimes();
//     });

//     print('⏰ Time checker started (checking every 30 seconds)');
//   }

//   void _checkForMedicationTimes() {
//     if (_medicineList?.medications == null ||
//         _medicineList!.medications!.isEmpty) {
//       print('❌ No medications loaded yet or empty medication list');
//       return;
//     }

//     final now = DateTime.now();
//     final currentTime24 =
//         '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
//     final currentTime12 = _convertTo12HourFormat(currentTime24);

//     print('');
//     print('🔔 ========================================');
//     print('🔔 Checking medication times');
//     print('⏰ Current time: $currentTime12 ($currentTime24 24hr)');
//     print('🔔 ========================================');

//     bool foundMatch = false;

//     for (final medication in _medicineList!.medications!) {
//       final medicineName = medication.medicine?.name ?? 'Unknown Medicine';
//       final interval = medication.interval?.toLowerCase().trim() ?? '';

//       if (interval.isEmpty) {
//         print('⏭️ Skipping $medicineName - no interval set');
//         continue;
//       }

//       final times = getTimesForInterval(interval);
//       if (times.isEmpty) {
//         print(
//           '⏭️ Skipping $medicineName - no times found for interval: $interval',
//         );
//         continue;
//       }

//       print('');
//       print('💊 Checking: $medicineName');
//       print('   Interval: $interval');
//       print('   Scheduled times: $times');

//       for (final scheduledTime in times) {
//         if (_isTimeMatch(currentTime24, scheduledTime)) {
//           final notificationKey =
//               '${medication.id}_$scheduledTime${now.day}${now.month}${now.year}';

//           if (!_shownNotifications.contains(notificationKey)) {
//             print('');
//             print('🎯 ✅✅✅ MATCH FOUND! ✅✅✅');
//             print('🎯 Medicine: $medicineName');
//             print(
//               '🎯 Scheduled: ${_convertTo12HourFormat(scheduledTime)} ($scheduledTime 24hr)',
//             );
//             print('🎯 Current: $currentTime12 ($currentTime24 24hr)');
//             print('🎯 Triggering notification...');

//             _triggerMedicationNotification(medication, scheduledTime);
//             _shownNotifications.add(notificationKey);
//             foundMatch = true;

//             _scheduleNotificationCleanup(notificationKey);
//           } else {
//             print(
//               '⏭️ Already shown today at ${_convertTo12HourFormat(scheduledTime)}',
//             );
//           }
//           break;
//         }
//       }
//     }

//     if (!foundMatch) {
//       print('');
//       print('❌ No matches for $currentTime12 ($currentTime24 24hr)');
//     }
//     print('');
//   }

//   bool _isTimeMatch(String currentTime24, String scheduledTime) {
//     try {
//       String formattedScheduledTime = scheduledTime;
//       if (!scheduledTime.contains(':') || scheduledTime.length < 5) {
//         final parts = scheduledTime.split(':');
//         if (parts.length == 2) {
//           final hour = parts[0].padLeft(2, '0');
//           final minute = parts[1].padLeft(2, '0');
//           formattedScheduledTime = '$hour:$minute';
//         }
//       }

//       final currentParts = currentTime24.split(':');
//       final scheduledParts = formattedScheduledTime.split(':');

//       if (currentParts.length != 2 || scheduledParts.length != 2) {
//         print('   ❌ Format error');
//         return false;
//       }

//       final currentHour = int.parse(currentParts[0]);
//       final currentMinute = int.parse(currentParts[1]);
//       final scheduledHour = int.parse(scheduledParts[0]);
//       final scheduledMinute = int.parse(scheduledParts[1]);

//       print(
//         '   ⏱️  Comparing: $currentHour:$currentMinute vs $scheduledHour:$scheduledMinute',
//       );

//       if (currentHour != scheduledHour) {
//         print('   ❌ Hour mismatch ($currentHour ≠ $scheduledHour)');
//         return false;
//       }

//       final minuteDiff = (currentMinute - scheduledMinute).abs();
//       final isMatch = minuteDiff <= 2;

//       if (isMatch) {
//         print('✅ MATCH! (minute diff: $minuteDiff ≤ 2)');
//       } else {
//         print('❌ Minute diff too large ($minuteDiff > 2)');
//       }

//       return isMatch;
//     } catch (e) {
//       print('❌ Error: $e');
//       return false;
//     }
//   }

//   void _triggerMedicationNotification(
//     Medication medication,
//     String scheduledTime,
//   ) {
//     final medicine = medication.medicine;
//     final medicineName = medicine?.name ?? 'Unknown Medicine';
//     final dosage = medicine?.dosage ?? '';
//     final interval = medication.interval ?? '';
//     final timing = medication.medicationTiming ?? '';
//     final isTaken = medication.status == true;

//     final displayTime = _convertTo12HourFormat(scheduledTime);

//     print('🔔 Triggering notification for $medicineName at $displayTime');

//     String body = '$medicineName';
//     if (dosage.isNotEmpty) body += ' ($dosage)';
//     body += ' at $displayTime';
//     if (timing.isNotEmpty) body += ' - $timing';
//     if (isTaken) body += ' ✓ Already Taken';

//     _notificationService.showInstantNotification(
//       title: '💊 Medication Reminder',
//       body: body,
//     );

//     print('✅ Notification sent!');

//     _showForegroundSnackbar(medicineName, displayTime, isTaken);

//     scheduleSingleMedicationReminder(medication, scheduledTime);
//   }

//   void _showForegroundSnackbar(
//     String medicineName,
//     String displayTime,
//     bool isTaken,
//   ) {
//     final context = _getSafeContext();
//     if (context != null && context.mounted) {
//       try {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 '💊 $medicineName at $displayTime ${isTaken ? "✓" : ""}',
//               ),
//               backgroundColor: isTaken ? Colors.orange : Colors.green,
//               duration: const Duration(seconds: 10),
//               action: SnackBarAction(
//                 label: 'OK',
//                 textColor: Colors.white,
//                 onPressed: () {
//                   ScaffoldMessenger.of(context).hideCurrentSnackBar();
//                 },
//               ),
//             ),
//           );
//         });
//         print('✅ Foreground snackbar shown');
//       } catch (e) {
//         print('⚠️ Could not show snackbar (app may be in background): $e');
//       }
//     } else {
//       print('📱 App is in background, notification only shown');
//     }
//   }

//   List<String> getTimesForInterval(String interval) {
//     final cleanInterval = interval.toLowerCase().trim();

//     print('   🕒 Getting times for "$cleanInterval"');

//     if (cleanInterval.contains(',')) {
//       final intervals = cleanInterval.split(',').map((e) => e.trim()).toList();
//       final allTimes = <String>[];

//       for (final i in intervals) {
//         if (_productionTimes.containsKey(i)) {
//           allTimes.addAll(_productionTimes[i]!);
//           print('   ✅ Found "$i": ${_productionTimes[i]}');
//         } else {
//           print('   ⚠️ Unknown interval: "$i"');
//         }
//       }

//       final uniqueTimes = allTimes.toSet().toList()..sort();
//       print('   📋 Combined result: $uniqueTimes');
//       return uniqueTimes;
//     }

//     if (_productionTimes.containsKey(cleanInterval)) {
//       final times = _productionTimes[cleanInterval]!;
//       print('   ✅ Times: $times');
//       return times;
//     } else {
//       print(
//         '   ⚠️ Interval not found. Available intervals: ${_productionTimes.keys.toList()}',
//       );
//       return [];
//     }
//   }

//   void scheduleAllMedicationReminders() {
//     if (_medicineList?.medications == null ||
//         _medicineList!.medications!.isEmpty) {
//       print('❌ No medications to schedule');
//       return;
//     }

//     print('');
//     print('📅 Scheduling all medication reminders...');

//     _shownNotifications.clear();

//     int count = 0;
//     for (final medication in _medicineList!.medications!) {
//       final interval = medication.interval?.toLowerCase().trim() ?? '';
//       if (interval.isNotEmpty) {
//         scheduleMedicationRemindersForInterval(medication, interval);
//         count++;
//       }
//     }

//     print('✅ Scheduled $count medications');
//     print('');
//   }

//   void scheduleMedicationRemindersForInterval(
//     Medication medication,
//     String interval,
//   ) {
//     final times = getTimesForInterval(interval);
//     for (final time in times) {
//       scheduleSingleMedicationReminder(medication, time);
//     }
//   }

//   void scheduleSingleMedicationReminder(Medication medication, String time) {
//     final medicineName = medication.medicine?.name ?? 'Unknown Medicine';
//     final notificationId = _generateNotificationId(medication, time);

//     _notificationService.scheduleMedicationReminder(
//       medicineName: medicineName,
//       dosage: medication.medicine?.dosage ?? '',
//       time: time,
//       notificationId: notificationId,
//       context: _getSafeContext(),
//     );
//   }

//   int _generateNotificationId(Medication medication, String time) {
//     final now = DateTime.now();
//     final dateString = '${now.day}${now.month}${now.year}';
//     final uniqueString = '${medication.id}_${time}_$dateString';
//     return uniqueString.hashCode.abs() % 100000;
//   }

//   String _convertTo12HourFormat(String time24) {
//     try {
//       String formattedTime = time24;
//       if (!time24.contains(':') || time24.length < 5) {
//         final parts = time24.split(':');
//         if (parts.length == 2) {
//           final hour = parts[0].padLeft(2, '0');
//           final minute = parts[1].padLeft(2, '0');
//           formattedTime = '$hour:$minute';
//         }
//       }

//       final parts = formattedTime.split(':');
//       if (parts.length == 2) {
//         int hour = int.parse(parts[0]);
//         int minute = int.parse(parts[1]);

//         String period = hour >= 12 ? 'PM' : 'AM';
//         if (hour > 12) hour -= 12;
//         if (hour == 0) hour = 12;

//         return '$hour:${minute.toString().padLeft(2, '0')} $period';
//       }
//     } catch (e) {
//       print('Error converting time "$time24": $e');
//     }
//     return time24;
//   }

//   void _clearAllScheduledNotifications() {
//     print('🗑️ Clearing all notifications');
//     _notificationService.cancelAllNotifications();
//     _shownNotifications.clear();
//   }

//   void _scheduleNotificationCleanup(String notificationKey) {
//     final now = DateTime.now();
//     final midnight = DateTime(now.year, now.month, now.day + 1, 0, 0, 0);
//     final durationUntilMidnight = midnight.difference(now);

//     if (durationUntilMidnight.inSeconds > 0) {
//       Future.delayed(durationUntilMidnight, () {
//         _shownNotifications.remove(notificationKey);
//         print('🔄 Cleared lock for $notificationKey');
//       });
//     }
//   }

//   void dispose() {
//     _timeCheckTimer?.cancel();
//     _shownNotifications.clear();
//     _isInitialized = false;
//     print('🔔 MedicationReminderService disposed');
//   }
// }
// ignore_for_file: avoid_print, unused_local_variable, unused_element

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:aiims_heartcare/data/model/medicineModel.dart';
import 'package:aiims_heartcare/service/NotificationsService.dart';

class MedicationReminderService {
  final NotificationService _notificationService;
  Timer? _timeCheckTimer;
  final Set<String> _shownNotifications = {};
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Default times for intervals (used as fallback)
  static const Map<String, List<String>> _defaultIntervalTimes = {
    'od': ['07:55'],
    'bd': ['07:55', '19:55'],
    'tds': ['07:55', '13:55', '20:55'],
    'qid': ['07:55', '13:55', '17:55', '20:55'],
    'sos': ['16:55'],
    'hs': ['21:55'],
  };

  MedicineResponse? _medicineList;
  BuildContext? _context;
  bool _isInitialized = false;
  List<Medication> _activeMedications = [];

  MedicationReminderService() : _notificationService = NotificationService();

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _notificationService.initialize();

    print('');
    print('🔔 ========================================');
    print('🔔 MedicationReminderService initialized');
    print('📱 Mode: Production with Dynamic Timing');
    print('⏰ Current device time: ${getCurrentTime24()}');
    print('');
    print('📋 DEFAULT INTERVAL TIMES (Fallback):');
    _defaultIntervalTimes.forEach((key, value) {
      print('   $key: $value');
    });
    print('🔔 ========================================');
    print('');

    _isInitialized = true;
    _startTimeChecker();
  }

  /// Get current device time in 24-hour format
  static String getCurrentTime24() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  void updateContext(BuildContext? context) {
    if (context != null && context.mounted) {
      _context = context;
      print('📱 Context updated');
    }
  }

  BuildContext? _getSafeContext() {
    if (_context != null && _context!.mounted) {
      return _context;
    }
    if (navigatorKey.currentContext != null) {
      return navigatorKey.currentContext;
    }
    return null;
  }

  void updateMedicineList(MedicineResponse? medicineList) {
    _medicineList = medicineList;
    _activeMedications.clear();
    
    if (medicineList?.medications != null) {
      // Filter active medications (not deleted and within date range)
      final now = DateTime.now();
      for (final medication in medicineList!.medications!) {
        if (_isMedicationActive(medication, now)) {
          _activeMedications.add(medication);
        }
      }
      
      print(
        '📋 Updated medication list with ${_activeMedications.length} active medications (from ${medicineList.medications!.length} total)',
      );
      scheduleAllMedicationReminders();
    }
  }

  bool _isMedicationActive(Medication medication, DateTime now) {
    // Check if medication is deleted
    if (medication.deletedAt != null && medication.deletedAt.toString().isNotEmpty) {
      return false;
    }
    
    // Check startedAt date
    if (medication.startedAt != null && medication.startedAt!.isNotEmpty) {
      try {
        final startedAt = DateTime.parse(medication.startedAt!);
        if (now.isBefore(startedAt)) {
          return false;
        }
      } catch (e) {
        print('⚠️ Error parsing startedAt: ${medication.startedAt}');
      }
    }
    
    // Check endedAt date
    if (medication.endedAt != null && medication.endedAt!.isNotEmpty) {
      try {
        final endedAt = DateTime.parse(medication.endedAt!);
        if (now.isAfter(endedAt.add(const Duration(days: 1)))) {
          return false;
        }
      } catch (e) {
        print('⚠️ Error parsing endedAt: ${medication.endedAt}');
      }
    }
    
    // Check week days
    if (medication.weekDays != null && medication.weekDays!.isNotEmpty) {
      final currentWeekDay = now.weekday;
      final weekDayNames = {
        1: 'Monday',
        2: 'Tuesday',
        3: 'Wednesday',
        4: 'Thursday',
        5: 'Friday',
        6: 'Saturday',
        7: 'Sunday'
      };
      
      final currentDayName = weekDayNames[currentWeekDay];
      if (!medication.weekDays!.contains(currentDayName)) {
        return false;
      }
    }
    
    return true;
  }

  void _startTimeChecker() {
    _timeCheckTimer?.cancel();

    _timeCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkForMedicationTimes();
    });

    Timer(const Duration(seconds: 5), () {
      _checkForMedicationTimes();
    });

    print('⏰ Time checker started (checking every 30 seconds)');
  }

  void _checkForMedicationTimes() {
    if (_activeMedications.isEmpty) {
      print('❌ No active medications loaded');
      return;
    }

    final now = DateTime.now();
    final currentTime24 =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final currentTime12 = _convertTo12HourFormat(currentTime24);

    print('');
    print('🔔 ========================================');
    print('🔔 Checking medication times');
    print('⏰ Current time: $currentTime12 ($currentTime24 24hr)');
    print('📊 Active medications: ${_activeMedications.length}');
    print('🔔 ========================================');

    bool foundMatch = false;

    for (final medication in _activeMedications) {
      final medicineName = medication.medicine?.name ?? 'Unknown Medicine';
      final interval = medication.interval?.toLowerCase().trim() ?? '';
      
      // Get times from dynamic timing or fallback to default
      final times = getTimesForInterval(interval);
      if (times.isEmpty) {
        print(
          '⏭️ Skipping $medicineName - no times found',
        );
        continue;
      }

      print('');
      print('💊 Checking: $medicineName');
      print('   Interval: $interval');
      print('   Timing: ${medication.timing?.map((t) => t.time).toList()}');
      print('   Scheduled times: $times');

      for (final scheduledTime in times) {
        if (_isTimeMatch(currentTime24, scheduledTime)) {
          final notificationKey =
              '${medication.id}_$scheduledTime${now.day}${now.month}${now.year}';

          if (!_shownNotifications.contains(notificationKey)) {
            print('');
            print('🎯 ✅✅✅ MATCH FOUND! ✅✅✅');
            print('🎯 Medicine: $medicineName');
            print(
              '🎯 Scheduled: ${_convertTo12HourFormat(scheduledTime)} ($scheduledTime 24hr)',
            );
            print('🎯 Current: $currentTime12 ($currentTime24 24hr)');
            print('🎯 Triggering notification...');

            _triggerMedicationNotification(medication, scheduledTime);
            _shownNotifications.add(notificationKey);
            foundMatch = true;

            _scheduleNotificationCleanup(notificationKey);
          } else {
            print(
              '⏭️ Already shown today at ${_convertTo12HourFormat(scheduledTime)}',
            );
          }
          break;
        }
      }
    }

    if (!foundMatch) {
      print('');
      print('❌ No matches for $currentTime12 ($currentTime24 24hr)');
    }
    print('');
  }

  List<String> getTimesForInterval(String interval) {
    final cleanInterval = interval.toLowerCase().trim();
    final times = <String>{};

    print('   🕒 Getting times for "$cleanInterval"');

    // Handle multiple intervals (e.g., "od,hs")
    if (cleanInterval.contains(',')) {
      final intervals = cleanInterval.split(',').map((e) => e.trim()).toList();
      for (final i in intervals) {
        if (_defaultIntervalTimes.containsKey(i)) {
          times.addAll(_defaultIntervalTimes[i]!);
          print('   ✅ Found "$i": ${_defaultIntervalTimes[i]}');
        } else {
          print('   ⚠️ Unknown interval: "$i"');
        }
      }
    } else if (_defaultIntervalTimes.containsKey(cleanInterval)) {
      times.addAll(_defaultIntervalTimes[cleanInterval]!);
      print('   ✅ Times: ${_defaultIntervalTimes[cleanInterval]}');
    } else {
      print(
        '   ⚠️ Interval not found. Available intervals: ${_defaultIntervalTimes.keys.toList()}',
      );
    }

    // Validate and format all times
    final validatedTimes = <String>[];
    for (final time in times) {
      final formattedTime = _validateAndFormatTime(time);
      if (formattedTime != null) {
        validatedTimes.add(formattedTime);
      }
    }
    
    validatedTimes.sort();
    return validatedTimes;
  }

  String? _validateAndFormatTime(String time) {
    try {
      // Remove any whitespace
      final cleanedTime = time.trim();
      
      // Check if it's already in HH:MM format
      if (RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(cleanedTime)) {
        final parts = cleanedTime.split(':');
        final hour = parts[0].padLeft(2, '0');
        final minute = parts[1].padLeft(2, '0');
        return '$hour:$minute';
      }
      
      // Try to parse various formats
      if (cleanedTime.contains(':')) {
        final parts = cleanedTime.split(':');
        if (parts.length >= 2) {
          int hour = int.tryParse(parts[0]) ?? 0;
          int minute = int.tryParse(parts[1]) ?? 0;
          
          // Handle 12-hour format with AM/PM
          if (cleanedTime.toLowerCase().contains('am') || cleanedTime.toLowerCase().contains('pm')) {
            final isPM = cleanedTime.toLowerCase().contains('pm');
            if (isPM && hour < 12) hour += 12;
            if (!isPM && hour == 12) hour = 0;
          }
          
          if (hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
            return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
          }
        }
      }
      
      print('⚠️ Invalid time format: "$time"');
      return null;
    } catch (e) {
      print('⚠️ Error parsing time "$time": $e');
      return null;
    }
  }

  bool _isTimeMatch(String currentTime24, String scheduledTime) {
    try {
      final formattedScheduledTime = _validateAndFormatTime(scheduledTime);
      if (formattedScheduledTime == null) {
        print('   ❌ Invalid scheduled time format: $scheduledTime');
        return false;
      }

      final currentParts = currentTime24.split(':');
      final scheduledParts = formattedScheduledTime.split(':');

      if (currentParts.length != 2 || scheduledParts.length != 2) {
        print('   ❌ Format error');
        return false;
      }

      final currentHour = int.parse(currentParts[0]);
      final currentMinute = int.parse(currentParts[1]);
      final scheduledHour = int.parse(scheduledParts[0]);
      final scheduledMinute = int.parse(scheduledParts[1]);

      print(
        '   ⏱️  Comparing: $currentHour:$currentMinute vs $scheduledHour:$scheduledMinute',
      );

      if (currentHour != scheduledHour) {
        print('   ❌ Hour mismatch ($currentHour ≠ $scheduledHour)');
        return false;
      }

      final minuteDiff = (currentMinute - scheduledMinute).abs();
      final isMatch = minuteDiff <= 2;

      if (isMatch) {
        print('✅ MATCH! (minute diff: $minuteDiff ≤ 2)');
      } else {
        print('❌ Minute diff too large ($minuteDiff > 2)');
      }

      return isMatch;
    } catch (e) {
      print('❌ Error comparing times: $e');
      return false;
    }
  }

  void _triggerMedicationNotification(
    Medication medication,
    String scheduledTime,
  ) {
    final medicine = medication.medicine;
    final medicineName = medicine?.name ?? 'Unknown Medicine';
    final dosage = medicine?.dosage ?? '';
    final interval = medication.interval ?? '';
    final timing = medication.medicationTiming ?? '';
    final isTaken = medication.status == true;

    final displayTime = _convertTo12HourFormat(scheduledTime);

    print('🔔 Triggering notification for $medicineName at $displayTime');

    String body = '$medicineName';
    if (dosage.isNotEmpty) body += ' ($dosage)';
    body += ' at $displayTime';
    if (timing.isNotEmpty) body += ' - $timing';
    if (isTaken) body += ' ✓ Already Taken';

    _notificationService.showInstantNotification(
      title: '💊 Medication Reminder',
      body: body,
    );

    print('✅ Notification sent!');

    _showForegroundSnackbar(medicineName, displayTime, isTaken);

    scheduleMedicationRemindersForInterval(medication, interval);
  }

  void _showForegroundSnackbar(
    String medicineName,
    String displayTime,
    bool isTaken,
  ) {
    final context = _getSafeContext();
    if (context != null && context.mounted) {
      try {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '💊 $medicineName at $displayTime ${isTaken ? "✓" : ""}',
              ),
              backgroundColor: isTaken ? Colors.orange : Colors.green,
              duration: const Duration(seconds: 10),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        });
        print('✅ Foreground snackbar shown');
      } catch (e) {
        print('⚠️ Could not show snackbar (app may be in background): $e');
      }
    } else {
      print('📱 App is in background, notification only shown');
    }
  }

  void scheduleAllMedicationReminders() {
    if (_activeMedications.isEmpty) {
      print('❌ No active medications to schedule');
      return;
    }

    print('');
    print('📅 Scheduling all medication reminders...');

    _shownNotifications.clear();

    int count = 0;
    for (final medication in _activeMedications) {
      final interval = medication.interval?.toLowerCase().trim() ?? '';
      if (interval.isNotEmpty) {
        scheduleMedicationRemindersForInterval(medication, interval);
        count++;
      }
    }

    print('✅ Scheduled $count medications');
    print('');
  }

  void scheduleMedicationRemindersForInterval(
    Medication medication,
    String interval,
  ) {
    final times = getTimesForInterval(interval);
    for (final time in times) {
      scheduleSingleMedicationReminder(medication, time);
    }
  }

  void scheduleSingleMedicationReminder(Medication medication, String time) {
    final medicineName = medication.medicine?.name ?? 'Unknown Medicine';
    final formattedTime = _validateAndFormatTime(time);
    
    if (formattedTime == null) {
      print('⚠️ Cannot schedule reminder for invalid time: $time');
      return;
    }
    
    final notificationId = _generateNotificationId(medication, formattedTime);

    _notificationService.scheduleMedicationReminder(
      medicineName: medicineName,
      dosage: medication.medicine?.dosage ?? '',
      time: formattedTime,
      notificationId: notificationId,
      context: _getSafeContext(),
    );
    
    print('   ✅ Scheduled $medicineName at ${_convertTo12HourFormat(formattedTime)}');
  }

  int _generateNotificationId(Medication medication, String time) {
    final now = DateTime.now();
    final dateString = '${now.day}${now.month}${now.year}';
    final uniqueString = '${medication.id}_${time}_$dateString';
    return uniqueString.hashCode.abs() % 100000;
  }

  String _convertTo12HourFormat(String time24) {
    try {
      final formattedTime = _validateAndFormatTime(time24);
      if (formattedTime == null) return time24;
      
      final parts = formattedTime.split(':');
      if (parts.length == 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);

        String period = hour >= 12 ? 'PM' : 'AM';
        if (hour > 12) hour -= 12;
        if (hour == 0) hour = 12;

        return '$hour:${minute.toString().padLeft(2, '0')} $period';
      }
    } catch (e) {
      print('Error converting time "$time24": $e');
    }
    return time24;
  }

  void clearAllScheduledNotifications() {
    print('🗑️ Clearing all notifications');
    _notificationService.cancelAllNotifications();
    _shownNotifications.clear();
  }

  void _scheduleNotificationCleanup(String notificationKey) {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1, 0, 0, 0);
    final durationUntilMidnight = midnight.difference(now);

    if (durationUntilMidnight.inSeconds > 0) {
      Future.delayed(durationUntilMidnight, () {
        _shownNotifications.remove(notificationKey);
        print('🔄 Cleared lock for $notificationKey');
      });
    }
  }

  // Public method to refresh active medications based on current time
  void refreshActiveMedications() {
    if (_medicineList?.medications != null) {
      _activeMedications.clear();
      final now = DateTime.now();
      
      for (final medication in _medicineList!.medications!) {
        if (_isMedicationActive(medication, now)) {
          _activeMedications.add(medication);
        }
      }
      
      print('🔄 Refreshed active medications: ${_activeMedications.length} active');
      scheduleAllMedicationReminders();
    }
  }

  // Getter for active medications (for debugging/testing)
  List<Medication> getActiveMedications() {
    return List.from(_activeMedications);
  }

  void dispose() {
    _timeCheckTimer?.cancel();
    _shownNotifications.clear();
    _activeMedications.clear();
    _isInitialized = false;
    print('🔔 MedicationReminderService disposed');
  }
}
