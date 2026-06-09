import 'package:flutter/material.dart';
import 'package:preschool_math_app/features/counting/screens/level_4/activity_1_page.dart';
import 'package:preschool_math_app/features/shared/screens/complete_screen.dart';

class Level3CompleteScreen extends StatelessWidget {
  const Level3CompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CompleteScreen(
      module: 'counting',
      levelCompleted: 3,
      badgeName: 'count_badge3',
      badgeImage: 'assets/images/count_badge3.png',
      backgroundImage: 'assets/images/counting_background4.png',
      onContinue: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Level4Activity1Page(),
          ),
        );
      },
    );
  }
}
