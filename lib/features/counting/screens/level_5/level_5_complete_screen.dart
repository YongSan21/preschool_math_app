import 'package:flutter/material.dart';
import 'package:preschool_math_app/features/shared/screens/complete_screen.dart';

class Level5CompleteScreen extends StatelessWidget {
  const Level5CompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CompleteScreen(
      module: 'counting',
      levelCompleted: 5,
      badgeName: 'count_badge5',
      badgeImage: 'assets/images/count_badge5.png',
      backgroundColor: Color(0xFFFEFACE),
      showContinueButton: false,
    );
  }
}
