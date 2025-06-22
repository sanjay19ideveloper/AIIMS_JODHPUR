import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> dashboardItems = [
    {
      "title": "Weight Tracker",
      "subtitle": "Track your daily weight",
      "icon": Icons.monitor_weight,
      "color": Colors.blueAccent.shade100,
    },
    {
      "title": "Symptoms Tracker",
      "subtitle": "Log your health symptoms",
      "icon": Icons.sick,
      "color": Colors.purpleAccent.shade100,
    },
    {
      "title": "Medicine Reminder",
      "subtitle": "Never miss a dose",
      "icon": Icons.medication_liquid,
      "color": Colors.tealAccent.shade100,
    },
    {
      "title": "Daily Logs",
      "subtitle": "Write your daily health log",
      "icon": Icons.edit_note,
      "color": Colors.orangeAccent.shade100,
    },
    {
      "title": "My Learning",
      "subtitle": "Health articles & videos",
      "icon": Icons.school_outlined,
      "color": Colors.amberAccent.shade100,
    },
    {
      "title": "Notifications",
      "subtitle": "Stay updated",
      "icon": Icons.notifications_active,
      "color": Colors.pinkAccent.shade100,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFF0C1C2C),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Color(0xFF0C1C2C),
            expandedHeight: height * 0.25,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(),
            ),
          ),
          SliverToBoxAdapter(
            child: 
            _buildDashboardGrid(width),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
             Image.asset('assets/images/logo.png', scale: 20),
              SizedBox(width: 8),
              Text('Hriday sathi (हृदय साथी)',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Spacer(),
                     Icon(Icons.menu, color: Colors.white),
            ],
          ),
          SizedBox(height: 16),
          Text('DR.Sanjay Gupta', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Tracking Today for a Healthier Tomorrow.', style: TextStyle(color: Colors.white54, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildDashboardGrid(double width) {
    return 
    Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: dashboardItems.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: width > 600 ? 3 : 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 4 / 4.5,
        ),
        itemBuilder: (context, index) {
          final item = dashboardItems[index];
          return _buildDashboardItem(item);
        },
      ),
    );
  }

  Widget _buildDashboardItem(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to respective screen
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: item['color'],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item['icon'], size: 40, color: Colors.black87),
            SizedBox(height: 12),
            Text(item['title'],
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text(item['subtitle'],
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomNavigationBar(
      backgroundColor: Color(0xFF0C1C2C),
      selectedItemColor: Colors.pinkAccent,
      unselectedItemColor: Colors.grey,
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            children: [
              Icon(Icons.notifications_none),
              Positioned(
                right: 0,
                child: CircleAvatar(
                  radius: 6,
                  backgroundColor: Colors.red,
                  child: Text('3', style: TextStyle(fontSize: 8, color: Colors.white)),
                ),
              ),
            ],
          ),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
