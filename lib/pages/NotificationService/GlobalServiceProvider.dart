// // medication_reminder_manager.dart
// import 'package:aiims_heartcare/pages/NotificationService/NotificationService.dart';
// import 'package:flutter/material.dart';


// class MedicationReminderManager {
//   static final MedicationReminderManager _instance = MedicationReminderManager._internal();
//   factory MedicationReminderManager() => _instance;
//   MedicationReminderManager._internal();

//   MedicationReminderService? _reminderService;

//   MedicationReminderService get reminderService {
//     if (_reminderService == null) {
//       throw Exception('MedicationReminderService not initialized. Call initialize() first.');
//     }
//     return _reminderService!;
//   }

//   Future<void> initialize(BuildContext context) async {
//     if (_reminderService == null) {
//       _reminderService = MedicationReminderService();
//       await _reminderService!.initialize();
//       _reminderService!.updateContext(context);
//       print('✅ MedicationReminderManager initialized globally');
//     }
//   }

//   void updateContext(BuildContext context) {
//     _reminderService?.updateContext(context);
//   }

//   void dispose() {
//     _reminderService?.dispose();
//     _reminderService = null;
//     print('🔔 MedicationReminderManager disposed');
//   }
// }

// medication_reminder_manager.dart
import 'package:aiims_heartcare/pages/NotificationService/NotificationService.dart';
import 'package:flutter/material.dart';


class MedicationReminderManager {
  static final MedicationReminderManager _instance = MedicationReminderManager._internal();
  factory MedicationReminderManager() => _instance;
  MedicationReminderManager._internal();

  MedicationReminderService? _reminderService;

  MedicationReminderService get reminderService {
    if (_reminderService == null) {
      throw Exception('MedicationReminderService not initialized. Call initialize() first.');
    }
    return _reminderService!;
  }

  Future<void> initialize() async {
    if (_reminderService == null) {
      _reminderService = MedicationReminderService();
      await _reminderService!.initialize();
      print('✅ MedicationReminderManager initialized globally');
    }
  }

  void updateContext(BuildContext? context) {
    if (context != null && context.mounted) {
      _reminderService?.updateContext(context);
    }
  }

  void updateMedicineList(dynamic medicineList) {
    _reminderService?.updateMedicineList(medicineList);
  }

  void dispose() {
    _reminderService?.dispose();
    _reminderService = null;
    print('🔔 MedicationReminderManager disposed');
  }
}