import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/activity_progress_bar.dart';

import 'activity_3_page.dart';

class AdditionLevel4Activity2Page extends StatefulWidget {
  const AdditionLevel4Activity2Page({super.key});

  @override
  State<AdditionLevel4Activity2Page> createState() =>
      _AdditionLevel4Activity2PageState();
}

class _AdditionLevel4Activity2PageState
    extends State<AdditionLevel4Activity2Page> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<bool> _tappedLemons = List<bool>.filled(16, false);
  late final Future<void> _audioReady;

  int _currentCount = 0;
  int _bouncingIndex = -1;
  bool _rightGroupUnlocked = false;
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

  Future<void> _tapLemon(int index) async {
    final isLeftLemon = index < 10;
    final canTap = isLeftLemon ? !_rightGroupUnlocked : _rightGroupUnlocked;

    if (_processingTap ||
        _activityComplete ||
        _tappedLemons[index] ||
        !canTap) {
      return;
    }

    setState(() {
      _processingTap = true;
      _tappedLemons[index] = true;
      _currentCount++;
      _bouncingIndex = index;
    });

    final numberAudio = _playAudio('$_currentCount.mp3');
    await Future<void>.delayed(const Duration(milliseconds: 260));

    if (!mounted) return;
    setState(() => _bouncingIndex = -1);
    await numberAudio;

    if (!mounted) return;

    if (_currentCount == 10) {
      setState(() {
        _rightGroupUnlocked = true;
        _processingTap = false;
      });
      return;
    }

    if (_currentCount == 16) {
      setState(() {
        _answerVisible = true;
        _activityComplete = true;
      });

      await _playAudio('great_job.mp3');
      await _playAudio('ten_plus_six_equals_sixteen.mp3');

      if (!mounted) return;
      setState(() => _processingTap = false);
      await Future<void>.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AdditionLevel4Activity3Page(),
        ),
      );
      return;
    }

    setState(() => _processingTap = false);
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
      case 'ten_plus_six_equals_sixteen.mp3':
        return const Duration(milliseconds: 3000);
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
          final lemonWidth = (width * 0.155).clamp(53.0, 62.0).toDouble();
          final lemonHeight = lemonWidth * 0.88;
          final equationLeft = width * 0.08;
          final equationRight = width * 0.06;
          final equationWidth = width - equationLeft - equationRight;
          final equationColumnWidth = equationWidth / 5;
          final leftGroupCenterX = equationLeft + (equationColumnWidth * 0.5);
          final rightGroupCenterX = equationLeft + (equationColumnWidth * 2.5);
          final groupWidth = lemonWidth * 2.05;

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
                    child: ActivityProgressBar(currentActivity: 2),
                  ),
                ),
              ),
              Positioned(
                top: height * 0.26,
                left: equationLeft,
                right: equationRight,
                child: Row(
                  children: [
                    _equationTerm('10'),
                    _equationTerm('+'),
                    _equationTerm('6'),
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
                              child: child,
                            );
                          },
                          child: Text(
                            _answerVisible ? '16' : '?',
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
                top: height * 0.35,
                left: leftGroupCenterX - (groupWidth / 2),
                width: groupWidth,
                height: height * 0.38,
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 1,
                    crossAxisSpacing: 1,
                  ),
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return Center(
                      child: _TappableLemon(
                        width: lemonWidth,
                        height: lemonHeight,
                        active:
                            !_rightGroupUnlocked &&
                            !_activityComplete &&
                            !_tappedLemons[index],
                        bouncing: _bouncingIndex == index,
                        onTap: () => _tapLemon(index),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: height * 0.35,
                left: rightGroupCenterX - (groupWidth / 2),
                width: groupWidth,
                height: height * 0.24,
                child: AnimatedOpacity(
                  opacity: _rightGroupUnlocked ? 1 : 0.30,
                  duration: const Duration(milliseconds: 350),
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 1,
                          crossAxisSpacing: 1,
                        ),
                    itemCount: 6,
                    itemBuilder: (context, groupIndex) {
                      final index = groupIndex + 10;
                      return Center(
                        child: _TappableLemon(
                          width: lemonWidth,
                          height: lemonHeight,
                          active:
                              _rightGroupUnlocked &&
                              !_activityComplete &&
                              !_tappedLemons[index],
                          bouncing: _bouncingIndex == index,
                          onTap: () => _tapLemon(index),
                        ),
                      );
                    },
                  ),
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
                              'Tap the lemons. How many are there altogether?',
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

  Widget _equationTerm(String value) {
    return Expanded(
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(value, style: _equationStyle),
        ),
      ),
    );
  }

  TextStyle get _equationStyle => GoogleFonts.quicksand(
    color: const Color(0xFF4A3728),
    fontSize: 36,
    fontWeight: FontWeight.w700,
  );
}

class _TappableLemon extends StatelessWidget {
  const _TappableLemon({
    required this.width,
    required this.height,
    required this.active,
    required this.bouncing,
    required this.onTap,
  });

  final double width;
  final double height;
  final bool active;
  final bool bouncing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: active ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: width,
        height: height,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
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
            offset: bouncing ? const Offset(0, -0.18) : Offset.zero,
            duration: const Duration(milliseconds: 180),
            child: Image.asset('assets/images/lemon.png', fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
