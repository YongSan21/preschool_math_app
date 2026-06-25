import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdditionLevel4Activity1Page extends StatefulWidget {
  const AdditionLevel4Activity1Page({super.key});

  @override
  State<AdditionLevel4Activity1Page> createState() =>
      _AdditionLevel4Activity1PageState();
}

class _AdditionLevel4Activity1PageState
    extends State<AdditionLevel4Activity1Page> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<_TomatoData> _basketTomatoes = [];
  late final Future<void> _audioReady;

  int _leftPlaced = 0;
  int _rightPlaced = 0;
  int _bouncingTomato = -1;
  bool _processingDrop = false;
  bool _equationVisible = false;
  bool _activityComplete = false;

  bool get _rightGroupActive => _leftPlaced == 12 && !_activityComplete;

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

  Future<void> _acceptTomato(_TomatoData tomato) async {
    final correctGroup = tomato.group == 0
        ? _leftPlaced < 12
        : _leftPlaced == 12 && _rightPlaced < 8;

    if (_processingDrop || _activityComplete || !correctGroup) return;

    setState(() {
      _processingDrop = true;
      _basketTomatoes.add(tomato);
      if (tomato.group == 0) {
        _leftPlaced++;
      } else {
        _rightPlaced++;
      }
    });

    final groupCount = tomato.group == 0 ? _leftPlaced : _rightPlaced;
    await _playAudio('$groupCount.mp3');
    if (!mounted) return;

    if (tomato.group == 0 && _leftPlaced == 12) {
      await _playAudio('twelve_tomatoes.mp3');
    } else if (tomato.group == 1 && _rightPlaced == 8) {
      await _playAudio('eight_more_tomatoes.mp3');
      if (!mounted) return;
      await _countAllTomatoes();
      return;
    }

    if (mounted) {
      setState(() => _processingDrop = false);
    }
  }

  Future<void> _countAllTomatoes() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    for (var index = 0; index < _basketTomatoes.length; index++) {
      if (!mounted) return;

      setState(() {
        _bouncingTomato = index;
        if (index == _basketTomatoes.length - 1) {
          _equationVisible = true;
        }
      });

      final audioFinished = _playAudio('${index + 1}.mp3');
      await Future<void>.delayed(const Duration(milliseconds: 260));

      if (!mounted) return;
      setState(() => _bouncingTomato = -1);
      await audioFinished;
    }

    await _playAudio('twelve_and_eight_make_twenty_altogether.mp3');
    if (!mounted) return;

    setState(() {
      _activityComplete = true;
      _processingDrop = false;
    });
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
      case 'twelve_tomatoes.mp3':
        return const Duration(milliseconds: 1900);
      case 'eight_more_tomatoes.mp3':
        return const Duration(milliseconds: 2200);
      case 'twelve_and_eight_make_twenty_altogether.mp3':
        return const Duration(milliseconds: 3800);
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
          final groupGap = width * 0.04;
          final groupWidth = (width - 32 - groupGap) / 2;
          final basketWidth = math.min(width * 0.75, 299.0);

          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/addition_background1.png',
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
                top: height * 0.105,
                left: 16,
                right: 16,
                child: AnimatedOpacity(
                  opacity: _equationVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 450),
                  child: AnimatedScale(
                    scale: _equationVisible ? 1 : 0.85,
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOutBack,
                    child: Text(
                      '12  +  8  =  20',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        color: const Color(0xFF4A3728),
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: height * 0.23,
                left: 16,
                width: groupWidth,
                height: height * 0.27,
                child: _TomatoGroup(
                  group: 0,
                  totalTomatoes: 12,
                  placedTomatoes: _leftPlaced,
                  active: !_processingDrop && _leftPlaced < 12,
                ),
              ),
              Positioned(
                top: height * 0.23,
                right: 16,
                width: groupWidth,
                height: height * 0.27,
                child: _TomatoGroup(
                  group: 1,
                  totalTomatoes: 8,
                  placedTomatoes: _rightPlaced,
                  active: !_processingDrop && _rightGroupActive,
                  dimmed: !_rightGroupActive && !_activityComplete,
                ),
              ),
              Positioned(
                top: height * 0.52,
                left: (width - basketWidth) / 2,
                width: basketWidth,
                height: basketWidth * 0.72,
                child: _BasketTarget(
                  tomatoes: _basketTomatoes,
                  bouncingIndex: _bouncingTomato,
                  onAccept: _acceptTomato,
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
                              'Put the 12 tomatoes and 8 tomatoes into the basket.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.quicksand(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                height: 1.30,
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
}

class _TomatoData {
  const _TomatoData({required this.group});

  final int group;
}

class _TomatoGroup extends StatelessWidget {
  const _TomatoGroup({
    required this.group,
    required this.totalTomatoes,
    required this.placedTomatoes,
    required this.active,
    this.dimmed = false,
  });

  final int group;
  final int totalTomatoes;
  final int placedTomatoes;
  final bool active;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: dimmed ? 0.30 : 1,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const columns = 4;
            final rows = (totalTomatoes / columns).ceil();
            final cellWidth = constraints.maxWidth / columns;
            final cellHeight = constraints.maxHeight / rows;
            final tomatoSize = math.min(cellWidth * 0.86, cellHeight * 0.78);

            return Stack(
              children: [
                for (var index = placedTomatoes; index < totalTomatoes; index++)
                  Positioned(
                    left:
                        (index % columns) * cellWidth +
                        ((cellWidth - tomatoSize) / 2),
                    top:
                        (index ~/ columns) * cellHeight +
                        ((cellHeight - tomatoSize) / 2),
                    child: Draggable<_TomatoData>(
                      data: _TomatoData(group: group),
                      maxSimultaneousDrags: active ? 1 : 0,
                      feedback: Material(
                        color: Colors.transparent,
                        child: _TomatoImage(size: tomatoSize),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0,
                        child: _TomatoImage(size: tomatoSize),
                      ),
                      child: _TomatoImage(size: tomatoSize),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BasketTarget extends StatelessWidget {
  const _BasketTarget({
    required this.tomatoes,
    required this.bouncingIndex,
    required this.onAccept,
  });

  final List<_TomatoData> tomatoes;
  final int bouncingIndex;
  final ValueChanged<_TomatoData> onAccept;

  static const List<Offset> _positions = [
    Offset(0.26, 0.28),
    Offset(0.38, 0.28),
    Offset(0.50, 0.28),
    Offset(0.62, 0.28),
    Offset(0.74, 0.28),
    Offset(0.26, 0.40),
    Offset(0.38, 0.40),
    Offset(0.50, 0.40),
    Offset(0.62, 0.40),
    Offset(0.74, 0.40),
    Offset(0.26, 0.52),
    Offset(0.38, 0.52),
    Offset(0.50, 0.52),
    Offset(0.62, 0.52),
    Offset(0.74, 0.52),
    Offset(0.26, 0.64),
    Offset(0.38, 0.64),
    Offset(0.50, 0.64),
    Offset(0.62, 0.64),
    Offset(0.74, 0.64),
  ];

  @override
  Widget build(BuildContext context) {
    return DragTarget<_TomatoData>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidateData, rejectedData) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final tomatoSize = (constraints.maxWidth * 0.105)
                .clamp(27.0, 34.0)
                .toDouble();

            return AnimatedScale(
              scale: candidateData.isNotEmpty ? 1.025 : 1,
              duration: const Duration(milliseconds: 150),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/basket.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                  for (var index = 0; index < tomatoes.length; index++)
                    Positioned(
                      left:
                          constraints.maxWidth * _positions[index].dx -
                          (tomatoSize / 2),
                      top:
                          constraints.maxHeight * _positions[index].dy -
                          (tomatoSize / 2),
                      child: AnimatedScale(
                        scale: bouncingIndex == index ? 1.18 : 1,
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutBack,
                        child: AnimatedSlide(
                          offset: bouncingIndex == index
                              ? const Offset(0, -0.20)
                              : Offset.zero,
                          duration: const Duration(milliseconds: 180),
                          child: _TomatoImage(size: tomatoSize),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _TomatoImage extends StatelessWidget {
  const _TomatoImage({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/tomato.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
