import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/bottom_nav_screen.dart';
import 'package:leadmanagementsystem/main.dart';
import 'package:leadmanagementsystem/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  splashHandler() {
    if (loginStorage.getUserId() != null) {
      Timer(const Duration(seconds: 2), () {
        // Get.off(const AdminHomePage());
        Get.off(const BottomNavScreen());
      });
    } else {
      Timer(const Duration(seconds: 2), () {
        Get.off(const LoginScreen());
      });
    }
  }

  @override
  void initState() {
    super.initState();
    splashHandler();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'images/main-logo.png',
              height: 130,
              width: 130,
            ),
          ),
        ));
  }
}
