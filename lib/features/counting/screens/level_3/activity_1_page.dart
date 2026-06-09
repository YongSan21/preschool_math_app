import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'activity_2_page.dart';

class Level3Activity1Page extends StatefulWidget {
  const Level3Activity1Page({super.key});

  @override
  State<Level3Activity1Page> createState() => _Level3Activity1PageState();
}

class _Level3Activity1PageState extends State<Level3Activity1Page> {
  late AudioPlayer _audioPlayer;

  int _currentCount = 0;
  final int _totalRabbits = 15;
  final List<int?> _rabbitNumbers = List.filled(15, null);

  bool _isLocked = false;
  int? _bouncingRabbitIndex;

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

  void _onRabbitTapped(int index) async {
    if (_isLocked || _rabbitNumbers[index] != null) return;

    setState(() {
      _isLocked = true;
      _currentCount++;
      _rabbitNumbers[index] = _currentCount;
      _bouncingRabbitIndex = index;
    });

    try {
      await _audioPlayer.play(AssetSource('audio/$_currentCount.mp3'));
      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      setState(() {
        _bouncingRabbitIndex = null;
        _isLocked = false;
      });

      if (_currentCount == _totalRabbits) {
        _handleActivityComplete();
      }
    } catch (e) {
      print('Audio error: $e');
      if (mounted) {
        setState(() => _isLocked = false);
      }
    }
  }

  void _handleActivityComplete() async {
    setState(() => _isLocked = true);

    try {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      await _audioPlayer.play(AssetSource('audio/great_job_counting.mp3'));
      await Future.delayed(const Duration(milliseconds: 3500));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Level3Activity2Page()),
        );
      }
    } catch (e) {
      print('Audio error: $e');
      if (mounted) {
        setState(() => _isLocked = false);
      }
    }
  }

  Widget _buildAnimatedRabbit(int index) {
    final int? assignedNumber = _rabbitNumbers[index];
    final bool isCounted = assignedNumber != null;
    final bool isBouncing = _bouncingRabbitIndex == index;
    final bool useBrownRabbit = index.isEven;

    return GestureDetector(
      onTap: () => _onRabbitTapped(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        height: 112,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedOpacity(
              opacity: isCounted ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Text(
                assignedNumber?.toString() ?? '',
                style: GoogleFonts.quicksand(
                  color: const Color(0xFF4A3728),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              transform:
                  Matrix4.translationValues(0, isBouncing ? -15.0 : 0.0, 0),
              child: Image.asset(
                useBrownRabbit
                    ? 'assets/images/brown_rabbit.png'
                    : 'assets/images/khaki_rabbit.png',
                width: 66,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRabbitRow(List<int> indices) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: indices.map((index) => _buildAnimatedRabbit(index)).toList(),
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
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    _buildRabbitRow([0, 1, 2, 3]),
                    const SizedBox(height: 4),
                    _buildRabbitRow([4, 5, 6, 7]),
                    const SizedBox(height: 4),
                    _buildRabbitRow([8, 9, 10]),
                    const SizedBox(height: 4),
                    _buildRabbitRow([11, 12, 13, 14]),
                    const SizedBox(height: 112),
                  ],
                ),
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
                        'Can you tap the rabbits to count them?',
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
