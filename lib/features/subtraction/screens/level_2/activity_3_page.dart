import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:preschool_math_app/features/shared/screens/complete_screen.dart';

class SubtractionLevel2Activity3Page extends StatefulWidget {
  const SubtractionLevel2Activity3Page({super.key});

  @override
  State<SubtractionLevel2Activity3Page> createState() =>
      _SubtractionLevel2Activity3PageState();
}

class _SubtractionLevel2Activity3PageState
    extends State<SubtractionLevel2Activity3Page> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late final Future<void> _audioReady;

  bool _isLocked = false;
  bool _wrongAnswerGreyed = false;
  bool _fishVisible = false;
  bool _answerVisible = false;
  bool _showCompletePopup = false;
  final Set<int> _crossedFishIndexes = {};
  int _bouncingFishIndex = -1;
  int _audioGeneration = 0;

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

    setState(() => _fishVisible = true);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    for (var count = 1; count <= 6; count++) {
      await _bounceAndCount(count - 1, count);
      if (!mounted) return;
    }

    await _takeAwayFish(5, 'take_away_one.mp3');
    if (!mounted) return;

    await _takeAwayFish(4, 'take_away_two.mp3');
    if (!mounted) return;

    final remainingIndexes = <int>[0, 1, 2, 3];
    for (var count = 1; count <= remainingIndexes.length; count++) {
      await _bounceAndCount(remainingIndexes[count - 1], count);
      if (!mounted) return;
    }

    setState(() => _answerVisible = true);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    await _playAudio('six_minus_two_equals_four.mp3');

    if (!mounted) return;
    setState(() => _showCompletePopup = true);
  }

  Future<void> _takeAwayFish(int fishIndex, String audioFile) async {
    setState(() => _crossedFishIndexes.add(fishIndex));
    await _playAudio(audioFile);

    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 350));
  }

  Future<void> _bounceAndCount(int fishIndex, int number) async {
    setState(() => _bouncingFishIndex = fishIndex);
    final audio = _playAudio('$number.mp3');
    await Future<void>.delayed(const Duration(milliseconds: 280));

    if (!mounted) return;
    setState(() => _bouncingFishIndex = -1);
    await audio;
  }

  Future<void> _playAudio(String fileName) async {
    try {
      final generation = ++_audioGeneration;
      await _audioReady;
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('audio/$fileName'));
      await Future<void>.delayed(_audioDuration(fileName));
      if (generation == _audioGeneration) {
        await _audioPlayer.stop();
      }
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
      case 'take_away_one.mp3':
      case 'take_away_two.mp3':
        return const Duration(milliseconds: 1300);
      case 'six_minus_two_equals_four.mp3':
        return const Duration(milliseconds: 2400);
      default:
        return const Duration(milliseconds: 900);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final fishWidth = (width * 0.16).clamp(54.0, 68.0).toDouble();
          final fishHeight = fishWidth * 0.58;
          final equationLeft = width * 0.08;
          final equationRight = width * 0.08;
          final equationWidth = width - equationLeft - equationRight;
          final equationColumnWidth = equationWidth / 5;
          final fishCenterX = equationLeft + equationColumnWidth * 0.50;
          final fishStartX = fishCenterX - fishWidth / 2;
          final fishGapX = fishWidth * 1.10;
          final firstFishY = height * 0.35;
          final fishGapY = fishHeight * 1.24;

          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/subtraction_background1.png',
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
                top: height * 0.275,
                left: equationLeft,
                right: equationRight,
                child: Row(
                  children: [
                    _equationTerm('6'),
                    _equationTerm('-'),
                    _equationTerm('2'),
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
                              child: FadeTransition(
                                opacity: animation,
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
              ...List.generate(6, (index) {
                final row = index ~/ 2;
                final col = index % 2;
                return Positioned(
                  left: fishStartX + col * fishGapX,
                  top: firstFishY + row * fishGapY,
                  child: AnimatedOpacity(
                    opacity: _fishVisible ? 1 : 0,
                    duration: const Duration(milliseconds: 350),
                    child: _SubtractionFish(
                      width: fishWidth,
                      height: fishHeight,
                      crossedOut: _crossedFishIndexes.contains(index),
                      bouncing: _bouncingFishIndex == index,
                    ),
                  ),
                );
              }),
              Positioned(
                top: height * 0.61,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedOpacity(
                      opacity: _wrongAnswerGreyed ? 0.35 : 1,
                      duration: const Duration(milliseconds: 300),
                      child: _NumberChoiceButton(
                        number: 3,
                        disabled: _isLocked,
                        onTap: () => _onAnswerTapped(3),
                      ),
                    ),
                    SizedBox(width: width * 0.17),
                    _NumberChoiceButton(
                      number: 4,
                      disabled: _isLocked,
                      onTap: () => _onAnswerTapped(4),
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
                const CompletePopup(
                  module: 'subtraction',
                  levelCompleted: 2,
                  badgeName: 'subtract_badge2',
                  badgeImage: 'assets/images/subtract_badge2.png',
                  showContinueButton: false,
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

class _SubtractionFish extends StatelessWidget {
  const _SubtractionFish({
    required this.width,
    required this.height,
    required this.crossedOut,
    required this.bouncing,
  });

  final double width;
  final double height;
  final bool crossedOut;
  final bool bouncing;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: bouncing ? 1.16 : 1,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
      child: AnimatedSlide(
        offset: bouncing ? const Offset(0, -0.18) : Offset.zero,
        duration: const Duration(milliseconds: 180),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ColorFiltered(
              colorFilter: crossedOut
                  ? const ColorFilter.matrix(<double>[
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
                    ])
                  : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
              child: Image.asset(
                'assets/images/blue_fish.png',
                width: width,
                height: height,
                fit: BoxFit.contain,
              ),
            ),
            if (crossedOut)
              Text(
                'X',
                style: GoogleFonts.quicksand(
                  color: const Color(0xFF4A3728),
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
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
