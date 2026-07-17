import 'package:audioplayers/audioplayers.dart';
import '../../../shared/widgets/activity_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'activity_3_page.dart';

class Level5Activity2Page extends StatefulWidget {
  const Level5Activity2Page({super.key});

  @override
  State<Level5Activity2Page> createState() => _Level5Activity2PageState();
}

class _Level5Activity2PageState extends State<Level5Activity2Page> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late final Future<void> _audioReady;

  final Set<int> _missingNumbers = {3, 7, 14, 16};
  final List<int> _choices = [3, 7, 14, 16];
  final Map<int, Color> _numberColors = const {
    1: Color(0xFFF6AEAE),
    2: Color(0xFF76ED5B),
    3: Color(0xFF98B7E9),
    4: Color(0xFFFFC74E),
    5: Color(0xFFB770BB),
    6: Color(0xFF99B8E9),
    7: Color(0xFFFFC74E),
    8: Color(0xFFF6AFAF),
    9: Color(0xFFB870BB),
    10: Color(0xFF99B8E9),
    11: Color(0xFF76ED5B),
    12: Color(0xFFB870BB),
    13: Color(0xFF99B8E9),
    14: Color(0xFFFFC74E),
    15: Color(0xFFF6AFAF),
    16: Color(0xFFF6AFAF),
    17: Color(0xFFFFC74E),
    18: Color(0xFF76ED5B),
    19: Color(0xFFFFC74E),
    20: Color(0xFF99B8E9),
  };

  final Map<int, int> _filledNumbers = {};
  bool _isLocked = false;
  bool _isCheckingDrop = false;

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
    required int boxNumber,
    required int droppedNumber,
  }) async {
    if (_isLocked || _isCheckingDrop || _filledNumbers.containsKey(boxNumber)) {
      return;
    }

    if (boxNumber == droppedNumber) {
      setState(() {
        _filledNumbers[boxNumber] = droppedNumber;
      });

      if (_filledNumbers.length == _missingNumbers.length) {
        await _handleActivityComplete();
      }
    } else {
      setState(() => _isCheckingDrop = true);
      await _playAudio('try_again.mp3');

      if (mounted) {
        setState(() => _isCheckingDrop = false);
      }
    }
  }

  Future<void> _handleActivityComplete() async {
    setState(() => _isLocked = true);

    try {
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;

      await _playAudio('great_job.mp3');

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Level5Activity3Page()),
        );
      }
    } catch (e) {
      debugPrint('Audio error: $e');
    }
  }

  Future<void> _playAudio(String fileName) async {
    try {
      await _audioReady;
      await _audioPlayer.play(AssetSource('audio/$fileName'));
      await Future<void>.delayed(
        fileName == 'great_job.mp3'
            ? const Duration(milliseconds: 1500)
            : const Duration(milliseconds: 1100),
      );
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint('Audio error: $e');
    }
  }

  Widget _buildSequenceTile(int number) {
    final bool isMissing = _missingNumbers.contains(number);
    final int? filledNumber = _filledNumbers[number];

    if (isMissing) {
      return DragTarget<int>(
        onWillAcceptWithDetails: (_) =>
            !_isLocked && !_isCheckingDrop && filledNumber == null,
        onAcceptWithDetails: (details) {
          _handleDrop(boxNumber: number, droppedNumber: details.data);
        },
        builder: (context, candidateData, rejectedData) {
          return _buildNumberBox(
            number: filledNumber,
            color: _numberColors[number]!,
            isHighlighted: candidateData.isNotEmpty,
          );
        },
      );
    }

    return _buildNumberBox(number: number, color: _numberColors[number]!);
  }

  Widget _buildNumberBox({
    required int? number,
    required Color color,
    bool isHighlighted = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 58,
      height: 56,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHighlighted ? const Color(0xFF4A3728) : Colors.transparent,
          width: 3,
        ),
      ),
      child: Center(
        child: Text(
          number?.toString() ?? '',
          style: GoogleFonts.inter(
            color: const Color(0xFF4A3728),
            fontSize: 32,
            fontWeight: FontWeight.w400,
            height: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceNumber(int number) {
    final bool isUsed = _filledNumbers.containsValue(number);

    if (isUsed) {
      return const SizedBox(width: 52, height: 54);
    }

    final child = SizedBox(
      width: 52,
      height: 54,
      child: Center(
        child: Text(
          number.toString(),
          style: GoogleFonts.inter(
            color: const Color(0xFF4A3728),
            fontSize: 32,
            fontWeight: FontWeight.w400,
            height: 1,
          ),
        ),
      ),
    );

    return Draggable<int>(
      data: number,
      feedback: Material(color: Colors.transparent, child: child),
      childWhenDragging: Opacity(opacity: 0.25, child: child),
      child: child,
    );
  }

  Widget _buildChoiceBar() {
    return Container(
      width: 336,
      height: 67,
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _choices.map(_buildChoiceNumber).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFFFAB),
      body: Stack(
        children: [
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
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  Wrap(
                    spacing: 8,
                    runSpacing: 26,
                    alignment: WrapAlignment.center,
                    children: List.generate(20, (index) {
                      return _buildSequenceTile(index + 1);
                    }),
                  ),
                  const SizedBox(height: 30),
                  _buildChoiceBar(),
                  const SizedBox(height: 142),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 24.0,
                  left: 16.0,
                  right: 16.0,
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
                        bottom: 28.0,
                        left: 20.0,
                        right: 20.0,
                      ),
                      child: Text(
                        'Drag the correct number to the empty box.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.quicksand(
                          color: Colors.black,
                          fontSize: 16,
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
        ],
      ),
    );
  }
}
