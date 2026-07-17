import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:preschool_math_app/features/subtraction/screens/level_5/activity_1_page.dart';
import 'package:preschool_math_app/features/shared/screens/complete_screen.dart';
import 'package:preschool_math_app/features/shared/widgets/activity_progress_bar.dart';

class SubtractionLevel4Activity3Page extends StatefulWidget {
  const SubtractionLevel4Activity3Page({super.key});

  @override
  State<SubtractionLevel4Activity3Page> createState() =>
      _SubtractionLevel4Activity3PageState();
}

class _SubtractionLevel4Activity3PageState
    extends State<SubtractionLevel4Activity3Page> {
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

    if (selectedAnswer != 14) {
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

    for (var count = 1; count <= 17; count++) {
      await _bounceAndCount(count - 1, count);
      if (!mounted) return;
    }

    for (var index = 16; index >= 14; index--) {
      final takenNumber = 17 - index;
      await _takeAwayFish(index, _takeAwayAudioForCount(takenNumber));
      if (!mounted) return;
    }

    for (var count = 1; count <= 14; count++) {
      await _bounceAndCount(count - 1, count);
      if (!mounted) return;
    }

    setState(() => _answerVisible = true);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    await _playAudio('seventeen_minus_three_equals_fourteen.mp3');

    if (!mounted) return;
    setState(() => _showCompletePopup = true);
  }

  Future<void> _takeAwayFish(int fishIndex, String audioFile) async {
    setState(() => _crossedFishIndexes.add(fishIndex));
    await _playAudio(audioFile);

    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _bounceAndCount(int fishIndex, int number) async {
    setState(() => _bouncingFishIndex = fishIndex);
    final audio = _playAudio('$number.mp3');
    await Future<void>.delayed(const Duration(milliseconds: 280));

    if (!mounted) return;
    setState(() => _bouncingFishIndex = -1);
    await audio;
  }

  String _takeAwayAudioForCount(int count) {
    switch (count) {
      case 1:
        return 'take_away_one.mp3';
      case 2:
        return 'take_away_two.mp3';
      case 3:
      default:
        return 'take_away_three.mp3';
    }
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
      case 'take_away_three.mp3':
        return const Duration(milliseconds: 1300);
      case 'seventeen_minus_three_equals_fourteen.mp3':
        return const Duration(milliseconds: 3000);
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
          final fishWidth = (width * 0.14).clamp(48.0, 62.0).toDouble();
          final fishHeight = fishWidth * 0.70;
          final equationLeft = width * 0.08;
          final equationRight = width * 0.08;
          final equationWidth = width - equationLeft - equationRight;
          final equationColumnWidth = equationWidth / 5;
          final fishCenterX = equationLeft + equationColumnWidth * 0.50;
          final fishStartX = fishCenterX - fishWidth / 2;
          final fishGapX = fishWidth * 1.02;
          final firstFishY = height * 0.30;
          final fishGapY = fishHeight * 1.08;

          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/subtraction_background3.png',
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
                    child: ActivityProgressBar(currentActivity: 3),
                  ),
                ),
              ),
              Positioned(
                top: height * 0.20,
                left: equationLeft,
                right: equationRight,
                child: Row(
                  children: [
                    _equationTerm('17'),
                    _equationTerm('-'),
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
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            _answerVisible ? '14' : '?',
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
                final row = index ~/ 4;
                final col = index % 4;
                final rowOffsetX = row == 4 ? fishGapX * 0.5 : 0.0;

                return Positioned(
                  left: fishStartX + rowOffsetX + col * fishGapX,
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
                        number: 13,
                        disabled: _isLocked,
                        onTap: () => _onAnswerTapped(13),
                      ),
                    ),
                    SizedBox(width: width * 0.17),
                    _NumberChoiceButton(
                      number: 14,
                      disabled: _isLocked,
                      onTap: () => _onAnswerTapped(14),
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
                  module: 'subtraction',
                  levelCompleted: 4,
                  badgeName: 'subtract_badge4',
                  badgeImage: 'assets/images/subtract_badge4.png',
                  onContinue: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const SubtractionLevel5Activity1Page(),
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
    fontSize: 30,
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
                'assets/images/pink_fish.png',
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
                  fontSize: 34,
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
              fontSize: 30,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
