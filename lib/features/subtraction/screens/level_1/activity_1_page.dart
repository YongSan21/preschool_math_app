import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/activity_progress_bar.dart';

import 'activity_2_page.dart';

class SubtractionLevel1Activity1Page extends StatefulWidget {
  const SubtractionLevel1Activity1Page({super.key});

  @override
  State<SubtractionLevel1Activity1Page> createState() =>
      _SubtractionLevel1Activity1PageState();
}

class _SubtractionLevel1Activity1PageState
    extends State<SubtractionLevel1Activity1Page> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final GlobalKey _fishBoxKey = GlobalKey();
  late final Future<void> _audioReady;

  final List<bool> _removedFish = List<bool>.filled(5, false);
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
  ) async {
    if (_processingDrag || _activityComplete || _removedFish[index]) {
      return;
    }

    final boxRect = _fishBoxRect;
    final droppedOutsideBox =
        boxRect == null ||
        !boxRect.inflate(12).contains(details.offset + const Offset(36, 24));

    if (!droppedOutsideBox) {
      return;
    }

    final overlayStart = Offset(
      details.offset.dx.clamp(0.0, screenSize.width - 72),
      details.offset.dy.clamp(0.0, screenSize.height - 50),
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

    final takeAwayAudio = _fishTaken == 1
        ? 'take_away_one.mp3'
        : 'take_away_two.mp3';
    await _playAudio(takeAwayAudio);

    if (!mounted) return;
    setState(() {
      _swimmingFish.removeWhere((fish) => fish.id == swimId);
    });

    if (_fishTaken == 2) {
      await _countRemainingFish();
      return;
    }

    if (mounted) {
      setState(() => _processingDrag = false);
    }
  }

  Future<void> _countRemainingFish() async {
    final remainingIndexes = <int>[0, 1, 2];

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
    await _playAudio('five_minus_two_equals_three.mp3');

    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SubtractionLevel1Activity2Page(),
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
        return const Duration(milliseconds: 1300);
      case 'three_fish_left.mp3':
        return const Duration(milliseconds: 1600);
      case 'five_minus_two_equals_three.mp3':
        return const Duration(milliseconds: 2600);
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
          final fishWidth = (width * 0.19).clamp(66.0, 78.0).toDouble();
          final fishHeight = fishWidth * 0.69;
          final boxWidth = width * 0.63;
          final boxHeight = height * 0.19;
          final boxLeft = (width - boxWidth) / 2;
          final boxTop = height * 0.395;

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
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(56, 10, 16, 0),
                    child: ActivityProgressBar(currentActivity: 1),
                  ),
                ),
              ),
              Positioned(
                top: height * 0.245,
                left: width * 0.16,
                right: width * 0.16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('5', style: _equationStyle),
                    Text('  -  ', style: _equationStyle),
                    Text('2', style: _equationStyle),
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
                        _answerVisible ? '3' : '?',
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
                    children: [
                      _fishInBox(
                        index: 0,
                        leftFactor: 0.024,
                        topFactor: 0.20,
                        fishWidth: fishWidth,
                        fishHeight: fishHeight,
                        highlighted: false,
                        screenSize: Size(width, height),
                      ),
                      _fishInBox(
                        index: 1,
                        leftFactor: 0.349,
                        topFactor: 0.20,
                        fishWidth: fishWidth,
                        fishHeight: fishHeight,
                        highlighted: false,
                        screenSize: Size(width, height),
                      ),
                      _fishInBox(
                        index: 2,
                        leftFactor: 0.674,
                        topFactor: 0.20,
                        fishWidth: fishWidth,
                        fishHeight: fishHeight,
                        highlighted: false,
                        screenSize: Size(width, height),
                      ),
                      _fishInBox(
                        index: 3,
                        leftFactor: 0.22,
                        topFactor: 0.58,
                        fishWidth: fishWidth,
                        fishHeight: fishHeight,
                        highlighted: true,
                        screenSize: Size(width, height),
                      ),
                      _fishInBox(
                        index: 4,
                        leftFactor: 0.52,
                        topFactor: 0.58,
                        fishWidth: fishWidth,
                        fishHeight: fishHeight,
                        highlighted: true,
                        screenSize: Size(width, height),
                      ),
                    ],
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
                              'Drag away the 2 glowing fish.',
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
      left: leftFactor * (screenSize.width * 0.63),
      top: topFactor * (screenSize.height * 0.19),
      child: canDrag
          ? Draggable<int>(
              data: index,
              feedback: Material(
                color: Colors.transparent,
                child: _FishImage(width: fishWidth, height: fishHeight),
              ),
              childWhenDragging: Opacity(opacity: 0.25, child: fish),
              onDragEnd: (details) =>
                  _handleFishDragEnd(index, details, screenSize),
              child: fish,
            )
          : fish,
    );
  }

  TextStyle get _equationStyle => GoogleFonts.quicksand(
    color: const Color(0xFF4A3728),
    fontSize: 36,
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
      'assets/images/yellow_fish.png',
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
