import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../widgets/level_node.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/screens/login_page.dart';
import '../../counting/screens/level_1/activity_1_page.dart';

class CountingMapPage extends StatefulWidget {
  const CountingMapPage({super.key});

  @override
  State<CountingMapPage> createState() => _CountingMapPageState();
}

class _CountingMapPageState extends State<CountingMapPage> {
  // Controls whether the intro dialog is visible
  bool _showIntroDialog = true;

  void _handleNodeTap(String level) {
    if (level == '1') {
      // Navigate to the activity we just built!
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Activity1Page()),
      );
    } else {
      // Show a temporary message for nodes 2, 3, 4, and 5
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Level $level is locked! Finish previous levels first.'),
          backgroundColor: const Color(0xFF4A3728),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Gets the size of the current screen to calculate percentages
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ---------------------------------------------------------
          // 1. BACKGROUND LAYER
          // ---------------------------------------------------------
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/counting_map.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ---------------------------------------------------------
          // 2. LOGOUT BUTTON (TOP RIGHT)
          // ---------------------------------------------------------
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, right: 16.0),
                child: GestureDetector(
                  onTap: () async {
                    // 1. Tell Firebase to log the user out
                    await context.read<AuthController>().logoutUser();
                    
                    // 2. Kick them back to Login and destroy the map history
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                        (route) => false, // This forces the memory clear
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: Color(0xFF4A3728), // Matches your Figma text color
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ---------------------------------------------------------
          // 3. INTERACTIVE NODES (Calculated by % of screen)
          // ---------------------------------------------------------
          Positioned(
            left: size.width * 0.44, 
            top: size.height * 0.87, 
            child: LevelNode(levelNumber: '1', onTap: () => _handleNodeTap('1')),
          ),
          Positioned(
            left: size.width * 0.52,
            top: size.height * 0.72,
            child: LevelNode(levelNumber: '2', onTap: () => _handleNodeTap('2')),
          ),
          Positioned(
            left: size.width * 0.29,
            top: size.height * 0.57,
            child: LevelNode(levelNumber: '3', onTap: () => _handleNodeTap('3')),
          ),
          Positioned(
            left: size.width * 0.61,
            top: size.height * 0.45,
            child: LevelNode(levelNumber: '4', onTap: () => _handleNodeTap('4')),
          ),
          Positioned(
            left: size.width * 0.33,
            top: size.height * 0.33,
            child: LevelNode(levelNumber: '5', onTap: () => _handleNodeTap('5')),
          ),

          // ---------------------------------------------------------
          // 4. INTRODUCTORY CHICKEN DIALOG OVERLAY
          // ---------------------------------------------------------
          if (_showIntroDialog)
            GestureDetector(
              onTap: () {
                setState(() {
                  _showIntroDialog = false;
                });
              },
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.transparent, 
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Positioned(
                      bottom: 40,
                      child: Container(
                        width: size.width * 0.90, 
                        height: 140,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/chicken.png',
                              height: 100,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Let’s count!',
                                    style: GoogleFonts.quicksand(
                                      color: const Color(0xFF4A3728),
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      'Tap anywhere to continue',
                                      style: GoogleFonts.quicksand(
                                        color: const Color(0xFFAEAAAA),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}