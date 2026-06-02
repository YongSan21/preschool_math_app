import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CountableRabbit extends StatefulWidget {
  final int? assignedNumber; // Null if not tapped yet
  final VoidCallback onTap;

  const CountableRabbit({
    super.key,
    required this.assignedNumber,
    required this.onTap,
  });

  @override
  State<CountableRabbit> createState() => _CountableRabbitState();
}

class _CountableRabbitState extends State<CountableRabbit> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Setup a quick bounce animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.8), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 0.8, end: 1.0), weight: 50),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.assignedNumber == null) {
      _controller.forward(from: 0.0); // Trigger the bounce
      widget.onTap(); // Tell the parent screen this was tapped
    } else {
      // Optional: Play a tiny error wiggle or just bounce again if they tap an already counted rabbit
      _controller.forward(from: 0.0); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The Number (Maintains its height even when invisible so layout doesn't shift)
          Opacity(
            opacity: widget.assignedNumber != null ? 1.0 : 0.0,
            child: Text(
              widget.assignedNumber?.toString() ?? '1',
              style: GoogleFonts.quicksand(
                color: const Color(0xFF4A3728),
                fontSize: 32,
                fontWeight: FontWeight.w700,
                height: 1.40,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // The Animated Rabbit
          ScaleTransition(
            scale: _scaleAnimation,
            child: Image.asset(
              'assets/images/rabbit.png',
              // Using flexible constraints so they fit nicely next to each other
              width: 70, 
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}