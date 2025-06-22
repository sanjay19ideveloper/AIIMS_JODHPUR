import 'package:aiims_heartcare/blocs/bloc_manager.dart';
import 'package:aiims_heartcare/blocs/home_bloc.dart';
import 'package:aiims_heartcare/data/api/api_service.dart';
import 'package:aiims_heartcare/utils/loading.dart';
import 'package:aiims_heartcare/utils/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class DailyLogsPage extends StatefulWidget {
  const DailyLogsPage({super.key});

  @override
  State<DailyLogsPage> createState() => _DailyLogsPageState();
}

class _DailyLogsPageState extends State<DailyLogsPage> {
  bool _isLoading = false;
  bool _isInitialLoad = true;
  List<dynamic> contentList = [];
  double _maxDailyWaterIntakeMl = 2000.0; // Default value
  int? _userAge;
  bool _ageNotSet = false;
  bool _showOnlyTop5 = true; // New variable to control list display

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserAge();
    });
  }

  void _checkUserAge() {
    // In a real app, you would fetch this from user profile or preferences
    // For demo, we'll show the age dialog if not set
    if (_userAge == null) {
      _showAgeInputDialog(context);
    } else {
      fetchDailyLogs();
    }
  }

  double _calculateCurrentTotal() {
    double total = 0;
    DateTime now = DateTime.now();
    
    for (var item in contentList) {
      try {
        DateTime itemDate = item.createdAt;
        if (itemDate.year == now.year &&
            itemDate.month == now.month &&
            itemDate.day == now.day) {
          double amount = double.tryParse(
                  item.howMuch.toString().replaceAll(RegExp(r'[^0-9.]'), '')) ??
              0;
          total += amount;
        }
      } catch (e) {
        Log.v('Error parsing date or amount: $e');
      }
    }
    return total;
  }

  void _showLimitExceededDialog(BuildContext context, double attemptedAmount, double currentTotal) {
    double remaining = _maxDailyWaterIntakeMl - currentTotal;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
            SizedBox(width: 8),
            Text('Limit Exceeded', style: TextStyle(color: Colors.orange.shade800)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You cannot add ${attemptedAmount.toStringAsFixed(0)}ml as it would exceed your daily limit based on your age.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            _buildInfoRow('Current intake', '${currentTotal.toStringAsFixed(0)} ml'),
            _buildInfoRow('Daily limit', '${_maxDailyWaterIntakeMl.toStringAsFixed(0)} ml'),
            _buildInfoRow('Remaining allowance', '${remaining > 0 ? remaining.toStringAsFixed(0) : 0} ml'),
            SizedBox(height: 16),
            Text(
              'Why is this important?',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade800),
            ),
            SizedBox(height: 8),
            Text(
              'Drinking too much water can lead to water intoxication (hyponatremia), '
              'which dilutes sodium in your blood and can be dangerous.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showAgeInputDialog(BuildContext context, {bool isForAddingIntake = false}) {
    final ageController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: !isForAddingIntake,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.person, color: Colors.blue),
            SizedBox(width: 8),
            Text('Enter Your Age'),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('We need your age to calculate your recommended daily water intake.'),
              SizedBox(height: 16),
              TextFormField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                  suffixText: 'years',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  final age = int.tryParse(value);
                  if (age == null || age <= 0 || age > 120) {
                    return 'Please enter a valid age (1-120)';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          if (!isForAddingIntake)
            TextButton(
              onPressed: () {
                setState(() {
                  _ageNotSet = true;
                });
                Navigator.pop(context);
              },
              child: Text('Skip'),
            ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final age = int.parse(ageController.text);
                setState(() {
                  _userAge = age;
                  _ageNotSet = false;
                  // Calculate recommended water intake based on age
                  _maxDailyWaterIntakeMl = _calculateRecommendedIntake(age);
                });
                Navigator.pop(context);
                
                if (isForAddingIntake) {
                  // Show water intake dialog after age is set
                  _showAddWaterIntakeDialog(context);
                } else {
                  fetchDailyLogs();
                }
              }
            },
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }

  double _calculateRecommendedIntake(int age) {
    // Recommended water intake calculation based on age
    if (age < 1) return 800.0; // Infants
    if (age <= 3) return 1300.0; // Toddlers
    if (age <= 8) return 1700.0; // Children
    if (age <= 13) return 2400.0; // Pre-teens
    if (age <= 18) return 3300.0; // Teens
    if (age <= 30) return 3700.0; // Young adults
    if (age <= 50) return 3500.0; // Middle-aged adults
    if (age <= 70) return 3000.0; // Older adults
    return 2800.0; // Seniors (70+)
  }

  // New method to show all water intake logs
  void _showAllWaterIntakeLogs(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllWaterIntakeLogsPage(
          contentList: contentList,
          maxDailyWaterIntakeMl: _maxDailyWaterIntakeMl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocManager(
      initState: (BuildContext context) {},
      child: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is ReminderState) {
            handleDailyLogsResponse(state);
          }

          if (state is LogSaveState) {
            handleLogSaveResponse(state);
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF0D3B3F),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Daily Logs',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            centerTitle: true,
          ),
          body: _ageNotSet
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person, size: 64, color: Colors.white70),
                      SizedBox(height: 20),
                      Text(
                        'Age Information Required',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'We need your age to calculate your recommended daily water intake.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () => _showAgeInputDialog(context),
                        child: Text('Enter Your Age'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                      ),
                    ],
                  ),
                )
              : ScreenWithLoader(
                  isLoading: _isLoading,
                  body: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.water_drop_rounded,
                                color: Colors.lightBlueAccent,
                                size: 32,
                              ),
                              const SizedBox(width: 10),
                              RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Daily',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' Logs',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.lightBlueAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Padding(
                            padding: EdgeInsets.only(left: 42),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Record your daily activities',
                                  style: TextStyle(fontSize: 16, color: Colors.white70),
                                ),
                                if (_userAge != null)
                                  Text(
                                    'Recommended intake: ${_maxDailyWaterIntakeMl.toStringAsFixed(0)} ml (Age: $_userAge)',
                                    style: TextStyle(fontSize: 14, color: Colors.white70),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 25),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Track your hydration journey',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (contentList.length > 5)
                                      TextButton(
                                        onPressed: () => _showAllWaterIntakeLogs(context),
                                        child: Text(
                                          'View All',
                                          style: TextStyle(
                                            color: const Color(0xFF4CACBC),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                _isInitialLoad
                                    ? _buildShimmerLoader()
                                    : contentList.isNotEmpty
                                        ? ListView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: _showOnlyTop5 
                                                ? (contentList.length > 2 ? 2 : contentList.length)
                                                : contentList.length,
                                            itemBuilder: (context, index) {
                                              var item = contentList[index];
                                              double amount =
                                                  double.tryParse(
                                                        item.howMuch.toString().replaceAll(
                                                          RegExp(r'[^0-9.]'),
                                                          '',
                                                        ),
                                                      ) ??
                                                      0;
                                              int percentage = ((amount / _maxDailyWaterIntakeMl) * 100)
                                                  .round()
                                                  .clamp(0, 100);

                                              String dayText = 'Today';
                                              String timeText = '';
                                              try {
                                                DateTime dateTime = item.createdAt;
                                                DateTime now = DateTime.now();
                                                if (dateTime.year == now.year &&
                                                    dateTime.month == now.month &&
                                                    dateTime.day == now.day) {
                                                  dayText = 'Today';
                                                } else if (dateTime.year == now.year &&
                                                    dateTime.month == now.month &&
                                                    dateTime.day == now.day - 1) {
                                                  dayText = 'Yesterday';
                                                } else {
                                                  dayText = DateFormat(
                                                    'MMM dd',
                                                  ).format(dateTime);
                                                }
                                                timeText = DateFormat(
                                                  'h:mm a',
                                                ).format(dateTime);
                                              } catch (e) {
                                                timeText = '8:30 AM';
                                              }

                                              return Container(
                                                margin: const EdgeInsets.only(bottom: 12),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFE8F9FC),
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(16),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 60,
                                                        height: 60,
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: Center(
                                                          child: Icon(
                                                            Icons.water_drop,
                                                            color: const Color(0xFF4CACBC),
                                                            size: 32,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 16),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              '${item.howMuch} ml',
                                                              style: const TextStyle(
                                                                fontSize: 24,
                                                                fontWeight: FontWeight.bold,
                                                                color: Color(0xFF333333),
                                                            ),
                                                            ),
                                                            const SizedBox(height: 4),
                                                            Row(
                                                              children: [
                                                                const Icon(
                                                                  Icons.calendar_today,
                                                                  size: 16,
                                                                  color: Color(0xFF666666),
                                                                ),
                                                                const SizedBox(width: 4),
                                                                Text(
                                                                  dayText,
                                                                  style: const TextStyle(
                                                                    fontSize: 14,
                                                                    color: Color(0xFF666666),
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 16),
                                                                const Icon(
                                                                  Icons.access_time,
                                                                  size: 16,
                                                                  color: Color(0xFF666666),
                                                                ),
                                                                const SizedBox(width: 4),
                                                                Text(
                                                                  timeText,
                                                                  style: const TextStyle(
                                                                    fontSize: 14,
                                                                    color: Color(0xFF666666),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      circularProgressWithText(
                                                        percentage.toDouble(),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        : _buildEmptyState(),
                                if (contentList.isEmpty && !_isInitialLoad)
                                  const SizedBox(height: 20),
                                if (!_isInitialLoad)
                                  Center(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        if (_userAge == null) {
                                          _showAgeInputDialog(context, isForAddingIntake: true);
                                        } else {
                                          _showAddWaterIntakeDialog(context);
                                        }
                                      },
                                      icon: const Icon(Icons.add),
                                      label: const Text('Add Water Intake'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF4CACBC),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.lightBlue.shade50,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.flag_rounded,
                                        color: Colors.blue,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Daily Target',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0D3B3F),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildTargetItem(
                                      '${(_maxDailyWaterIntakeMl * 0.5).toStringAsFixed(0)} ml',
                                      'Minimum',
                                      Icons.water_drop,
                                    ),
                                    _buildTargetItem(
                                      '${_maxDailyWaterIntakeMl.toStringAsFixed(0)} ml',
                                      'Your Goal',
                                      Icons.local_drink,
                                    ),
                                    _buildTargetItem(
                                      '250 ml',
                                      'Per Glass',
                                      Icons.straighten,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          floatingActionButton: _ageNotSet
              ? null
              : FloatingActionButton(
                  backgroundColor: Colors.lightBlueAccent,
                  onPressed: () {
                    if (_userAge == null) {
                      _showAgeInputDialog(context, isForAddingIntake: true);
                    } else {
                      _showAddWaterIntakeDialog(context);
                    }
                  },
                  child: const Icon(Icons.add, color: Colors.white),
                ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(
          3,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 100, height: 24, color: Colors.white),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 16),
                            Container(
                              width: 60,
                              height: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTargetItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.blue, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF0D3B3F),
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget circularProgressWithText(double percentage) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            value: percentage / 100,
            strokeWidth: 6,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CACBC)),
          ),
        ),
        Text(
          '${percentage.toStringAsFixed(0)}%',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4CACBC),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.water_drop_outlined,
            size: 60,
            color: Colors.blue.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No water intake logs yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your hydration by adding your first water intake',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              if (_userAge == null) {
                _showAgeInputDialog(context, isForAddingIntake: true);
              } else {
                _showAddWaterIntakeDialog(context);
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Water Intake'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddWaterIntakeDialog(BuildContext context) {
    String selectedAmount = '250';
    double currentTotal = _calculateCurrentTotal();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Add Water Intake'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Limit: ${_maxDailyWaterIntakeMl.toStringAsFixed(0)} ml (Age: $_userAge)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Current intake: ${currentTotal.toStringAsFixed(0)} ml',
                        style: TextStyle(
                          fontSize: 14,
                          color: currentTotal >= _maxDailyWaterIntakeMl
                              ? Colors.red
                              : Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('How much water did you drink?'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildWaterAmountOption(
                      context,
                      '100',
                      selectedAmount,
                      (value) {
                        setState(() {
                          selectedAmount = value;
                        });
                      },
                    ),
                    _buildWaterAmountOption(
                      context,
                      '250',
                      selectedAmount,
                      (value) {
                        setState(() {
                          selectedAmount = value;
                        });
                      },
                    ),
                    _buildWaterAmountOption(
                      context,
                      '500',
                      selectedAmount,
                      (value) {
                        setState(() {
                          selectedAmount = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Custom Amount (ml)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      setState(() {
                        selectedAmount = value;
                      });
                    }
                  },
                ),
                if (currentTotal >= _maxDailyWaterIntakeMl)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'You have reached your daily limit!',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  double amount = double.tryParse(selectedAmount) ?? 0;
                  double newTotal = currentTotal + amount;
                  
                  if (newTotal > _maxDailyWaterIntakeMl) {
                    _showLimitExceededDialog(context, amount, currentTotal);
                  } else {
                    Navigator.pop(context);
                    getLogSave(howMuch: selectedAmount);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWaterAmountOption(
    BuildContext context,
    String amount,
    String selectedAmount,
    Function(String) onSelected,
  ) {
    final isSelected = selectedAmount == amount;
    return InkWell(
      onTap: () {
        onSelected(amount);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue.shade400 : Colors.blue.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.water_drop, color: Colors.blue.shade400),
            const SizedBox(height: 4),
            Text(
              '$amount ml',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void fetchDailyLogs() {
    if (mounted) {
      setState(() {
        _isInitialLoad = true;
      });
    }
    BlocProvider.of<HomeBloc>(context).add(ReminderEvent());
  }

  void handleDailyLogsResponse(ReminderState state) {
    if (!mounted) return;

    switch (state.apiState) {
      case ApiStatus.LOADING:
        Log.v("Loading...");
        setState(() {
          _isLoading = true;
        });
        break;
      case ApiStatus.SUCCESS:
        Log.v("Success loading data : ${state.response}");
        setState(() {
          _isLoading = false;
          _isInitialLoad = false;
          contentList = state.response?.dailyLog ?? [];
          Log.v('data is $contentList');
        });
        break;
      case ApiStatus.ERROR:
        Log.v("Error: ${state.error}");
        setState(() {
          _isLoading = false;
          _isInitialLoad = false;
        });
        break;
      case ApiStatus.INITIAL:
        break;
    }
  }

  void getLogSave({String? howMuch}) {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    BlocProvider.of<HomeBloc>(context).add(LogSaveEvent(howMuch: howMuch));
  }

  void handleLogSaveResponse(LogSaveState state) {
    if (!mounted) return;

    switch (state.apiState) {
      case ApiStatus.LOADING:
        setState(() {
          _isLoading = true;
        });
        break;
      case ApiStatus.SUCCESS:
        setState(() {
          _isLoading = false;
          contentList = state.response?.dailyLog ?? [];
        });
        fetchDailyLogs(); // Refresh the list after saving
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

// New page to show all water intake logs
class AllWaterIntakeLogsPage extends StatelessWidget {
  final List<dynamic> contentList;
  final double maxDailyWaterIntakeMl;

  const AllWaterIntakeLogsPage({
    super.key,
    required this.contentList,
    required this.maxDailyWaterIntakeMl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D3B3F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'All Water Intake Logs',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.water_drop, color: Colors.blue.shade600, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Complete Water Intake History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: contentList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.water_drop_outlined,
                            size: 60,
                            color: Colors.blue.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No water intake logs found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: contentList.length,
                      itemBuilder: (context, index) {
                        var item = contentList[index];
                        double amount = double.tryParse(
                              item.howMuch.toString().replaceAll(
                                RegExp(r'[^0-9.]'),
                                '',
                              ),
                            ) ??
                            0;
                        int percentage = ((amount / maxDailyWaterIntakeMl) * 100)
                            .round()
                            .clamp(0, 100);

                        String dayText = 'Today';
                        String timeText = '';
                        String fullDateText = '';
                        try {
                          DateTime dateTime = item.createdAt;
                          DateTime now = DateTime.now();
                          if (dateTime.year == now.year &&
                              dateTime.month == now.month &&
                              dateTime.day == now.day) {
                            dayText = 'Today';
                          } else if (dateTime.year == now.year &&
                              dateTime.month == now.month &&
                              dateTime.day == now.day - 1) {
                            dayText = 'Yesterday';
                          } else {
                            dayText = DateFormat('MMM dd').format(dateTime);
                          }
                          timeText = DateFormat('h:mm a').format(dateTime);
                          fullDateText = DateFormat('MMM dd, yyyy').format(dateTime);
                        } catch (e) {
                          timeText = '8:30 AM';
                          fullDateText = 'Unknown date';
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F9FC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.blue.shade100,
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.1),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.water_drop,
                                      color: const Color(0xFF4CACBC),
                                      size: 32,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${item.howMuch} ml',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF333333),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_today,
                                            size: 16,
                                            color: Color(0xFF666666),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            fullDateText,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF666666),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time,
                                            size: 16,
                                            color: Color(0xFF666666),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            timeText,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF666666),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: CircularProgressIndicator(
                                        value: percentage / 100,
                                        strokeWidth: 6,
                                        backgroundColor: Colors.grey[300],
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xFF4CACBC),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${percentage.toStringAsFixed(0)}%',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF4CACBC),
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
            ),
          ],
        ),
      ),
    );
  }
}