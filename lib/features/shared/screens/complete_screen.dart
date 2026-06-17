import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:preschool_math_app/features/auth/services/auth_service.dart';

class CompleteScreen extends StatelessWidget {
  const CompleteScreen({
    super.key,
    required this.module,
    required this.levelCompleted,
    required this.badgeName,
    required this.badgeImage,
    this.backgroundImage,
    this.backgroundColor,
    this.showContinueButton = true,
    this.onContinue,
  });

  final String module;
  final int levelCompleted;
  final String badgeName;
  final String badgeImage;
  final String? backgroundImage;
  final Color? backgroundColor;
  final bool showContinueButton;
  final VoidCallback? onContinue;

  Future<void> _saveProgress() async {
    await AuthService().saveBadgeAndProgress(
      module,
      badgeName,
      levelCompleted,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: backgroundColor,
              image: backgroundImage == null
                  ? null
                  : DecorationImage(
                      image: AssetImage(backgroundImage!),
                      fit: BoxFit.cover,
                    ),
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 32.0,
                  horizontal: 24.0,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1FFE2),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Congrats!',
                      style: GoogleFonts.quicksand(
                        color: const Color(0xFF4A3728),
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDFF7B3),
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
                          Image.asset(
                            badgeImage,
                            width: 130,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          text: 'Back to Map',
                          backgroundColor: const Color(0xFFFFB347),
                          onTap: () async {
                            await _saveProgress();

                            if (context.mounted) {
                              Navigator.popUntil(
                                context,
                                (route) => route.isFirst,
                              );
                            }
                          },
                        ),
                        if (showContinueButton)
                          _buildActionButton(
                            text: 'Continue',
                            backgroundColor: const Color(0xFFF2D06B),
                            onTap: () async {
                              await _saveProgress();

                              if (context.mounted) {
                                onContinue?.call();
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

  Widget _buildActionButton({
    required String text,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 14.0,
        ),
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
