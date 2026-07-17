import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/activity_progress_bar.dart';

import 'activity_3_page.dart';

class SubtractionLevel4Activity2Page extends StatefulWidget {
  const SubtractionLevel4Activity2Page({super.key});

  @override
  State<SubtractionLevel4Activity2Page> createState() =>
      _SubtractionLevel4Activity2PageState();
}

class _SubtractionLevel4Activity2PageState
    extends State<SubtractionLevel4Activity2Page> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late final Future<void> _audioReady;

  final Set<int> _crossedFishIndexes = {};
  int _takenCount = 0;
  int _bouncingIndex = -1;
  bool _processingTap = false;
  bool _answerVisible = false;
  bool _activityComplete = false;

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

  Future<void> _takeAwayFish(int index) async {
    if (_processingTap ||
        _activityComplete ||
        _crossedFishIndexes.contains(index) ||
        !_isTakeAwayFish(index)) {
      return;
    }

    setState(() {
      _processingTap = true;
      _takenCount++;
      _crossedFishIndexes.add(index);
    });

    await _playAudio(_takeAwayAudioForCount(_takenCount));
    if (!mounted) return;

    if (_takenCount == 4) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      await _countRemainingFish();
      return;
    }

    setState(() => _processingTap = false);
  }

  Future<void> _countRemainingFish() async {
    final remainingIndexes = List<int>.generate(12, (index) => index);

    for (var count = 1; count <= remainingIndexes.length; count++) {
      if (!mounted) return;
      setState(() => _bouncingIndex = remainingIndexes[count - 1]);

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

    await Future<void>.delayed(const Duration(milliseconds: 350));
    await _playAudio('sixteen_minus_four_equals_twelve.mp3');

    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SubtractionLevel4Activity3Page(),
      ),
    );

    if (mounted) {
      setState(() => _processingTap = false);
    }
  }

  bool _isTakeAwayFish(int index) => index >= 12;

  String _takeAwayAudioForCount(int count) {
    switch (count) {
      case 1:
        return 'take_away_one.mp3';
      case 2:
        return 'take_away_two.mp3';
      case 3:
        return 'take_away_three.mp3';
      case 4:
      default:
        return 'take_away_four.mp3';
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
      case 'take_away_two.mp3':
      case 'take_away_three.mp3':
      case 'take_away_four.mp3':
        return const Duration(milliseconds: 1300);
      case 'sixteen_minus_four_equals_twelve.mp3':
        return const Duration(milliseconds: 3000);
      default:
        return const Duration(milliseconds: 900);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCFF7FF),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final fishWidth = (width * 0.17).clamp(58.0, 74.0).toDouble();
          final fishHeight = fishWidth * 0.58;
          final equationLeft = width * 0.08;
          final equationRight = width * 0.08;
          final equationWidth = width - equationLeft - equationRight;
          final equationColumnWidth = equationWidth / 5;
          final fishCenterX = equationLeft + equationColumnWidth * 0.50;
          final fishStartX = fishCenterX - fishWidth / 2;
          final fishGapX = fishWidth * 1.04;
          final firstFishY = height * 0.31;
          final fishGapY = fishHeight * 1.12;

          return Stack(
            children: [
              const Positioned.fill(
                child: ColoredBox(color: Color(0xFFCFF7FF)),
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
                top: height * 0.22,
                left: equationLeft,
                right: equationRight,
                child: Row(
                  children: [
                    _equationTerm('16'),
                    _equationTerm('-'),
                    _equationTerm('4'),
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
                            _answerVisible ? '12' : '?',
                            key: ValueKey<bool>(_answerVisible),
                            style: _equationStyle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...List.generate(16, (index) {
                final row = index ~/ 4;
                final col = index % 4;
                final isActive =
                    _isTakeAwayFish(index) &&
                    !_crossedFishIndexes.contains(index) &&
                    !_processingTap &&
                    !_activityComplete;

                return Positioned(
                  left: fishStartX + col * fishGapX,
                  top: firstFishY + row * fishGapY,
                  child: _TappableBlueFish(
                    width: fishWidth,
                    height: fishHeight,
                    active: isActive,
                    crossedOut: _crossedFishIndexes.contains(index),
                    bouncing: _bouncingIndex == index,
                    onTap: () => _takeAwayFish(index),
                  ),
                );
              }),
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
                              'Tap the 4 glowing fish to take them away.',
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

class _TappableBlueFish extends StatelessWidget {
  const _TappableBlueFish({
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
        padding: const EdgeInsets.all(4),
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
                      fontSize: 34,
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
