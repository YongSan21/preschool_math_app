import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:preschool_math_app/features/addition/screens/level_5/activity_1_page.dart';
import 'package:preschool_math_app/features/shared/screens/complete_screen.dart';

class AdditionLevel4Activity3Page extends StatefulWidget {
  const AdditionLevel4Activity3Page({super.key});

  @override
  State<AdditionLevel4Activity3Page> createState() =>
      _AdditionLevel4Activity3PageState();
}

class _AdditionLevel4Activity3PageState
    extends State<AdditionLevel4Activity3Page> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late final Future<void> _audioReady;

  bool _isLocked = false;
  bool _wrongAnswerGreyed = false;
  bool _firstGroupVisible = false;
  bool _secondGroupVisible = false;
  bool _merged = false;
  bool _answerVisible = false;
  bool _showCompletePopup = false;
  int _bouncingCarrotIndex = -1;
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

    if (selectedAnswer != 17) {
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
    await _playAudio('nine_plus_eight_equals_seventeen.mp3');

    if (!mounted) return;
    setState(() => _showCompletePopup = true);
  }

  Future<void> _countFirstGroup() async {
    setState(() => _firstGroupVisible = true);
    await Future<void>.delayed(const Duration(milliseconds: 350));

    for (var index = 0; index < 9; index++) {
      await _bounceAndCount(index, index + 1);
      if (!mounted) return;
    }
  }

  Future<void> _countSecondGroup() async {
    setState(() => _secondGroupVisible = true);
    await Future<void>.delayed(const Duration(milliseconds: 350));

    for (var index = 0; index < 8; index++) {
      await _bounceAndCount(index + 9, index + 1);
      if (!mounted) return;
    }
  }

  Future<void> _countMergedGroup() async {
    for (var index = 0; index < 17; index++) {
      await _bounceAndCount(index, index + 1, showCountLabel: true);
      if (!mounted) return;
    }
  }

  Future<void> _bounceAndCount(
    int carrotIndex,
    int number, {
    bool showCountLabel = false,
  }) async {
    setState(() {
      _bouncingCarrotIndex = carrotIndex;
      if (showCountLabel) {
        _visibleMergedCountLabels = number;
      }
    });

    final audio = _playAudio('$number.mp3');
    await Future<void>.delayed(const Duration(milliseconds: 280));

    if (!mounted) return;
    setState(() => _bouncingCarrotIndex = -1);
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
      case 'nine_plus_eight_equals_seventeen.mp3':
        return const Duration(milliseconds: 3100);
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
          final initialCarrotWidth = (width * 0.13)
              .clamp(47.0, 56.0)
              .toDouble();
          final initialCarrotHeight = initialCarrotWidth * 1.20;
          final mergedCarrotWidth = (width * 0.11).clamp(40.0, 47.0).toDouble();
          final mergedCarrotHeight = mergedCarrotWidth * 1.20;
          final equationLeft = width * 0.15;
          final equationRight = width * 0.08;
          final equationWidth = width - equationLeft - equationRight;
          final equationColumnWidth = equationWidth / 5;
          final firstGroupCenterX =
              equationLeft + (equationColumnWidth * 0.5) - (width * 0.035);
          final secondGroupCenterX =
              equationLeft + (equationColumnWidth * 2.5) + (width * 0.055);
          final initialGapX = initialCarrotWidth * 1.04;
          final initialGapY = initialCarrotHeight * 1.02;
          final initialGroupWidth = initialCarrotWidth + (initialGapX * 2);
          final firstGroupX = firstGroupCenterX - (initialGroupWidth / 2);
          final secondGroupX = secondGroupCenterX - (initialGroupWidth / 2);
          final topGroupY = height * 0.24;

          final mergedGap = mergedCarrotWidth * 1.03;
          final firstRowWidth = mergedCarrotWidth + (mergedGap * 5);
          final secondRowWidth = mergedCarrotWidth + (mergedGap * 5);
          final thirdRowWidth = mergedCarrotWidth + (mergedGap * 4);
          final firstRowX = (width - firstRowWidth) / 2;
          final secondRowX = (width - secondRowWidth) / 2;
          final thirdRowX = (width - thirdRowWidth) / 2;
          final mergedFirstRowY = height * 0.43;
          final mergedSecondRowY = mergedFirstRowY + mergedCarrotHeight * 1.05;
          final mergedThirdRowY = mergedSecondRowY + mergedCarrotHeight * 1.05;

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
              Positioned(
                top: height * 0.14,
                left: equationLeft,
                right: equationRight,
                child: Row(
                  children: [
                    _equationTerm('9'),
                    _equationTerm('+'),
                    _equationTerm('8'),
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
                            _answerVisible ? '17' : '',
                            key: ValueKey<bool>(_answerVisible),
                            style: _equationStyle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...List.generate(17, (index) {
                final isFirstGroup = index < 9;
                final visible = isFirstGroup
                    ? _firstGroupVisible
                    : _secondGroupVisible;
                final groupIndex = isFirstGroup ? index : index - 9;

                late final int initialColumn;
                late final int initialRow;
                if (isFirstGroup) {
                  initialColumn = groupIndex % 3;
                  initialRow = groupIndex ~/ 3;
                } else if (groupIndex < 3) {
                  initialColumn = groupIndex;
                  initialRow = 0;
                } else if (groupIndex < 6) {
                  initialColumn = groupIndex - 3;
                  initialRow = 1;
                } else {
                  initialColumn = groupIndex - 6;
                  initialRow = 2;
                }

                final startX =
                    (isFirstGroup ? firstGroupX : secondGroupX) +
                    (initialColumn * initialGapX);
                final startY = topGroupY + (initialRow * initialGapY);

                final inFirstMergedRow = index < 6;
                final inSecondMergedRow = index >= 6 && index < 12;
                final endX = inFirstMergedRow
                    ? firstRowX + (index * mergedGap)
                    : inSecondMergedRow
                    ? secondRowX + ((index - 6) * mergedGap)
                    : thirdRowX + ((index - 12) * mergedGap);
                final endY = inFirstMergedRow
                    ? mergedFirstRowY
                    : inSecondMergedRow
                    ? mergedSecondRowY
                    : mergedThirdRowY;
                final countLabel = _merged && index < _visibleMergedCountLabels
                    ? '${index + 1}'
                    : null;

                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeInOut,
                  left: _merged ? endX : startX,
                  top: _merged ? endY : startY,
                  width: _merged ? mergedCarrotWidth : initialCarrotWidth,
                  height: _merged ? mergedCarrotHeight : initialCarrotHeight,
                  child: AnimatedOpacity(
                    opacity: visible ? 1 : 0,
                    duration: const Duration(milliseconds: 350),
                    child: _AnimatedCarrot(
                      bouncing: _bouncingCarrotIndex == index,
                      countLabel: countLabel,
                    ),
                  ),
                );
              }),
              Positioned(
                top: height * 0.67,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _NumberChoiceButton(
                      number: 17,
                      disabled: _isLocked,
                      onTap: () => _onAnswerTapped(17),
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
                                number: 19,
                                disabled: _isLocked,
                                onTap: () => _onAnswerTapped(19),
                              ),
                            )
                          : _NumberChoiceButton(
                              number: 19,
                              disabled: _isLocked,
                              onTap: () => _onAnswerTapped(19),
                            ),
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
                  levelCompleted: 4,
                  badgeName: 'add_badge4',
                  badgeImage: 'assets/images/add_badge4.png',
                  onContinue: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const AdditionLevel5Activity1Page(),
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

class _AnimatedCarrot extends StatelessWidget {
  const _AnimatedCarrot({required this.bouncing, required this.countLabel});

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
            top: -22,
            child: AnimatedOpacity(
              opacity: countLabel == null ? 0 : 1,
              duration: const Duration(milliseconds: 120),
              child: Text(
                countLabel ?? '',
                style: GoogleFonts.quicksand(
                  color: const Color(0xFF4A3728),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          AnimatedScale(
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
