import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LevelNode extends StatelessWidget {
  final String levelNumber;
  final VoidCallback onTap;

  const LevelNode({
    super.key,
    required this.levelNumber,
    required this.onTap,
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
            // 1. Bottom Shadow (Dark Yellow)
            Positioned(
              top: 7,
              child: Container(
                width: 71,
                height: 58,
                decoration: const ShapeDecoration(
                  color: Color(0xFFE6A000), 
                  shape: OvalBorder(),
                ),
              ),
            ),
            // 2. Main Coin Body (Gold)
            Positioned(
              top: 0,
              child: Container(
                width: 71,
                height: 58,
                decoration: const ShapeDecoration(
                  color: Color(0xFFFFC800), 
                  shape: OvalBorder(),
                ),
              ),
            ),
            // 3. Inner Highlight (Translucent White instead of solid gray)
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
            // 4. Level Number
            Positioned(
              top: 9,
              child: Text(
                levelNumber,
                style: GoogleFonts.quicksand(
                  color: const Color(0xFF4A3728),
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  height: 1.40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}