// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_app/view/screens/config.dart';
import 'package:flutter_app/view/screens/splash_screen.dart';
import 'package:flutter_app/view/screens/wifi.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_app/view/screens/sign_in.dart';
import 'package:get/get.dart';
import 'package:flutter_app/view/screens/home_screen.dart';
import 'package:flutter_app/view/screens/welcome.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
