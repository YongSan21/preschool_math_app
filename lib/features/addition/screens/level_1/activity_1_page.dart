import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'activity_2_page.dart';

class AdditionLevel1Activity1Page extends StatefulWidget {
  const AdditionLevel1Activity1Page({super.key});

  @override
  State<AdditionLevel1Activity1Page> createState() =>
      _AdditionLevel1Activity1PageState();
}

class _AdditionLevel1Activity1PageState
    extends State<AdditionLevel1Activity1Page> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<_CarrotData> _basketCarrots = [];

  int _leftPlaced = 0;
  int _rightPlaced = 0;
  int _bouncingCarrot = -1;
  bool _processingDrop = false;
  bool _equationVisible = false;
  bool _activityComplete = false;

  bool get _rightGroupActive => _leftPlaced == 2 && !_activityComplete;

  @override
  void initState() {
    super.initState();
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _acceptCarrot(_CarrotData carrot) async {
    final correctGroup = carrot.group == 0
        ? _leftPlaced < 2
        : _leftPlaced == 2 && _rightPlaced < 3;

    if (_processingDrop || _activityComplete || !correctGroup) return;

    setState(() {
      _processingDrop = true;
      _basketCarrots.add(carrot);
      if (carrot.group == 0) {
        _leftPlaced++;
      } else {
        _rightPlaced++;
      }
    });

    final groupCount = carrot.group == 0 ? _leftPlaced : _rightPlaced;
    await _playAudio('$groupCount.mp3');
    if (!mounted) return;

    if (carrot.group == 0 && _leftPlaced == 2) {
      await _playAudio('two_carrots.mp3');
    } else if (carrot.group == 1 && _rightPlaced == 3) {
      await _playAudio('three_more_carrots.mp3');
      if (!mounted) return;
      await _countAllCarrots();
      return;
    }

    if (mounted) {
      setState(() => _processingDrop = false);
    }
  }

  Future<void> _countAllCarrots() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    for (var index = 0; index < _basketCarrots.length; index++) {
      if (!mounted) return;

      setState(() {
        _bouncingCarrot = index;
        if (index == _basketCarrots.length - 1) {
          _equationVisible = true;
        }
      });
      final audioFinished = _playAudio('${index + 1}.mp3');
      await Future<void>.delayed(const Duration(milliseconds: 260));

      if (!mounted) return;
      setState(() => _bouncingCarrot = -1);
      await audioFinished;
    }

    await _playAudio('two_and_three_make_five_altogether.mp3');
    if (!mounted) return;

    setState(() {
      _activityComplete = true;
      _processingDrop = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const AdditionLevel1Activity2Page(),
      ),
    );
  }

  Future<void> _playAudio(String fileName) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('audio/$fileName'));
      await Future<void>.delayed(_audioDuration(fileName));
    } catch (error) {
      debugPrint('Audio error for $fileName: $error');
    }
  }

  Duration _audioDuration(String fileName) {
    switch (fileName) {
      case 'two_carrots.mp3':
        return const Duration(milliseconds: 1600);
      case 'three_more_carrots.mp3':
        return const Duration(milliseconds: 1900);
      case 'two_and_three_make_five_altogether.mp3':
        return const Duration(milliseconds: 3200);
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
          final basketWidth = math.min(width * 0.75, 320.0);

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
                top: height * 0.27,
                left: 24,
                right: 24,
                child: AnimatedOpacity(
                  opacity: _equationVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 450),
                  child: AnimatedScale(
                    scale: _equationVisible ? 1 : 0.85,
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOutBack,
                    child: Text(
                      '2  +  3  =  5',
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
                top: height * 0.35,
                left: (width - basketWidth) / 2,
                width: basketWidth,
                height: basketWidth * 0.72,
                child: _BasketTarget(
                  carrots: _basketCarrots,
                  bouncingIndex: _bouncingCarrot,
                  onAccept: _acceptCarrot,
                ),
              ),
              Positioned(
                top: height * 0.64,
                left: 18,
                right: 18,
                height: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _CarrotGroup(
                      count: 2 - _leftPlaced,
                      group: 0,
                      active: !_processingDrop && _leftPlaced < 2,
                    ),
                    _CarrotGroup(
                      count: 3 - _rightPlaced,
                      group: 1,
                      active: !_processingDrop && _rightGroupActive,
                      dimmed: !_rightGroupActive && !_activityComplete,
                    ),
                  ],
                ),
              ),
              SafeArea(
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
                            'Put the 2 carrots and 3 carrots into the basket.',
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
            ],
          );
        },
      ),
    );
  }
}

class _CarrotData {
  const _CarrotData({required this.group});

  final int group;
}

class _CarrotGroup extends StatelessWidget {
  const _CarrotGroup({
    required this.count,
    required this.group,
    required this.active,
    this.dimmed = false,
  });

  final int count;
  final int group;
  final bool active;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: dimmed ? 0.32 : 1,
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.39,
        height: 120,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final preferredWidth = count == 3 ? 46.0 : 58.0;
            final availableWidth = constraints.maxWidth / math.max(count, 1);
            final carrotWidth = math.min(preferredWidth, availableWidth);

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(count, (_) {
                final carrot = _CarrotData(group: group);
                final carrotImage = Image.asset(
                  'assets/images/carrot.png',
                  width: carrotWidth,
                  height: 84,
                  fit: BoxFit.contain,
                );

                return Draggable<_CarrotData>(
                  data: carrot,
                  maxSimultaneousDrags: active ? 1 : 0,
                  feedback: Material(
                    color: Colors.transparent,
                    child: Image.asset(
                      'assets/images/carrot.png',
                      width: 58,
                      height: 84,
                      fit: BoxFit.contain,
                    ),
                  ),
                  childWhenDragging: Opacity(opacity: 0, child: carrotImage),
                  child: carrotImage,
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

class _BasketTarget extends StatelessWidget {
  const _BasketTarget({
    required this.carrots,
    required this.bouncingIndex,
    required this.onAccept,
  });

  final List<_CarrotData> carrots;
  final int bouncingIndex;
  final ValueChanged<_CarrotData> onAccept;

  static const _positions = [
    Offset(0.28, 0.31),
    Offset(0.42, 0.27),
    Offset(0.55, 0.31),
    Offset(0.67, 0.27),
    Offset(0.77, 0.33),
  ];

  @override
  Widget build(BuildContext context) {
    return DragTarget<_CarrotData>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidateData, rejectedData) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return AnimatedScale(
              scale: candidateData.isNotEmpty ? 1.03 : 1,
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
                  for (var index = 0; index < carrots.length; index++)
                    Positioned(
                      left: constraints.maxWidth * _positions[index].dx - 24,
                      top: constraints.maxHeight * _positions[index].dy - 24,
                      child: AnimatedScale(
                        scale: bouncingIndex == index ? 1.18 : 1,
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutBack,
                        child: AnimatedSlide(
                          offset: bouncingIndex == index
                              ? const Offset(0, -0.22)
                              : Offset.zero,
                          duration: const Duration(milliseconds: 180),
                          child: Image.asset(
                            'assets/images/carrot.png',
                            width: 48,
                            height: 62,
                            fit: BoxFit.contain,
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
