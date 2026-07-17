import 'package:audioplayers/audioplayers.dart';
import '../../../shared/widgets/activity_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'activity_2_page.dart';

class Level4Activity1Page extends StatefulWidget {
  const Level4Activity1Page({super.key});

  @override
  State<Level4Activity1Page> createState() => _Level4Activity1PageState();
}

class _Level4Activity1PageState extends State<Level4Activity1Page> {
  late AudioPlayer _audioPlayer;

  int _currentCount = 0;
  final int _totalSheep = 20;
  final List<int?> _sheepNumbers = List.filled(20, null);

  bool _isLocked = false;
  int? _bouncingSheepIndex;

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

  void _onSheepTapped(int index) async {
    if (_isLocked || _sheepNumbers[index] != null) return;

    setState(() {
      _isLocked = true;
      _currentCount++;
      _sheepNumbers[index] = _currentCount;
      _bouncingSheepIndex = index;
    });

    try {
      await _audioPlayer.play(AssetSource('audio/$_currentCount.mp3'));
      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      setState(() {
        _bouncingSheepIndex = null;
        _isLocked = false;
      });

      if (_currentCount == _totalSheep) {
        _handleActivityComplete();
      }
    } catch (e) {
      debugPrint('Audio error: $e');
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
          MaterialPageRoute(builder: (context) => const Level4Activity2Page()),
        );
      }
    } catch (e) {
      debugPrint('Audio error: $e');
      if (mounted) {
        setState(() => _isLocked = false);
      }
    }
  }

  Widget _buildAnimatedSheep(int index) {
    final int? assignedNumber = _sheepNumbers[index];
    final bool isCounted = assignedNumber != null;
    final bool isBouncing = _bouncingSheepIndex == index;

    return GestureDetector(
      onTap: () => _onSheepTapped(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 68,
        height: 100,
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
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              transform: Matrix4.translationValues(
                0,
                isBouncing ? -15.0 : 0.0,
                0,
              ),
              child: Image.asset(
                'assets/images/sheep.png',
                width: 64,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheepRow(int startIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return _buildAnimatedSheep(startIndex + index);
      }),
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
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/counting_background5.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    _buildSheepRow(0),
                    const SizedBox(height: 10),
                    _buildSheepRow(5),
                    const SizedBox(height: 10),
                    _buildSheepRow(10),
                    const SizedBox(height: 10),
                    _buildSheepRow(15),
                    const SizedBox(height: 176),
                  ],
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: Align(
              alignment: const Alignment(0, 0.55),
              child: Image.asset(
                'assets/images/fence.png',
                width: double.infinity,
                height: 90,
                fit: BoxFit.fill,
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
                        'Can you tap the sheep to count them?',
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
