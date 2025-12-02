// ignore_for_file: unused_element

import 'package:aiims_heartcare/pages/NotificationService/GlobalServiceProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aiims_heartcare/blocs/bloc_manager.dart';
import 'package:aiims_heartcare/blocs/home_bloc.dart';
import 'package:aiims_heartcare/data/api/api_service.dart';
import 'package:aiims_heartcare/data/model/medicineModel.dart';
import 'package:aiims_heartcare/data/model/medicineSaveStatusResponse.dart';
import 'package:aiims_heartcare/utils/loading.dart';
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
  String? takenStatus;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Initialize the global reminder manager
    await MedicationReminderManager().initialize();
    print('✅ Reminder service initialized globally');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update context in the global manager
    MedicationReminderManager().updateContext(context);
  }

  @override
  void dispose() {
    // Don't dispose the global manager here
    super.dispose();
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
                children: [
                  _buildHeader(), 
                  _buildMedicationsList(),
                ],
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

Widget _buildDebugInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
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
    if (medicineList?.medications == null || medicineList!.medications!.isEmpty) {
      return Container(
        height: 200,
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchMedicineList,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: const Text('Refresh Medications'),
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
    final isTaken = medication.status == true;
    final interval = medication.interval ?? 'No interval set';
    final timing = medication.medicationTiming ?? 'No timing specified';
    final notes = medication.notes ?? '';
    final startDate = _formatDate(medication.startedAt);
    final endDate = _formatDate(medication.endedAt);
    
    final times = _getTimesForInterval(interval.toLowerCase());
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isTaken ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isTaken ? 'TAKEN' : 'PENDING',
                      style: TextStyle(
                        color: isTaken ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoRow(Icons.access_time, 'Times: $timeDisplay', Colors.blue),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.repeat, 'Interval: $interval', Colors.purple),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.restaurant, 'Timing: $timing', Colors.orange),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Duration: $startDate to $endDate',
                    Colors.teal,
                  ),
                  if (notes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.note, 'Notes: $notes', Colors.grey),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!isTaken && times.isNotEmpty)
                        InkWell(
                          onTap: () {
                            _scheduleMedicationReminder(medication);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Reminders set for $interval at $timeDisplay'),
                                backgroundColor: Colors.blue,
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.notifications_active,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Set Reminders',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      InkWell(
                        onTap: () {
                          _toggleMedicationStatus(medication);
                        },
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isTaken ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isTaken ? Icons.undo : Icons.check_circle,
                                color: isTaken ? Colors.orange : Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isTaken ? 'Mark as Pending' : 'Mark as Taken',
                                style: TextStyle(
                                  color: isTaken ? Colors.orange : Colors.green,
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

  List<String> _getTimesForInterval(String interval) {
    // Use the global reminder service
    return MedicationReminderManager().reminderService.getTimesForInterval(interval);
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

  void _toggleMedicationStatus(Medication medication) {
    final newStatus = medication.status == true ? 'pending' : 'taken';
    final medicineId = medication.id;

    if (medicineId != null) {
      saveMedicineStatus(medicineId: medicineId, status: newStatus);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(medication.status == true 
            ? 'Marked ${medication.medicine?.name} as pending' 
            : 'Marked ${medication.medicine?.name} as taken'),
          backgroundColor: medication.status == true ? Colors.orange : Colors.green,
        ),
      );
    }
  }

  void _scheduleMedicationReminder(Medication medication) {
    final interval = medication.interval?.toLowerCase().trim() ?? '';
    if (interval.isNotEmpty) {
      MedicationReminderManager().reminderService.scheduleMedicationRemindersForInterval(medication, interval);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reminders set for ${medication.medicine?.name}'),
          backgroundColor: Colors.blue,
        ),
      );
    }
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
        print('✅ Loaded ${medicineList?.medications?.length} medications');
        
        // Update the global service with the new medicine list
        MedicationReminderManager().reminderService.updateMedicineList(medicineList);
        
        break;
      case ApiStatus.ERROR:
        setState(() => _isLoading = false);
        print('❌ Error loading medications');
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
        print('✅ Medicine status updated: $takenStatus');
        fetchMedicineList(); 
        break;
      case ApiStatus.ERROR:
        setState(() => _isLoading = false);
        print('❌ Error updating medicine status');
        break;
      case ApiStatus.INITIAL:
        break;
    }
  }
}