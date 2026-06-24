import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:preschool_math_app/features/addition/screens/level_3/activity_1_page.dart';
import 'package:preschool_math_app/features/shared/screens/complete_screen.dart';

class AdditionLevel2Activity3Page extends StatefulWidget {
  const AdditionLevel2Activity3Page({super.key});

  @override
  State<AdditionLevel2Activity3Page> createState() =>
      _AdditionLevel2Activity3PageState();
}

class _AdditionLevel2Activity3PageState
    extends State<AdditionLevel2Activity3Page> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late final Future<void> _audioReady;

  bool _isLocked = false;
  bool _wrongAnswerGreyed = false;
  bool _firstGroupVisible = false;
  bool _secondGroupVisible = false;
  bool _merged = false;
  bool _answerVisible = false;
  bool _showCompletePopup = false;
  int _bouncingAppleIndex = -1;
  int _visibleMergedCountLabels = 0;

  @override
  void initState() {
    super.initState();
    _audioReady = Future.wait([
      _audioPlayer.setPlayerMode(PlayerMode.lowLatency),
      _audioPlayer.setReleaseMode(ReleaseMode.stop),
    ]);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _onAnswerTapped(int selectedAnswer) async {
    if (_isLocked) return;
    if (selectedAnswer != 6) {
      await _playAudio('try_again.mp3');
      return;
    }

    setState(() {
      _isLocked = true;
      _wrongAnswerGreyed = true;
    });

    debugPrint('>> playing great_job');
    await _playAudio('great_job.mp3');
    if (!mounted) return;

    debugPrint('>> counting first group');
    await _countFirstGroup();
    if (!mounted) return;

    debugPrint('>> counting second group');
    await _countSecondGroup();
    if (!mounted) return;

    debugPrint('>> merging');
    setState(() => _merged = true);
    await Future<void>.delayed(const Duration(milliseconds: 750));
    if (!mounted) return;

    debugPrint('>> counting merged group');
    await _countMergedGroup();
    if (!mounted) return;

    debugPrint('>> showing answer');
    setState(() => _answerVisible = true);
    await Future<void>.delayed(const Duration(milliseconds: 450));

    debugPrint('>> playing equation audio');
    await _playAudio('four_plus_two_equals_six.mp3');
    if (!mounted) return;

    debugPrint('>> showing popup');
    setState(() => _showCompletePopup = true);
  }

  Future<void> _countFirstGroup() async {
    setState(() => _firstGroupVisible = true);
    await Future<void>.delayed(const Duration(milliseconds: 350));

    for (var index = 0; index < 4; index++) {
      await _bounceAndCount(index, index + 1);
      if (!mounted) return;
    }
  }

  Future<void> _countSecondGroup() async {
    setState(() => _secondGroupVisible = true);
    await Future<void>.delayed(const Duration(milliseconds: 350));

    for (var index = 0; index < 2; index++) {
      await _bounceAndCount(index + 4, index + 1);
      if (!mounted) return;
    }
  }

  Future<void> _countMergedGroup() async {
    for (var index = 0; index < 6; index++) {
      await _bounceAndCount(index, index + 1, showCountLabel: true);
      if (!mounted) return;
    }
  }

  Future<void> _bounceAndCount(
    int appleIndex,
    int number, {
    bool showCountLabel = false,
  }) async {
    setState(() {
      _bouncingAppleIndex = appleIndex;
      if (showCountLabel) {
        _visibleMergedCountLabels = number;
      }
    });

    final audio = _playAudio('$number.mp3');
    await Future<void>.delayed(const Duration(milliseconds: 280));

    if (!mounted) return;
    setState(() => _bouncingAppleIndex = -1);
    await audio;
  }

  Future<void> _playAudio(String fileName) async {
    try {
      await _audioReady;
      await _audioPlayer.play(AssetSource('audio/$fileName'));
      await Future<void>.delayed(_audioDuration(fileName));
      await _audioPlayer.stop();
    } catch (error) {
      debugPrint('Audio error for $fileName: $error');
    }
  }

  Duration _audioDuration(String fileName) {
    switch (fileName) {
      case 'try_again.mp3':
        return const Duration(milliseconds: 1100);
      case 'great_job.mp3':
        return const Duration(milliseconds: 1500);
      case 'four_plus_two_equals_six.mp3':
        return const Duration(milliseconds: 2800);
      default:
        return const Duration(milliseconds: 900);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE1E1),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final appleSize = (width * 0.13).clamp(46.0, 58.0).toDouble();
          final equationLeft = width * 0.10;
          final equationRight = width * 0.10;
          final equationWidth = width - equationLeft - equationRight;
          final equationColumnWidth = equationWidth / 5;
          final firstGroupCenterX = equationLeft + (equationColumnWidth * 0.5);
          final secondGroupCenterX = equationLeft + (equationColumnWidth * 2.5);
          final initialGap = appleSize * 1.05;
          final firstGroupWidth = appleSize + initialGap;
          final secondGroupWidth = appleSize + initialGap;
          final mergedSpacing = appleSize * 1.08;
          final mergedGroupWidth = appleSize + (mergedSpacing * 5);
          final topGroupY = height * 0.35;
          final mergedY = height * 0.53;
          final firstGroupX = firstGroupCenterX - (firstGroupWidth / 2);
          final secondGroupX = secondGroupCenterX - (secondGroupWidth / 2);
          final mergedStartX = (width - mergedGroupWidth) / 2;

          return Stack(
            children: [
              const Positioned.fill(
                child: ColoredBox(color: Color(0xFFFFE1E1)),
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
                top: height * 0.25,
                left: equationLeft,
                right: equationRight,
                child: Row(
                  children: [
                    _equationTerm('4'),
                    _equationTerm('+'),
                    _equationTerm('2'),
                    _equationTerm('='),
                    Expanded(
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 450),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutBack,
                                ),
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            _answerVisible ? '6' : '',
                            key: ValueKey<bool>(_answerVisible),
                            style: _equationStyle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...List.generate(6, (index) {
                final isFirstGroup = index < 4;
                final visible = isFirstGroup
                    ? _firstGroupVisible
                    : _secondGroupVisible;
                final startX = isFirstGroup
                    ? firstGroupX + ((index % 2) * initialGap)
                    : secondGroupX + ((index - 4) * initialGap);
                final startY = isFirstGroup
                    ? topGroupY + ((index ~/ 2) * appleSize * 1.02)
                    : topGroupY;
                final endX = mergedStartX + (index * mergedSpacing);
                final countLabel = _merged && index < _visibleMergedCountLabels
                    ? '${index + 1}'
                    : null;

                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeInOut,
                  left: _merged ? endX : startX,
                  top: _merged ? mergedY : startY,
                  width: appleSize,
                  height: appleSize,
                  child: AnimatedOpacity(
                    opacity: visible ? 1 : 0,
                    duration: const Duration(milliseconds: 350),
                    child: _AnimatedApple(
                      bouncing: _bouncingAppleIndex == index,
                      countLabel: countLabel,
                    ),
                  ),
                );
              }),
              Positioned(
                top: height * 0.64,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedOpacity(
                      opacity: _wrongAnswerGreyed ? 0.35 : 1,
                      duration: const Duration(milliseconds: 300),
                      child: _wrongAnswerGreyed
                          ? ColorFiltered(
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
                              child: _NumberChoiceButton(
                                number: 7,
                                disabled: _isLocked,
                                onTap: () => _onAnswerTapped(7),
                              ),
                            )
                          : _NumberChoiceButton(
                              number: 7,
                              disabled: _isLocked,
                              onTap: () => _onAnswerTapped(7),
                            ),
                    ),
                    SizedBox(width: width * 0.16),
                    _NumberChoiceButton(
                      number: 6,
                      disabled: _isLocked,
                      onTap: () => _onAnswerTapped(6),
                    ),
                  ],
                ),
              ),
              IgnorePointer(
                child: SafeArea(
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
                              'Tap the correct answer.',
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
              ),
              if (_showCompletePopup)
                CompletePopup(
                  module: 'addition',
                  levelCompleted: 2,
                  badgeName: 'add_badge2',
                  badgeImage: 'assets/images/add_badge2.png',
                  onContinue: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const AdditionLevel3Activity1Page(),
                      ),
                    );
                  },
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

class _AnimatedApple extends StatelessWidget {
  const _AnimatedApple({required this.bouncing, required this.countLabel});

  final bool bouncing;
  final String? countLabel;

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      maxHeight: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            top: -34,
            child: AnimatedOpacity(
              opacity: countLabel == null ? 0 : 1,
              duration: const Duration(milliseconds: 120),
              child: Text(
                countLabel ?? '',
                style: GoogleFonts.quicksand(
                  color: const Color(0xFF4A3728),
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          AnimatedScale(
            scale: bouncing ? 1.18 : 1,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutBack,
            child: AnimatedSlide(
              offset: bouncing ? const Offset(0, -0.22) : Offset.zero,
              duration: const Duration(milliseconds: 180),
              child: Image.asset(
                'assets/images/apple.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberChoiceButton extends StatelessWidget {
  const _NumberChoiceButton({
    required this.number,
    required this.disabled,
    required this.onTap,
  });

  final int number;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: disabled ? null : onTap,
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
}
