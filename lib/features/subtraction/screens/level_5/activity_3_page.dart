import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:preschool_math_app/features/shared/screens/complete_screen.dart';
import 'package:preschool_math_app/features/shared/widgets/activity_progress_bar.dart';

class SubtractionLevel5Activity3Page extends StatefulWidget {
  const SubtractionLevel5Activity3Page({super.key});

  @override
  State<SubtractionLevel5Activity3Page> createState() =>
      _SubtractionLevel5Activity3PageState();
}

class _SubtractionLevel5Activity3PageState
    extends State<SubtractionLevel5Activity3Page> {
  static const List<_EquationData> _equations = [
    _EquationData(expression: '19  -  7', answer: 12, color: Color(0xFFF5DBEF)),
    _EquationData(expression: '10  -  3', answer: 7, color: Color(0xFFCAEAFF)),
    _EquationData(expression: '15  -  9', answer: 6, color: Color(0xFFCBF7AD)),
  ];
  static const List<int> _choices = [6, 12, 7];

  final AudioPlayer _audioPlayer = AudioPlayer();
  final Map<int, int> _filledAnswers = {};
  late final Future<void> _audioReady;

  bool _processingDrop = false;
  bool _showCompletePopup = false;

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

  Future<void> _handleDrop({
    required int equationIndex,
    required int answer,
  }) async {
    if (_processingDrop || _filledAnswers.containsKey(equationIndex)) return;

    final isCorrect = _equations[equationIndex].answer == answer;

    if (!isCorrect) {
      setState(() => _processingDrop = true);
      await _playAudio('try_again.mp3');
      if (mounted) {
        setState(() => _processingDrop = false);
      }
      return;
    }

    setState(() {
      _processingDrop = true;
      _filledAnswers[equationIndex] = answer;
    });

    await _playAudio('great_job.mp3');
    if (!mounted) return;

    setState(() {
      _processingDrop = false;
      if (_filledAnswers.length == _equations.length) {
        _showCompletePopup = true;
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFACE),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return Stack(
            children: [
              const Positioned.fill(
                child: ColoredBox(color: Color(0xFFFEFACE)),
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
                    child: ActivityProgressBar(currentActivity: 3),
                  ),
                ),
              ),
              Positioned(
                top: height * 0.18,
                left: width * 0.07,
                right: width * 0.07,
                height: height * 0.40,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_equations.length, (index) {
                    return _EquationRow(
                      data: _equations[index],
                      filledAnswer: _filledAnswers[index],
                      enabled: !_processingDrop,
                      onAccept: (answer) =>
                          _handleDrop(equationIndex: index, answer: answer),
                    );
                  }),
                ),
              ),
              Positioned(
                top: height * 0.63,
                left: width * 0.09,
                right: width * 0.09,
                height: 58,
                child: _AnswerChoiceBar(
                  choices: _choices,
                  usedAnswers: _filledAnswers.values.toSet(),
                  enabled: !_processingDrop,
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
              if (_showCompletePopup)
                const CompletePopup(
                  module: 'subtraction',
                  levelCompleted: 5,
                  badgeName: 'subtract_badge5',
                  badgeImage: 'assets/images/subtract_badge5.png',
                  showContinueButton: false,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _EquationData {
  const _EquationData({
    required this.expression,
    required this.answer,
    required this.color,
  });

  final String expression;
  final int answer;
  final Color color;
}

class _EquationRow extends StatelessWidget {
  const _EquationRow({
    required this.data,
    required this.filledAnswer,
    required this.enabled,
    required this.onAccept,
  });

  final _EquationData data;
  final int? filledAnswer;
  final bool enabled;
  final ValueChanged<int> onAccept;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 58,
              decoration: BoxDecoration(
                color: data.color,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    data.expression,
                    style: GoogleFonts.quicksand(
                      color: const Color(0xFF4A3728),
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Text(
            '=',
            style: GoogleFonts.quicksand(
              color: const Color(0xFF4A3728),
              fontSize: 34,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 18),
          DragTarget<int>(
            onWillAcceptWithDetails: (_) => enabled && filledAnswer == null,
            onAcceptWithDetails: (details) => onAccept(details.data),
            builder: (context, candidateData, rejectedData) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 64,
                height: 58,
                decoration: BoxDecoration(
                  color: data.color,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: candidateData.isNotEmpty
                        ? const Color(0xFF4A3728)
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Text(
                    filledAnswer?.toString() ?? '',
                    style: GoogleFonts.quicksand(
                      color: const Color(0xFF4A3728),
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AnswerChoiceBar extends StatelessWidget {
  const _AnswerChoiceBar({
    required this.choices,
    required this.usedAnswers,
    required this.enabled,
  });

  final List<int> choices;
  final Set<int> usedAnswers;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: choices.map((answer) {
          if (usedAnswers.contains(answer)) {
            return const SizedBox(width: 58, height: 52);
          }

          final child = SizedBox(
            width: 58,
            height: 52,
            child: Center(
              child: Text(
                answer.toString(),
                style: GoogleFonts.quicksand(
                  color: const Color(0xFF4A3728),
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );

          return Draggable<int>(
            data: answer,
            maxSimultaneousDrags: enabled ? 1 : 0,
            feedback: Material(color: Colors.transparent, child: child),
            childWhenDragging: Opacity(opacity: 0.25, child: child),
            child: child,
          );
        }).toList(),
      ),
    );
  }
}
