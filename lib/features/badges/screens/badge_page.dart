import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BadgePage extends StatelessWidget {
  const BadgePage({super.key});

  static const int totalBadges = 15;

  static const List<_BadgeModule> _modules = [
    _BadgeModule(
      title: 'Counting Badges',
      moduleKey: 'counting',
      badgePrefix: 'count_badge',
    ),
    _BadgeModule(
      title: 'Addition Badges',
      moduleKey: 'addition',
      badgePrefix: 'add_badge',
    ),
    _BadgeModule(
      title: 'Subtraction Badges',
      moduleKey: 'subtraction',
      badgePrefix: 'subtract_badge',
    ),
  ];

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
                    child: CircularProgressIndicator(color: Color(0xFF29694A)),
                  );
                }

                final data = snapshot.data?.data() ?? {};
                final progress = _BadgeProgress.fromUserData(data);

                return SafeArea(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(22, 28, 22, 84),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _BadgeHeader(),
                            const SizedBox(height: 22),
                            _ProgressPanel(
                              collectedCount: progress.totalCollected,
                            ),
                            const SizedBox(height: 28),
                            for (final module in _modules) ...[
                              _BadgeSection(
                                module: module,
                                collectedBadges: progress.badgesFor(
                                  module.moduleKey,
                                ),
                              ),
                              const SizedBox(height: 34),
                            ],
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: double.infinity,
                          height: 72,
                          color: Colors.white,
                          child: Center(
                            child: _BottomNavigationBar(
                              onHomeTap: () => Navigator.maybePop(context),
                              onBadgesTap: () {},
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
}

class _BadgeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/images/trophy.png',
          width: 72,
          height: 72,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Badges',
                style: GoogleFonts.quicksand(
                  color: const Color(0xFF4A3728),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Collect badges by completing levels!',
                style: GoogleFonts.quicksand(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressPanel extends StatelessWidget {
  const _ProgressPanel({required this.collectedCount});

  final int collectedCount;

  @override
  Widget build(BuildContext context) {
    final progress = collectedCount / BadgePage.totalBadges;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
      decoration: BoxDecoration(
        color: const Color(0xFFDCEBFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My current badges',
            style: GoogleFonts.quicksand(
              color: const Color(0xFF4A3728),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$collectedCount/${BadgePage.totalBadges}',
            style: GoogleFonts.quicksand(
              color: const Color(0xFF8F8F8F),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 10,
              backgroundColor: const Color(0xFFFFF8A8),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFF7C928),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeSection extends StatelessWidget {
  const _BadgeSection({required this.module, required this.collectedBadges});

  final _BadgeModule module;
  final Set<String> collectedBadges;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          module.title,
          style: GoogleFonts.quicksand(
            color: const Color(0xFF7A6A5C),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 20,
          children: List.generate(5, (index) {
            final level = index + 1;
            final badgeName = '${module.badgePrefix}$level';
            final isCollected = collectedBadges.contains(badgeName);

            return _BadgeTile(
              badgeName: badgeName,
              level: level,
              isCollected: isCollected,
            );
          }),
        ),
      ],
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({
    required this.badgeName,
    required this.level,
    required this.isCollected,
  });

  final String badgeName;
  final int level;
  final bool isCollected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 94,
      child: Column(
        children: [
          SizedBox(
            width: 88,
            height: 88,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isCollected)
                  Image.asset(
                    'assets/images/$badgeName.png',
                    width: 88,
                    height: 88,
                    fit: BoxFit.contain,
                  )
                else
                  ColorFiltered(
                    colorFilter: const ColorFilter.matrix(<double>[
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0,
                      0,
                      0,
                      1,
                      0,
                    ]),
                    child: Image.asset(
                      'assets/images/$badgeName.png',
                      width: 88,
                      height: 88,
                      fit: BoxFit.contain,
                    ),
                  ),
                if (!isCollected)
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.38),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      color: Color(0xFF6E6E6E),
                      size: 28,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Level $level',
            style: GoogleFonts.quicksand(
              color: const Color(0xFF4A3728),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
        border: Border.all(width: 3, color: const Color(0xFFD9D9D9)),
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
  const _NavIconButton({required this.imagePath, required this.onTap});

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

class _BadgeModule {
  const _BadgeModule({
    required this.title,
    required this.moduleKey,
    required this.badgePrefix,
  });

  final String title;
  final String moduleKey;
  final String badgePrefix;
}

class _BadgeProgress {
  const _BadgeProgress({
    required this.countingBadges,
    required this.additionBadges,
    required this.subtractionBadges,
  });

  final Set<String> countingBadges;
  final Set<String> additionBadges;
  final Set<String> subtractionBadges;

  int get totalCollected =>
      countingBadges.length + additionBadges.length + subtractionBadges.length;

  Set<String> badgesFor(String moduleKey) {
    switch (moduleKey) {
      case 'counting':
        return countingBadges;
      case 'addition':
        return additionBadges;
      case 'subtraction':
        return subtractionBadges;
      default:
        return const {};
    }
  }

  factory _BadgeProgress.fromUserData(Map<String, dynamic> data) {
    final progress = data['progress'] as Map<String, dynamic>?;
    final counting = progress?['counting'] as Map<String, dynamic>?;
    final addition = progress?['addition'] as Map<String, dynamic>?;
    final subtraction = progress?['subtraction'] as Map<String, dynamic>?;

    final countingBadges = _asBadgeSet(counting?['badges']);
    final legacyBadges = _asBadgeSet(data['badges']);

    return _BadgeProgress(
      countingBadges: countingBadges.isNotEmpty ? countingBadges : legacyBadges,
      additionBadges: _asBadgeSet(addition?['badges']),
      subtractionBadges: _asBadgeSet(subtraction?['badges']),
    );
  }

  static Set<String> _asBadgeSet(Object? value) {
    if (value is! List) return {};
    return value.whereType<String>().toSet();
  }
}
