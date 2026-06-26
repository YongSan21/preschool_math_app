import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'activity_3_page.dart';

class SubtractionLevel1Activity2Page extends StatefulWidget {
  const SubtractionLevel1Activity2Page({super.key});

  @override
  State<SubtractionLevel1Activity2Page> createState() =>
      _SubtractionLevel1Activity2PageState();
}

class _SubtractionLevel1Activity2PageState
    extends State<SubtractionLevel1Activity2Page> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late final Future<void> _audioReady;

  bool _fishTaken = false;
  bool _answerVisible = false;
  bool _processingTap = false;
  bool _activityComplete = false;
  int _bouncingIndex = -1;

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

  Future<void> _takeAwayFish() async {
    if (_processingTap || _activityComplete || _fishTaken) {
      return;
    }

    setState(() {
      _processingTap = true;
      _fishTaken = true;
    });

    await _playAudio('take_away_one.mp3');
    await _countRemainingFish();
  }

  Future<void> _countRemainingFish() async {
    for (var count = 1; count <= 3; count++) {
      if (!mounted) return;
      setState(() => _bouncingIndex = count - 1);

      final numberAudio = _playAudio('$count.mp3');
      await Future<void>.delayed(const Duration(milliseconds: 280));

      if (!mounted) return;
      setState(() => _bouncingIndex = -1);
      await numberAudio;
    }

    if (!mounted) return;
    setState(() {
      _answerVisible = true;
      _activityComplete = true;
    });

    await _playAudio('four_minus_one_equals_three.mp3');

    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SubtractionLevel1Activity3Page(),
      ),
    );

    if (mounted) {
      setState(() => _processingTap = false);
    }
  }

  Future<void> _playAudio(String fileName) async {
    try {
      await _audioReady;
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('audio/$fileName'));
      await Future<void>.delayed(_audioDuration(fileName));
      await _audioPlayer.stop();
    } catch (error) {
      debugPrint('Audio error for $fileName: $error');
    }
  }

  Duration _audioDuration(String fileName) {
    switch (fileName) {
      case 'take_away_one.mp3':
        return const Duration(milliseconds: 1300);
      case 'three_fish_left.mp3':
        return const Duration(milliseconds: 1600);
      case 'four_minus_one_equals_three.mp3':
        return const Duration(milliseconds: 3400);
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
          final fishWidth = (width * 0.225).clamp(78.0, 94.0).toDouble();
          final fishHeight = fishWidth * 0.84;
          final fishStep = fishHeight * 0.92;

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
              Positioned(
                top: height * 0.255,
                left: width * 0.08,
                right: width * 0.08,
                child: Row(
                  children: [
                    _equationTerm('4'),
                    _equationTerm('-'),
                    _equationTerm('1'),
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
                            _answerVisible ? '3' : '?',
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
                top: height * 0.345,
                left: width * 0.06,
                width: fishWidth + 16,
                height: fishStep * 3 + fishHeight + 16,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: List.generate(4, (index) {
                    return Positioned(
                      top: index * fishStep,
                      left: 0,
                      child: _TappablePufferfish(
                        width: fishWidth,
                        height: fishHeight,
                        active:
                            index == 3 &&
                            !_fishTaken &&
                            !_processingTap &&
                            !_activityComplete,
                        crossedOut: index == 3 && _fishTaken,
                        bouncing: _bouncingIndex == index,
                        onTap: _takeAwayFish,
                      ),
                    );
                  }),
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
                              'Tap 1 fish to take it away.',
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

class _TappablePufferfish extends StatelessWidget {
  const _TappablePufferfish({
    required this.width,
    required this.height,
    required this.active,
    required this.crossedOut,
    required this.bouncing,
    required this.onTap,
  });

  final double width;
  final double height;
  final bool active;
  final bool crossedOut;
  final bool bouncing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: active ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
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
            offset: bouncing ? const Offset(0, -0.16) : Offset.zero,
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
                      : const ColorFilter.mode(
                          Colors.transparent,
                          BlendMode.dst,
                        ),
                  child: Image.asset(
                    'assets/images/pufferfish.png',
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
                      fontSize: 46,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
