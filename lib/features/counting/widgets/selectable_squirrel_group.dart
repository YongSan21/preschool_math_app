import 'package:flutter/material.dart';

class SelectableSquirrelGroup extends StatelessWidget {
  const SelectableSquirrelGroup({
    super.key,
    required this.squirrelCount,
    required this.onTap,
    this.activeSquirrelIndex,
  });

  final int squirrelCount;
  final VoidCallback onTap;
  final int? activeSquirrelIndex;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 360,
        height: 225,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/images/board.png',
              width: 360,
              height: 225,
              fit: BoxFit.fill,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(36, 20, 36, 42),
              child: _buildSquirrelRows(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSquirrelRows() {
    final int firstRowCount = squirrelCount > 6 ? 6 : squirrelCount;
    final int secondRowCount = squirrelCount > 12 ? 6 : squirrelCount - firstRowCount;
    final int thirdRowCount = squirrelCount - firstRowCount - secondRowCount;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSquirrelRow(0, firstRowCount),
        if (secondRowCount > 0) _buildSquirrelRow(firstRowCount, secondRowCount),
        if (thirdRowCount > 0)
          _buildSquirrelRow(firstRowCount + secondRowCount, thirdRowCount),
      ],
    );
  }

  Widget _buildSquirrelRow(int startIndex, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        return _buildSquirrel(startIndex + index);
      }),
    );
  }

  Widget _buildSquirrel(int globalIndex) {
    final bool isBouncing = activeSquirrelIndex == globalIndex;

    return SizedBox(
      width: 47,
      height: 46,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, isBouncing ? -15.0 : 0.0, 0),
        child: Image.asset(
          'assets/images/squirrel.png',
          width: 44,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
