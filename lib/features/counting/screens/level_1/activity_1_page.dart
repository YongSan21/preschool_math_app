import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../shared/widgets/activity_progress_bar.dart';
import '../../widgets/countable_rabbit.dart';
import 'activity_2_page.dart';

class Activity1Page extends StatefulWidget {
  const Activity1Page({super.key});

  @override
  State<Activity1Page> createState() => _Activity1PageState();
}

class _Activity1PageState extends State<Activity1Page> {
  int _currentCount = 0;
  final List<int?> _rabbitNumbers = List.filled(5, null);

  // 1. Declare the player using 'late' so we can build it safely later
  late AudioPlayer _audioPlayer;

  // 2. Safely initialize the player exactly when the screen loads
  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // This is the magic line! It tells the player to instantly reset
    // after a sound effect finishes, keeping it perfectly ready for the next tap.
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
  }

  // 3. Forcefully and synchronously destroy the player
  @override
  void dispose() {
    // The package automatically stops the audio when dispose is called!
    _audioPlayer.dispose();
    super.dispose();
  }

  // 3. Make the function async to handle the audio playback
  void _onRabbitTapped(int index) async {
    // Only increment if this specific rabbit hasn't been tapped yet
    if (_rabbitNumbers[index] == null) {
      setState(() {
        _currentCount++;
        _rabbitNumbers[index] = _currentCount;
      });

      // 1. ALWAYS play the number first (1, 2, 3, 4, AND 5!)
      try {
        await _audioPlayer.play(AssetSource('audio/$_currentCount.mp3'));
      } catch (e) {
        debugPrint("Audio error: $e");
      }

      // 2. If it is the final rabbit, trigger the winning sequence
      if (_currentCount == 5) {
        // Wait 1 second to let the word "Five" completely finish playing
        await Future.delayed(const Duration(seconds: 1));

        // Safety check: Did the user hit the back button during that 1 second?
        if (!mounted) return;

        // Play the celebratory audio
        try {
          await _audioPlayer.play(AssetSource('audio/great_job_counting.mp3'));
        } catch (e) {
          debugPrint("Audio error: $e");
        }

        // Wait 3.5 seconds to let the "Great job, let's do more counting" audio finish.
        await Future.delayed(const Duration(milliseconds: 3500));

        // Final safety check before navigating
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Activity2Page()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ---------------------------------------------------------
          // 1. BACKGROUND LAYER
          // ---------------------------------------------------------
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/counting_background1.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ---------------------------------------------------------
          // 2. BACK BUTTON (Safe area top left)
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
          // 3. THE RABBITS (Centered horizontally)
          // ---------------------------------------------------------
          Align(
            alignment: Alignment.center,
            child: Padding(
              // Pushes the row slightly down to align with the pond in your background
              padding: const EdgeInsets.only(top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) {
                  return CountableRabbit(
                    assignedNumber: _rabbitNumbers[index],
                    onTap: () => _onRabbitTapped(index),
                  );
                }),
              ),
            ),
          ),

          // ---------------------------------------------------------
          // 4. CAT DIALOG (Bottom of screen)
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
                  height: 180, // Keeps the text box proportional
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/cat_dialog.png'),
                      fit: BoxFit
                          .contain, // Ensures the image doesn't stretch weirdly
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      // Padding to position the text exactly inside the white bubble area of the image
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
                          height: 1.30,
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
