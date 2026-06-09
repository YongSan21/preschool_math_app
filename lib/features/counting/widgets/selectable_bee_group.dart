import 'package:flutter/material.dart';

class SelectableBeeGroup extends StatelessWidget {
  const SelectableBeeGroup({
    super.key,
    required this.beeCount,
    required this.onTap,
    this.activeBeeIndex,
  });

  final int beeCount;
  final VoidCallback onTap;
  final int? activeBeeIndex;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 340,
        height: 205,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/images/flower_patch.png',
              width: 340,
              height: 205,
              fit: BoxFit.fill,
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 34,
                right: 34,
                top: 34,
                bottom: 34,
              ),
              child: _buildBeeRows(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBeeRows() {
    final int topRowCount = beeCount > 5 ? 5 : beeCount;
    final int middleRowCount = beeCount > 10 ? 5 : beeCount - topRowCount;
    final int bottomRowCount = beeCount - topRowCount - middleRowCount;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildBeeRow(0, topRowCount),
        if (middleRowCount > 0) _buildBeeRow(topRowCount, middleRowCount),
        if (bottomRowCount > 0)
          _buildBeeRow(topRowCount + middleRowCount, bottomRowCount),
      ],
    );
  }

  Widget _buildBeeRow(int startIndex, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        return _buildBee(startIndex + index);
      }),
    );
  }

  Widget _buildBee(int globalIndex) {
    final bool isBouncing = activeBeeIndex == globalIndex;

    return SizedBox(
      width: 48,
      height: 42,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, isBouncing ? -15.0 : 0.0, 0),
        child: Image.asset(
          'assets/images/bee.png',
          width: 44,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
