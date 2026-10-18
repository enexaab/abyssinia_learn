import 'dart:math' as math;
import 'package:flutter/material.dart';

class DottedPatternPainter extends CustomPainter {
  final Color color;
  final double spacing;
  final double maxRadius;
  final int seed;

  const DottedPatternPainter({
    this.color = Colors.white,
    this.spacing = 9,
    this.maxRadius = 1.9,
    this.seed = 7,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final cols = (size.width / spacing).ceil() + 1;
    final rows = (size.height / spacing).ceil() + 1;
    final blobs = <Offset>[
      Offset(size.width * 0.18, size.height * 0.35),
      Offset(size.width * 0.55, size.height * 0.7),
      Offset(size.width * 0.85, size.height * 0.3),
      Offset(size.width * 0.4, size.height * 0.1),
    ];
    final reach = math.max(size.width, size.height) * 0.34;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final offset = Offset(
          c * spacing + (r.isOdd ? spacing / 2 : 0),
          r * spacing,
        );
        double influence = 0;
        for (final blob in blobs) {
          final d = (offset - blob).distance;
          influence = math.max(influence, 1 - d / reach);
        }
        if (influence <= 0) continue;
        final noise =
            (math.sin((c + seed) * 12.9898 + (r + seed) * 78.233) * 43758.5453)
                .abs() %
                1;
        if (noise > 0.35 + influence * 0.6) continue;
        paint.color = color.withOpacity(0.05 + influence * 0.22);
        canvas.drawCircle(offset, maxRadius * (0.5 + influence * 0.5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DottedPatternPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.spacing != spacing ||
        oldDelegate.seed != seed;
  }
}

class DottedPattern extends StatelessWidget {
  final Color color;
  final double spacing;
  final int seed;

  const DottedPattern({
    super.key,
    this.color = Colors.white,
    this.spacing = 9,
    this.seed = 7,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: DottedPatternPainter(
          color: color,
          spacing: spacing,
          seed: seed,
        ),
        size: Size.infinite,
      ),
    );
  }
}
