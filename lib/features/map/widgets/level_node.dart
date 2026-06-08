import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LevelNode extends StatelessWidget {
  final String levelNumber;
  final VoidCallback onTap;
  final bool isUnlocked; // <-- NEW: Required to know if we show Yellow or Grey

  const LevelNode({
    super.key,
    required this.levelNumber,
    required this.onTap,
    required this.isUnlocked, // <-- Added to constructor
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      // Adds a playful bounce effect when pressed
      child: SizedBox(
        width: 71,
        height: 65,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Bottom Shadow 
            Positioned(
              top: 7,
              child: Container(
                width: 71,
                height: 58,
                decoration: ShapeDecoration(
                  // Dark Yellow if unlocked, Dark Grey if locked
                  color: isUnlocked ? const Color(0xFFE6A000) : Colors.grey.shade500, 
                  shape: const OvalBorder(),
                ),
              ),
            ),
            // 2. Main Coin Body 
            Positioned(
              top: 0,
              child: Container(
                width: 71,
                height: 58,
                decoration: ShapeDecoration(
                  // Gold if unlocked, Light Grey if locked
                  color: isUnlocked ? const Color(0xFFFFC800) : Colors.grey.shade300, 
                  shape: const OvalBorder(),
                ),
              ),
            ),
            // 3. Inner Highlight (Translucent White)
            Positioned(
              top: 5,
              child: Container(
                width: 58,
                height: 48,
                decoration: ShapeDecoration(
                  color: Colors.white.withOpacity(0.2), 
                  shape: const OvalBorder(),
                ),
              ),
            ),
            // 4. Level Number OR Lock Icon
            Positioned(
              top: isUnlocked ? 9 : 14, // Slightly adjust the top margin to center the lock icon
              child: isUnlocked
                  ? Text(
                      levelNumber,
                      style: GoogleFonts.quicksand(
                        color: const Color(0xFF4A3728),
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        height: 1.40,
                      ),
                    )
                  : const Icon(
                      Icons.lock_rounded,
                      color: Color(0xFF4A3728), // Keeping the brown color to match the aesthetic
                      size: 28,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}