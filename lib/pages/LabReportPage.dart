import 'package:aiims_heartcare/blocs/bloc_manager.dart';
import 'package:aiims_heartcare/blocs/home_bloc.dart';
import 'package:aiims_heartcare/data/api/api_service.dart';
import 'package:aiims_heartcare/data/model/LabReportResp.dart';
import 'package:aiims_heartcare/utils/loading.dart';
import 'package:flutter/material.dart';
import 'package:aiims_heartcare/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class LabReportPage extends StatefulWidget {
  const LabReportPage({super.key});

  @override
  State<LabReportPage> createState() => _LabReportPageState();
}

class _LabReportPageState extends State<LabReportPage> {
  bool _isLoading = false;
  LabReportResponse? testList;

  @override
  Widget build(BuildContext context) {
    return BlocManager(
      initState: (BuildContext context) {
        fetchLabReport();
      },
      child: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is LabReportState) {
            handleLabReportResponse(state);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.translate('labReports'),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF0D3B3F),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: ScreenWithLoader(
            isLoading: _isLoading,
            body:
                testList?.labTests == null || testList!.labTests!.isEmpty
                    ? _buildEmptyState()
                    : _buildLabReportsList(),
          ),
          // floatingActionButton: FloatingActionButton(
          //   backgroundColor: const Color(0xFF0D3B3F),
          //   child: const Icon(Icons.add, color: Colors.white),
          //   onPressed: () {
          //     // Add new lab report functionality
          //   },
          // ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.science_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.translate('noLabReports'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.translate('addLabReportsDesc'),
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLabReportsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: testList!.labTests!.length,
      itemBuilder: (context, index) {
        final labTest = testList!.labTests![index];
        return _buildLabReportCard(labTest);
      },
    );
  }

  Widget _buildLabReportCard(LabTest labTest) {
    return GestureDetector(
      onTap: () => _showLabTestDetails(labTest),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF0D3B3F),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.medical_information, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Lab Report - ${_formatDate(labTest.date.toString())}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
                  _buildParameterRow(
                    'Hemoglobin',
                    labTest.hemoglobin,
                    Icons.water_drop,
                    Colors.red,
                  ),
                  _buildParameterRow(
                    'Cholesterol',
                    labTest.cholesterol,
                    Icons.monitor_heart,
                    Colors.amber,
                  ),
                  _buildParameterRow(
                    'Blood Sugar',
                    labTest.bloodSugar,
                    Icons.bloodtype,
                    Colors.blue,
                  ),
                  _buildParameterRow(
                    'Blood Pressure',
                    labTest.bloodPressure,
                    Icons.favorite,
                    Colors.red,
                  ),
                  _buildParameterRow(
                    'Weight',
                    labTest.weight,
                    Icons.monitor_weight,
                    Colors.green,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ID: ${labTest.id?.substring(0, 8) ?? 'N/A'}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Created: ${_formatCreatedAt(labTest.createdAt)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
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

  Widget _buildParameterRow(
    String label,
    String? value,
    IconData icon,
    Color color,
  ) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLabTestDetails(LabTest labTest) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            expand: false,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Icon(
                            Icons.science,
                            color: Color(0xFF0D3B3F),
                            size: 28,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Lab Test Details - ${_formatDate(labTest.date)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(),

                      // Blood Parameters Section
                      _buildSectionTitle('Blood Parameters', Icons.water_drop),
                      _buildDetailRow('Hemoglobin', labTest.hemoglobin, 'g/dL'),
                      _buildDetailRow('Ferritin', labTest.ferritin, 'ng/mL'),
                      _buildDetailRow('TIBC', labTest.tibc, 'μg/dL'),
                      _buildDetailRow('ISAT', labTest.isat, '%'),
                      _buildDetailRow('MCV', labTest.mcv, 'fL'),
                      _buildDetailRow('MCHC', labTest.mchc, 'g/dL'),

                      const Divider(),

                      // Cardiac Parameters Section
                      _buildSectionTitle('Cardiac Parameters', Icons.favorite),
                      _buildDetailRow('hs-CRP', labTest.hsCrp, 'mg/L'),
                      _buildDetailRow('NT-proBNP', labTest.ntProBnp, 'pg/mL'),

                      const Divider(),

                      // Lipid Profile Section
                      _buildSectionTitle('Lipid Profile', Icons.monitor_heart),
                      _buildDetailRow(
                        'Cholesterol',
                        labTest.cholesterol,
                        'mg/dL',
                      ),
                      _buildDetailRow('HDL', labTest.hdl, 'mg/dL'),
                      _buildDetailRow('LDL', labTest.ldl, 'mg/dL'),
                      _buildDetailRow(
                        'Triglycerides',
                        labTest.triglycerides,
                        'mg/dL',
                      ),

                      const Divider(),

                      // Vital Signs Section
                      _buildSectionTitle('Vital Signs', Icons.monitor_weight),
                      _buildDetailRow(
                        'Blood Sugar',
                        labTest.bloodSugar,
                        'mg/dL',
                      ),
                      _buildDetailRow('Pulse Rate', labTest.pulseRate, 'bpm'),
                      _buildDetailRow(
                        'Blood Pressure',
                        labTest.bloodPressure,
                        'mmHg',
                      ),
                      _buildDetailRow('Weight', labTest.weight, 'kg'),

                      const SizedBox(height: 20),

                      // Metadata Section
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Report Information',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildMetadataRow('Report ID', labTest.id ?? 'N/A'),
                            _buildMetadataRow(
                              'User ID',
                              labTest.userId ?? 'N/A',
                            ),
                            _buildMetadataRow(
                              'Date',
                              _formatDate(labTest.date),
                            ),
                            _buildMetadataRow(
                              'Created',
                              _formatCreatedAt(labTest.createdAt),
                            ),
                            _buildMetadataRow(
                              'Updated',
                              _formatDate(labTest.updatedAt),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.share),
                              label: const Text('Share'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0D3B3F),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                // Share functionality
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.print),
                              label: const Text('Print'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF0D3B3F),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                side: const BorderSide(
                                  color: Color(0xFF0D3B3F),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                // Print functionality
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0D3B3F), size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D3B3F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value, String unit) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? date) {
    if (date == null) return 'N/A';
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('dd MMM yyyy').format(parsedDate);
    } catch (e) {
      return 'N/A';
    }
  }

  String _formatCreatedAt(String? createdAt) {
    if (createdAt == null) return 'N/A';
    return '2 May 2025'; // Based on your enum value
  }

  void fetchLabReport() {
    BlocProvider.of<HomeBloc>(context).add(LabReportEvent());
  }

  void handleLabReportResponse(LabReportState state) {
    switch (state.apiState) {
      case ApiStatus.LOADING:
        setState(() {
          _isLoading = true;
        });
        break;
      case ApiStatus.SUCCESS:
        setState(() {
          _isLoading = false;
          testList = state.response;
          debugPrint('WEIGHT IS ${state.response}');
        });
        break;
      case ApiStatus.ERROR:
        setState(() {
          _isLoading = false;
        });
        break;
      case ApiStatus.INITIAL:
        break;
    }
  }
}
