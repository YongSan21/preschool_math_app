import 'package:flutter/material.dart';

class ActivityProgressBar extends StatelessWidget {
  const ActivityProgressBar({
    super.key,
    required this.currentActivity,
    this.totalActivities = 3,
    this.height = 28,
  });

  final int currentActivity;
  final int totalActivities;
  final double height;

  static const Color activeColor = Color(0xFF9BFC92);
  static const Color inactiveColor = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    final safeCurrentActivity = currentActivity.clamp(0, totalActivities);

    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Row(
        children: List.generate(totalActivities * 2 - 1, (index) {
          if (index.isOdd) {
            return const SizedBox(width: 8);
          }

          final segmentIndex = index ~/ 2;

          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: segmentIndex < safeCurrentActivity
                    ? activeColor
                    : inactiveColor,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          );
        }),
      ),
    );
  }
}
