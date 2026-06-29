import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'activity_2_page.dart';

class SubtractionLevel5Activity1Page extends StatefulWidget {
  const SubtractionLevel5Activity1Page({super.key});

  @override
  State<SubtractionLevel5Activity1Page> createState() =>
      _SubtractionLevel5Activity1PageState();
}

class _SubtractionLevel5Activity1PageState
    extends State<SubtractionLevel5Activity1Page> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late final Future<void> _audioReady;

  int _fishPlaced = 0;
  int _bouncingSlot = -1;
  final Set<int> _draggedFishIndexes = {};
  bool _processingDrop = false;
  bool _answerVisible = false;
  bool _fishSwamAway = false;
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

  Future<void> _acceptFish(int sourceIndex) async {
    if (_processingDrop ||
        _activityComplete ||
        _draggedFishIndexes.contains(sourceIndex)) {
      return;
    }

    setState(() {
      _processingDrop = true;
      _draggedFishIndexes.add(sourceIndex);
      _fishPlaced++;
      _bouncingSlot = _fishPlaced - 1;
    });

    final numberAudio = _playAudio('$_fishPlaced.mp3');
    await Future<void>.delayed(const Duration(milliseconds: 280));

    if (!mounted) return;
    setState(() => _bouncingSlot = -1);
    await numberAudio;

    if (!mounted) return;

    if (_fishPlaced == 6) {
      await Future<void>.delayed(const Duration(milliseconds: 450));
      if (!mounted) return;

      setState(() => _fishSwamAway = true);
      await _playAudio('six_fish_swam_away.mp3');

      if (!mounted) return;
      setState(() {
        _answerVisible = true;
        _activityComplete = true;
      });

      await Future<void>.delayed(const Duration(milliseconds: 450));
      await _playAudio('fourteen_minus_six_equals_eight.mp3');

      if (!mounted) return;
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SubtractionLevel5Activity2Page(),
        ),
      );
    }

    if (mounted) {
      setState(() => _processingDrop = false);
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
      case 'six_fish_swam_away.mp3':
        return const Duration(milliseconds: 2000);
      case 'fourteen_minus_six_equals_eight.mp3':
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
                top: height * 0.125,
                left: width * 0.12,
                right: width * 0.12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('14', style: _equationStyle),
                    Text('  -  ', style: _equationStyle),
                    AnimatedSwitcher(
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
                        _answerVisible ? '6' : '?',
                        key: ValueKey<bool>(_answerVisible),
                        style: _equationStyle,
                      ),
                    ),
                    Text('  =  8', style: _equationStyle),
                  ],
                ),
              ),
              Positioned(
                top: height * 0.22,
                left: width * 0.12,
                right: width * 0.12,
                height: height * 0.30,
                child: _FishTargetBox(
                  fishPlaced: _fishPlaced,
                  bouncingSlot: _bouncingSlot,
                  fishSwamAway: _fishSwamAway,
                  onAccept: _acceptFish,
                ),
              ),
              Positioned(
                top: height * 0.54,
                left: width * 0.09,
                right: width * 0.07,
                height: height * 0.20,
                child: _FishSourceArea(
                  draggedFishIndexes: _draggedFishIndexes,
                  enabled: !_processingDrop && !_activityComplete,
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
                              'How many fish swam away? Drag them out.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.quicksand(
                                color: Colors.black,
                                fontSize: 14,
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

  TextStyle get _equationStyle => GoogleFonts.quicksand(
    color: const Color(0xFF4A3728),
    fontSize: 32,
    fontWeight: FontWeight.w700,
  );
}

class _FishTargetBox extends StatelessWidget {
  const _FishTargetBox({
    required this.fishPlaced,
    required this.bouncingSlot,
    required this.fishSwamAway,
    required this.onAccept,
  });

  final int fishPlaced;
  final int bouncingSlot;
  final bool fishSwamAway;
  final ValueChanged<int> onAccept;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fishWidth = (constraints.maxWidth * 0.20)
              .clamp(42.0, 56.0)
              .toDouble();
          final fishHeight = fishWidth * 0.66;
          final cellWidth = constraints.maxWidth / 4;
          final cellHeight = constraints.maxHeight / 4;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              for (var index = 0; index < 8; index++)
                Positioned(
                  left: (index % 4) * cellWidth + (cellWidth - fishWidth) / 2,
                  top:
                      (index ~/ 4) * cellHeight + (cellHeight - fishHeight) / 2,
                  child: _FishImage(width: fishWidth, height: fishHeight),
                ),
              for (var index = 0; index < 6; index++)
                Positioned(
                  left:
                      (index % 3) * cellWidth +
                      (cellWidth - fishWidth) / 2 +
                      (cellWidth * 0.5),
                  top:
                      (index ~/ 3 + 2) * cellHeight +
                      (cellHeight - fishHeight) / 2,
                  child: _FishSlot(
                    index: index,
                    fishPlaced: fishPlaced,
                    bouncing: bouncingSlot == index,
                    fishSwamAway: fishSwamAway,
                    fishWidth: fishWidth,
                    fishHeight: fishHeight,
                    onAccept: onAccept,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _FishSlot extends StatelessWidget {
  const _FishSlot({
    required this.index,
    required this.fishPlaced,
    required this.bouncing,
    required this.fishSwamAway,
    required this.fishWidth,
    required this.fishHeight,
    required this.onAccept,
  });

  final int index;
  final int fishPlaced;
  final bool bouncing;
  final bool fishSwamAway;
  final double fishWidth;
  final double fishHeight;
  final ValueChanged<int> onAccept;

  @override
  Widget build(BuildContext context) {
    final filled = index < fishPlaced;
    final canAccept = index == fishPlaced && !fishSwamAway;

    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => canAccept,
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidateData, rejectedData) {
        return AnimatedScale(
          scale: candidateData.isNotEmpty ? 1.08 : 1,
          duration: const Duration(milliseconds: 150),
          child: Container(
            width: fishWidth + 10,
            height: fishHeight + 10,
            decoration: BoxDecoration(
              border: Border.all(
                color: filled ? Colors.transparent : const Color(0xFFBFC7C9),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: AnimatedOpacity(
                opacity: filled && !fishSwamAway ? 1 : 0,
                duration: const Duration(milliseconds: 550),
                child: AnimatedSlide(
                  offset: fishSwamAway ? const Offset(-2.8, 0) : Offset.zero,
                  duration: const Duration(milliseconds: 850),
                  curve: Curves.easeInOut,
                  child: AnimatedScale(
                    scale: bouncing ? 1.16 : 1,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutBack,
                    child: _FishImage(width: fishWidth, height: fishHeight),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FishSourceArea extends StatelessWidget {
  const _FishSourceArea({
    required this.draggedFishIndexes,
    required this.enabled,
  });

  final Set<int> draggedFishIndexes;
  final bool enabled;

  static const List<Offset> _positions = [
    Offset(0.04, 0.28),
    Offset(0.27, 0.05),
    Offset(0.63, 0.20),
    Offset(0.88, 0.00),
    Offset(0.12, 0.62),
    Offset(0.48, 0.52),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fishWidth = (constraints.maxWidth * 0.18)
            .clamp(46.0, 62.0)
            .toDouble();
        final fishHeight = fishWidth * 0.66;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            for (var index = 0; index < 6; index++)
              if (!draggedFishIndexes.contains(index))
                Positioned(
                  left: _positions[index].dx * constraints.maxWidth,
                  top: _positions[index].dy * constraints.maxHeight,
                  child: Draggable<int>(
                    data: index,
                    maxSimultaneousDrags: enabled ? 1 : 0,
                    feedback: Material(
                      color: Colors.transparent,
                      child: _FishImage(width: fishWidth, height: fishHeight),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0,
                      child: _FishImage(width: fishWidth, height: fishHeight),
                    ),
                    child: _FishImage(width: fishWidth, height: fishHeight),
                  ),
                ),
          ],
        );
      },
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
      'assets/images/orange_fish.png',
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }
}
