import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdditionLevel1Activity2Page extends StatefulWidget {
  const AdditionLevel1Activity2Page({super.key});

  @override
  State<AdditionLevel1Activity2Page> createState() =>
      _AdditionLevel1Activity2PageState();
}

class _AdditionLevel1Activity2PageState
    extends State<AdditionLevel1Activity2Page> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<bool> _tappedCarrots = List<bool>.filled(4, false);

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

  Future<void> _tapCarrot(int index) async {
    final isLeftCarrot = index == 0;
    final canTap = isLeftCarrot
        ? !_rightGroupUnlocked
        : _rightGroupUnlocked;

    if (_processingTap ||
        _activityComplete ||
        _tappedCarrots[index] ||
        !canTap) {
      return;
    }

    setState(() {
      _processingTap = true;
      _tappedCarrots[index] = true;
      _currentCount++;
      _bouncingIndex = index;
    });

    final numberAudio = _playAudio('$_currentCount.mp3');
    await Future<void>.delayed(const Duration(milliseconds: 260));

    if (!mounted) return;
    setState(() => _bouncingIndex = -1);
    await numberAudio;

    if (!mounted) return;

    if (_currentCount == 1) {
      setState(() {
        _rightGroupUnlocked = true;
        _processingTap = false;
      });
      return;
    }

    if (_currentCount == 4) {
      setState(() {
        _answerVisible = true;
        _activityComplete = true;
      });

      await _playAudio('great_job.mp3');
      await _playAudio('one_plus_three_equals_four.mp3');

      if (mounted) {
        setState(() => _processingTap = false);
      }
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
      case 'one_plus_three_equals_four.mp3':
        return const Duration(milliseconds: 2600);
      default:
        return const Duration(milliseconds: 950);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFFFAB),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final carrotHeight =
              (height * 0.095).clamp(62.0, 82.0).toDouble();

          return Stack(
            children: [
              const Positioned.fill(
                child: ColoredBox(color: Color(0xFFDFFFAB)),
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
              Positioned(
                top: height * 0.31,
                left: width * 0.08,
                right: width * 0.05,
                child: Row(
                  children: [
                    _equationTerm('1'),
                    _equationTerm('+'),
                    _equationTerm('3'),
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
                            _answerVisible ? '4' : '?',
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
                top: height * 0.40,
                left: width * 0.047,
                width: width * 0.24,
                height: height * 0.30,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: _TappableCarrot(
                    height: carrotHeight,
                    active: !_rightGroupUnlocked && !_activityComplete,
                    bouncing: _bouncingIndex == 0,
                    onTap: () => _tapCarrot(0),
                  ),
                ),
              ),
              Positioned(
                top: height * 0.40,
                left: width * 0.395,
                width: width * 0.24,
                height: height * 0.30,
                child: AnimatedOpacity(
                  opacity: _rightGroupUnlocked ? 1 : 0.30,
                  duration: const Duration(milliseconds: 350),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(3, (groupIndex) {
                      final index = groupIndex + 1;
                      return _TappableCarrot(
                        height: carrotHeight,
                        active: _rightGroupUnlocked &&
                            !_activityComplete &&
                            !_tappedCarrots[index],
                        bouncing: _bouncingIndex == index,
                        onTap: () => _tapCarrot(index),
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
                            'Tap the carrots. How many are there altogether?',
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
      child: Center(
        child: Text(value, style: _equationStyle),
      ),
    );
  }

  TextStyle get _equationStyle => GoogleFonts.quicksand(
        color: const Color(0xFF4A3728),
        fontSize: 36,
        fontWeight: FontWeight.w700,
      );
}

class _TappableCarrot extends StatelessWidget {
  const _TappableCarrot({
    required this.height,
    required this.active,
    required this.bouncing,
    required this.onTap,
  });

  final double height;
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
        width: height * 0.95,
        height: height,
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
            child: Image.asset(
              'assets/images/carrot.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
