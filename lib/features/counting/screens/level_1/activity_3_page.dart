import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../shared/screens/complete_screen.dart';
import '../../../shared/widgets/activity_progress_bar.dart';
import '../level_2/activity_1_page.dart';

class Activity3Page extends StatefulWidget {
  const Activity3Page({super.key});

  @override
  State<Activity3Page> createState() => _Activity3PageState();
}

class _Activity3PageState extends State<Activity3Page> {
  late AudioPlayer _audioPlayer;
  final int _targetNumber = 5;

  // 1. State Variables for the animations
  bool _isLocked = false;
  bool _isGreyedOut = false;
  bool _showCompletePopup = false;
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
        // Lock screen and turn the wrong answer (3) grey
        setState(() {
          _isLocked = true;
          _isGreyedOut = true;
        });

        // 1. Play Great Job
        await _audioPlayer.play(AssetSource('audio/great_job.mp3'));
        await Future.delayed(const Duration(milliseconds: 1500));
        if (!mounted) return;

        // 2. Loop through and bounce all 5 ponies!
        for (int i = 0; i < 5; i++) {
          setState(() => _currentlyCountingIndex = i);

          // Reusing the audio files from Activity 1
          await _audioPlayer.play(AssetSource('audio/${i + 1}.mp3'));
          await Future.delayed(const Duration(milliseconds: 800));
          if (!mounted) return;
        }

        // 3. Reset ponies to the ground and play final conclusion
        setState(() => _currentlyCountingIndex = null);
        await _audioPlayer.play(AssetSource('audio/there_are_five_ponies.mp3'));
        await Future.delayed(const Duration(milliseconds: 3000));

        if (mounted) {
          setState(() => _showCompletePopup = true);
        }
      } else {
        // Wrong Answer
        await _audioPlayer.play(AssetSource('audio/try_again.mp3'));
      }
    } catch (e) {
      debugPrint("Audio error: $e");
    }
  }

  // Helper Widget: Builds a single animated pony based on its global index (0-4)
  Widget _buildAnimatedPony(int globalIndex, double horizontalPadding) {
    final isCountingMe = _currentlyCountingIndex == globalIndex;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        // Moves the pony up 20 pixels when it's their turn!
        transform: Matrix4.translationValues(0, isCountingMe ? -20.0 : 0.0, 0),
        child: Image.asset('assets/images/pony.png', width: 100),
      ),
    );
  }

  // Helper Widget: Builds the number buttons
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ---------------------------------------------------------
          // 1. BACKGROUND
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
          // 2. BACK BUTTON
          // ---------------------------------------------------------
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

          // ---------------------------------------------------------
          // 3. MAIN CONTENT
          // ---------------------------------------------------------
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- ROW 1: 3 Ponies (Indices 0, 1, 2) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return _buildAnimatedPony(index, 4.0);
                    }),
                  ),
                  const SizedBox(height: 10),

                  // --- ROW 2: 2 Ponies (Indices 3, 4) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(2, (index) {
                      // We add 3 to the index so these become pony #3 and #4!
                      return _buildAnimatedPony(index + 3, 10.0);
                    }),
                  ),

                  const SizedBox(height: 60),

                  // --- NUMBER BUTTONS ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // THE WRONG BUTTON (3) - Fades to grey
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 500),
                        crossFadeState: _isGreyedOut
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild: _buildNumberButton(3),
                        secondChild: ColorFiltered(
                          // Using the transparent-safe matrix from Activity 2!
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
                          child: _buildNumberButton(3, isDisabled: true),
                        ),
                      ),

                      const SizedBox(width: 60),

                      // THE CORRECT BUTTON (5)
                      _buildNumberButton(5),
                    ],
                  ),

                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),

          // ---------------------------------------------------------
          // 4. CAT DIALOG
          // ---------------------------------------------------------
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
                        'Tap the correct number of ponies.',
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
          if (_showCompletePopup)
            CompletePopup(
              module: 'counting',
              levelCompleted: 1,
              badgeName: 'count_badge1',
              badgeImage: 'assets/images/count_badge1.png',
              onContinue: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Level2Activity1Page(),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
