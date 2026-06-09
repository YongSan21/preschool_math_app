import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/selectable_bee_group.dart';
import 'activity_3_page.dart';

class Level3Activity2Page extends StatefulWidget {
  const Level3Activity2Page({super.key});

  @override
  State<Level3Activity2Page> createState() => _Level3Activity2PageState();
}

class _Level3Activity2PageState extends State<Level3Activity2Page> {
  late AudioPlayer _audioPlayer;

  final int _targetNumber = 11;
  final int _wrongNumber = 9;

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
      setState(() {
        _isLocked = true;
        _isGreyedOut = true;
      });

      try {
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
        await _audioPlayer.play(AssetSource('audio/there_are_eleven_bees.mp3'));
        await Future.delayed(const Duration(milliseconds: 3000));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Level3Activity3Page()),
          );
        }
      } catch (e) {
        print('Audio error: $e');
      }
    } else {
      try {
        await _audioPlayer.play(AssetSource('audio/try_again.mp3'));
      } catch (e) {
        print('Audio error: $e');
      }
    }
  }

  Widget _buildGreyedWrongGroup() {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 500),
      crossFadeState:
          _isGreyedOut ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      firstChild: SelectableBeeGroup(
        beeCount: _wrongNumber,
        onTap: () => _onGroupTapped(_wrongNumber),
      ),
      secondChild: ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0, 0, 0, 1, 0,
        ]),
        child: SelectableBeeGroup(
          beeCount: _wrongNumber,
          onTap: () {},
        ),
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
                image: AssetImage('assets/images/counting_background2.png'),
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
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  SelectableBeeGroup(
                    beeCount: _targetNumber,
                    activeBeeIndex: _currentlyCountingIndex,
                    onTap: () => _onGroupTapped(_targetNumber),
                  ),
                  const SizedBox(height: 26),
                  _buildGreyedWrongGroup(),
                  const SizedBox(height: 120),
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
                        'Select the group which has eleven bees.',
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
