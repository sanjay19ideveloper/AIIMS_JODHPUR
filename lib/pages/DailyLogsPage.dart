import 'package:aiims_heartcare/blocs/bloc_manager.dart';
import 'package:aiims_heartcare/blocs/home_bloc.dart';
import 'package:aiims_heartcare/data/api/api_service.dart';
import 'package:aiims_heartcare/l10n/app_localizations.dart';
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
  double _maxDailyWaterIntakeMl = 0.0; 
  String? todayTotalIntake = '0';
  bool _showOnlyTop5 = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchDailyLogs();
    });
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
          double amount =
              double.tryParse(
                item.howMuch.toString().replaceAll(RegExp(r'[^0-9.]'), ''),
              ) ??
              0;
          total += amount;
        }
      } catch (e) {
        Log.v('Error parsing date or amount: $e');
      }
    }
    return total;
  }

  void _showLimitExceededDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange.shade800,
            ),
            SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.translate('limit_exceeded')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.translate('reached_daily_limit'),
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.translate('water_intoxication_warning'),
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.translate('ok')),
          ),
        ],
      ),
    );
  }

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

  void _showAddWaterIntakeDialog(BuildContext context) {
    final TextEditingController amountController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    double currentTotal = _calculateCurrentTotal();
    bool willExceedLimit = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.water_drop, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.translate('add_water_intake')),
                ],
              ),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.translate('amount_ml'),
                        border: OutlineInputBorder(),
                        suffixText: 'ml',
                        prefixIcon: Icon(Icons.water_drop),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.translate('enter_amount');
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return AppLocalizations.of(context)!.translate('enter_valid_amount');
                        }
                        if (currentTotal + amount > _maxDailyWaterIntakeMl) {
                          return AppLocalizations.of(context)!.translate('exceeds_daily_limit');
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          final amount = double.tryParse(value) ?? 0;
                          setState(() {
                            willExceedLimit = currentTotal + amount > _maxDailyWaterIntakeMl;
                          });
                        } else {
                          setState(() {
                            willExceedLimit = false;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 10),
                    Text(
                      '${AppLocalizations.of(context)!.translate('current_total')}: ${currentTotal.toStringAsFixed(0)} ml',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    Text(
                      '${AppLocalizations.of(context)!.translate('remaining')}: ${(_maxDailyWaterIntakeMl - currentTotal).toStringAsFixed(0)} ml',
                      style: TextStyle(
                        color: Colors.blue.shade600,
                      ),
                    ),
                    if (willExceedLimit)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          AppLocalizations.of(context)!.translate('will_exceed_limit_warning'),
                          style: TextStyle(
                            color: Colors.orange.shade800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.translate('cancel')),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      double amount = double.parse(amountController.text);
                      
                      if (currentTotal + amount > _maxDailyWaterIntakeMl) {
                        bool? proceed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Row(
                              children: [
                                Icon(Icons.warning, color: Colors.orange),
                                SizedBox(width: 8),
                                Text(AppLocalizations.of(context)!.translate('warning')),
                              ],
                            ),
                            content: Text(
                              AppLocalizations.of(context)!.translate('exceeds_daily_limit_confirm'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(AppLocalizations.of(context)!.translate('cancel')),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(AppLocalizations.of(context)!.translate('proceed')),
                              ),
                            ],
                          ),
                        );
                        
                        if (proceed != true) {
                          return;
                        }
                      }
                      
                      Navigator.pop(context);
                      getLogSave(howMuch: amountController.text);
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.translate('save')),
                ),
              ],
            );
          },
        );
      },
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
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.water_drop_rounded,
                  color: Colors.lightBlueAccent,
                  size: 32,
                ),
                const SizedBox(width: 10),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: AppLocalizations.of(context)!.translate('daily'),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: AppLocalizations.of(context)!.translate('logs'),
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
            centerTitle: true,
          ),
          body: ScreenWithLoader(
            isLoading: _isLoading,
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 5),
                    Text(
                      AppLocalizations.of(context)!.translate('record_daily_activities'),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
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
                              Text(
                                AppLocalizations.of(context)!.translate('hydration_journey'),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (contentList.length > 5)
                                TextButton(
                                  onPressed: () => _showAllWaterIntakeLogs(context),
                                  child: Text(
                                    AppLocalizations.of(context)!.translate('view_all'),
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
                                          ? (contentList.length > 2
                                              ? 2
                                              : contentList.length)
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
                                        int percentage =
                                            ((amount / _maxDailyWaterIntakeMl) * 100)
                                                .round()
                                                .clamp(0, 100);

                                        String dayText = AppLocalizations.of(
                                          context,
                                        )!.translate('today');
                                        String timeText = '';
                                        try {
                                          DateTime dateTime = item.createdAt;
                                          DateTime now = DateTime.now();
                                          if (dateTime.year == now.year &&
                                              dateTime.month == now.month &&
                                              dateTime.day == now.day) {
                                            dayText = AppLocalizations.of(
                                              context,
                                            )!.translate('today');
                                          } else if (dateTime.year == now.year &&
                                              dateTime.month == now.month &&
                                              dateTime.day == now.day - 1) {
                                            dayText = AppLocalizations.of(
                                              context,
                                            )!.translate('yesterday');
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
                                                              color: Color(
                                                                0xFF666666,
                                                              ),
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
                                                              color: Color(
                                                                0xFF666666,
                                                              ),
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
                                  _showAddWaterIntakeDialog(context);
                                },
                                icon: const Icon(Icons.add),
                                label: Text(
                                  AppLocalizations.of(context)!.translate('add_water_intake'),
                                ),
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
                              Text(
                                AppLocalizations.of(context)!.translate('daily_target'),
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
                                AppLocalizations.of(context)!.translate('minimum'),
                                Icons.water_drop,
                              ),
                              _buildTargetItem(
                                '${_maxDailyWaterIntakeMl.toStringAsFixed(0)} ml',
                                AppLocalizations.of(context)!.translate('your_goal'),
                                Icons.local_drink,
                              ),
                              _buildTargetItem(
                                '250 ml',
                                AppLocalizations.of(context)!.translate('per_glass'),
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
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.lightBlueAccent,
            onPressed: () {
              _showAddWaterIntakeDialog(context);
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
            AppLocalizations.of(context)!.translate('no_water_intake_logs'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.translate('start_tracking_hydration'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _showAddWaterIntakeDialog(context);
            },
            icon: const Icon(Icons.add),
            label: Text(
              AppLocalizations.of(context)!.translate('add_water_intake'),
            ),
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
          if (state.response?.limit != null) {
            _maxDailyWaterIntakeMl =
                double.tryParse(state.response!.limit!.toString()) ?? 0.0;
          }
          todayTotalIntake = state.response?.todayTotal ?? '0';
          
          // Check if limit was exceeded after saving
          double newTotal = _calculateCurrentTotal();
          if (newTotal > _maxDailyWaterIntakeMl) {
            _showLimitExceededDialog(context);
          }
        });
        fetchDailyLogs();
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
        title: Text(
          AppLocalizations.of(context)!.translate('all_water_intake_logs'),
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
                    AppLocalizations.of(context)!.translate('complete_water_history'),
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
                            AppLocalizations.of(context)!.translate('no_water_intake_logs_found'),
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
                        double amount =
                            double.tryParse(
                                  item.howMuch.toString().replaceAll(
                                    RegExp(r'[^0-9.]'),
                                    '',
                                  ),
                                ) ??
                                0;
                        int percentage = ((amount / maxDailyWaterIntakeMl) * 100)
                            .round()
                            .clamp(0, 100);

                        String dayText = AppLocalizations.of(
                          context,
                        )!.translate('today');
                        String timeText = '';
                        String fullDateText = '';
                        try {
                          DateTime dateTime = item.createdAt;
                          DateTime now = DateTime.now();
                          if (dateTime.year == now.year &&
                              dateTime.month == now.month &&
                              dateTime.day == now.day) {
                            dayText = AppLocalizations.of(
                              context,
                            )!.translate('today');
                          } else if (dateTime.year == now.year &&
                              dateTime.month == now.month &&
                              dateTime.day == now.day - 1) {
                            dayText = AppLocalizations.of(
                              context,
                            )!.translate('yesterday');
                          } else {
                            dayText = DateFormat('MMM dd').format(dateTime);
                          }
                          timeText = DateFormat('h:mm a').format(dateTime);
                          fullDateText = DateFormat(
                            'MMM dd, yyyy',
                          ).format(dateTime);
                        } catch (e) {
                          timeText = '8:30 AM';
                          fullDateText = AppLocalizations.of(
                            context,
                          )!.translate('unknown_date');
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
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
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