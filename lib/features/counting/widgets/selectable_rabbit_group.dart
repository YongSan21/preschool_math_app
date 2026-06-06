import 'package:flutter/material.dart';

class SelectableRabbitGroup extends StatefulWidget {
  final int rabbitCount;
  final VoidCallback onTap;
  final int? activeRabbitIndex; // Tells the widget which rabbit is being counted

  const SelectableRabbitGroup({
    super.key,
    required this.rabbitCount,
    required this.onTap,
    this.activeRabbitIndex, 
  });

  @override
  State<SelectableRabbitGroup> createState() => _SelectableRabbitGroupState();
}

class _SelectableRabbitGroupState extends State<SelectableRabbitGroup> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Setup the bounce animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.9), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 0.9, end: 1.0), weight: 50),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0.0); // Trigger bounce
    widget.onTap(); // Tell the screen which group was tapped
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: 320,  // <-- Restored your perfect width
          height: 190, // <-- Restored your perfect height
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. BOTTOM LAYER: The Rug
              Image.asset(
                'assets/images/circle.png',
                width: 320,  // <-- Restored your perfect width
                height: 190, // <-- Restored your perfect height
                fit: BoxFit.fill,
              ),
              
              // 2. TOP LAYER: The Rabbits
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0), // <-- Restored your exact bottom padding
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.rabbitCount, (index) {
                    
                    // NEW: Check if this specific rabbit is the one being counted!
                    final isCountingMe = widget.activeRabbitIndex == index;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      // If it is counting this rabbit, push it UP by 20 pixels. Otherwise, stay at 0.
                      transform: Matrix4.translationValues(0, isCountingMe ? -20.0 : 0.0, 0),
                      padding: const EdgeInsets.symmetric(horizontal: 8.0), // <-- Restored your exact horizontal spacing
                      child: Image.asset(
                        'assets/images/rabbit.png',
                        width: 70,
                        fit: BoxFit.contain,
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}