import 'package:audioplayers/audioplayers.dart';
import '../../../shared/widgets/activity_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'activity_2_page.dart';

class Level5Activity1Page extends StatefulWidget {
  const Level5Activity1Page({super.key});

  @override
  State<Level5Activity1Page> createState() => _Level5Activity1PageState();
}

class _Level5Activity1PageState extends State<Level5Activity1Page> {
  late AudioPlayer _audioPlayer;

  final int _targetBirds = 5;
  final List<int?> _birdNumbers = List.filled(12, null);

  int _currentCount = 0;
  bool _isLocked = false;

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

  void _onBirdTapped(int index) async {
    if (_isLocked || _birdNumbers[index] != null) return;

    final int tappedNumber = _currentCount + 1;

    setState(() {
      _currentCount = tappedNumber;
      _birdNumbers[index] = tappedNumber;
      if (_currentCount == _targetBirds) {
        _isLocked = true;
      }
    });

    try {
      await _audioPlayer.play(AssetSource('audio/$tappedNumber.mp3'));
      await Future.delayed(const Duration(milliseconds: 800));
    } catch (e) {
      debugPrint('Audio error: $e');
    }

    if (_currentCount == _targetBirds) {
      try {
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;

        await _audioPlayer.play(AssetSource('audio/great_job.mp3'));
        await Future.delayed(const Duration(milliseconds: 1400));
        if (!mounted) return;

        await _audioPlayer.play(
          AssetSource('audio/you_tapped_on_five_birds.mp3'),
        );
        await Future.delayed(const Duration(milliseconds: 3000));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const Level5Activity2Page(),
            ),
          );
        }
      } catch (e) {
        debugPrint('Audio error: $e');
      }
    }
  }

  Widget _buildBird(int index) {
    final int? assignedNumber = _birdNumbers[index];
    final bool isTapped = assignedNumber != null;
    final bool useBlueBird = index % 4 == 1 || index % 4 == 2;

    return GestureDetector(
      onTap: () => _onBirdTapped(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 82,
        height: 130,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedOpacity(
              opacity: isTapped ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: Text(
                assignedNumber?.toString() ?? '',
                style: GoogleFonts.quicksand(
                  color: const Color(0xFF4A3728),
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(height: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              transform: Matrix4.translationValues(
                0,
                isTapped ? -12.0 : 0.0,
                0,
              ),
              child: Image.asset(
                useBlueBird
                    ? 'assets/images/blue_bird.png'
                    : 'assets/images/green_bird.png',
                width: 76,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBirdRow(int startIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return _buildBird(startIndex + index);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9E9FF),
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
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(56, 10, 16, 0),
                child: ActivityProgressBar(currentActivity: 1),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 80),
                  _buildBirdRow(0),
                  const SizedBox(height: 38),
                  _buildBirdRow(4),
                  const SizedBox(height: 38),
                  _buildBirdRow(8),
                  const SizedBox(height: 164),
                ],
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
                        'Can you tap five birds?',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.quicksand(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 2.6,
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
