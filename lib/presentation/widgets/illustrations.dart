import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/course.dart';
import 'dotted_pattern.dart';

const Color _ink = Color(0xFF14231A);
const Color _sun = Color(0xFFFFC857);
const Color _teal = Color(0xFF14B8A6);

class HeroIllustration extends StatelessWidget {
  final double height;

  const HeroIllustration({super.key, this.height = 220});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: AspectRatio(
        aspectRatio: 320 / 240,
        child: CustomPaint(painter: _HeroPainter()),
      ),
    );
  }
}

class _HeroPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 320, size.height / 240);
    final fill = Paint()..style = PaintingStyle.fill;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    fill.color = Colors.white.withOpacity(0.14);
    canvas.drawCircle(const Offset(160, 125), 104, fill);
    fill.color = Colors.white.withOpacity(0.12);
    canvas.drawCircle(const Offset(160, 125), 72, fill);

    fill.color = Colors.black.withOpacity(0.10);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(160, 232), width: 290, height: 14),
      fill,
    );

    fill.color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(30, 180, 190, 10),
        const Radius.circular(5),
      ),
      fill,
    );
    fill.color = Colors.white.withOpacity(0.85);
    canvas.drawRect(const Rect.fromLTWH(48, 190, 8, 42), fill);
    canvas.drawRect(const Rect.fromLTWH(194, 190, 8, 42), fill);

    final base = Path()
      ..moveTo(52, 173)
      ..lineTo(168, 173)
      ..lineTo(178, 181)
      ..lineTo(42, 181)
      ..close();
    fill.color = const Color(0xFFEAF5EE);
    canvas.drawPath(base, fill);

    fill.color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(60, 100, 100, 74),
        const Radius.circular(8),
      ),
      fill,
    );
    fill.color = AppColors.primaryLight;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(67, 107, 86, 58),
        const Radius.circular(5),
      ),
      fill,
    );
    fill.color = AppColors.primary;
    canvas.drawCircle(const Offset(110, 133), 15, fill);
    fill.color = Colors.white;
    final play = Path()
      ..moveTo(106, 125)
      ..lineTo(106, 141)
      ..lineTo(119, 133)
      ..close();
    canvas.drawPath(play, fill);
    fill.color = AppColors.primary.withOpacity(0.25);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(75, 156, 70, 4),
        const Radius.circular(2),
      ),
      fill,
    );
    fill.color = AppColors.primary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(75, 156, 42, 4),
        const Radius.circular(2),
      ),
      fill,
    );

    final books = <List<dynamic>>[
      [const Rect.fromLTWH(180, 173, 34, 8), _sun],
      [const Rect.fromLTWH(183, 165, 30, 8), Colors.white],
      [const Rect.fromLTWH(178, 157, 34, 8), _teal],
    ];
    for (final book in books) {
      fill.color = book[1] as Color;
      canvas.drawRRect(
        RRect.fromRectAndRadius(book[0] as Rect, const Radius.circular(2)),
        fill,
      );
    }

    fill.color = _ink;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(236, 168, 13, 58),
        const Radius.circular(6),
      ),
      fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(252, 168, 13, 58),
        const Radius.circular(6),
      ),
      fill,
    );
    fill.color = Colors.white;
    canvas.drawOval(const Rect.fromLTWH(231, 222, 22, 10), fill);
    canvas.drawOval(const Rect.fromLTWH(248, 222, 22, 10), fill);

    fill.color = _sun;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(229, 108, 44, 68),
        const Radius.circular(16),
      ),
      fill,
    );
    stroke
      ..color = _sun
      ..strokeWidth = 11;
    canvas.drawLine(const Offset(234, 120), const Offset(216, 150), stroke);
    fill.color = AppColors.skin;
    canvas.drawCircle(const Offset(215, 152), 6, fill);

    fill.color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(198, 142, 20, 26),
        const Radius.circular(3),
      ),
      fill,
    );
    fill.color = AppColors.primary;
    canvas.drawRect(const Rect.fromLTWH(198, 142, 4, 26), fill);
    stroke
      ..color = AppColors.primary.withOpacity(0.5)
      ..strokeWidth = 1.5;
    canvas.drawLine(const Offset(205, 150), const Offset(214, 150), stroke);
    canvas.drawLine(const Offset(205, 156), const Offset(214, 156), stroke);

    fill.color = AppColors.skin;
    canvas.drawRect(const Rect.fromLTWH(246, 96, 8, 14), fill);
    canvas.drawCircle(const Offset(251, 90), 17, fill);
    fill.color = _ink;
    final hair = Path()
      ..moveTo(234, 90)
      ..quadraticBezierTo(236, 70, 251, 72)
      ..quadraticBezierTo(267, 72, 268, 90)
      ..quadraticBezierTo(258, 80, 244, 82)
      ..quadraticBezierTo(238, 84, 234, 90)
      ..close();
    canvas.drawPath(hair, fill);
    canvas.drawCircle(const Offset(245, 92), 1.8, fill);
    canvas.drawCircle(const Offset(257, 92), 1.8, fill);
    stroke
      ..color = _ink
      ..strokeWidth = 1.6;
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(251, 98), width: 10, height: 6),
      0.2,
      2.7,
      false,
      stroke,
    );

    fill.color = _ink;
    final cap = Path()
      ..moveTo(228, 72)
      ..lineTo(251, 62)
      ..lineTo(274, 72)
      ..lineTo(251, 82)
      ..close();
    canvas.drawPath(cap, fill);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(241, 80, 20, 7),
        const Radius.circular(3),
      ),
      fill,
    );
    stroke
      ..color = _sun
      ..strokeWidth = 1.8;
    canvas.drawLine(const Offset(270, 74), const Offset(270, 90), stroke);
    fill.color = _sun;
    canvas.drawCircle(const Offset(270, 92), 2.6, fill);

    fill.color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(28, 36, 58, 40),
        const Radius.circular(6),
      ),
      fill,
    );
    stroke
      ..color = AppColors.primary.withOpacity(0.45)
      ..strokeWidth = 2;
    canvas.drawLine(const Offset(36, 48), const Offset(78, 48), stroke);
    canvas.drawLine(const Offset(36, 56), const Offset(68, 56), stroke);
    fill.color = _sun;
    canvas.drawCircle(const Offset(72, 66), 5.5, fill);
    fill.color = AppColors.primary;
    canvas.drawCircle(const Offset(72, 66), 2.4, fill);

    fill.color = _sun;
    canvas.drawCircle(const Offset(150, 46), 13, fill);
    fill.color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(144, 58, 12, 7),
        const Radius.circular(2),
      ),
      fill,
    );
    stroke
      ..color = Colors.white.withOpacity(0.9)
      ..strokeWidth = 2;
    for (int i = 0; i < 5; i++) {
      final a = -math.pi + (i + 0.5) * math.pi / 5;
      final from = Offset(150 + math.cos(a) * 19, 46 + math.sin(a) * 19);
      final to = Offset(150 + math.cos(a) * 26, 46 + math.sin(a) * 26);
      canvas.drawLine(from, to, stroke);
    }

    _sparkle(canvas, const Offset(108, 30), 7);
    _sparkle(canvas, const Offset(206, 36), 6);
    _sparkle(canvas, const Offset(296, 60), 8);
    _sparkle(canvas, const Offset(20, 130), 6);

    fill.color = Colors.white;
    final pot = Path()
      ..moveTo(284, 204)
      ..lineTo(308, 204)
      ..lineTo(304, 228)
      ..lineTo(288, 228)
      ..close();
    canvas.drawPath(pot, fill);
    fill.color = _teal;
    for (final angle in [-0.6, 0.0, 0.6]) {
      canvas.save();
      canvas.translate(296, 204);
      canvas.rotate(angle);
      canvas.drawOval(const Rect.fromLTWH(-6, -34, 12, 34), fill);
      canvas.restore();
    }
    canvas.restore();
  }

  void _sparkle(Canvas canvas, Offset c, double r) {
    final paint = Paint()..color = Colors.white.withOpacity(0.95);
    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum EmptyKind { search, downloads, error, courses }

class EmptyIllustration extends StatelessWidget {
  final EmptyKind kind;
  final double size;

  const EmptyIllustration({super.key, required this.kind, this.size = 160});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _EmptyPainter(kind)),
    );
  }
}

class _EmptyPainter extends CustomPainter {
  final EmptyKind kind;

  _EmptyPainter(this.kind);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 160, size.height / 160);
    final fill = Paint()..style = PaintingStyle.fill;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    fill.color = AppColors.primaryLight;
    canvas.drawCircle(const Offset(80, 80), 70, fill);
    fill.color = AppColors.primary.withOpacity(0.10);
    canvas.drawCircle(const Offset(80, 80), 48, fill);
    fill.color = AppColors.primary.withOpacity(0.35);
    canvas.drawCircle(const Offset(24, 40), 4, fill);
    canvas.drawCircle(const Offset(138, 56), 3, fill);
    canvas.drawCircle(const Offset(128, 128), 5, fill);

    switch (kind) {
      case EmptyKind.search:
        stroke
          ..color = AppColors.primary
          ..strokeWidth = 9;
        canvas.drawCircle(const Offset(72, 72), 26, stroke);
        stroke.strokeWidth = 11;
        canvas.drawLine(const Offset(92, 92), const Offset(116, 116), stroke);
        stroke
          ..color = AppColors.primary.withOpacity(0.45)
          ..strokeWidth = 4;
        canvas.drawLine(const Offset(60, 72), const Offset(84, 72), stroke);
        break;
      case EmptyKind.downloads:
        fill.color = Colors.white;
        final cloud = Path()
          ..moveTo(52, 100)
          ..quadraticBezierTo(36, 100, 38, 84)
          ..quadraticBezierTo(40, 70, 56, 72)
          ..quadraticBezierTo(60, 50, 82, 52)
          ..quadraticBezierTo(102, 52, 106, 70)
          ..quadraticBezierTo(124, 70, 122, 88)
          ..quadraticBezierTo(120, 100, 106, 100)
          ..close();
        canvas.drawShadow(cloud, AppColors.primary.withOpacity(0.5), 4, false);
        canvas.drawPath(cloud, fill);
        stroke
          ..color = AppColors.primary
          ..strokeWidth = 7;
        canvas.drawLine(const Offset(80, 66), const Offset(80, 96), stroke);
        canvas.drawLine(const Offset(68, 86), const Offset(80, 98), stroke);
        canvas.drawLine(const Offset(92, 86), const Offset(80, 98), stroke);
        canvas.drawLine(const Offset(62, 116), const Offset(98, 116), stroke);
        break;
      case EmptyKind.error:
        fill.color = Colors.white;
        final cloud = Path()
          ..moveTo(52, 104)
          ..quadraticBezierTo(36, 104, 38, 88)
          ..quadraticBezierTo(40, 74, 56, 76)
          ..quadraticBezierTo(60, 54, 82, 56)
          ..quadraticBezierTo(102, 56, 106, 74)
          ..quadraticBezierTo(124, 74, 122, 92)
          ..quadraticBezierTo(120, 104, 106, 104)
          ..close();
        canvas.drawShadow(cloud, AppColors.error.withOpacity(0.45), 4, false);
        canvas.drawPath(cloud, fill);
        stroke
          ..color = AppColors.error
          ..strokeWidth = 7;
        canvas.drawLine(const Offset(80, 68), const Offset(80, 88), stroke);
        fill.color = AppColors.error;
        canvas.drawCircle(const Offset(80, 97), 4, fill);
        break;
      case EmptyKind.courses:
        final stack = <List<dynamic>>[
          [const Rect.fromLTWH(46, 98, 68, 14), AppColors.primary],
          [const Rect.fromLTWH(52, 82, 60, 14), _sun],
          [const Rect.fromLTWH(44, 66, 66, 14), _teal],
        ];
        for (final b in stack) {
          fill.color = b[1] as Color;
          canvas.drawRRect(
            RRect.fromRectAndRadius(b[0] as Rect, const Radius.circular(4)),
            fill,
          );
        }
        fill.color = Colors.white.withOpacity(0.8);
        canvas.drawRect(const Rect.fromLTWH(58, 102, 30, 3), fill);
        canvas.drawRect(const Rect.fromLTWH(62, 86, 24, 3), fill);
        canvas.drawRect(const Rect.fromLTWH(56, 70, 28, 3), fill);
        break;
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _EmptyPainter oldDelegate) =>
      oldDelegate.kind != kind;
}

class CourseArt extends StatelessWidget {
  final CourseThumbnail thumbnail;
  final BorderRadius borderRadius;

  const CourseArt({
    super.key,
    required this.thumbnail,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: thumbnail.colors,
              ),
            ),
          ),
          const DottedPattern(spacing: 8),
          CustomPaint(painter: _CourseArtPainter(thumbnail.art)),
        ],
      ),
    );
  }
}

class _CourseArtPainter extends CustomPainter {
  final String art;

  _CourseArtPainter(this.art);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / 200, size.height / 120);
    canvas.translate(
      (size.width - 200 * scale) / 2,
      (size.height - 120 * scale) / 2,
    );
    canvas.scale(scale);
    final fill = Paint()..style = PaintingStyle.fill;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (art) {
      case 'code':
        fill.color = Colors.white;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(46, 22, 108, 76),
            const Radius.circular(10),
          ),
          fill,
        );
        fill.color = Colors.black.withOpacity(0.10);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(46, 22, 108, 16),
            const Radius.circular(10),
          ),
          fill,
        );
        for (int i = 0; i < 3; i++) {
          fill.color = [AppColors.error, _sun, AppColors.primary][i];
          canvas.drawCircle(Offset(58.0 + i * 11, 30), 3, fill);
        }
        stroke
          ..color = AppColors.primary
          ..strokeWidth = 5;
        final left = Path()
          ..moveTo(80, 56)
          ..lineTo(66, 68)
          ..lineTo(80, 80);
        final right = Path()
          ..moveTo(120, 56)
          ..lineTo(134, 68)
          ..lineTo(120, 80);
        canvas.drawPath(left, stroke);
        canvas.drawPath(right, stroke);
        stroke
          ..color = _ink
          ..strokeWidth = 4;
        canvas.drawLine(const Offset(106, 54), const Offset(94, 82), stroke);
        break;
      case 'design':
        fill.color = Colors.white;
        canvas.drawCircle(const Offset(72, 62), 28, fill);
        fill.color = _sun;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(88, 50, 52, 44),
            const Radius.circular(8),
          ),
          fill,
        );
        fill.color = Colors.white.withOpacity(0.9);
        final tri = Path()
          ..moveTo(130, 22)
          ..lineTo(152, 60)
          ..lineTo(108, 60)
          ..close();
        canvas.drawPath(tri, fill);
        stroke
          ..color = _ink
          ..strokeWidth = 3;
        final curve = Path()
          ..moveTo(40, 96)
          ..cubicTo(70, 40, 120, 110, 160, 40);
        canvas.drawPath(curve, stroke);
        fill.color = Colors.white;
        for (final p in const [Offset(40, 96), Offset(160, 40)]) {
          canvas.drawRect(Rect.fromCenter(center: p, width: 9, height: 9), fill);
          stroke
            ..color = _ink
            ..strokeWidth = 2;
          canvas.drawRect(Rect.fromCenter(center: p, width: 9, height: 9), stroke);
        }
        break;
      case 'data':
        fill.color = Colors.white;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(40, 18, 120, 86),
            const Radius.circular(10),
          ),
          fill,
        );
        const heights = [26.0, 42.0, 34.0, 56.0];
        for (int i = 0; i < heights.length; i++) {
          fill.color = i.isEven ? AppColors.primary : _teal;
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(54.0 + i * 24, 92 - heights[i], 14, heights[i]),
              const Radius.circular(3),
            ),
            fill,
          );
        }
        stroke
          ..color = _sun
          ..strokeWidth = 3.5;
        final line = Path()
          ..moveTo(54, 56)
          ..lineTo(84, 46)
          ..lineTo(108, 52)
          ..lineTo(146, 30);
        canvas.drawPath(line, stroke);
        fill.color = _sun;
        canvas.drawCircle(const Offset(146, 30), 4.5, fill);
        break;
      case 'marketing':
        fill.color = Colors.white;
        final horn = Path()
          ..moveTo(60, 50)
          ..lineTo(124, 22)
          ..lineTo(124, 90)
          ..lineTo(60, 70)
          ..close();
        canvas.drawPath(horn, fill);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(44, 48, 24, 24),
            const Radius.circular(6),
          ),
          fill,
        );
        fill.color = _sun;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(64, 72, 14, 26),
            const Radius.circular(5),
          ),
          fill,
        );
        stroke
          ..color = Colors.white
          ..strokeWidth = 4;
        for (int i = 0; i < 3; i++) {
          final r = 14.0 + i * 12;
          canvas.drawArc(
            Rect.fromCenter(center: const Offset(128, 56), width: r * 2, height: r * 2),
            -0.7,
            1.4,
            false,
            stroke..color = Colors.white.withOpacity(1 - i * 0.28),
          );
        }
        break;
      default:
        fill.color = Colors.white;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(60, 30, 80, 60),
            const Radius.circular(10),
          ),
          fill,
        );
        fill.color = AppColors.primary;
        canvas.drawCircle(const Offset(100, 60), 14, fill);
    }
  }

  @override
  bool shouldRepaint(covariant _CourseArtPainter oldDelegate) =>
      oldDelegate.art != art;
}
