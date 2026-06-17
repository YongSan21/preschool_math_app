import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../auth/screens/login_page.dart';

class SplashPage2 extends StatelessWidget {
  const SplashPage2({super.key});

  void _goToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFCFF1FF),
      body: Stack(
        children: [
          Positioned(
            left: -size.width * 0.22,
            top: size.height * 0.27,
            child: Container(
              width: size.width * 1.44,
              height: size.height * 0.86,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.10),
                  Image.asset(
                    'assets/images/icon2.png',
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 80),
                  Text(
                    "Let's Learn Math!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.quicksand(
                      color: Colors.black,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Practice counting, addition and subtraction through fun activities on the farm!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.quicksand(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 44),
                  GestureDetector(
                    onTap: () => _goToLogin(context),
                    child: Container(
                      width: double.infinity,
                      height: 53,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2D06B),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          'GET STARTED',
                          style: GoogleFonts.quicksand(
                            color: const Color(0xFF4A3728),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
