import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../widgets/selectable_rabbit_group.dart';

class Activity2Page extends StatefulWidget {
  const Activity2Page({super.key});

  @override
  State<Activity2Page> createState() => _Activity2PageState();
}

class _Activity2PageState extends State<Activity2Page> {
  late AudioPlayer _audioPlayer;
  
  // The answer the child is looking for
  final int _targetNumber = 3; 

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
    try {
      if (count == _targetNumber) {
        await _audioPlayer.play(AssetSource('audio/great_job.mp3'));
        print('Correct! Move to next activity.');
      } else {
        await _audioPlayer.play(AssetSource('audio/try_again.mp3'));
      }
    } catch (e) {
      print("Audio error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD2E7EC), // From your Figma design
      body: Stack(
        children: [
          // ---------------------------------------------------------
          // 1. BACK BUTTON
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
          // 2. RABBIT GROUPS (Centered vertically using a Column)
          // ---------------------------------------------------------
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Wrong Group
                  SelectableRabbitGroup(
                    rabbitCount: 2,
                    onTap: () => _onGroupTapped(2),
                  ),
                  const SizedBox(height: 20),
                  // Correct Group
                  SelectableRabbitGroup(
                    rabbitCount: 3,
                    onTap: () => _onGroupTapped(3),
                  ),
                  const SizedBox(height: 120), // Buffer space for the cat dialog
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