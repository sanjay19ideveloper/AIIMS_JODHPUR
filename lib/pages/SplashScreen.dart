import 'package:aiims_heartcare/pages/LoginPage.dart';
import 'package:aiims_heartcare/pages/Preboarding.dart';
import 'package:aiims_heartcare/pages/HomePage.dart';
import 'package:aiims_heartcare/utils/log.dart';
import 'package:aiims_heartcare/utils/user_sessions.dart'; 
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _initializeAnimation();
  }

  // Future<void> _checkLoginStatus() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  //   });
  // }
  Future<void> _checkLoginStatus() async {
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final token = UserSession.userToken;
  Log.v("isLoggedIn: $isLoggedIn, token: $token");

  await Future.delayed(Duration(seconds: 1));

  if (isLoggedIn && token != null && token.isNotEmpty) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HeartCareDashboard()),
    );
  } else {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
}

  void _initializeAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _animation = CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeInOut,
    );

    _controller!.forward();

    Timer(Duration(seconds: 3), () {
      _navigateToNextScreen();
    });
  }

  void _navigateToNextScreen() {
    print('chekkkkkkk${ _isLoggedIn}');
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 800),
        pageBuilder: (context, animation, secondaryAnimation) =>
            _isLoggedIn ? Scaffold(body:  HomePage()) : PreboardingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var curve = Curves.easeInOut.transform(animation.value);
          return Opacity(
            opacity: curve,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff16423C),
      body: Center(
        child: ScaleTransition(
          scale: _animation!,
          child: Image.asset(
            'assets/images/logo.png',
            width: 150,
            height: 150,
          ),
        ),
      ),
    );
  }
}