import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/widgets/activity_progress_bar.dart';
import 'activity_2_page.dart';

class AdditionLevel3Activity1Page extends StatefulWidget {
  const AdditionLevel3Activity1Page({super.key});

  @override
  State<AdditionLevel3Activity1Page> createState() =>
      _AdditionLevel3Activity1PageState();
}

class _AdditionLevel3Activity1PageState
    extends State<AdditionLevel3Activity1Page> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<_LemonData> _jarLemons = [];
  late final Future<void> _audioReady;

  int _leftPlaced = 0;
  int _rightPlaced = 0;
  int _bouncingLemon = -1;
  bool _processingDrop = false;
  bool _equationVisible = false;
  bool _activityComplete = false;

  bool get _rightGroupActive => _leftPlaced == 9 && !_activityComplete;

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

  Future<void> _acceptLemon(_LemonData lemon) async {
    final correctGroup = lemon.group == 0
        ? _leftPlaced < 9
        : _leftPlaced == 9 && _rightPlaced < 6;

    if (_processingDrop || _activityComplete || !correctGroup) return;

    setState(() {
      _processingDrop = true;
      _jarLemons.add(lemon);
      if (lemon.group == 0) {
        _leftPlaced++;
      } else {
        _rightPlaced++;
      }
    });

    final groupCount = lemon.group == 0 ? _leftPlaced : _rightPlaced;
    await _playAudio('$groupCount.mp3');
    if (!mounted) return;

    if (lemon.group == 0 && _leftPlaced == 9) {
      await _playAudio('nine_lemons.mp3');
    } else if (lemon.group == 1 && _rightPlaced == 6) {
      await _playAudio('six_more_lemons.mp3');
      if (!mounted) return;
      await _countAllLemons();
      return;
    }

    if (mounted) {
      setState(() => _processingDrop = false);
    }
  }

  Future<void> _countAllLemons() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    for (var index = 0; index < _jarLemons.length; index++) {
      if (!mounted) return;

      setState(() {
        _bouncingLemon = index;
        if (index == _jarLemons.length - 1) {
          _equationVisible = true;
        }
      });

      final audioFinished = _playAudio('${index + 1}.mp3');
      await Future<void>.delayed(const Duration(milliseconds: 260));

      if (!mounted) return;
      setState(() => _bouncingLemon = -1);
      await audioFinished;
    }

    await _playAudio('nine_and_six_makes_fifteen_altogether.mp3');
    if (!mounted) return;

    setState(() {
      _activityComplete = true;
      _processingDrop = false;
    });

    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const AdditionLevel3Activity2Page(),
      ),
    );
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
      case 'nine_lemons.mp3':
        return const Duration(milliseconds: 1800);
      case 'six_more_lemons.mp3':
        return const Duration(milliseconds: 2100);
      case 'nine_and_six_makes_fifteen_altogether.mp3':
        return const Duration(milliseconds: 3600);
      default:
        return const Duration(milliseconds: 950);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD3E8EC),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final jarWidth = math.min(width * 0.76, 338.0);
          final jarHeight = jarWidth * 1.11;
          final groupGap = width * 0.04;
          final groupWidth = (width - 32 - groupGap) / 2;

          return Stack(
            children: [
              const Positioned.fill(
                child: ColoredBox(color: Color(0xFFD3E8EC)),
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
                top: height * 0.12,
                left: 20,
                right: 20,
                child: AnimatedOpacity(
                  opacity: _equationVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 450),
                  child: AnimatedScale(
                    scale: _equationVisible ? 1 : 0.85,
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOutBack,
                    child: Text(
                      '9  +  6  =  15',
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
                top: height * 0.20,
                left: (width - jarWidth) / 2,
                width: jarWidth,
                height: jarHeight,
                child: _JarTarget(
                  lemons: _jarLemons,
                  bouncingIndex: _bouncingLemon,
                  onAccept: _acceptLemon,
                ),
              ),
              Positioned(
                top: height * 0.62,
                left: 16,
                width: groupWidth,
                height: height * 0.18,
                child: _LemonGroup(
                  group: 0,
                  totalLemons: 9,
                  placedLemons: _leftPlaced,
                  active: !_processingDrop && _leftPlaced < 9,
                ),
              ),
              Positioned(
                top: height * 0.62,
                right: 16,
                width: groupWidth,
                height: height * 0.18,
                child: _LemonGroup(
                  group: 1,
                  totalLemons: 6,
                  placedLemons: _rightPlaced,
                  active: !_processingDrop && _rightGroupActive,
                  dimmed: !_rightGroupActive && !_activityComplete,
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
                              'Put the 9 lemons and 6 lemons into the jar.',
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

class _LemonData {
  const _LemonData({required this.group});

  final int group;
}

class _LemonGroup extends StatelessWidget {
  const _LemonGroup({
    required this.group,
    required this.totalLemons,
    required this.placedLemons,
    required this.active,
    this.dimmed = false,
  });

  final int group;
  final int totalLemons;
  final int placedLemons;
  final bool active;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: dimmed ? 0.30 : 1,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: const Color(0xFFA4AAFF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cellWidth = constraints.maxWidth / 3;
            final cellHeight = constraints.maxHeight / 3;
            final lemonWidth = math.min(cellWidth * 0.88, 50.0);
            final lemonHeight = lemonWidth * 0.88;

            return Stack(
              children: [
                for (var index = placedLemons; index < totalLemons; index++)
                  Positioned(
                    left:
                        (index % 3) * cellWidth +
                        ((cellWidth - lemonWidth) / 2),
                    top:
                        (index ~/ 3) * cellHeight +
                        ((cellHeight - lemonHeight) / 2),
                    child: Draggable<_LemonData>(
                      data: _LemonData(group: group),
                      maxSimultaneousDrags: active ? 1 : 0,
                      feedback: Material(
                        color: Colors.transparent,
                        child: _LemonImage(
                          width: lemonWidth,
                          height: lemonHeight,
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0,
                        child: _LemonImage(
                          width: lemonWidth,
                          height: lemonHeight,
                        ),
                      ),
                      child: _LemonImage(
                        width: lemonWidth,
                        height: lemonHeight,
                      ),
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

class _JarTarget extends StatelessWidget {
  const _JarTarget({
    required this.lemons,
    required this.bouncingIndex,
    required this.onAccept,
  });

  final List<_LemonData> lemons;
  final int bouncingIndex;
  final ValueChanged<_LemonData> onAccept;

  static const List<Offset> _positions = [
    Offset(0.25, 0.35),
    Offset(0.40, 0.33),
    Offset(0.55, 0.35),
    Offset(0.70, 0.33),
    Offset(0.32, 0.47),
    Offset(0.48, 0.46),
    Offset(0.64, 0.47),
    Offset(0.24, 0.59),
    Offset(0.40, 0.58),
    Offset(0.56, 0.59),
    Offset(0.71, 0.58),
    Offset(0.32, 0.70),
    Offset(0.48, 0.70),
    Offset(0.64, 0.70),
    Offset(0.25, 0.80),
  ];

  @override
  Widget build(BuildContext context) {
    return DragTarget<_LemonData>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidateData, rejectedData) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final lemonWidth = (constraints.maxWidth * 0.13)
                .clamp(34.0, 46.0)
                .toDouble();
            final lemonHeight = lemonWidth * 0.88;

            return AnimatedScale(
              scale: candidateData.isNotEmpty ? 1.025 : 1,
              duration: const Duration(milliseconds: 150),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/jar.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  for (var index = 0; index < lemons.length; index++)
                    Positioned(
                      left:
                          constraints.maxWidth * _positions[index].dx -
                          (lemonWidth / 2),
                      top:
                          constraints.maxHeight * _positions[index].dy -
                          (lemonHeight / 2),
                      child: AnimatedScale(
                        scale: bouncingIndex == index ? 1.18 : 1,
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutBack,
                        child: AnimatedSlide(
                          offset: bouncingIndex == index
                              ? const Offset(0, -0.20)
                              : Offset.zero,
                          duration: const Duration(milliseconds: 180),
                          child: _LemonImage(
                            width: lemonWidth,
                            height: lemonHeight,
                          ),
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

class _LemonImage extends StatelessWidget {
  const _LemonImage({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/lemon.png',
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }
}
