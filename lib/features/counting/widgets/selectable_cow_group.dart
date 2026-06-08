import 'package:flutter/material.dart';

class SelectableCowGroup extends StatelessWidget {
  final int cowCount;
  final VoidCallback onTap;
  final int? activeCowIndex;

  const SelectableCowGroup({
    super.key,
    required this.cowCount,
    required this.onTap,
    this.activeCowIndex,
  });

  @override
  Widget build(BuildContext context) {
    // Calculates how many cows go in the top row (max 5) and bottom row
    final int topRowCount = cowCount > 5 ? 5 : cowCount;
    final int bottomRowCount = cowCount > 5 ? cowCount - 5 : 0;

    // 1. Wrap the entire tap area in a ClipOval!
    return ClipOval(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 335,
          height: 270,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/circle.png'), 
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- ROW 1 (Up to 5 Cows) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(topRowCount, (index) {
                  return _buildPaddedCow(index);
                }),
              ),
              
              // --- ROW 2 (Remaining Cows) ---
              if (bottomRowCount > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(bottomRowCount, (index) {
                    // Add 5 to the index so it maps correctly to the global count (5, 6, 7...)
                    return _buildPaddedCow(index + 5);
                  }),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to handle the bouncy animation for each individual cow
  Widget _buildPaddedCow(int globalIndex) {
    final bool isBouncing = activeCowIndex == globalIndex;

    return SizedBox(
      width: 42,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, isBouncing ? -15.0 : 0.0, 0),
        child: Image.asset(
          'assets/images/cow.png',
          width: 70,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}