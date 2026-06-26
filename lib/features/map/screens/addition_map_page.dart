import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../addition/screens/level_1/activity_1_page.dart';
import '../../addition/screens/level_2/activity_1_page.dart';
import '../../addition/screens/level_3/activity_1_page.dart';
import '../../addition/screens/level_4/activity_1_page.dart';
import '../../addition/screens/level_5/activity_1_page.dart';
import '../widgets/level_node.dart';

class AdditionMapPage extends StatefulWidget {
  const AdditionMapPage({super.key, this.showIntroDialog = true});

  final bool showIntroDialog;

  @override
  State<AdditionMapPage> createState() => _AdditionMapPageState();
}

class _AdditionMapPageState extends State<AdditionMapPage> {
  late bool _showIntroDialog = widget.showIntroDialog;

  Future<void> _handleNodeTap(String levelStr, int levelsCompleted) async {
    final int level = int.parse(levelStr);
    final bool isUnlocked = level <= (levelsCompleted + 1);

    if (!isUnlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Level $level is locked! Finish previous levels first.',
          ),
          backgroundColor: const Color(0xFF4A3728),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    Widget? destination;

    if (level == 1) {
      destination = const AdditionLevel1Activity1Page();
    } else if (level == 2) {
      destination = const AdditionLevel2Activity1Page();
    } else if (level == 3) {
      destination = const AdditionLevel3Activity1Page();
    } else if (level == 4) {
      destination = const AdditionLevel4Activity1Page();
    } else if (level == 5) {
      destination = const AdditionLevel5Activity1Page();
    }

    if (destination != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => destination!),
      );

      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: user == null
          ? const Center(child: Text('Error: Not logged in!'))
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF29694A)),
                  );
                }

                int levelsCompleted = 0;

                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() ?? {};
                  final progress = data['progress'] as Map<String, dynamic>?;
                  final additionProgress =
                      progress?['addition'] as Map<String, dynamic>?;
                  final value = additionProgress?['levelsCompleted'];

                  if (value is int) {
                    levelsCompleted = value;
                  }
                }

                return Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/addition_map.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.black,
                            size: 32,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    Positioned(
                      left: size.width * 0.42,
                      top: size.height * 0.89,
                      child: LevelNode(
                        levelNumber: '1',
                        isUnlocked: 1 <= (levelsCompleted + 1),
                        onTap: () => _handleNodeTap('1', levelsCompleted),
                      ),
                    ),
                    Positioned(
                      left: size.width * 0.25,
                      top: size.height * 0.75,
                      child: LevelNode(
                        levelNumber: '2',
                        isUnlocked: 2 <= (levelsCompleted + 1),
                        onTap: () => _handleNodeTap('2', levelsCompleted),
                      ),
                    ),
                    Positioned(
                      left: size.width * 0.45,
                      top: size.height * 0.64,
                      child: LevelNode(
                        levelNumber: '3',
                        isUnlocked: 3 <= (levelsCompleted + 1),
                        onTap: () => _handleNodeTap('3', levelsCompleted),
                      ),
                    ),
                    Positioned(
                      left: size.width * 0.44,
                      top: size.height * 0.48,
                      child: LevelNode(
                        levelNumber: '4',
                        isUnlocked: 4 <= (levelsCompleted + 1),
                        onTap: () => _handleNodeTap('4', levelsCompleted),
                      ),
                    ),
                    Positioned(
                      left: size.width * 0.60,
                      top: size.height * 0.37,
                      child: LevelNode(
                        levelNumber: '5',
                        isUnlocked: 5 <= (levelsCompleted + 1),
                        onTap: () => _handleNodeTap('5', levelsCompleted),
                      ),
                    ),
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Let's add!",
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
                                                  color: const Color(
                                                    0xFFAEAAAA,
                                                  ),
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
