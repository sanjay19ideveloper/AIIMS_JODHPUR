import 'package:flutter/material.dart';

class MedicineReminderScreen extends StatefulWidget {
  const MedicineReminderScreen({super.key});

  @override
  _MedicineReminderScreenState createState() => _MedicineReminderScreenState();
}

class _MedicineReminderScreenState extends State<MedicineReminderScreen> {


  final List<Map<String, dynamic>> tasks = [
    {
      "time": "12 AM",
      "title": "NexGard Chewables, 10 mg",
      "subtitle": "1 Tablet, per day",
      "duration": "12:20 - 01:20",
      "color": Colors.blue.shade100,
    },
    {
      "time": "2 PM",
      "title": "Vet Appointment for vaccine",
      "subtitle": "Canine Rabies",
      "duration": "2:00 - 2:50",
      "color": Colors.yellow.shade100,
    },
    {
      "time": "4 PM",
      "title": "Walk with Tommy",
      "subtitle": "Evening Exercise",
      "duration": "4:30 - 4:50",
      "color": Colors.red.shade100,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1C2C),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFF0C1C2C),
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildTaskList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context); // back button
            },
            child: Row(
              children: [
                const Icon(Icons.arrow_back, color: Colors.white),
                const SizedBox(width: 8),
                const Text(
                  'Medicine Reminder',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Today',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              Text('January 14, 2021',
                  style: TextStyle(color: Colors.white54)),
            ],
          ),
          const SizedBox(height: 16),
          _buildDatePicker(),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final List<String> dates = ['12', '13', '14', '15', '16', '17'];

    final int itemCount = days.length < dates.length ? days.length : dates.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(itemCount, (index) {
        bool isSelected = index == 2; // today's date selected
        return Column(
          children: [
            Text(days[index], style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.pink.shade100 : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                dates[index],
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTaskList() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('To Take',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('+Add', style: TextStyle(color: Colors.green)),
              ],
            ),
            const SizedBox(height: 16),
            ...tasks.map((task) => _buildTaskCard(task)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: task['color'],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: task['color']!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(task['time'],
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey)),
          const SizedBox(height: 8),
          Text(task['title'],
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(task['subtitle'],
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time,
                      size: 14, color: Colors.black54),
                  const SizedBox(width: 4),
                  Text(task['duration'],
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54)),
                ],
              ),
              const Icon(Icons.notifications_none,
                  size: 20, color: Colors.black54),
            ],
          ),
        ],
      ),
    );
  }
}
