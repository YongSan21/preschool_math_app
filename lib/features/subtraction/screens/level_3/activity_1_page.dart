import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'activity_2_page.dart';

class SubtractionLevel3Activity1Page extends StatefulWidget {
  const SubtractionLevel3Activity1Page({super.key});

  @override
  State<SubtractionLevel3Activity1Page> createState() =>
      _SubtractionLevel3Activity1PageState();
}

class _SubtractionLevel3Activity1PageState
    extends State<SubtractionLevel3Activity1Page> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final GlobalKey _fishBoxKey = GlobalKey();
  late final Future<void> _audioReady;

  final List<bool> _removedFish = List<bool>.filled(15, false);
  final List<_SwimAwayFish> _swimmingFish = [];

  int _fishTaken = 0;
  int _bouncingIndex = -1;
  bool _answerVisible = false;
  bool _processingDrag = false;
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

  Future<void> _handleFishDragEnd(
    int index,
    DraggableDetails details,
    Size screenSize,
    Size fishSize,
  ) async {
    if (_processingDrag || _activityComplete || _removedFish[index]) {
      return;
    }

    final boxRect = _fishBoxRect;
    final dropCenter =
        details.offset + Offset(fishSize.width / 2, fishSize.height / 2);
    final droppedOutsideBox =
        boxRect == null || !boxRect.inflate(12).contains(dropCenter);

    if (!droppedOutsideBox) {
      return;
    }

    final overlayStart = Offset(
      details.offset.dx.clamp(0.0, screenSize.width - fishSize.width),
      details.offset.dy.clamp(0.0, screenSize.height - fishSize.height),
    );
    final swimId = DateTime.now().microsecondsSinceEpoch;

    setState(() {
      _processingDrag = true;
      _fishTaken++;
      _removedFish[index] = true;
      _swimmingFish.add(_SwimAwayFish(id: swimId, start: overlayStart));
    });

    await Future<void>.delayed(const Duration(milliseconds: 40));
    if (!mounted) return;
    setState(() {
      final fishIndex = _swimmingFish.indexWhere((fish) => fish.id == swimId);
      if (fishIndex != -1) {
        _swimmingFish[fishIndex] = _swimmingFish[fishIndex].copyWith(
          targetLeft: -90,
          opacity: 0,
        );
      }
    });

    await _playAudio(_takeAwayAudioForCount(_fishTaken));

    if (!mounted) return;
    setState(() {
      _swimmingFish.removeWhere((fish) => fish.id == swimId);
    });

    if (_fishTaken == 4) {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      await _countRemainingFish();
      return;
    }

    if (mounted) {
      setState(() => _processingDrag = false);
    }
  }

  Future<void> _countRemainingFish() async {
    final remainingIndexes = List<int>.generate(11, (index) => index);

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
    await _playAudio('fifteen_minus_four_equals_eleven.mp3');

    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SubtractionLevel3Activity2Page(),
      ),
    );

    if (mounted) {
      setState(() => _processingDrag = false);
    }
  }

  Rect? get _fishBoxRect {
    final context = _fishBoxKey.currentContext;
    if (context == null) return null;

    final renderBox = context.findRenderObject();
    if (renderBox is! RenderBox) return null;

    final topLeft = renderBox.localToGlobal(Offset.zero);
    return topLeft & renderBox.size;
  }

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
      case 'fifteen_minus_four_equals_eleven.mp3':
        return const Duration(milliseconds: 3600);
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
          final fishWidth = (width * 0.14).clamp(46.0, 58.0).toDouble();
          final fishHeight = fishWidth * 0.66;
          final boxWidth = width * 0.68;
          final boxHeight = height * 0.35;
          final boxLeft = (width - boxWidth) / 2;
          final boxTop = height * 0.30;
          final screenSize = Size(width, height);
          final fishSize = Size(fishWidth, fishHeight);

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
                top: height * 0.20,
                left: width * 0.14,
                right: width * 0.14,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('15', style: _equationStyle),
                    Text('  -  ', style: _equationStyle),
                    Text('4', style: _equationStyle),
                    Text('  =  ', style: _equationStyle),
                    AnimatedSwitcher(
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
                        _answerVisible ? '11' : '?',
                        key: ValueKey<bool>(_answerVisible),
                        style: _equationStyle,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                key: _fishBoxKey,
                top: boxTop,
                left: boxLeft,
                width: boxWidth,
                height: boxHeight,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: List.generate(15, (index) {
                      final row = index ~/ 4;
                      final col = index % 4;
                      const columnGapFactor = 0.235;
                      final firstColumnLeftFactor =
                          (1 - (columnGapFactor * 3) - (fishWidth / boxWidth)) /
                          2;
                      final leftFactor =
                          firstColumnLeftFactor + (col * columnGapFactor);
                      final topFactor = 0.10 + (row * 0.215);

                      return _fishInBox(
                        index: index,
                        leftFactor: leftFactor,
                        topFactor: topFactor,
                        fishWidth: fishWidth,
                        fishHeight: fishHeight,
                        highlighted: index >= 11,
                        screenSize: screenSize,
                        fishSize: fishSize,
                      );
                    }),
                  ),
                ),
              ),
              for (final fish in _swimmingFish)
                AnimatedPositioned(
                  key: ValueKey<int>(fish.id),
                  duration: const Duration(milliseconds: 720),
                  curve: Curves.easeInOut,
                  left: fish.targetLeft ?? fish.start.dx,
                  top: fish.start.dy,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 720),
                    opacity: fish.opacity,
                    child: _FishImage(width: fishWidth, height: fishHeight),
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
                              'Drag away the 4 glowing fish.',
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

  Widget _fishInBox({
    required int index,
    required double leftFactor,
    required double topFactor,
    required double fishWidth,
    required double fishHeight,
    required bool highlighted,
    required Size screenSize,
    required Size fishSize,
  }) {
    if (_removedFish[index]) {
      return const SizedBox.shrink();
    }

    final canDrag = highlighted && !_processingDrag && !_activityComplete;
    final fish = _BoxFish(
      width: fishWidth,
      height: fishHeight,
      highlighted: canDrag,
      bouncing: _bouncingIndex == index,
    );

    return Positioned(
      left: leftFactor * (screenSize.width * 0.68),
      top: topFactor * (screenSize.height * 0.35),
      child: canDrag
          ? Draggable<int>(
              data: index,
              feedback: Material(
                color: Colors.transparent,
                child: _FishImage(width: fishWidth, height: fishHeight),
              ),
              childWhenDragging: Opacity(opacity: 0.25, child: fish),
              onDragEnd: (details) =>
                  _handleFishDragEnd(index, details, screenSize, fishSize),
              child: fish,
            )
          : fish,
    );
  }

  TextStyle get _equationStyle => GoogleFonts.quicksand(
    color: const Color(0xFF4A3728),
    fontSize: 32,
    fontWeight: FontWeight.w700,
  );
}

class _BoxFish extends StatelessWidget {
  const _BoxFish({
    required this.width,
    required this.height,
    required this.highlighted,
    required this.bouncing,
  });

  final double width;
  final double height;
  final bool highlighted;
  final bool bouncing;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: highlighted
            ? const [
                BoxShadow(
                  color: Color(0xFFFFF27D),
                  blurRadius: 16,
                  spreadRadius: 4,
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
          child: _FishImage(width: width, height: height),
        ),
      ),
    );
  }
}

class _FishImage extends StatelessWidget {
  const _FishImage({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/red_fish.png',
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }
}

class _SwimAwayFish {
  const _SwimAwayFish({
    required this.id,
    required this.start,
    this.targetLeft,
    this.opacity = 1,
  });

  final int id;
  final Offset start;
  final double? targetLeft;
  final double opacity;

  _SwimAwayFish copyWith({double? targetLeft, double? opacity}) {
    return _SwimAwayFish(
      id: id,
      start: start,
      targetLeft: targetLeft ?? this.targetLeft,
      opacity: opacity ?? this.opacity,
    );
  }
}
