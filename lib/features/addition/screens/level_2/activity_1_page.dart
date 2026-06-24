import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'activity_2_page.dart';

class AdditionLevel2Activity1Page extends StatefulWidget {
  const AdditionLevel2Activity1Page({super.key});

  @override
  State<AdditionLevel2Activity1Page> createState() =>
      _AdditionLevel2Activity1PageState();
}

class _AdditionLevel2Activity1PageState
    extends State<AdditionLevel2Activity1Page> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<_AppleData> _basketApples = [];

  int _leftPlaced = 0;
  int _rightPlaced = 0;
  int _bouncingApple = -1;
  bool _processingDrop = false;
  bool _equationVisible = false;
  bool _activityComplete = false;

  bool get _rightGroupActive => _leftPlaced == 6 && !_activityComplete;

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

  Future<void> _acceptApple(_AppleData apple) async {
    final correctGroup = apple.group == 0
        ? _leftPlaced < 6
        : _leftPlaced == 6 && _rightPlaced < 4;

    if (_processingDrop || _activityComplete || !correctGroup) return;

    setState(() {
      _processingDrop = true;
      _basketApples.add(apple);
      if (apple.group == 0) {
        _leftPlaced++;
      } else {
        _rightPlaced++;
      }
    });

    final groupCount = apple.group == 0 ? _leftPlaced : _rightPlaced;
    await _playAudio('$groupCount.mp3');
    if (!mounted) return;

    if (apple.group == 0 && _leftPlaced == 6) {
      await _playAudio('six_apples.mp3');
    } else if (apple.group == 1 && _rightPlaced == 4) {
      await _playAudio('four_more_apples.mp3');
      if (!mounted) return;
      await _countAllApples();
      return;
    }

    if (mounted) {
      setState(() => _processingDrop = false);
    }
  }

  Future<void> _countAllApples() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    for (var index = 0; index < _basketApples.length; index++) {
      if (!mounted) return;

      setState(() {
        _bouncingApple = index;
        if (index == _basketApples.length - 1) {
          _equationVisible = true;
        }
      });

      final audioFinished = _playAudio('${index + 1}.mp3');
      await Future<void>.delayed(const Duration(milliseconds: 260));

      if (!mounted) return;
      setState(() => _bouncingApple = -1);
      await audioFinished;
    }

    await _playAudio('six_and_four_make_ten_altogether.mp3');
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
        builder: (context) => const AdditionLevel2Activity2Page(),
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
      case 'six_apples.mp3':
        return const Duration(milliseconds: 1700);
      case 'four_more_apples.mp3':
        return const Duration(milliseconds: 1900);
      case 'six_and_four_make_ten_altogether.mp3':
        return const Duration(milliseconds: 3400);
      default:
        return const Duration(milliseconds: 950);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFFFAB),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final treeWidth = math.min(width * 0.48, 205.0);
          final treeHeight = treeWidth * 1.39;
          final basketWidth = math.min(width * 0.76, 310.0);

          return Stack(
            children: [
              const Positioned.fill(
                child: ColoredBox(color: Color(0xFFDFFFAB)),
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
                top: height * 0.12,
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
                      '6  +  4  =  10',
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
                top: height * 0.22,
                left: width * 0.02,
                width: treeWidth,
                height: treeHeight,
                child: _AppleTreeGroup(
                  group: 0,
                  totalApples: 6,
                  placedApples: _leftPlaced,
                  active: !_processingDrop && _leftPlaced < 6,
                  positions: _leftApplePositions,
                ),
              ),
              Positioned(
                top: height * 0.22,
                right: width * 0.02,
                width: treeWidth,
                height: treeHeight,
                child: _AppleTreeGroup(
                  group: 1,
                  totalApples: 4,
                  placedApples: _rightPlaced,
                  active: !_processingDrop && _rightGroupActive,
                  dimmed: !_rightGroupActive && !_activityComplete,
                  positions: _rightApplePositions,
                ),
              ),
              Positioned(
                top: height * 0.52,
                left: (width - basketWidth) / 2,
                width: basketWidth,
                height: basketWidth * 0.58,
                child: _BasketTarget(
                  apples: _basketApples,
                  bouncingIndex: _bouncingApple,
                  onAccept: _acceptApple,
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
                            'Put the 6 apples and 4 apples into the basket.',
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

const List<Offset> _leftApplePositions = [
  Offset(0.22, 0.18),
  Offset(0.45, 0.18),
  Offset(0.68, 0.18),
  Offset(0.22, 0.36),
  Offset(0.45, 0.36),
  Offset(0.68, 0.36),
];

const List<Offset> _rightApplePositions = [
  Offset(0.26, 0.18),
  Offset(0.58, 0.18),
  Offset(0.18, 0.36),
  Offset(0.70, 0.36),
];

class _AppleData {
  const _AppleData({required this.group});

  final int group;
}

class _AppleTreeGroup extends StatelessWidget {
  const _AppleTreeGroup({
    required this.group,
    required this.totalApples,
    required this.placedApples,
    required this.active,
    required this.positions,
    this.dimmed = false,
  });

  final int group;
  final int totalApples;
  final int placedApples;
  final bool active;
  final bool dimmed;
  final List<Offset> positions;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: dimmed ? 0.32 : 1,
      duration: const Duration(milliseconds: 300),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final appleSize =
              (constraints.maxWidth * 0.19).clamp(28.0, 40.0).toDouble();

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/tree.png',
                  fit: BoxFit.fill,
                ),
              ),
              for (var index = placedApples;
                  index < totalApples;
                  index++)
                Positioned(
                  left: constraints.maxWidth * positions[index].dx,
                  top: constraints.maxHeight * positions[index].dy,
                  child: Draggable<_AppleData>(
                    data: _AppleData(group: group),
                    maxSimultaneousDrags: active ? 1 : 0,
                    feedback: Material(
                      color: Colors.transparent,
                      child: Image.asset(
                        'assets/images/apple.png',
                        width: appleSize,
                        height: appleSize,
                        fit: BoxFit.contain,
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0,
                      child: _AppleImage(size: appleSize),
                    ),
                    child: _AppleImage(size: appleSize),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _BasketTarget extends StatelessWidget {
  const _BasketTarget({
    required this.apples,
    required this.bouncingIndex,
    required this.onAccept,
  });

  final List<_AppleData> apples;
  final int bouncingIndex;
  final ValueChanged<_AppleData> onAccept;

  static const _positions = [
    Offset(0.24, 0.26),
    Offset(0.36, 0.22),
    Offset(0.48, 0.25),
    Offset(0.60, 0.22),
    Offset(0.72, 0.27),
    Offset(0.30, 0.42),
    Offset(0.42, 0.39),
    Offset(0.54, 0.42),
    Offset(0.66, 0.39),
    Offset(0.76, 0.45),
  ];

  @override
  Widget build(BuildContext context) {
    return DragTarget<_AppleData>(
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
                  for (var index = 0; index < apples.length; index++)
                    Positioned(
                      left: constraints.maxWidth * _positions[index].dx - 15,
                      top: constraints.maxHeight * _positions[index].dy - 15,
                      child: AnimatedScale(
                        scale: bouncingIndex == index ? 1.18 : 1,
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutBack,
                        child: AnimatedSlide(
                          offset: bouncingIndex == index
                              ? const Offset(0, -0.22)
                              : Offset.zero,
                          duration: const Duration(milliseconds: 180),
                          child: const _AppleImage(size: 32),
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

class _AppleImage extends StatelessWidget {
  const _AppleImage({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/apple.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
