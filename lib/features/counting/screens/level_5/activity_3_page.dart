import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'level_5_complete_screen.dart';

class Level5Activity3Page extends StatefulWidget {
  const Level5Activity3Page({super.key});

  @override
  State<Level5Activity3Page> createState() => _Level5Activity3PageState();
}

class _Level5Activity3PageState extends State<Level5Activity3Page> {
  late AudioPlayer _audioPlayer;

  final int _targetNumber = 3;
  bool _isLocked = false;
  int? _selectedNumber;

  final List<_BubbleItem> _bubbles = const [
    _BubbleItem(number: 9, alignment: Alignment(0.0, -0.72)),
    _BubbleItem(number: 5, alignment: Alignment(-0.82, -0.52)),
    _BubbleItem(number: 16, alignment: Alignment(0.82, -0.50)),
    _BubbleItem(number: 10, alignment: Alignment(0.06, -0.26)),
    _BubbleItem(number: 4, alignment: Alignment(-0.78, -0.10)),
    _BubbleItem(number: 3, alignment: Alignment(0.88, -0.10)),
    _BubbleItem(number: 1, alignment: Alignment(-0.30, 0.28)),
    _BubbleItem(number: 11, alignment: Alignment(0.68, 0.36)),
    _BubbleItem(number: 19, alignment: Alignment(-0.82, 0.62)),
    _BubbleItem(number: 12, alignment: Alignment(0.34, 0.66)),
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _onBubbleTapped(int number) async {
    if (_isLocked) return;

    if (number == _targetNumber) {
      setState(() {
        _isLocked = true;
        _selectedNumber = number;
      });

      try {
        await _audioPlayer.play(AssetSource('audio/great_job.mp3'));
        await Future.delayed(const Duration(milliseconds: 1500));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Level5CompleteScreen()),
          );
        }
      } catch (e) {
        print('Audio error: $e');
      }
    } else {
      try {
        await _audioPlayer.play(AssetSource('audio/try_again.mp3'));
      } catch (e) {
        print('Audio error: $e');
      }
    }
  }

  Widget _buildBubble(_BubbleItem bubble) {
    final bool isSelected = _selectedNumber == bubble.number;

    return Align(
      alignment: bubble.alignment,
      child: GestureDetector(
        onTap: () => _onBubbleTapped(bubble.number),
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: isSelected ? 1.12 : 1.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/images/bubble.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
                Text(
                  bubble.number.toString(),
                  style: GoogleFonts.inter(
                    color: const Color(0xFF4A3728),
                    fontSize: 36,
                    fontWeight: FontWeight.w400,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFACE),
      body: Stack(
        children: [
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.black,
                  size: 32,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 170),
              child: Stack(
                children: _bubbles.map(_buildBubble).toList(),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 24.0,
                  left: 16.0,
                  right: 16.0,
                ),
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/cat_dialog.png'),
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: 28.0,
                        left: 20.0,
                        right: 20.0,
                      ),
                      child: Text(
                        'Tap the bubble with the number three.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.quicksand(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BubbleItem {
  const _BubbleItem({
    required this.number,
    required this.alignment,
  });

  final int number;
  final Alignment alignment;
}
