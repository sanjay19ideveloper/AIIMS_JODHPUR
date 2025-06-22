import 'dart:async';
import 'package:aiims_heartcare/pages/LoginPage.dart';
import 'package:flutter/material.dart';

class PreboardingScreen extends StatefulWidget {
  @override
  _PreboardingScreenState createState() => _PreboardingScreenState();
}

class _PreboardingScreenState extends State<PreboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, dynamic>> pages = [
    {
      'title': 'Medicine Reminder',
      'subtitle': 'Easily track and get reminded about your medications daily.',
      'image':
          'https://images.pexels.com/photos/3683070/pexels-photo-3683070.jpeg?auto=compress&cs=tinysrgb&w=1200',
    },
    {
      'title': 'Lab Test',
      'subtitle':
          'Detailed ReportFast, Reliable, and Accurate Laboratory Testing',
      'image':
          'https://images.pexels.com/photos/8949863/pexels-photo-8949863.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
    },
    {
      'title': 'Weight Tracker',
      'subtitle': 'Monitor your weight progress with easy tracking tools.',
      'image':
          'https://images.pexels.com/photos/1740904/pexels-photo-1740904.jpeg?auto=compress&cs=tinysrgb&w=1200',
    },
    {
      'title': 'Symptom Tracker',
      'subtitle': 'Track symptoms to better understand your health patterns.',
      'image':
          'https://images.pexels.com/photos/5858853/pexels-photo-5858853.jpeg?auto=compress&cs=tinysrgb&w=1200',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(Duration(seconds: 4), (timer) {
      if (_currentPage < pages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _nextPage() {
    if (_currentPage < pages.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildImageBackground(),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildImageBackground() {
    return PageView.builder(
      controller: _pageController,
      itemCount: pages.length,
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
        });
      },
      itemBuilder: (context, index) {
        return AnimatedSwitcher(
          duration: Duration(milliseconds: 600),
          child: Container(
            key: ValueKey(index),
            child: Image.network(
              pages[index]['image'],
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSection() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.30,
      decoration: BoxDecoration(
        color: Color(0xff16423C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          _buildPageIndicator(),
          SizedBox(height: 20),
          Text(
            pages[_currentPage]['title'],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Text(
            pages[_currentPage]['subtitle'],
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFF4E8C1),
              minimumSize: Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: _nextPage,
            child: Text(
              _currentPage == pages.length - 1 ? 'Get Started' : 'Get Started',
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pages.length,
        (index) => AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index ? Color(0xFFF4E8C1) : Colors.white24,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
