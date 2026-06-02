import 'package:flutter/material.dart';

class SelectableRabbitGroup extends StatefulWidget {
  final int rabbitCount;
  final VoidCallback onTap;

  const SelectableRabbitGroup({
    super.key,
    required this.rabbitCount,
    required this.onTap,
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
          width: 320,
          height: 190, // The total invisible box holding this group
          child: Stack(
            alignment: Alignment.center, // <-- This magically centers everything!
            children: [
              // 1. BOTTOM LAYER: The Rug (Centered automatically)
              Image.asset(
                'assets/images/circle.png',
                width: 320,
                height: 190, // A nice thick oval (Don't go too high, or it becomes a circle!)
                fit: BoxFit.fill,
              ),
              
              // 2. TOP LAYER: The Rabbits
              // We use Padding to just slightly nudge the rabbits up from the exact center
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0), 
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.rabbitCount, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
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