import 'package:flutter/material.dart';
import 'package:preschool_math_app/features/shared/screens/complete_screen.dart';

class Level4CompleteScreen extends StatelessWidget {
  const Level4CompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CompleteScreen(
      module: 'counting',
      levelCompleted: 4,
      badgeName: 'count_badge4',
      badgeImage: 'assets/images/count_badge4.png',
      backgroundImage: 'assets/images/counting_background2.png',
      onContinue: () {
        print('Navigate to Level 5!');
      },
    );
  }
}
