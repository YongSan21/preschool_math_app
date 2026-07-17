import 'package:audioplayers/audioplayers.dart';
import '../../../shared/widgets/activity_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/selectable_squirrel_group.dart';
import 'activity_3_page.dart';

class Level4Activity2Page extends StatefulWidget {
  const Level4Activity2Page({super.key});

  @override
  State<Level4Activity2Page> createState() => _Level4Activity2PageState();
}

class _Level4Activity2PageState extends State<Level4Activity2Page> {
  late AudioPlayer _audioPlayer;

  final int _targetNumber = 17;
  final int _wrongNumber = 15;

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

          final number = i + 1;
          await _audioPlayer.play(AssetSource('audio/$number.mp3'));
          await Future.delayed(_numberAudioDelay(number));
          if (!mounted) return;
        }

        setState(() => _currentlyCountingIndex = null);
        await _audioPlayer.play(
          AssetSource('audio/there_are_seventeen_squirrels.mp3'),
        );
        await Future.delayed(const Duration(milliseconds: 3000));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const Level4Activity3Page(),
            ),
          );
        }
      } catch (e) {
        debugPrint('Audio error: $e');
      }
    } else {
      try {
        await _audioPlayer.play(AssetSource('audio/try_again.mp3'));
      } catch (e) {
        debugPrint('Audio error: $e');
      }
    }
  }

  Duration _numberAudioDelay(int number) {
    if (number >= 16) {
      return const Duration(milliseconds: 1300);
    }

    if (number >= 11) {
      return const Duration(milliseconds: 1100);
    }

    return const Duration(milliseconds: 800);
  }

  Widget _buildGreyedWrongGroup() {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 500),
      crossFadeState: _isGreyedOut
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      firstChild: SelectableSquirrelGroup(
        squirrelCount: _wrongNumber,
        onTap: () => _onGroupTapped(_wrongNumber),
      ),
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
        child: SelectableSquirrelGroup(
          squirrelCount: _wrongNumber,
          onTap: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD3E8EC),
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
                child: ActivityProgressBar(currentActivity: 2),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  _buildGreyedWrongGroup(),
                  const SizedBox(height: 18),
                  SelectableSquirrelGroup(
                    squirrelCount: _targetNumber,
                    activeSquirrelIndex: _currentlyCountingIndex,
                    onTap: () => _onGroupTapped(_targetNumber),
                  ),
                  const SizedBox(height: 124),
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
                        'Select the group which has seventeen squirrels.',
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
