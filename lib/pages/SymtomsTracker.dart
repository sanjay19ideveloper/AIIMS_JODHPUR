import 'package:aiims_heartcare/blocs/bloc_manager.dart';
import 'package:aiims_heartcare/blocs/home_bloc.dart';
import 'package:aiims_heartcare/data/api/api_service.dart';
import 'package:aiims_heartcare/data/model/QuestionListResp.dart';
import 'package:aiims_heartcare/data/model/attemptModel.dart';
import 'package:aiims_heartcare/data/model/request/AttemptSaveRequest.dart';
import 'package:aiims_heartcare/utils/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class SymptomsTrackerScreen extends StatefulWidget {
  const SymptomsTrackerScreen({Key? key}) : super(key: key);

  @override
  State<SymptomsTrackerScreen> createState() => _SymptomsTrackerScreenState();
}

class _SymptomsTrackerScreenState extends State<SymptomsTrackerScreen> {
  int currentStep = 0;
  bool isCompleted = false;
  bool _isLoading = false;
  bool _isSavingResponse = false;
  var attemptList = [];
  QuestionListResponse? questionList;
  Map<String, dynamic> currentAnswers = {};
  String? currentZone;
  String? currentAttemptId;
  bool isAssessmentStarted = false;
  String? attemptStatus;
  List<String>? stepsTaken;

  // Track the selected option for the current question
  String? selectedOptionId;
  String? selectedResponse;

  @override
  Widget build(BuildContext context) {
    return BlocManager(
      initState: (BuildContext context) {
        fetchAttemptListData();
        fetchQuestionList();
      },
      child: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is AttemptState) {
            handleAttemptResponse(state);
          }
          if (state is QuestionState) {
            handleQuestionListResponse(state);
          }

          if (state is AttemptSaveState) {
            handleSaveResponseState(state);
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF0D3B3F),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0D3B3F),
            elevation: 2,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'Symptoms Tracker',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          body:
              isAssessmentStarted
                  ? _buildQuestionScreen()
                  : _buildMainContent(),
          floatingActionButton:
              !isAssessmentStarted
                  ? FloatingActionButton.extended(
                    onPressed: _startNewAssessment,
                    icon: const Icon(Icons.assessment),
                    label: const Text('Start Assessment'),
                    backgroundColor: const Color(0xFF1E88E5),
                    foregroundColor: Colors.white,
                  )
                  : null,
        ),
      ),
    );
  }

  Widget _buildQuestionScreen() {
    if (_isLoading) {
      return ScreenWithLoader(isLoading: _isLoading);
    }

    return _buildQuestionCard();
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return ScreenWithLoader(isLoading: _isLoading);
    }

    if (isCompleted) {
      return _buildResultsScreen();
    }

    if (attemptList.isEmpty) {
      return _buildEmptyState();
    }

    return _buildAllAttemptsList();
  }

  Widget _buildAllAttemptsList() {
    return ListView.builder(
      itemCount: attemptList.length,
      itemBuilder: (context, index) {
        final attempt = attemptList[index];
        return _buildAttemptCard(attempt, index);
      },
    );
  }

  Widget _buildAttemptCard(Datum attempt, int index) {
    Color zoneColor;
    switch (attempt.zone?.toLowerCase()) {
      case 'green':
        zoneColor = Colors.green;
        break;
      case 'yellow':
        zoneColor = Colors.orange;
        break;
      case 'red':
        zoneColor = Colors.red;
        break;
      default:
        zoneColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.all(10),
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
          'Attempt ${index + 1} - ${attempt.zone?.toUpperCase() ?? ''} Zone',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Status: ${attempt.status ?? 'N/A'}\n'
          'Updated: ${DateFormat('MMM dd, yyyy - hh:mm a').format(attempt.updatedAt!)}',
        ),
        trailing:
            attempt.status == 'pending'
                ? ElevatedButton(
                  onPressed: () => _continuePendingAssessment(attempt),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Re-Attempt'),
                )
                : const Icon(Icons.chevron_right),
        onTap: () {
          if (attempt.status != 'pending') {
            _navigateToAttemptDetails(attempt);
          } else {
            _continuePendingAssessment(attempt);
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.assignment_outlined,
            size: 80,
            color: Colors.white70,
          ),
          const SizedBox(height: 20),
          const Text(
            'No assessments yet',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          const SizedBox(height: 10),
          const Text(
            'Start your first assessment to track your symptoms',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _startNewAssessment,
            child: const Text('Start Assessment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    final allQuestions = [
      ...?questionList?.questions?.green,
      ...?questionList?.questions?.yellow,
      ...?questionList?.questions?.red,
    ];

    if (currentStep >= allQuestions.length) {
      return const Center(child: Text('No more questions'));
    }

    final currentQuestion = allQuestions[currentStep];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          _buildProgressIndicator(allQuestions.length),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child:
                  _isSavingResponse
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: _getZoneColor(
                                currentQuestion.zone!,
                              ).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              currentQuestion.zone
                                  .toString()
                                  .split('.')
                                  .last
                                  .toUpperCase(),
                              style: TextStyle(
                                color: _getZoneColor(currentQuestion.zone!),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              currentQuestion.question ?? 'No question text',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Column(
                            children:
                                (currentQuestion.options ?? []).map((option) {
                                  final isSelected =
                                      option.id == selectedOptionId;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 5,
                                      horizontal: 24,
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          selectedOptionId = option.id;
                                          selectedResponse =
                                              option.option == OptionEnum.OPTION
                                                  ? 'नहीं'
                                                  : 'हाँ';
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size(
                                          double.infinity,
                                          50,
                                        ),
                                        backgroundColor:
                                            isSelected
                                                ? (option.option ==
                                                        OptionEnum.OPTION
                                                    ? Colors.red[400]
                                                    : Colors.green[400])
                                                : (option.option ==
                                                        OptionEnum.OPTION
                                                    ? Colors.red[50]
                                                    : Colors.green[50]),
                                        foregroundColor:
                                            isSelected
                                                ? Colors.white
                                                : (option.option ==
                                                        OptionEnum.OPTION
                                                    ? Colors.red[800]
                                                    : Colors.green[800]),
                                      ),
                                      child: Text(
                                        option.option == OptionEnum.OPTION
                                            ? 'नहीं'
                                            : 'हाँ',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight:
                                              isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
            ),
          ),
          _buildNavigationButtons(allQuestions.length),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(int totalQuestions) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (currentStep + 1) / totalQuestions,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
            minHeight: 10,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 8),
          Text(
            'Question ${currentStep + 1} of $totalQuestions',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(int totalQuestions) {
    final isLastQuestion = currentStep == totalQuestions - 1;
    final allQuestions = [
      ...?questionList?.questions?.green,
      ...?questionList?.questions?.yellow,
      ...?questionList?.questions?.red,
    ];
    final currentQuestion = allQuestions[currentStep];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (currentStep > 0)
            ElevatedButton.icon(
              onPressed: _previousQuestion,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Previous'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            )
          else
            const SizedBox(width: 120),
          ElevatedButton(
            onPressed:
                _isSavingResponse
                    ? null
                    : () {
                      _saveAttemptResponse(
                        questionId: currentQuestion.id!,
                        response: null,
                        optionId: null,
                      ).then((_) => _skipQuestion());
                    },
            child: const Text('Skip'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black54,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed:
                _isSavingResponse ||
                        (selectedOptionId == null &&
                            currentAnswers[currentQuestion.id!] == null)
                    ? null
                    : () async {
                      if (selectedOptionId != null) {
                        await _saveAttemptResponse(
                          questionId: currentQuestion.id!,
                          response: selectedResponse,
                          optionId: selectedOptionId,
                        );
                      } else if (!currentAnswers.containsKey(
                        currentQuestion.id!,
                      )) {
                        await _saveAttemptResponse(
                          questionId: currentQuestion.id!,
                          response: null,
                          optionId: null,
                        );
                      }

                      if (isLastQuestion) {
                        await _finishAssessment();
                      } else {
                        _nextQuestion();
                      }
                    },
            icon: Icon(
              attemptStatus == 'completed' ? Icons.check : Icons.arrow_forward,
            ),
            label: Text(attemptStatus == 'completed' ? 'Finish' : 'Next'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              disabledBackgroundColor: Colors.grey[400],
              disabledForegroundColor: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
          const SizedBox(height: 20),
          const Text(
            'Assessment Complete',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getZoneColorFromString(
                currentZone ?? 'green',
              ).withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Your assessment has been categorized as\n${currentZone?.toUpperCase() ?? 'GREEN'} ZONE',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: _getZoneColorFromString(currentZone ?? 'green'),
              ),
            ),
          ),
          if (stepsTaken != null && stepsTaken!.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildStepsTakenCard(),
          ],
          const SizedBox(height: 20),
          const Text(
            'Your results have been saved',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const SymptomsTrackerScreen(),
                ),
              );
            },
            child: const Text('Back to Home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsTakenCard() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A4A4E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommended Steps:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          ...stepsTaken!
              .map(
                (step) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          step,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  // void _showHistoryDialog() {
  //   showDialog(
  //     context: context,
  //     builder:
  //         (context) => AlertDialog(
  //           title: const Text('Assessment History'),
  //           content: Container(
  //             width: double.maxFinite,
  //             height: 300,
  //             child:
  //                 attemptList.isEmpty
  //                     ? const Center(
  //                       child: Text('No assessment history available'),
  //                     )
  //                     : ListView.builder(
  //                       itemCount: attemptList.length,
  //                       itemBuilder: (context, index) {
  //                         final attempt = attemptList[index];
  //                         return ListTile(
  //                           leading: Container(
  //                             padding: const EdgeInsets.all(8),
  //                             decoration: BoxDecoration(
  //                               color: _getZoneColorFromString(
  //                                 attempt.zone ?? '',
  //                               ).withOpacity(0.2),
  //                               shape: BoxShape.circle,
  //                             ),
  //                             child: Icon(
  //                               Icons.assignment,
  //                               color: _getZoneColorFromString(
  //                                 attempt.zone ?? '',
  //                               ),
  //                             ),
  //                           ),
  //                           title: Text('Attempt ${index + 1}'),
  //                           subtitle: Text(
  //                             'Zone: ${attempt.zone?.toUpperCase() ?? 'UNKNOWN'}\n'
  //                             'Status: ${attempt.status?.toUpperCase() ?? 'N/A'}\n'
  //                             'Date: ${DateFormat('MMM dd, yyyy').format(attempt.updatedAt!)}',
  //                           ),
  //                           trailing:
  //                               attempt.status == 'pending'
  //                                   ? TextButton(
  //                                     onPressed: () {
  //                                       Navigator.pop(context);
  //                                       _continuePendingAssessment(attempt);
  //                                     },
  //                                     child: const Text('Continue'),
  //                                   )
  //                                   : null,
  //                           onTap: () {
  //                             Navigator.pop(context);
  //                             if (attempt.status != 'pending') {
  //                               _navigateToAttemptDetails(attempt);
  //                             } else {
  //                               _continuePendingAssessment(attempt);
  //                             }
  //                           },
  //                         );
  //                       },
  //                     ),
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.pop(context),
  //               child: const Text('Close'),
  //             ),
  //           ],
  //         ),
  //   );
  // }

  Future<void> _saveAttemptResponse({
    required String questionId,
    required dynamic response,
    required String? optionId,
  }) async {
    try {
      setState(() {
        _isSavingResponse = true;
      });

      final request = AttemptSaveRequest(
        questionId: questionId,
        response: response?.toString(),
        optionId: optionId,
      );

      BlocProvider.of<HomeBloc>(
        context,
      ).add(AttemptSaveEvent(request: request));

      final zone = _getQuestionZone(questionId);
      currentAnswers[questionId] = {
        'answer': response,
        'zone': zone,
        'question_id': questionId,
        'option_id': optionId,
      };

      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save response: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSavingResponse = false;
        });
      }
    }
  }

  void _nextQuestion() {
    setState(() {
      if (currentStep < _getTotalQuestions() - 1) {
        currentStep++;
        selectedOptionId = null;
        selectedResponse = null;

        final allQuestions = [
          ...?questionList?.questions?.green,
          ...?questionList?.questions?.yellow,
          ...?questionList?.questions?.red,
        ];
        final nextQuestion = allQuestions[currentStep];
        final existingAnswer = currentAnswers[nextQuestion.id!];

        if (existingAnswer != null) {
          selectedOptionId = existingAnswer['option_id'];
          selectedResponse = existingAnswer['answer'];
        }
      }
    });
  }

  Future<void> _finishAssessment() async {
    final allQuestions = [
      ...?questionList?.questions?.green,
      ...?questionList?.questions?.yellow,
      ...?questionList?.questions?.red,
    ];

    final currentQuestion = allQuestions[currentStep];

    if (selectedOptionId != null) {
      await _saveAttemptResponse(
        questionId: currentQuestion.id!,
        response: selectedResponse,
        optionId: selectedOptionId,
      );
    } else if (!currentAnswers.containsKey(currentQuestion.id!)) {
      await _saveAttemptResponse(
        questionId: currentQuestion.id!,
        response: null,
        optionId: null,
      );
    }

    _determineZoneAndSave();
  }

  void _determineZoneAndSave() {
    bool hasRedAnswer = currentAnswers.values.any(
      (answer) => answer['zone'] == Zone.RED && answer['answer'] == 'हाँ',
    );
    bool hasYellowAnswer = currentAnswers.values.any(
      (answer) => answer['zone'] == Zone.YELLOW && answer['answer'] == 'हाँ',
    );

    if (hasRedAnswer) {
      currentZone = 'red';
    } else if (hasYellowAnswer) {
      currentZone = 'yellow';
    } else {
      currentZone = 'green';
    }
  }

  void _previousQuestion() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
        selectedOptionId = null;
        selectedResponse = null;

        final allQuestions = [
          ...?questionList?.questions?.green,
          ...?questionList?.questions?.yellow,
          ...?questionList?.questions?.red,
        ];
        final prevQuestion = allQuestions[currentStep];
        final existingAnswer = currentAnswers[prevQuestion.id!];

        if (existingAnswer != null) {
          selectedOptionId = existingAnswer['option_id'];
          selectedResponse = existingAnswer['answer'];
        }
      });
    }
  }

  void _skipQuestion() {
    setState(() {
      if (currentStep < _getTotalQuestions() - 1) {
        currentStep++;
        selectedOptionId = null;
        selectedResponse = null;
      } else {
        _finishAssessment();
      }
    });
  }

  void _startNewAssessment() {
    setState(() {
      currentStep = 0;
      isCompleted = false;
      currentAnswers = {};
      currentZone = 'green';
      isAssessmentStarted = true;
      attemptStatus = 'pending';
      selectedOptionId = null;
      selectedResponse = null;
    });

    BlocProvider.of<HomeBloc>(context).add(QuestionEvent());
  }

  void _continuePendingAssessment(Datum attempt) {
    setState(() {
      currentAttemptId = attempt.id;
      currentZone = attempt.zone;
      isAssessmentStarted = true;
      attemptStatus = attempt.status;
      currentStep = 0;
      selectedOptionId = null;
      selectedResponse = null;
    });

    BlocProvider.of<HomeBloc>(context).add(QuestionEvent());
  }

  void _navigateToAttemptDetails(Datum attempt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                AttemptDetailsScreen(attempt: attempt, stepsTaken: stepsTaken),
      ),
    );
  }

  int _getTotalQuestions() {
    return (questionList?.questions?.green?.length ?? 0) +
        (questionList?.questions?.yellow?.length ?? 0) +
        (questionList?.questions?.red?.length ?? 0);
  }

  Zone _getQuestionZone(String questionId) {
    final allQuestions = [
      ...questionList?.questions?.green ?? [],
      ...questionList?.questions?.yellow ?? [],
      ...questionList?.questions?.red ?? [],
    ];

    final question = allQuestions.firstWhere(
      (q) => q.id == questionId,
      orElse: () => Green(zone: Zone.GREEN),
    );

    return question.zone!;
  }

  Color _getZoneColor(Zone zone) {
    switch (zone) {
      case Zone.GREEN:
        return Colors.green;
      case Zone.YELLOW:
        return Colors.orange;
      case Zone.RED:
        return Colors.red;
    }
  }

  Color _getZoneColorFromString(String zone) {
    switch (zone.toLowerCase()) {
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.orange;
      case 'red':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void fetchAttemptListData() {
    BlocProvider.of<HomeBloc>(context).add(AttemptEvent());
  }

  void fetchQuestionList() {
    BlocProvider.of<HomeBloc>(context).add(QuestionEvent());
  }

  void handleAttemptResponse(AttemptState state) {
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
          SnackBar(content: Text('Failed to load attempts: ${state.error}')),
        );
        break;
      case ApiStatus.INITIAL:
        break;
    }
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
          SnackBar(content: Text('Failed to load questions: ${state.error}')),
        );
        break;
      case ApiStatus.INITIAL:
        break;
    }
  }

  void handleSaveResponseState(AttemptSaveState state) {
    switch (state.apiState) {
      case ApiStatus.LOADING:
        break;
      case ApiStatus.SUCCESS:
        setState(() {
          attemptStatus = state.response?.attemptStatus;
          stepsTaken = state.response?.stepsTaken;

          // Immediately finish assessment if status is completed
          if (attemptStatus == 'completed') {
            isCompleted = true;
            isAssessmentStarted = false;

            // Find the current attempt from the list
            final currentAttempt = attemptList.firstWhere(
              (attempt) => attempt.id == currentAttemptId,
              orElse: () => null,
            );

            if (currentAttempt != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => AttemptDetailsScreen(
                        attempt: currentAttempt,
                        stepsTaken: stepsTaken,
                      ),
                ),
              );
            }
          }
        });
        break;
      case ApiStatus.ERROR:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save response: ${state.error}')),
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
    return Scaffold(
      backgroundColor: const Color(0xFF0D3B3F),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF0D3B3F),
        title: Text(
          'Attempt Details - ${attempt.zone?.toUpperCase() ?? ''} Zone',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Information Card
            Card(
              color: const Color(0xFF1A4A4E),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.white70),
                        SizedBox(width: 10),
                        Text(
                          'Basic Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      'Status:',
                      attempt.status == 'completed' ? 'Completed' : 'Pending',
                    ),
                    _buildDetailRow(
                      'Zone:',
                      attempt.zone?.toUpperCase() ?? 'Not specified',
                    ),
                    _buildDetailRow(
                      'Created:',
                      DateFormat(
                        'MMM dd, yyyy - hh:mm a',
                      ).format(attempt.createdAt!),
                    ),
                    _buildDetailRow(
                      'Updated:',
                      DateFormat(
                        'MMM dd, yyyy - hh:mm a',
                      ).format(attempt.updatedAt!),
                    ),

                    // Recommended Steps inside the same card
                    if (stepsTaken != null && stepsTaken!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Divider(color: Colors.white54),
                      const SizedBox(height: 10),
                      const Row(
                        children: [
                          Icon(Icons.medical_services, color: Colors.white70),
                          SizedBox(width: 10),
                          Text(
                            'Recommended Steps',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...stepsTaken!
                          .map(
                            (step) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      step,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ],
                  ],
                ),
              ),
            ),

            if (attempt.status == 'pending')
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SymptomsTrackerScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text('Continue Assessment'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
