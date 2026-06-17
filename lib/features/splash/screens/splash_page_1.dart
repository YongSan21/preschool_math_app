import 'dart:async';

import 'package:flutter/material.dart';

import 'splash_page_2.dart';

class SplashPage1 extends StatefulWidget {
  const SplashPage1({super.key});

  @override
  State<SplashPage1> createState() => _SplashPage1State();
}

class _SplashPage1State extends State<SplashPage1> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SplashPage2()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCFF1FF),
      body: Center(
        child: Image.asset(
          'assets/images/icon1.png',
          width: 299,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
