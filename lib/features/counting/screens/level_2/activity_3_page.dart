import 'package:audioplayers/audioplayers.dart';
import '../../../shared/widgets/activity_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'level_2_complete_screen.dart';

class Level2Activity3Page extends StatefulWidget {
  const Level2Activity3Page({super.key});

  @override
  State<Level2Activity3Page> createState() => _Level2Activity3PageState();
}

class _Level2Activity3PageState extends State<Level2Activity3Page> {
  late AudioPlayer _audioPlayer;

  final int _targetNumber = 10;
  final int _wrongNumber = 6;

  bool _isLocked = false;
  bool _isGreyedOut = false;
  int? _currentlyCountingIndex;

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

  void _onNumberTapped(int selectedNumber) async {
    if (_isLocked) return;

    try {
      if (selectedNumber == _targetNumber) {
        setState(() {
          _isLocked = true;
          _isGreyedOut = true;
        });

        await _audioPlayer.play(AssetSource('audio/great_job.mp3'));
        await Future.delayed(const Duration(milliseconds: 1500));
        if (!mounted) return;

        for (int i = 0; i < _targetNumber; i++) {
          setState(() => _currentlyCountingIndex = i);

          await _audioPlayer.play(AssetSource('audio/${i + 1}.mp3'));
          await Future.delayed(const Duration(milliseconds: 800));
          if (!mounted) return;
        }

        setState(() => _currentlyCountingIndex = null);
        await _audioPlayer.play(
          AssetSource('audio/there_are_ten_chickens.mp3'),
        );
        await Future.delayed(const Duration(milliseconds: 3000));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const Level2CompleteScreen(),
            ),
          );
        }
      } else {
        await _audioPlayer.play(AssetSource('audio/try_again.mp3'));
      }
    } catch (e) {
      debugPrint('Audio error: $e');
      if (mounted) {
        setState(() => _isLocked = false);
      }
    }
  }

  Widget _buildAnimatedChicken(int globalIndex) {
    final bool isCountingMe = _currentlyCountingIndex == globalIndex;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(0, isCountingMe ? -20.0 : 0.0, 0),
      child: Image.asset(
        'assets/images/chicken2.png',
        width: 70,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildChickenRow(int startIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (index) {
        return _buildAnimatedChicken(startIndex + index);
      }),
    );
  }

  Widget _buildNumberButton(int number, {bool isDisabled = false}) {
    return GestureDetector(
      onTap: isDisabled ? null : () => _onNumberTapped(number),
      child: Container(
        width: 80,
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFF29694A),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: Text(
            number.toString(),
            style: GoogleFonts.inter(
              color: const Color(0xFFF5F5F5),
              fontSize: 36,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreyedWrongButton() {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 500),
      crossFadeState: _isGreyedOut
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      firstChild: _buildNumberButton(_wrongNumber),
      secondChild: ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]),
        child: _buildNumberButton(_wrongNumber, isDisabled: true),
      ),
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
                image: AssetImage('assets/images/counting_background3.png'),
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
                child: ActivityProgressBar(currentActivity: 3),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 70),
                  _buildChickenRow(0),
                  const SizedBox(height: 44),
                  _buildChickenRow(5),
                  const SizedBox(height: 68),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildNumberButton(_targetNumber),
                      const SizedBox(width: 60),
                      _buildGreyedWrongButton(),
                    ],
                  ),
                  const SizedBox(height: 150),
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
                        'Tap the correct number of chickens.',
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
