import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/activity_progress_bar.dart';

import 'activity_3_page.dart';

class SubtractionLevel5Activity2Page extends StatefulWidget {
  const SubtractionLevel5Activity2Page({super.key});

  @override
  State<SubtractionLevel5Activity2Page> createState() =>
      _SubtractionLevel5Activity2PageState();
}

class _SubtractionLevel5Activity2PageState
    extends State<SubtractionLevel5Activity2Page> {
  static const List<String> _equations = ['12  -  4', '18  -  9', '7  -  2'];
  static const List<int> _answers = [8, 5, 9];
  static const List<int> _correctAnswerIndexes = [0, 2, 1];

  final AudioPlayer _audioPlayer = AudioPlayer();
  final Map<int, int> _matches = {};
  late final Future<void> _audioReady;

  int? _activeEquation;
  Offset? _dragPosition;
  bool _processingMatch = false;

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

  Future<void> _playAudio(String fileName) async {
    try {
      await _audioReady;
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('audio/$fileName'));
      await Future<void>.delayed(
        fileName == 'great_job.mp3'
            ? const Duration(milliseconds: 1500)
            : const Duration(milliseconds: 1100),
      );
      await _audioPlayer.stop();
    } catch (error) {
      debugPrint('Audio error for $fileName: $error');
    }
  }

  void _startDrag(Offset position, List<Rect> equationRects) {
    if (_processingMatch) return;

    for (var index = 0; index < equationRects.length; index++) {
      if (equationRects[index].contains(position) &&
          !_matches.containsKey(index)) {
        setState(() {
          _activeEquation = index;
          _dragPosition = position;
        });
        return;
      }
    }
  }

  void _updateDrag(Offset position) {
    if (_activeEquation == null) return;
    setState(() => _dragPosition = position);
  }

  Future<void> _finishDrag(Offset position, List<Rect> answerRects) async {
    final equationIndex = _activeEquation;
    if (equationIndex == null) return;

    int? answerIndex;
    for (var index = 0; index < answerRects.length; index++) {
      if (answerRects[index].inflate(12).contains(position) &&
          !_matches.containsValue(index)) {
        answerIndex = index;
        break;
      }
    }

    final isCorrect = answerIndex == _correctAnswerIndexes[equationIndex];

    setState(() {
      if (isCorrect && answerIndex != null) {
        _matches[equationIndex] = answerIndex;
      }
      _activeEquation = null;
      _dragPosition = null;
      _processingMatch = true;
    });

    await _playAudio(isCorrect ? 'great_job.mp3' : 'try_again.mp3');

    if (!mounted) return;

    if (isCorrect && _matches.length == _equations.length) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SubtractionLevel5Activity3Page(),
        ),
      );
      return;
    }

    setState(() => _processingMatch = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFFFAB),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final equationWidth = (width * 0.38).clamp(130.0, 160.0).toDouble();
          final equationHeight = (height * 0.07).clamp(54.0, 64.0).toDouble();
          final answerSize = (width * 0.17).clamp(58.0, 70.0).toDouble();
          final rowCenters = [
            Offset(width * 0.27, height * 0.24),
            Offset(width * 0.27, height * 0.40),
            Offset(width * 0.27, height * 0.56),
          ];
          final answerCenters = [
            Offset(width * 0.79, height * 0.24),
            Offset(width * 0.79, height * 0.40),
            Offset(width * 0.79, height * 0.56),
          ];
          final equationRects = rowCenters
              .map(
                (center) => Rect.fromCenter(
                  center: center,
                  width: equationWidth,
                  height: equationHeight,
                ),
              )
              .toList();
          final answerRects = answerCenters
              .map(
                (center) => Rect.fromCenter(
                  center: center,
                  width: answerSize,
                  height: answerSize,
                ),
              )
              .toList();

          return Stack(
            children: [
              const Positioned.fill(
                child: ColoredBox(color: Color(0xFFDFFFAB)),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: _MatchingLinePainter(
                    equationRects: equationRects,
                    answerRects: answerRects,
                    matches: _matches,
                    activeEquation: _activeEquation,
                    dragPosition: _dragPosition,
                  ),
                ),
              ),
              for (var index = 0; index < equationRects.length; index++)
                Positioned.fromRect(
                  rect: equationRects[index],
                  child: _EquationPill(equation: _equations[index]),
                ),
              for (var index = 0; index < answerRects.length; index++)
                Positioned.fromRect(
                  rect: answerRects[index],
                  child: _AnswerCircle(answer: _answers[index]),
                ),
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onPanStart: (details) =>
                      _startDrag(details.localPosition, equationRects),
                  onPanUpdate: (details) => _updateDrag(details.localPosition),
                  onPanEnd: (_) {
                    final position = _dragPosition;
                    if (position != null) {
                      _finishDrag(position, answerRects);
                    }
                  },
                  onPanCancel: () {
                    setState(() {
                      _activeEquation = null;
                      _dragPosition = null;
                    });
                  },
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
                    child: ActivityProgressBar(currentActivity: 2),
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
                              'Match each equation to the correct answer.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.quicksand(
                                color: Colors.black,
                                fontSize: 14,
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

class _MatchingLinePainter extends CustomPainter {
  const _MatchingLinePainter({
    required this.equationRects,
    required this.answerRects,
    required this.matches,
    required this.activeEquation,
    required this.dragPosition,
  });

  final List<Rect> equationRects;
  final List<Rect> answerRects;
  final Map<int, int> matches;
  final int? activeEquation;
  final Offset? dragPosition;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    for (final match in matches.entries) {
      canvas.drawLine(
        equationRects[match.key].centerRight,
        answerRects[match.value].centerLeft,
        paint,
      );
    }

    if (activeEquation != null && dragPosition != null) {
      canvas.drawLine(
        equationRects[activeEquation!].centerRight,
        dragPosition!,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MatchingLinePainter oldDelegate) {
    return oldDelegate.matches.length != matches.length ||
        oldDelegate.activeEquation != activeEquation ||
        oldDelegate.dragPosition != dragPosition;
  }
}

class _EquationPill extends StatelessWidget {
  const _EquationPill({required this.equation});

  final String equation;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD6E5FF),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFF6BA8FF), width: 2),
      ),
      child: Center(
        child: Text(
          equation,
          style: GoogleFonts.quicksand(
            color: const Color(0xFF4A3728),
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _AnswerCircle extends StatelessWidget {
  const _AnswerCircle({required this.answer});

  final int answer;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD6E5FF),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF6BA8FF), width: 2),
      ),
      child: Center(
        child: Text(
          answer.toString(),
          style: GoogleFonts.quicksand(
            color: const Color(0xFF4A3728),
            fontSize: 30,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
