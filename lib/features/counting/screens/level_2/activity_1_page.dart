import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../shared/widgets/activity_progress_bar.dart';
import 'activity_2_page.dart';

class Level2Activity1Page extends StatefulWidget {
  const Level2Activity1Page({super.key});

  @override
  State<Level2Activity1Page> createState() => _Level2Activity1PageState();
}

class _Level2Activity1PageState extends State<Level2Activity1Page> {
  late AudioPlayer _audioPlayer;

  // Game State
  int _currentCount = 0;
  final int _totalCows = 10;

  // This array stores exactly which number was assigned to which cow based on tap order!
  final List<int?> _cowNumbers = List.filled(10, null);

  bool _isLocked = false;
  int? _bouncingCowIndex; // Tracks which cow is jumping right now

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

  void _onCowTapped(int index) async {
    // Prevent tapping if audio is playing, or if THIS specific cow was already counted
    if (_isLocked || _cowNumbers[index] != null) return;

    setState(() {
      _isLocked = true;
      _currentCount++;
      _cowNumbers[index] =
          _currentCount; // Give this cow the next available number!
      _bouncingCowIndex = index;
    });

    try {
      // Play the specific number audio (1.mp3 up to 10.mp3)
      await _audioPlayer.play(AssetSource('audio/$_currentCount.mp3'));

      // Wait for the audio and bounce to finish before letting them tap the next one
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        setState(() {
          _bouncingCowIndex = null; // Reset the bounce
          _isLocked = false;
        });
      }

      // Check if they won!
      if (_currentCount == _totalCows) {
        _handleLevelComplete();
      }
    } catch (e) {
      debugPrint("Audio error: $e");
      setState(() => _isLocked = false);
    }
  }

  void _handleLevelComplete() async {
    setState(() => _isLocked = true);

    try {
      // Wait 1 second to let the word "Ten" completely finish playing
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      // Play the celebratory audio matching Level 1
      await _audioPlayer.play(AssetSource('audio/great_job_counting.mp3'));

      // Wait 3.5 seconds to let the audio finish.
      await Future.delayed(const Duration(milliseconds: 3500));

      if (mounted) {
        // Navigate seamlessly to Level 2 Activity 2
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Level2Activity2Page()),
        );
      }
    } catch (e) {
      debugPrint("Audio error: $e");
    }
  }

  // ---------------------------------------------------------
  // HELPER WIDGET: Builds a single interactive cow
  // ---------------------------------------------------------
  Widget _buildAnimatedCow(int index) {
    // Check if this specific cow has a number yet
    final int? assignedNumber = _cowNumbers[index];
    final bool isCounted = assignedNumber != null;
    final bool isBouncing = _bouncingCowIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onCowTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. The Number (Invisible until counted)
            AnimatedOpacity(
              opacity: isCounted ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Text(
                assignedNumber?.toString() ?? '', // Show the dynamic number!
                style: GoogleFonts.quicksand(
                  color: const Color(0xFF4A3728),
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 4),

            // 2. The Cow (Bounces up 15 pixels when tapped)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              transform: Matrix4.translationValues(
                0,
                isBouncing ? -15.0 : 0.0,
                0,
              ),
              child: Image.asset(
                'assets/images/cow.png',
                width: 75,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFFFAB), // Figma Light Green Background
      body: Stack(
        children: [
          // ---------------------------------------------------------
          // 1. BACK BUTTON
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
                child: ActivityProgressBar(currentActivity: 1),
              ),
            ),
          ),

          // ---------------------------------------------------------
          // 2. MAIN CONTENT (The 10 Cows)
          // ---------------------------------------------------------
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- ROW 1: Cows 0 to 4 ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        5,
                        (index) => _buildAnimatedCow(index),
                      ),
                    ),

                    const SizedBox(height: 40), // Space between rows
                    // --- ROW 2: Cows 5 to 9 ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        5,
                        (index) => _buildAnimatedCow(index + 5),
                      ),
                    ),

                    const SizedBox(
                      height: 120,
                    ), // Buffer space for the cat dialog
                  ],
                ),
              ),
            ),
          ),

          // ---------------------------------------------------------
          // 3. CAT DIALOG
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
                        'Can you tap the cows to count them?',
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
