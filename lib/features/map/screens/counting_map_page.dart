import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added Firestore
import 'package:firebase_auth/firebase_auth.dart';     // Added Auth

import '../widgets/level_node.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/screens/login_page.dart';
import '../../counting/screens/level_1/activity_1_page.dart';
import '../../counting/screens/level_2/activity_1_page.dart';
import '../../counting/screens/level_3/activity_1_page.dart';
import '../../counting/screens/level_4/activity_1_page.dart';
import '../../counting/screens/level_5/activity_1_page.dart';

class CountingMapPage extends StatefulWidget {
  const CountingMapPage({super.key});

  @override
  State<CountingMapPage> createState() => _CountingMapPageState();
}

class _CountingMapPageState extends State<CountingMapPage> {
  // Controls whether the intro dialog is visible
  bool _showIntroDialog = true;

  // Added levelsCompleted as a required parameter to determine routing
  void _handleNodeTap(String levelStr, int levelsCompleted) {
    int level = int.parse(levelStr);
    bool isUnlocked = level <= (levelsCompleted + 1);

    if (isUnlocked) {
      if (level == 1) {
        // Navigate to Activity 1
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Activity1Page()),
        );
      } else if (level == 2) {
        // <-- NEW: Navigate to Level 2!
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Level2Activity1Page()),
        );
      } else if (level == 3) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Level3Activity1Page()),
        );
      } else if (level == 4) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Level4Activity1Page()),
        );
      } else if (level == 5) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Level5Activity1Page()),
        );
      } else {
        print("Navigate to Level $level!");
      }
    } else {
      // Show locked message
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
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      // Ensure the user is logged in before rendering the map
      body: user == null
          ? const Center(child: Text("Error: Not logged in!"))
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
              builder: (context, snapshot) {
                // Show a loading spinner while fetching player data
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF29694A)));
                }

                // Safely extract levelsCompleted (defaults to 0 for new players)
                int levelsCompleted = 0;

                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;

                  final progress = data['progress'] as Map<String, dynamic>?;
                  final countingProgress =
                      progress?['counting'] as Map<String, dynamic>?;

                  levelsCompleted =
                      countingProgress?['levelsCompleted'] ??
                      data['levelsCompleted'] ??
                      0;
                }

                return Stack(
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
                                  (route) => false,
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
                                color: Color(0xFF4A3728),
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
                      child: LevelNode(
                        levelNumber: '1', 
                        isUnlocked: 1 <= (levelsCompleted + 1), 
                        onTap: () => _handleNodeTap('1', levelsCompleted),
                      ),
                    ),
                    Positioned(
                      left: size.width * 0.52,
                      top: size.height * 0.72,
                      child: LevelNode(
                        levelNumber: '2', 
                        isUnlocked: 2 <= (levelsCompleted + 1),
                        onTap: () => _handleNodeTap('2', levelsCompleted),
                      ),
                    ),
                    Positioned(
                      left: size.width * 0.29,
                      top: size.height * 0.57,
                      child: LevelNode(
                        levelNumber: '3', 
                        isUnlocked: 3 <= (levelsCompleted + 1),
                        onTap: () => _handleNodeTap('3', levelsCompleted),
                      ),
                    ),
                    Positioned(
                      left: size.width * 0.61,
                      top: size.height * 0.45,
                      child: LevelNode(
                        levelNumber: '4', 
                        isUnlocked: 4 <= (levelsCompleted + 1),
                        onTap: () => _handleNodeTap('4', levelsCompleted),
                      ),
                    ),
                    Positioned(
                      left: size.width * 0.33,
                      top: size.height * 0.33,
                      child: LevelNode(
                        levelNumber: '5', 
                        isUnlocked: 5 <= (levelsCompleted + 1),
                        onTap: () => _handleNodeTap('5', levelsCompleted),
                      ),
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
                );
              },
            ),
    );
  }
}
