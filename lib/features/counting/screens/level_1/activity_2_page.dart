import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../shared/widgets/activity_progress_bar.dart';
import '../../widgets/selectable_rabbit_group.dart';
import 'activity_3_page.dart';

class Activity2Page extends StatefulWidget {
  const Activity2Page({super.key});

  @override
  State<Activity2Page> createState() => _Activity2PageState();
}

class _Activity2PageState extends State<Activity2Page> {
  late AudioPlayer _audioPlayer;

  // The answer the child is looking for
  final int _targetNumber = 3;

  // State Variables for animations and logic
  bool _isGreyedOut = false;
  bool _isLocked = false;
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

  void _onGroupTapped(int count) async {
    // Prevent taps while the success animation is playing
    if (_isLocked) return;

    if (count == _targetNumber) {
      // 1. Lock screen and trigger the greyscale fade for the wrong answer
      setState(() {
        _isLocked = true;
        _isGreyedOut = true;
      });

      try {
        // 2. Play Great Job
        await _audioPlayer.play(AssetSource('audio/great_job.mp3'));
        await Future.delayed(const Duration(milliseconds: 1500));
        if (!mounted) return;

        // 3. Bounce and Count Rabbit 1
        setState(() => _currentlyCountingIndex = 0);
        await _audioPlayer.play(AssetSource('audio/1.mp3'));
        await Future.delayed(const Duration(milliseconds: 800));

        // 4. Bounce and Count Rabbit 2
        setState(() => _currentlyCountingIndex = 1);
        await _audioPlayer.play(AssetSource('audio/2.mp3'));
        await Future.delayed(const Duration(milliseconds: 800));

        // 5. Bounce and Count Rabbit 3
        setState(() => _currentlyCountingIndex = 2);
        await _audioPlayer.play(AssetSource('audio/3.mp3'));
        await Future.delayed(const Duration(milliseconds: 800));

        // 6. Reset all rabbits and play the final explanatory audio
        setState(() => _currentlyCountingIndex = null);
        await _audioPlayer.play(
          AssetSource('audio/there_are_three_rabbits.mp3'),
        );

        // Wait for the final audio to finish
        await Future.delayed(const Duration(milliseconds: 3000));

        // 7. Transition to Activity 3
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Activity3Page()),
          );
        }
      } catch (e) {
        debugPrint("Audio error: $e");
      }
    } else {
      // THE WRONG ANSWER
      try {
        await _audioPlayer.play(AssetSource('audio/try_again.mp3'));
      } catch (e) {
        debugPrint("Audio error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD2E7EC),
      body: Stack(
        children: [
          // ---------------------------------------------------------
          // 1. BACK BUTTON (Safe area top left)
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
                child: ActivityProgressBar(currentActivity: 2),
              ),
            ),
          ),

          // ---------------------------------------------------------
          // 2. RABBIT GROUPS (Centered vertically using a Column)
          // ---------------------------------------------------------
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ---------------------------------------------------------
                  // The Wrong Group (2 Rabbits) - Fades to Grey on Win
                  // ---------------------------------------------------------
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 500),
                    crossFadeState: _isGreyedOut
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,

                    // STATE 1: Full Color
                    firstChild: SelectableRabbitGroup(
                      rabbitCount: 2,
                      onTap: () => _onGroupTapped(2),
                    ),

                    // STATE 2: Greyscale
                    secondChild: ColorFiltered(
                      // This matrix drains color but perfectly preserves transparency
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
                      child: SelectableRabbitGroup(
                        rabbitCount: 2,
                        onTap:
                            () {}, // Empty tap so it cannot trigger audio again
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ---------------------------------------------------------
                  // The Correct Group (3 Rabbits) - Handles the individual bouncing
                  // ---------------------------------------------------------
                  SelectableRabbitGroup(
                    rabbitCount: 3,
                    activeRabbitIndex: _currentlyCountingIndex,
                    onTap: () => _onGroupTapped(3),
                  ),

                  const SizedBox(
                    height: 120,
                  ), // Buffer space for the cat dialog
                ],
              ),
            ),
          ),

          // ---------------------------------------------------------
          // 3. CAT DIALOG (Bottom of screen)
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
                        'Select the group which has three rabbits.',
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
