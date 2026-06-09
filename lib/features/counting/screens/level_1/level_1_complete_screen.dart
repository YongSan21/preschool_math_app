import 'package:flutter/material.dart';
import 'package:preschool_math_app/features/shared/screens/complete_screen.dart';
import 'package:preschool_math_app/features/counting/screens/level_2/activity_1_page.dart';

class Level1CompleteScreen extends StatelessWidget {
  const Level1CompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CompleteScreen(
      module: 'counting',
      levelCompleted: 1,
      badgeName: 'count_badge1',
      badgeImage: 'assets/images/count_badge1.png',
      backgroundImage: 'assets/images/counting_background2.png',
      onContinue: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Level2Activity1Page(),
          ),
        );
      },
    );
  }
}