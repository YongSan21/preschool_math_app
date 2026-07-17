import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/widgets/activity_progress_bar.dart';
import 'activity_3_page.dart';

class AdditionLevel2Activity2Page extends StatefulWidget {
  const AdditionLevel2Activity2Page({super.key});

  @override
  State<AdditionLevel2Activity2Page> createState() =>
      _AdditionLevel2Activity2PageState();
}

class _AdditionLevel2Activity2PageState
    extends State<AdditionLevel2Activity2Page> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<bool> _tappedOranges = List<bool>.filled(8, false);

  int _currentCount = 0;
  int _bouncingIndex = -1;
  bool _rightGroupUnlocked = false;
  bool _processingTap = false;
  bool _answerVisible = false;
  bool _activityComplete = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _tapOrange(int index) async {
    final isLeftOrange = index < 3;
    final canTap = isLeftOrange ? !_rightGroupUnlocked : _rightGroupUnlocked;

    if (_processingTap ||
        _activityComplete ||
        _tappedOranges[index] ||
        !canTap) {
      return;
    }

    setState(() {
      _processingTap = true;
      _tappedOranges[index] = true;
      _currentCount++;
      _bouncingIndex = index;
    });

    final numberAudio = _playAudio('$_currentCount.mp3');
    await Future<void>.delayed(const Duration(milliseconds: 260));

    if (!mounted) return;
    setState(() => _bouncingIndex = -1);
    await numberAudio;

    if (!mounted) return;

    if (_currentCount == 3) {
      setState(() {
        _rightGroupUnlocked = true;
        _processingTap = false;
      });
      return;
    }

    if (_currentCount == 8) {
      setState(() {
        _answerVisible = true;
        _activityComplete = true;
      });

      await _playAudio('great_job.mp3');
      await _playAudio('three_plus_five_equals_eight.mp3');

      if (!mounted) return;
      setState(() => _processingTap = false);
      await Future<void>.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AdditionLevel2Activity3Page(),
        ),
      );
      return;
    }

    setState(() => _processingTap = false);
  }

  Future<void> _playAudio(String fileName) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('audio/$fileName'));
      await Future<void>.delayed(_audioDuration(fileName));
    } catch (error) {
      debugPrint('Audio error for $fileName: $error');
    }
  }

  Duration _audioDuration(String fileName) {
    switch (fileName) {
      case 'great_job.mp3':
        return const Duration(milliseconds: 1500);
      case 'three_plus_five_equals_eight.mp3':
        return const Duration(milliseconds: 2800);
      default:
        return const Duration(milliseconds: 950);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final orangeSize = (width * 0.165).clamp(54.0, 68.0).toDouble();

          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/counting_background5.png',
                  fit: BoxFit.cover,
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
                    child: ActivityProgressBar(currentActivity: 2),
                  ),
                ),
              ),
              Positioned(
                top: height * 0.25,
                left: width * 0.08,
                right: width * 0.05,
                child: Row(
                  children: [
                    _equationTerm('3'),
                    _equationTerm('+'),
                    _equationTerm('5'),
                    _equationTerm('='),
                    Expanded(
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 450),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              scale: CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutBack,
                              ),
                              child: child,
                            );
                          },
                          child: Text(
                            _answerVisible ? '8' : '?',
                            key: ValueKey<bool>(_answerVisible),
                            style: _equationStyle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: height * 0.33,
                left: width * 0.065,
                width: width * 0.19,
                height: height * 0.30,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(3, (index) {
                    return _TappableOrange(
                      size: orangeSize,
                      active:
                          !_rightGroupUnlocked &&
                          !_activityComplete &&
                          !_tappedOranges[index],
                      bouncing: _bouncingIndex == index,
                      onTap: () => _tapOrange(index),
                    );
                  }),
                ),
              ),
              Positioned(
                top: height * 0.33,
                left: width * 0.415,
                width: width * 0.19,
                height: height * 0.40,
                child: AnimatedOpacity(
                  opacity: _rightGroupUnlocked ? 1 : 0.30,
                  duration: const Duration(milliseconds: 350),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(5, (groupIndex) {
                      final index = groupIndex + 3;
                      return _TappableOrange(
                        size: orangeSize,
                        active:
                            _rightGroupUnlocked &&
                            !_activityComplete &&
                            !_tappedOranges[index],
                        bouncing: _bouncingIndex == index,
                        onTap: () => _tapOrange(index),
                      );
                    }),
                  ),
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 24,
                      left: 16,
                      right: 16,
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
                            bottom: 28,
                            left: 20,
                            right: 20,
                          ),
                          child: Text(
                            'Tap the oranges. How many are there altogether?',
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
          );
        },
      ),
    );
  }

  Widget _equationTerm(String value) {
    return Expanded(
      child: Center(child: Text(value, style: _equationStyle)),
    );
  }

  TextStyle get _equationStyle => GoogleFonts.quicksand(
    color: const Color(0xFF4A3728),
    fontSize: 36,
    fontWeight: FontWeight.w700,
  );
}

class _TappableOrange extends StatelessWidget {
  const _TappableOrange({
    required this.size,
    required this.active,
    required this.bouncing,
    required this.onTap,
  });

  final double size;
  final bool active;
  final bool bouncing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: active ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: size,
        height: size,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: active ? const Color(0xFFFFC83D) : Colors.transparent,
            width: 3,
          ),
          boxShadow: active
              ? const [
                  BoxShadow(
                    color: Color(0x99FFD54F),
                    blurRadius: 14,
                    spreadRadius: 3,
                  ),
                ]
              : const [],
        ),
        child: AnimatedScale(
          scale: bouncing ? 1.16 : 1,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          child: AnimatedSlide(
            offset: bouncing ? const Offset(0, -0.18) : Offset.zero,
            duration: const Duration(milliseconds: 180),
            child: Image.asset('assets/images/orange.png', fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
