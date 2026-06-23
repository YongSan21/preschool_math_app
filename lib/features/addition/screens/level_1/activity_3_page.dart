import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:preschool_math_app/features/addition/screens/level_2/activity_1_page.dart';
import 'package:preschool_math_app/features/shared/screens/complete_screen.dart';

class AdditionLevel1Activity3Page extends StatefulWidget {
  const AdditionLevel1Activity3Page({super.key});

  @override
  State<AdditionLevel1Activity3Page> createState() =>
      _AdditionLevel1Activity3PageState();
}

class _AdditionLevel1Activity3PageState
    extends State<AdditionLevel1Activity3Page> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isLocked = false;
  bool _wrongAnswerGreyed = false;
  bool _firstGroupVisible = false;
  bool _secondGroupVisible = false;
  bool _merged = false;
  bool _answerVisible = false;
  bool _showCompletePopup = false;
  int _bouncingOrangeIndex = -1;
  int _visibleMergedCountLabels = 0;

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

  Future<void> _onAnswerTapped(int selectedAnswer) async {
    if (_isLocked) return;

    if (selectedAnswer != 4) {
      await _playAudio('try_again.mp3');
      return;
    }

    setState(() {
      _isLocked = true;
      _wrongAnswerGreyed = true;
    });

    await _playAudio('great_job.mp3');
    if (!mounted) return;

    await _countFirstGroup();
    if (!mounted) return;

    await _countSecondGroup();
    if (!mounted) return;

    setState(() => _merged = true);
    await Future<void>.delayed(const Duration(milliseconds: 750));
    if (!mounted) return;

    await _countMergedGroup();
    if (!mounted) return;

    setState(() => _answerVisible = true);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    await _playAudio('two_plus_two_equals_four.mp3');

    if (!mounted) return;
    setState(() => _showCompletePopup = true);
  }

  Future<void> _countFirstGroup() async {
    setState(() => _firstGroupVisible = true);
    await Future<void>.delayed(const Duration(milliseconds: 350));

    for (int i = 0; i < 2; i++) {
      await _bounceAndCount(i, i + 1);
      if (!mounted) return;
    }
  }

  Future<void> _countSecondGroup() async {
    setState(() => _secondGroupVisible = true);
    await Future<void>.delayed(const Duration(milliseconds: 350));

    for (int i = 0; i < 2; i++) {
      await _bounceAndCount(i + 2, i + 1);
      if (!mounted) return;
    }
  }

  Future<void> _countMergedGroup() async {
    for (int i = 0; i < 4; i++) {
      await _bounceAndCount(i, i + 1, showCountLabel: true);
      if (!mounted) return;
    }
  }

  Future<void> _bounceAndCount(
    int orangeIndex,
    int number, {
    bool showCountLabel = false,
  }) async {
    setState(() {
      _bouncingOrangeIndex = orangeIndex;
      if (showCountLabel) {
        _visibleMergedCountLabels = number;
      }
    });
    final audio = _playAudio('$number.mp3');
    await Future<void>.delayed(const Duration(milliseconds: 280));
    if (!mounted) return;
    setState(() => _bouncingOrangeIndex = -1);
    await audio;
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
      case 'try_again.mp3':
        return const Duration(milliseconds: 1100);
      case 'great_job.mp3':
        return const Duration(milliseconds: 1500);
      case 'two_plus_two_equals_four.mp3':
        return const Duration(milliseconds: 2600);
      default:
        return const Duration(milliseconds: 900);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFACE),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final orangeSize = (width * 0.13).clamp(44.0, 58.0).toDouble();
          final equationLeft = width * 0.10;
          final equationRight = width * 0.10;
          final equationWidth = width - equationLeft - equationRight;
          final equationColumnWidth = equationWidth / 5;
          final firstTwoCenterX = equationLeft + (equationColumnWidth * 0.5);
          final secondTwoCenterX = equationLeft + (equationColumnWidth * 2.5);
          final groupWidth = orangeSize * 2.05;
          final mergedSpacing = orangeSize * 1.18;
          final mergedGroupWidth = orangeSize + (mergedSpacing * 3);
          final topGroupY = height * 0.39;
          final mergedY = height * 0.55;
          final leftGroupX = firstTwoCenterX - (groupWidth / 2);
          final rightGroupX = secondTwoCenterX - (groupWidth / 2);
          final mergedStartX = (width - mergedGroupWidth) / 2;

          return Stack(
            children: [
              const Positioned.fill(
                child: ColoredBox(color: Color(0xFFFEFACE)),
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
                top: height * 0.305,
                left: equationLeft,
                right: equationRight,
                child: Row(
                  children: [
                    _equationTerm('2'),
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
                            _answerVisible ? '4' : '',
                            key: ValueKey<bool>(_answerVisible),
                            style: _equationStyle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...List.generate(4, (index) {
                final isFirstGroup = index < 2;
                final visible =
                    isFirstGroup ? _firstGroupVisible : _secondGroupVisible;
                final groupX = isFirstGroup ? leftGroupX : rightGroupX;
                final groupIndex = index % 2;
                final startX = groupX + (groupIndex * orangeSize * 1.05);
                final startY = topGroupY;
                final endX = mergedStartX + (index * mergedSpacing);
                final endY = mergedY;
                final countLabel = _merged && index < _visibleMergedCountLabels
                    ? '${index + 1}'
                    : null;

                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeInOut,
                  left: _merged ? endX : startX,
                  top: _merged ? endY : startY,
                  width: orangeSize,
                  height: orangeSize,
                  child: AnimatedOpacity(
                    opacity: visible ? 1 : 0,
                    duration: const Duration(milliseconds: 350),
                    child: _AnimatedOrange(
                      bouncing: _bouncingOrangeIndex == index,
                      countLabel: countLabel,
                    ),
                  ),
                );
              }),
              Positioned(
                top: height * 0.66,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _NumberChoiceButton(
                      number: 4,
                      disabled: _isLocked,
                      onTap: () => _onAnswerTapped(4),
                    ),
                    SizedBox(width: width * 0.16),
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
                                number: 5,
                                disabled: _isLocked,
                                onTap: () => _onAnswerTapped(5),
                              ),
                            )
                          : _NumberChoiceButton(
                              number: 5,
                              disabled: _isLocked,
                              onTap: () => _onAnswerTapped(5),
                            ),
                    ),
                  ],
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
              if (_showCompletePopup)
                CompletePopup(
                  module: 'addition',
                  levelCompleted: 1,
                  badgeName: 'add_badge1',
                  badgeImage: 'assets/images/add_badge1.png',
                  onContinue: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const AdditionLevel2Activity1Page(),
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

class _AnimatedOrange extends StatelessWidget {
  const _AnimatedOrange({
    required this.bouncing,
    required this.countLabel,
  });

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
                'assets/images/orange.png',
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
