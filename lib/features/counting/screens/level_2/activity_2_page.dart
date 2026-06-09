import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../widgets/selectable_cow_group.dart';
import 'activity_3_page.dart';

class Level2Activity2Page extends StatefulWidget {
  const Level2Activity2Page({super.key});

  @override
  State<Level2Activity2Page> createState() => _Level2Activity2PageState();
}

class _Level2Activity2PageState extends State<Level2Activity2Page> {
  late AudioPlayer _audioPlayer;
  
  // The answer the child is looking for
  final int _targetNumber = 7; 

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
    if (_isLocked) return;

    if (count == _targetNumber) {
      // 1. Lock screen and trigger the greyscale fade for the wrong answer (9)
      setState(() {
        _isLocked = true;
        _isGreyedOut = true; 
      });

      try {
        // 2. Play Great Job
        await _audioPlayer.play(AssetSource('audio/great_job.mp3'));
        await Future.delayed(const Duration(milliseconds: 1500));
        if (!mounted) return;

        // 3. Loop through and bounce all 7 cows!
        for (int i = 0; i < 7; i++) {
          setState(() => _currentlyCountingIndex = i);
          
          await _audioPlayer.play(AssetSource('audio/${i + 1}.mp3'));
          await Future.delayed(const Duration(milliseconds: 800));
          if (!mounted) return;
        }

        // 4. Reset cows to the ground and play final conclusion
        setState(() => _currentlyCountingIndex = null);
        await _audioPlayer.play(AssetSource('audio/there_are_seven_cows.mp3'));
        await Future.delayed(const Duration(milliseconds: 3000));

        // 5. Transition to Activity 3
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Level2Activity3Page()),
          );
        }
      } catch (e) {
        print("Audio error: $e");
      }
    } else {
      // THE WRONG ANSWER
      try {
        await _audioPlayer.play(AssetSource('audio/try_again.mp3'));
      } catch (e) {
        print("Audio error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFFFAB),
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
                image: AssetImage('assets/images/counting_background3.png'),
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
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.black, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // ---------------------------------------------------------
          // 3. COW GROUPS (Centered vertically)
          // ---------------------------------------------------------
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20), // Buffer space from the top
                  // ---------------------------------------------------------
                  // TOP: The Correct Group (7 Cows) 
                  // ---------------------------------------------------------
                  SelectableCowGroup(
                    cowCount: 7,
                    activeCowIndex: _currentlyCountingIndex,
                    onTap: () => _onGroupTapped(7),
                  ),
                  
                  const SizedBox(height: 5), // Space between the two groups),
                  
                  // ---------------------------------------------------------
                  // BOTTOM: The Wrong Group (9 Cows) - Fades to Grey
                  // ---------------------------------------------------------
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 500),
                    crossFadeState: _isGreyedOut ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    
                    // STATE 1: Full Color
                    firstChild: SelectableCowGroup(
                      cowCount: 9,
                      onTap: () => _onGroupTapped(9),
                    ),
                    
                    // STATE 2: Greyscale (Preserves transparency!)
                    secondChild: ColorFiltered(
                      colorFilter: const ColorFilter.matrix(<double>[
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0,      0,      0,      1, 0,
                      ]),
                      child: SelectableCowGroup(
                        cowCount: 9,
                        onTap: () {}, // Empty tap to prevent audio triggers
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 100), // Buffer space for the cat dialog
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
                padding: const EdgeInsets.only(bottom: 24.0, left: 16.0, right: 16.0),
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
                      padding: const EdgeInsets.only(bottom: 28.0, left: 20.0, right: 20.0),
                      child: Text(
                        'Select the group which has seven cows.',
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
