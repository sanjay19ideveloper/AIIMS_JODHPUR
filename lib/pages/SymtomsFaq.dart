import 'package:aiims_heartcare/data/api/api_service.dart';
import 'package:aiims_heartcare/data/model/ZoneSaveResp.dart';
import 'package:aiims_heartcare/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aiims_heartcare/blocs/bloc_manager.dart';
import 'package:aiims_heartcare/blocs/home_bloc.dart';
import 'package:aiims_heartcare/data/model/QuestionListResp.dart';
import 'package:aiims_heartcare/data/model/attemptModel.dart';
import 'package:aiims_heartcare/utils/loading.dart';
import 'package:intl/intl.dart';

class ZoneFAQScreen extends StatefulWidget {
  const ZoneFAQScreen({Key? key}) : super(key: key);

  @override
  State<ZoneFAQScreen> createState() => _ZoneFAQScreenState();
}

class _ZoneFAQScreenState extends State<ZoneFAQScreen> {
  String? selectedZone;
  bool _isLoading = false;
  QuestionListResponse? questionList;
  ZoneSaveResponse? zoneSaveResponse;
  List<Datum> attemptList = [];
  bool showAttempts = false;

  // Track expanded state for each accordion
  bool isGreenExpanded = true;
  bool isYellowExpanded = false;
  bool isRedExpanded = false;

  @override
  void initState() {
    super.initState();
    fetchQuestionList();
    fetchAttemptList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocManager(
      initState: (BuildContext context) {
        fetchQuestionList();
        fetchAttemptList();
      },
      child: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is QuestionState) {
            handleQuestionListResponse(state);
          }
          if (state is ZoneSaveState) {
            handleZoneSaveResponse(state);
          }
          if (state is AttemptState) {
            handleAttemptListResponse(state);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            backgroundColor: const Color(0xFF0D3B3F),
            title: Text(
              AppLocalizations.of(context)!.translate('symptomsTracker'),
              style: const TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: () {
                  setState(() {
                    showAttempts = !showAttempts;
                  });
                },
              ),
            ],
          ),
          body: _isLoading
              ? ScreenWithLoader(isLoading: true)
              : showAttempts
                  ? _buildAttemptList()
                  : _buildFAQContent(),
          floatingActionButton: showAttempts
              ? FloatingActionButton.extended(
                  onPressed: () {
                    setState(() {
                      showAttempts = false;
                    });
                  },
                  icon: const Icon(Icons.help_outline),
                  label: Text(AppLocalizations.of(context)!.translate('viewFAQs')),
              ): null,
        ),
      ),
    );
  }

  Widget _buildFAQContent() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (questionList?.questions?.green?.isNotEmpty ?? false)
                  _buildAccordion(
                    title: AppLocalizations.of(context)!.translate('greenZoneFAQ'),
                    isExpanded: isGreenExpanded,
                    onTap: () {
                      setState(() {
                        isGreenExpanded = !isGreenExpanded;
                        if (isGreenExpanded) {
                          isYellowExpanded = false;
                          isRedExpanded = false;
                        }
                      });
                    },
                    color: Colors.green,
                    questions: questionList?.questions?.green ?? [],
                  ),
                
                const SizedBox(height: 16),
                
                if (questionList?.questions?.yellow?.isNotEmpty ?? false)
                  _buildAccordion(
                    title: AppLocalizations.of(context)!.translate('yellowZoneFAQ'),
                    isExpanded: isYellowExpanded,
                    onTap: () {
                      setState(() {
                        isYellowExpanded = !isYellowExpanded;
                        if (isYellowExpanded) {
                          isGreenExpanded = false;
                          isRedExpanded = false;
                        }
                      });
                    },
                    color: Colors.amber,
                    questions: questionList?.questions?.yellow ?? [],
                  ),
                
                const SizedBox(height: 16),
                
                if (questionList?.questions?.red?.isNotEmpty ?? false)
                  _buildAccordion(
                    title: AppLocalizations.of(context)!.translate('redZoneFAQ'),
                    isExpanded: isRedExpanded,
                    onTap: () {
                      setState(() {
                        isRedExpanded = !isRedExpanded;
                        if (isRedExpanded) {
                          isGreenExpanded = false;
                          isYellowExpanded = false;
                        }
                      });
                    },
                    color: Colors.red,
                    questions: questionList?.questions?.red ?? [],
                  ),
              ],
            ),
          ),
        ),
        
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.translate('whichZoneQuestion'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D3B3F),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildZoneButton(
                    displayName: AppLocalizations.of(context)!.translate('greenZone'),
                    apiParam: 'green',
                    color: Colors.green,
                  ),
                  _buildZoneButton(
                    displayName: AppLocalizations.of(context)!.translate('yellowZone'),
                    apiParam: 'yellow',
                    color: Colors.amber,
                  ),
                  _buildZoneButton(
                    displayName: AppLocalizations.of(context)!.translate('redZone'),
                    apiParam: 'red',
                    color: Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttemptList() {
    if (attemptList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_outlined, size: 80, color: Colors.white70),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.translate('noAssessments'),
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.translate('completeAssessment'),
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: attemptList.length,
      itemBuilder: (context, index) {
        final attempt = attemptList[index];
        return _buildAttemptCard(attempt);
      },
    );
  }

  Widget _buildAttemptCard(Datum attempt) {
    Color zoneColor;
    switch (attempt.zone?.toLowerCase()) {
      case 'green':
        zoneColor = Colors.green;
        break;
      case 'yellow':
        zoneColor = Colors.amber;
        break;
      case 'red':
        zoneColor = Colors.red;
        break;
      default:
        zoneColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: zoneColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.assignment, color: zoneColor),
        ),
        title: Text(
          '${AppLocalizations.of(context)!.translate('assessment')} - ${attempt.zone?.toUpperCase() ?? ''} ${AppLocalizations.of(context)!.translate('zone')}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${AppLocalizations.of(context)!.translate('status')}: ${attempt.status?.toUpperCase() ?? 'N/A'}\n'
          '${AppLocalizations.of(context)!.translate('date')}: ${DateFormat('MMM dd, yyyy - hh:mm a').format(attempt.updatedAt!)}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          _navigateToAttemptDetails(attempt);
        },
      ),
    );
  }

  Widget _buildAccordion({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required Color color,
    required List<Green> questions,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: isExpanded 
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                      )
                    : BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D3B3F),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.remove : Icons.add,
                    color: const Color(0xFF0D3B3F),
                  ),
                ],
              ),
            ),
          ),
          
          if (isExpanded)
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: questions.map((question) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question.question ?? AppLocalizations.of(context)!.translate('noQuestionText'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (question != questions.last) const Divider(height: 24),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildZoneButton({
    required String displayName,
    required String apiParam,
    required Color color,
  }) {
    final isSelected = selectedZone == displayName;
    
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedZone = displayName;
          
          if (apiParam == 'green') {
            isGreenExpanded = true;
            isYellowExpanded = false;
            isRedExpanded = false;
          } else if (apiParam == 'yellow') {
            isGreenExpanded = false;
            isYellowExpanded = true;
            isRedExpanded = false;
          } else if (apiParam == 'red') {
            isGreenExpanded = false;
            isYellowExpanded = false;
            isRedExpanded = true;
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.translate('confirmedZone', namedArgs: {'zoneName': displayName})),
            backgroundColor: color,
            duration: const Duration(seconds: 2),
          ),
        );
        
        saveZoneSelection(apiParam); // Pass the English parameter to the API
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : Colors.white,
        foregroundColor: isSelected ? Colors.white : const Color(0xFF0D3B3F),
        side: BorderSide(color: color, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        displayName,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> saveZoneSelection(String zone) async {
    BlocProvider.of<HomeBloc>(context).add(ZoneSaveEvent(zone: zone));
  }

  List<String> _getRecommendedSteps(String zoneName) {
    if (zoneName.contains('green')) {
      return [
        AppLocalizations.of(context)!.translate('continueMonitoring'),
        AppLocalizations.of(context)!.translate('maintainLifestyle'),
        AppLocalizations.of(context)!.translate('checkAgain'),
      ];
    } else if (zoneName.contains('yellow')) {
      return [
        AppLocalizations.of(context)!.translate('increaseMonitoring'),
        AppLocalizations.of(context)!.translate('consultDoctor'),
        AppLocalizations.of(context)!.translate('followMedications'),
      ];
    } else {
      return [
        AppLocalizations.of(context)!.translate('seekMedicalAttention'),
        AppLocalizations.of(context)!.translate('callEmergency'),
        AppLocalizations.of(context)!.translate('followProtocols'),
      ];
    }
  }

  void _navigateToAttemptDetails(Datum attempt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttemptDetailsScreen(
          attempt: attempt,
          stepsTaken: zoneSaveResponse?.stepsToBeTaken ?? 
              _getRecommendedSteps('${attempt.zone} ${AppLocalizations.of(context)!.translate('zone')}'),
        ),
      ),
    );
  }

  void fetchQuestionList() {
    BlocProvider.of<HomeBloc>(context).add(QuestionEvent());
  }

  void fetchAttemptList() {
    BlocProvider.of<HomeBloc>(context).add(AttemptEvent());
  }

  void handleQuestionListResponse(QuestionState state) {
    switch (state.apiState) {
      case ApiStatus.LOADING:
        setState(() => _isLoading = true);
        break;
      case ApiStatus.SUCCESS:
        setState(() {
          _isLoading = false;
          questionList = state.response;
        });
        break;
      case ApiStatus.ERROR:
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.translate('failedToLoadQuestions')}: ${state.error}')),
        );
        break;
      case ApiStatus.INITIAL:
        break;
    }
  }

  void handleZoneSaveResponse(ZoneSaveState state) {
    switch (state.apiState) {
      case ApiStatus.LOADING:
        setState(() => _isLoading = true);
        break;
      case ApiStatus.SUCCESS:
        setState(() {
          _isLoading = false;
          zoneSaveResponse = state.response;
          fetchAttemptList();
          
          // Create a mock attempt with the selected zone
          final newAttempt = Datum(
            id: 'new-${DateTime.now().millisecondsSinceEpoch}',
            zone: selectedZone?.split(' ').first.toLowerCase(),
            status: 'completed',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          // Navigate to details page with dynamic steps
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AttemptDetailsScreen(
                attempt: newAttempt,
                stepsTaken: state.response?.stepsToBeTaken ?? 
                    _getRecommendedSteps(selectedZone ?? AppLocalizations.of(context)!.translate('greenZone')),
              ),
            ),
          );
        });
        break;
      case ApiStatus.ERROR:
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.translate('failedToSaveZone')}: ${state.error}')),
        );
        break;
      case ApiStatus.INITIAL:
        break;
    }
  }

  void handleAttemptListResponse(AttemptState state) {
    switch (state.apiState) {
      case ApiStatus.LOADING:
        setState(() => _isLoading = true);
        break;
      case ApiStatus.SUCCESS:
        setState(() {
          _isLoading = false;
          attemptList = state.response?.data ?? [];
        });
        break;
      case ApiStatus.ERROR:
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.translate('failedToLoadAttempts')}: ${state.error}')),
        );
        break;
      case ApiStatus.INITIAL:
        break;
    }
  }
}

class AttemptDetailsScreen extends StatelessWidget {
  final Datum attempt;
  final List<String>? stepsTaken;

  const AttemptDetailsScreen({Key? key, required this.attempt, this.stepsTaken})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color zoneColor;
    switch (attempt.zone?.toLowerCase()) {
      case 'green':
        zoneColor = Colors.green;
        break;
      case 'yellow':
        zoneColor = Colors.amber;
        break;
      case 'red':
        zoneColor = Colors.red;
        break;
      default:
        zoneColor = Colors.grey;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D3B3F),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF0D3B3F),
        title: Text(
          AppLocalizations.of(context)!.translate('symptomsDetails'),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.translate('testProcedureComplete'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: zoneColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: zoneColor, width: 2),
              ),
              child: Text(
                '${AppLocalizations.of(context)!.translate('assessmentCategorized')} ${attempt.zone?.toUpperCase() ?? 'GREEN'} ${AppLocalizations.of(context)!.translate('zone')}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: zoneColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (stepsTaken != null && stepsTaken!.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A4A4E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('recommendedSteps'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...stepsTaken!.map((step) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white),
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              step,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ],
                ),
              ),
            const SizedBox(height: 30),
            Text(
              AppLocalizations.of(context)!.translate('resultsSaved'),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.translate('backToHome')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}