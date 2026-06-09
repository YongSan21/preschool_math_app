import 'package:flutter/material.dart';
import 'package:preschool_math_app/features/counting/screens/level_3/activity_1_page.dart';
import 'package:preschool_math_app/features/shared/screens/complete_screen.dart';

class Level2CompleteScreen extends StatelessWidget {
  const Level2CompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CompleteScreen(
      module: 'counting',
      levelCompleted: 2,
      badgeName: 'count_badge2',
      badgeImage: 'assets/images/count_badge2.png',
      backgroundImage: 'assets/images/counting_background3.png',
      onContinue: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Level3Activity1Page(),
          ),
        );
      },
    );
  }
}
