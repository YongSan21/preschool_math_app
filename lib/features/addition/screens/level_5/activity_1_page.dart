import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'activity_2_page.dart';

class AdditionLevel5Activity1Page extends StatefulWidget {
  const AdditionLevel5Activity1Page({super.key});

  @override
  State<AdditionLevel5Activity1Page> createState() =>
      _AdditionLevel5Activity1PageState();
}

class _AdditionLevel5Activity1PageState
    extends State<AdditionLevel5Activity1Page> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late final Future<void> _audioReady;

  int _strawberriesAdded = 0;
  int _bouncingIndex = -1;
  bool _processingDrop = false;
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

  Future<void> _acceptStrawberry(int sourceIndex) async {
    if (_processingDrop ||
        _activityComplete ||
        sourceIndex < _strawberriesAdded) {
      return;
    }

    setState(() {
      _processingDrop = true;
      _strawberriesAdded++;
      _bouncingIndex = 9 + _strawberriesAdded;
    });

    final number = 10 + _strawberriesAdded;
    final numberAudio = _playAudio('$number.mp3');
    await Future<void>.delayed(const Duration(milliseconds: 280));

    if (!mounted) return;
    setState(() => _bouncingIndex = -1);
    await numberAudio;

    if (!mounted) return;

    if (_strawberriesAdded == 4) {
      await _playAudio('great_job.mp3');
      if (!mounted) return;

      setState(() {
        _answerVisible = true;
        _activityComplete = true;
      });

      await Future<void>.delayed(const Duration(milliseconds: 450));
      await _playAudio('ten_plus_four_equals_fourteen.mp3');

      if (!mounted) return;
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AdditionLevel5Activity2Page(),
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
      await _audioPlayer.play(AssetSource('audio/$fileName'));
      await Future<void>.delayed(_audioDuration(fileName));
      await _audioPlayer.stop();
    } catch (error) {
      debugPrint('Audio error for $fileName: $error');
    }
  }

  Duration _audioDuration(String fileName) {
    switch (fileName) {
      case 'great_job.mp3':
        return const Duration(milliseconds: 1500);
      case 'ten_plus_four_equals_fourteen.mp3':
        return const Duration(milliseconds: 2900);
      default:
        return const Duration(milliseconds: 950);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE2E2),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return Stack(
            children: [
              const Positioned.fill(
                child: ColoredBox(color: Color(0xFFFFE2E2)),
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
                    onPressed: () => _returnToMap(context),
                  ),
                ),
              ),
              Positioned(
                top: height * 0.17,
                left: width * 0.12,
                right: width * 0.12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('10', style: _equationStyle),
                    Text('  +  ', style: _equationStyle),
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
                        _answerVisible ? '4' : '?',
                        key: ValueKey<bool>(_answerVisible),
                        style: _equationStyle,
                      ),
                    ),
                    Text('  =  14', style: _equationStyle),
                  ],
                ),
              ),
              Positioned(
                top: height * 0.29,
                left: width * 0.13,
                right: width * 0.13,
                height: height * 0.30,
                child: _StrawberryTarget(
                  strawberriesAdded: _strawberriesAdded,
                  bouncingIndex: _bouncingIndex,
                  onAccept: _acceptStrawberry,
                ),
              ),
              Positioned(
                top: height * 0.64,
                left: width * 0.08,
                right: width * 0.08,
                height: height * 0.095,
                child: _StrawberrySource(
                  strawberriesAdded: _strawberriesAdded,
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
                              'Add strawberries to make 14',
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

  TextStyle get _equationStyle => GoogleFonts.quicksand(
    color: const Color(0xFF4A3728),
    fontSize: 36,
    fontWeight: FontWeight.w700,
  );

  void _returnToMap(BuildContext context) {
    Navigator.pop(context);
  }
}

class _StrawberryTarget extends StatelessWidget {
  const _StrawberryTarget({
    required this.strawberriesAdded,
    required this.bouncingIndex,
    required this.onAccept,
  });

  final int strawberriesAdded;
  final int bouncingIndex;
  final ValueChanged<int> onAccept;

  @override
  Widget build(BuildContext context) {
    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => details.data >= strawberriesAdded,
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidateData, rejectedData) {
        return AnimatedScale(
          scale: candidateData.isNotEmpty ? 1.02 : 1,
          duration: const Duration(milliseconds: 150),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cellWidth = constraints.maxWidth / 5;
                final cellHeight = constraints.maxHeight / 3;
                final strawberryWidth = (cellWidth * 0.82)
                    .clamp(38.0, 50.0)
                    .toDouble();
                final strawberryHeight = strawberryWidth * 1.30;
                final total = 10 + strawberriesAdded;

                return Stack(
                  children: [
                    for (var index = 0; index < total; index++)
                      Positioned(
                        left:
                            (index % 5) * cellWidth +
                            ((cellWidth - strawberryWidth) / 2),
                        top:
                            (index ~/ 5) * cellHeight +
                            ((cellHeight - strawberryHeight) / 2),
                        child: AnimatedScale(
                          scale: bouncingIndex == index ? 1.16 : 1,
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOutBack,
                          child: AnimatedSlide(
                            offset: bouncingIndex == index
                                ? const Offset(0, -0.18)
                                : Offset.zero,
                            duration: const Duration(milliseconds: 180),
                            child: _StrawberryImage(
                              width: strawberryWidth,
                              height: strawberryHeight,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _StrawberrySource extends StatelessWidget {
  const _StrawberrySource({
    required this.strawberriesAdded,
    required this.enabled,
  });

  final int strawberriesAdded;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFC0C0C0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final slotWidth = constraints.maxWidth / 4;
          final strawberryWidth = (slotWidth * 0.62)
              .clamp(42.0, 52.0)
              .toDouble();
          final strawberryHeight = strawberryWidth * 1.30;

          return Stack(
            children: [
              for (var index = strawberriesAdded; index < 4; index++)
                Positioned(
                  left: index * slotWidth + ((slotWidth - strawberryWidth) / 2),
                  top: (constraints.maxHeight - strawberryHeight) / 2,
                  child: Draggable<int>(
                    data: index,
                    maxSimultaneousDrags: enabled ? 1 : 0,
                    feedback: Material(
                      color: Colors.transparent,
                      child: _StrawberryImage(
                        width: strawberryWidth,
                        height: strawberryHeight,
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0,
                      child: _StrawberryImage(
                        width: strawberryWidth,
                        height: strawberryHeight,
                      ),
                    ),
                    child: _StrawberryImage(
                      width: strawberryWidth,
                      height: strawberryHeight,
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

class _StrawberryImage extends StatelessWidget {
  const _StrawberryImage({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/strawberry.png',
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }
}
