import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:preschool_math_app/features/auth/services/auth_service.dart';

class Level1CompleteScreen extends StatelessWidget {
  const Level1CompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ---------------------------------------------------------
          // 1. BACKGROUND LAYER
          // ---------------------------------------------------------
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/counting_background2.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ---------------------------------------------------------
          // 2. MAIN CONGRATS CARD
          // ---------------------------------------------------------
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1FFE2), // Light Green Card
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Shrinks the column to fit the content
                  children: [
                    // --- Title ---
                    Text(
                      'Congrats!',
                      style: GoogleFonts.quicksand(
                        color: const Color(0xFF4A3728),
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // --- Inner Badge Container ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDFF7B3), // Darker Green Inner Box
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Earn Badge',
                            style: GoogleFonts.quicksand(
                              color: const Color(0xFF4A3728),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // The Badge Image
                          Image.asset(
                            'assets/images/count_badge1.png',
                            width: 130, 
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // --- Action Buttons ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          text: 'Back to Map',
                          backgroundColor: const Color(0xFFFFB347), 
                          onTap: () async {
                            // 1. Save the badge and mark Level 1 as completed
                            await AuthService().saveBadgeAndProgress('count_badge1', 1);
                            
                            // 2. Navigate back to the map
                            if (context.mounted) {
                              Navigator.popUntil(context, (route) => route.isFirst);
                            }
                          },
                        ),
                        _buildActionButton(
                          text: 'Continue',
                          backgroundColor: const Color(0xFFF2D06B), 
                          onTap: () async {
                            // 1. Save the badge and mark Level 1 as completed
                            await AuthService().saveBadgeAndProgress('count_badge1', 1);
                            
                            // 2. Navigate to Level 2
                            if (context.mounted) {
                              print("Navigate to Level 2!");
                              // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Level2Screen()));
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // HELPER METHOD: Builds consistent, responsive buttons
  // ---------------------------------------------------------
  Widget _buildActionButton({
    required String text,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 3),
              blurRadius: 2,
            ),
          ],
        ),
        child: Text(
          text,
          style: GoogleFonts.quicksand(
            color: const Color(0xFF4A3728),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}