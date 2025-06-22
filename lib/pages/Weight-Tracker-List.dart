import 'package:aiims_heartcare/blocs/bloc_manager.dart';
import 'package:aiims_heartcare/blocs/home_bloc.dart';
import 'package:aiims_heartcare/data/api/api_service.dart';
import 'package:aiims_heartcare/data/model/weightListResp.dart';
import 'package:aiims_heartcare/utils/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WeightTrackerPage extends StatefulWidget {
  const WeightTrackerPage({Key? key}) : super(key: key);

  @override
  State<WeightTrackerPage> createState() => _WeightTrackerPageState();
}

class _WeightTrackerPageState extends State<WeightTrackerPage> {
  bool _isLoading = false;
  List<Weight>? weightList;
  List<Weight>? weightSaveList;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  final TextEditingController _weightController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isCalendarView = true;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    fetchWeightList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocManager(
      initState: (BuildContext context) {
        fetchWeightList();
      },
      child: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is WeightListState) {
            handleWeightResponse(state);
          }
          if (state is WeightSaveState) {
            handleWeightSaveResponse(state);
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: ScreenWithLoader(
            isLoading: _isLoading,
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  iconTheme: IconThemeData(color: Colors.white),
                  backgroundColor: const Color(0xFF0D3B3F),
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  actions: [
                    IconButton(
                      icon: Icon(
                        _isCalendarView ? Icons.list : Icons.calendar_today,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _isCalendarView = !_isCalendarView;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.filter_list, color: Colors.white),
                      onPressed: () {
                        _showFilterDialog();
                      },
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      color: const Color(0xFF0D3B3F),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                height: 120,
                                width: 120,
                                child: CircularProgressIndicator(
                                  value: 0.7,
                                  strokeWidth: 10,
                                  backgroundColor: Colors.white.withOpacity(
                                    0.3,
                                  ),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    '${weightList?.first.weight ?? 0}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Text(
                                        'KG',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(
                                        FontAwesomeIcons.weightScale,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildStatCard(
                                Icons.trending_down,
                                '-0.7',
                                'This Week',
                              ),
                              _buildStatCard(
                                Icons.trending_up,
                                '+1.2',
                                'This Month',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child:
                      _isCalendarView
                          ? _buildCalendarView()
                          : Container(
                            color: const Color(0xFF0D3B3F),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildMonthTab('Week 1', false),
                                _buildMonthTab('Week 2', true),
                                _buildMonthTab('Week 3', false),
                                _buildMonthTab('Week 4', false),
                              ],
                            ),
                          ),
                ),
                _isCalendarView
                    ? _buildCalendarEntries()
                    : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        if (weightList == null || weightList!.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('No weight entries found'),
                            ),
                          );
                        }
                        final weight = weightList![index];
                        DateTime? date;
                        try {
                          date = DateTime.tryParse(weight.measuredAt ?? '');
                          if (date == null) {
                            // Try parsing with different format if needed
                            date = DateFormat(
                              'dd MMM yyyy',
                            ).parse(weight.measuredAt!);
                          }
                        } catch (e) {
                          date = DateTime.now();
                        }

                        final day = date.day.toString();
                        final dayOfWeek =
                            DateFormat('E').format(date).toUpperCase();
                        return _buildWeightEntry(
                          day,
                          dayOfWeek,
                          weight.weight ?? '0',
                          'Measured at ${DateFormat('hh:mm a').format(date)}',
                        );
                      }, childCount: weightList?.length ?? 0),
                    ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _showAddWeightDialog();
            },
            backgroundColor: const Color(0xFF0D3B3F),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: const Color(0xFF0D3B3F).withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: Color(0xFF0D3B3F),
              shape: BoxShape.circle,
            ),
            markerDecoration: const BoxDecoration(
              color: Colors.redAccent,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            formatButtonDecoration: BoxDecoration(
              color: const Color(0xFF0D3B3F),
              borderRadius: BorderRadius.circular(16),
            ),
            formatButtonTextStyle: const TextStyle(color: Colors.white),
            titleTextStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D3B3F),
            ),
          ),
        ),
      ),
    );
  }

  SliverList _buildCalendarEntries() {
    // Filter entries for the selected day
    final filteredEntries =
        weightList?.where((entry) {
          if (entry.measuredAt == null) return false;

          DateTime? entryDate;
          try {
            entryDate = DateTime.tryParse(entry.measuredAt ?? '');
            if (entryDate == null) {
              entryDate = DateFormat('dd MMM yyyy').parse(entry.measuredAt!);
            }
          } catch (e) {
            return false;
          }

          return isSameDay(entryDate, _selectedDay);
        }).toList();

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (filteredEntries == null || filteredEntries.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No weight entries for this day'),
              ),
            );
          }
          final weight = filteredEntries[index];
          DateTime? date;
          try {
            date = DateTime.tryParse(weight.measuredAt ?? '');
            if (date == null) {
              date = DateFormat('dd MMM yyyy').parse(weight.measuredAt!);
            }
          } catch (e) {
            date = DateTime.now();
          }

          final day = date.day.toString();
          final dayOfWeek = DateFormat('E').format(date).toUpperCase();
          return _buildWeightEntry(
            day,
            dayOfWeek,
            weight.weight ?? '0',
            'Measured at ${DateFormat('hh:mm a').format(date)}',
          );
        },
        childCount:
            (filteredEntries?.length ?? 0) == 0 ? 1 : filteredEntries?.length,
      ),
    );
  }

  Widget _buildMonthTab(String month, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration:
          isSelected
              ? const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.white, width: 2.0),
                ),
              )
              : null,
      child: Text(
        month,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildWeightEntry(
    String day,
    String dayOfWeek,
    String weight,
    String note,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF0D3B3F).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                day,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D3B3F),
                ),
              ),
              Text(
                dayOfWeek,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        title: Row(
          children: [
            Text(
              '$weight KG',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 8),
            const Icon(
              FontAwesomeIcons.weightScale,
              size: 14,
              color: Color(0xFF0D3B3F),
            ),
          ],
        ),
        subtitle: note != '-' ? Text(note) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF0D3B3F), size: 20),
              onPressed: () {
                _showEditWeightDialog(weight);
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
                size: 20,
              ),
              onPressed: () {
                _showDeleteConfirmation();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWeightDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: const [
                Icon(
                  FontAwesomeIcons.weightScale,
                  color: Color(0xFF0D3B3F),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text('Add Weight'),
              ],
            ),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _weightController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Weight (kg)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(
                        FontAwesomeIcons.weightScale,
                        size: 16,
                      ),
                      suffixText: 'kg',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your weight';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDay)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Time: ${DateFormat('hh:mm a').format(DateTime.now())}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D3B3F),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final weight = _weightController.text.trim();
                    debugPrint('weight count is $weight');
                    gethWeightSave(weightCount: weight);
                    fetchWeightList();

                    Navigator.pop(context);
                    _showSuccessSnackBar('Weight added successfully!');
                    _weightController.clear();
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _showEditWeightDialog(String currentWeight) {
    _weightController.text = currentWeight;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.edit, color: Color(0xFF0D3B3F), size: 20),
                SizedBox(width: 8),
                Text('Edit Weight'),
              ],
            ),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _weightController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Weight (kg)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(
                        FontAwesomeIcons.weightScale,
                        size: 16,
                      ),
                      suffixText: 'kg',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your weight';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D3B3F),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context);
                    _showSuccessSnackBar('Weight updated successfully!');
                    _weightController.clear();
                  }
                },
                child: const Text('Update'),
              ),
            ],
          ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Weight Entry'),
            content: const Text(
              'Are you sure you want to delete this weight entry?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                  _showSuccessSnackBar('Weight entry deleted!');
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.filter_list, color: Color(0xFF0D3B3F), size: 20),
                SizedBox(width: 8),
                Text('Filter Weight Entries'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('This Week'),
                  onTap: () {
                    Navigator.pop(context);
                    _showSuccessSnackBar('Filtered by: This Week');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: const Text('This Month'),
                  onTap: () {
                    Navigator.pop(context);
                    _showSuccessSnackBar('Filtered by: This Month');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.date_range),
                  title: const Text('Last 3 Months'),
                  onTap: () {
                    Navigator.pop(context);
                    _showSuccessSnackBar('Filtered by: Last 3 Months');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.all_inclusive),
                  title: const Text('All Time'),
                  onTap: () {
                    Navigator.pop(context);
                    _showSuccessSnackBar('Filtered by: All Time');
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF0D3B3F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void gethWeightSave({String? weightCount}) {
    BlocProvider.of<HomeBloc>(
      context,
    ).add(WeightSaveEvent(weight: weightCount));
  }

  void handleWeightSaveResponse(WeightSaveState state) {
    switch (state.apiState) {
      case ApiStatus.LOADING:
        setState(() {
          _isLoading = true;
        });
        break;
      case ApiStatus.SUCCESS:
        setState(() {
          _isLoading = false;
          weightSaveList = state.response?.weights;
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

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return false;
    }
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void fetchWeightList() {
    BlocProvider.of<HomeBloc>(context).add(WeightListEvent());
  }

  void handleWeightResponse(WeightListState state) {
    switch (state.apiState) {
      case ApiStatus.LOADING:
        setState(() {
          _isLoading = true;
        });
        break;
      case ApiStatus.SUCCESS:
        setState(() {
          _isLoading = false;
          weightList = state.response?.weights;
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
