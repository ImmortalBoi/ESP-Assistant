import 'package:flutter/material.dart';
import 'package:flutter_app/colors/app_colors.dart';
import 'package:flutter_app/view/screens/welcome.dart';
import 'package:lottie/lottie.dart';
import 'dart:async'; // Import the async package for Timer

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 6), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Welcome()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: SizedBox(
          width: 250, // Specify the width of the animation
          height: 250, // Specify the height of the animation
          child: Lottie.asset(
              'assets/animations/robot.json'), // Replace 'your_animation.json' with your actual Lottie JSON file name
        ),
      ),
    );
  }
}
