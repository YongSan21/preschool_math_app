import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../auth/controllers/auth_controller.dart';
import '../../auth/screens/login_page.dart';
import '../../map/screens/addition_map_page.dart';
import '../../map/screens/counting_map_page.dart';
import '../../map/screens/subtraction_map_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const int totalBadges = 15;
  static const int levelsPerModule = 5;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
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
                    child: CircularProgressIndicator(
                      color: Color(0xFF29694A),
                    ),
                  );
                }

                final data = snapshot.data?.data() ?? {};
                final dashboard = _DashboardProgress.fromUserData(data);

                return SafeArea(
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 35, 16, 72),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi, ${dashboard.username}',
                                style: GoogleFonts.quicksand(
                                  color: const Color(0xFF4A3728),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Start your math learning journey here!',
                                style: GoogleFonts.quicksand(
                                  color: const Color(0xFF4A3728),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _ProgressCard(
                                badgesCollected: dashboard.totalBadgeCount,
                                onViewBadges: () => _showComingSoon(
                                  context,
                                  'Badge screen coming soon!',
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Learning Modules',
                                style: GoogleFonts.fredoka(
                                  color: Colors.black,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _ModuleCard(
                                title: 'Counting',
                                progressText:
                                    '${dashboard.countingLevels}/$levelsPerModule',
                                backgroundColor: const Color(0xFFF5DBEF),
                                imagePath: 'assets/images/home_counting.png',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CountingMapPage(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              _ModuleCard(
                                title: 'Addition',
                                progressText:
                                    '${dashboard.additionLevels}/$levelsPerModule',
                                backgroundColor: const Color(0xFFCBF7AD),
                                imagePath: 'assets/images/home_addition.png',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const AdditionMapPage(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              _ModuleCard(
                                title: 'Subtraction',
                                progressText:
                                    '${dashboard.subtractionLevels}/$levelsPerModule',
                                backgroundColor: const Color(0xFFCAEEFF),
                                imagePath:
                                    'assets/images/home_subtraction.png',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SubtractionMapPage(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8, right: 16),
                          child: GestureDetector(
                            onTap: () async {
                              await context.read<AuthController>().logoutUser();

                              if (context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
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
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _BottomNavigationBar(
                            onHomeTap: () {},
                            onBadgesTap: () => _showComingSoon(
                              context,
                              'Badge screen coming soon!',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _showComingSoon(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4A3728),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.badgesCollected,
    required this.onViewBadges,
  });

  final int badgesCollected;
  final VoidCallback onViewBadges;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 154,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF27D),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            top: 32,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/home_badge.png',
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Progress',
                  style: GoogleFonts.quicksand(
                    color: const Color(0xFF1E1E1E),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '$badgesCollected/${HomePage.totalBadges} Badges collected',
                  style: GoogleFonts.quicksand(
                    color: const Color(0xFFA59493),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Keep learning!',
                  style: GoogleFonts.quicksand(
                    color: const Color(0xFF4A3728),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onViewBadges,
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2D06B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      widthFactor: 1,
                      child: Text(
                        'View Badges',
                        style: GoogleFonts.quicksand(
                          color: const Color(0xFF4A3728),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.title,
    required this.progressText,
    required this.backgroundColor,
    required this.imagePath,
    required this.onTap,
  });

  final String title;
  final String progressText;
  final Color backgroundColor;
  final String imagePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 153,
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned.fill(
                top: 39,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.quicksand(
                        color: const Color(0xFF4A3728),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      progressText,
                      style: GoogleFonts.quicksand(
                        color: const Color(0xFFA59493),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavigationBar extends StatelessWidget {
  const _BottomNavigationBar({
    required this.onHomeTap,
    required this.onBadgesTap,
  });

  final VoidCallback onHomeTap;
  final VoidCallback onBadgesTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 244,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          width: 3,
          color: const Color(0xFFD9D9D9),
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavIconButton(
            imagePath: 'assets/images/home_icon.png',
            onTap: onHomeTap,
          ),
          _NavIconButton(
            imagePath: 'assets/images/trophy_icon.png',
            onTap: onBadgesTap,
          ),
        ],
      ),
    );
  }
}

class _NavIconButton extends StatelessWidget {
  const _NavIconButton({
    required this.imagePath,
    required this.onTap,
  });

  final String imagePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 48,
        height: 40,
        child: Center(
          child: Image.asset(
            imagePath,
            width: 30,
            height: 30,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _DashboardProgress {
  const _DashboardProgress({
    required this.username,
    required this.totalBadgeCount,
    required this.countingLevels,
    required this.additionLevels,
    required this.subtractionLevels,
  });

  final String username;
  final int totalBadgeCount;
  final int countingLevels;
  final int additionLevels;
  final int subtractionLevels;

  factory _DashboardProgress.fromUserData(Map<String, dynamic> data) {
    final progress = data['progress'] as Map<String, dynamic>?;
    final counting = progress?['counting'] as Map<String, dynamic>?;
    final addition = progress?['addition'] as Map<String, dynamic>?;
    final subtraction = progress?['subtraction'] as Map<String, dynamic>?;

    final countingBadges = _asList(counting?['badges']);
    final additionBadges = _asList(addition?['badges']);
    final subtractionBadges = _asList(subtraction?['badges']);
    final legacyBadges = _asList(data['badges']);

    final moduleBadgeCount = countingBadges.length +
        additionBadges.length +
        subtractionBadges.length;

    return _DashboardProgress(
      username: (data['username'] as String?)?.trim().isNotEmpty == true
          ? data['username'] as String
          : 'Farmer',
      totalBadgeCount:
          moduleBadgeCount > 0 ? moduleBadgeCount : legacyBadges.length,
      countingLevels: _levelsForModule(
        counting,
        legacyLevels: data['levelsCompleted'],
      ),
      additionLevels: _levelsForModule(addition),
      subtractionLevels: _levelsForModule(subtraction),
    );
  }

  static List<dynamic> _asList(Object? value) {
    return value is List ? value : const [];
  }

  static int _levelsForModule(
    Map<String, dynamic>? module, {
    Object? legacyLevels,
  }) {
    final value = module?['levelsCompleted'] ?? legacyLevels;
    if (value is int) {
      return value.clamp(0, HomePage.levelsPerModule).toInt();
    }
    return 0;
  }
}
