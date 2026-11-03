import 'dart:math' as math;
import 'package:flutter/widgets.dart';

/// Clean custom vector icons matching the original cmdk examples.
class CmdkIcons {
  static Widget raycast(
      {double size = 16, Color color = const Color(0xFFFF6363)}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _RaycastPainter(color),
    );
  }

  static Widget linear(
      {double size = 16, Color color = const Color(0xFF5E6AD2)}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _LinearPainter(color),
    );
  }

  static Widget vercel(
      {double size = 16, Color color = const Color(0xFFFFFFFF)}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _VercelPainter(color),
    );
  }

  static Widget framer(
      {double size = 16, Color color = const Color(0xFFFFFFFF)}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _FramerPainter(color),
    );
  }

  static Widget figma({double size = 16}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _FigmaPainter(),
    );
  }

  static Widget slack({double size = 16}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SlackPainter(),
    );
  }

  static Widget youtube({double size = 16}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _YouTubePainter(),
    );
  }

  static Widget clipboardGradient({double size = 20}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF55354), Color(0xFFEB4646)],
        ),
      ),
      alignment: Alignment.center,
      child: CustomPaint(
        size: Size(size * 0.65, size * 0.65),
        painter: _ClipboardIconPainter(const Color(0xFFFFFFFF)),
      ),
    );
  }

  static Widget hammerGradient({double size = 20}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF6CB9A3), Color(0xFF2C6459)],
        ),
      ),
      alignment: Alignment.center,
      child: CustomPaint(
        size: Size(size * 0.65, size * 0.65),
        painter: _HammerIconPainter(const Color(0xFFFFFFFF)),
      ),
    );
  }

  static Widget search(
      {double size = 18, Color color = const Color(0xFF888888)}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SearchPainter(color),
    );
  }

  static Widget github(
      {double size = 14, Color color = const Color(0xFFEDEDED)}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GitHubPainter(color),
    );
  }

  static Widget copy(
      {double size = 14, Color color = const Color(0xFF888888)}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CopyPainter(color),
    );
  }

  static Widget check(
      {double size = 14, Color color = const Color(0xFF10B981)}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CheckPainter(color),
    );
  }

  static Widget shift(
      {double size = 12, Color color = const Color(0xFF888888)}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ShiftPainter(color),
    );
  }

  // Linear issue action icons
  static Widget assignTo(
      {double size = 16, Color color = const Color(0xFF888888)}) {
    return CustomPaint(
        size: Size(size, size), painter: _AssignToPainter(color));
  }

  static Widget assignToMe(
      {double size = 16, Color color = const Color(0xFF888888)}) {
    return CustomPaint(
        size: Size(size, size), painter: _AssignToMePainter(color));
  }

  static Widget changeStatus(
      {double size = 16, Color color = const Color(0xFF888888)}) {
    return CustomPaint(
        size: Size(size, size), painter: _ChangeStatusPainter(color));
  }

  static Widget changePriority(
      {double size = 16, Color color = const Color(0xFF888888)}) {
    return CustomPaint(
        size: Size(size, size), painter: _ChangePriorityPainter(color));
  }

  static Widget changeLabels(
      {double size = 16, Color color = const Color(0xFF888888)}) {
    return CustomPaint(
        size: Size(size, size), painter: _ChangeLabelsPainter(color));
  }

  static Widget removeLabel(
      {double size = 16, Color color = const Color(0xFF888888)}) {
    return CustomPaint(
        size: Size(size, size), painter: _RemoveLabelPainter(color));
  }

  static Widget setDueDate(
      {double size = 16, Color color = const Color(0xFF888888)}) {
    return CustomPaint(
        size: Size(size, size), painter: _SetDueDatePainter(color));
  }

  // Vercel icons
  static Widget projects(
      {double size = 16, Color color = const Color(0xFF888888)}) {
    return CustomPaint(
        size: Size(size, size), painter: _ProjectsPainter(color));
  }

  static Widget plus(
      {double size = 16, Color color = const Color(0xFF888888)}) {
    return CustomPaint(size: Size(size, size), painter: _PlusPainter(color));
  }

  static Widget teams(
      {double size = 16, Color color = const Color(0xFF888888)}) {
    return CustomPaint(size: Size(size, size), painter: _TeamsPainter(color));
  }

  static Widget docs(
      {double size = 16, Color color = const Color(0xFF888888)}) {
    return CustomPaint(size: Size(size, size), painter: _DocsPainter(color));
  }

  static Widget feedback(
      {double size = 16, Color color = const Color(0xFF888888)}) {
    return CustomPaint(
        size: Size(size, size), painter: _FeedbackPainter(color));
  }

  static Widget support(
      {double size = 16, Color color = const Color(0xFF888888)}) {
    return CustomPaint(size: Size(size, size), painter: _SupportPainter(color));
  }

  // Framer component icons
  static Widget framerButton(
      {double size = 16, Color color = const Color(0xFFFFFFFF)}) {
    return CustomPaint(
        size: Size(size, size), painter: _FramerButtonPainter(color));
  }

  static Widget framerInput(
      {double size = 16, Color color = const Color(0xFFFFFFFF)}) {
    return CustomPaint(
        size: Size(size, size), painter: _FramerInputPainter(color));
  }

  static Widget framerRadio(
      {double size = 16, Color color = const Color(0xFFFFFFFF)}) {
    return CustomPaint(
        size: Size(size, size), painter: _FramerRadioPainter(color));
  }

  static Widget framerBadge(
      {double size = 16, Color color = const Color(0xFFFFFFFF)}) {
    return CustomPaint(
        size: Size(size, size), painter: _FramerBadgePainter(color));
  }

  static Widget framerSlider(
      {double size = 16, Color color = const Color(0xFFFFFFFF)}) {
    return CustomPaint(
        size: Size(size, size), painter: _FramerSliderPainter(color));
  }

  static Widget framerAvatar(
      {double size = 16, Color color = const Color(0xFFFFFFFF)}) {
    return CustomPaint(
        size: Size(size, size), painter: _FramerAvatarPainter(color));
  }

  static Widget framerContainer(
      {double size = 16, Color color = const Color(0xFFFFFFFF)}) {
    return CustomPaint(
        size: Size(size, size), painter: _FramerContainerPainter(color));
  }
}

// ==================== PAINTERS ====================

class _RaycastPainter extends CustomPainter {
  _RaycastPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.15, size.height * 0.5)
      ..lineTo(size.width * 0.5, size.height * 0.15)
      ..lineTo(size.width * 0.85, size.height * 0.5)
      ..lineTo(size.width * 0.5, size.height * 0.85)
      ..close();

    canvas.drawPath(path, paint);

    final innerPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.18,
      innerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LinearPainter extends CustomPainter {
  _LinearPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.18
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.8),
      Offset(size.width * 0.8, size.height * 0.2),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.8),
      Offset(size.width * 0.8, size.height * 0.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _VercelPainter extends CustomPainter {
  _VercelPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.12)
      ..lineTo(size.width * 0.9, size.height * 0.88)
      ..lineTo(size.width * 0.1, size.height * 0.88)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FramerPainter extends CustomPainter {
  _FramerPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Framer layered block logo
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.0, 0)
      ..lineTo(w, 0)
      ..lineTo(w * 0.5, h * 0.33)
      ..lineTo(0, h * 0.33)
      ..close()
      ..moveTo(0, h * 0.33)
      ..lineTo(w * 0.5, h * 0.33)
      ..lineTo(w, h * 0.67)
      ..lineTo(0, h * 0.67)
      ..close()
      ..moveTo(0, h * 0.67)
      ..lineTo(w * 0.5, h * 0.67)
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FigmaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      const Color(0xFFF24E1E),
      const Color(0xFFA259FF),
      const Color(0xFF1ABCFE),
      const Color(0xFF0ACF83),
      const Color(0xFFFF7262),
    ];
    final paint = Paint()..style = PaintingStyle.fill;

    final r = size.width * 0.2;
    paint.color = colors[0];
    canvas.drawCircle(Offset(size.width * 0.33, size.height * 0.22), r, paint);
    paint.color = colors[4];
    canvas.drawCircle(Offset(size.width * 0.67, size.height * 0.22), r, paint);
    paint.color = colors[1];
    canvas.drawCircle(Offset(size.width * 0.33, size.height * 0.5), r, paint);
    paint.color = colors[2];
    canvas.drawCircle(Offset(size.width * 0.67, size.height * 0.5), r, paint);
    paint.color = colors[3];
    canvas.drawCircle(Offset(size.width * 0.33, size.height * 0.78), r, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SlackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFE01E5A);
    final r = size.width * 0.16;
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.3), r, paint);
    paint.color = const Color(0xFF36C5F0);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.3), r, paint);
    paint.color = const Color(0xFF2EB67D);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.7), r, paint);
    paint.color = const Color(0xFFECB22E);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.7), r, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _YouTubePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF0000)
      ..style = PaintingStyle.fill;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.height * 0.15, size.width, size.height * 0.7),
      Radius.circular(size.width * 0.25),
    );
    canvas.drawRRect(rrect, paint);

    final trianglePaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width * 0.40, size.height * 0.33)
      ..lineTo(size.width * 0.68, size.height * 0.5)
      ..lineTo(size.width * 0.40, size.height * 0.67)
      ..close();
    canvas.drawPath(path, trianglePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ClipboardIconPainter extends CustomPainter {
  _ClipboardIconPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final rect = Rect.fromLTWH(size.width * 0.15, size.height * 0.22,
        size.width * 0.7, size.height * 0.68);
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)), paint);

    final clipPath = Path()
      ..moveTo(size.width * 0.35, size.height * 0.22)
      ..lineTo(size.width * 0.35, size.height * 0.12)
      ..lineTo(size.width * 0.65, size.height * 0.12)
      ..lineTo(size.width * 0.65, size.height * 0.22);
    canvas.drawPath(clipPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HammerIconPainter extends CustomPainter {
  _HammerIconPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(size.width * 0.5, size.height * 0.5);
    canvas.rotate(-math.pi / 4);

    // Handle
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-1.5, 0, 3, 7),
        const Radius.circular(1),
      ),
      paint,
    );

    // Head
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-5, -4, 10, 4),
        const Radius.circular(1),
      ),
      paint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SearchPainter extends CustomPainter {
  _SearchPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final radius = size.width * 0.32;
    final center = Offset(size.width * 0.42, size.height * 0.42);
    canvas.drawCircle(center, radius, paint);

    final angle = math.pi / 4;
    final start = Offset(center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle));
    final end = Offset(size.width * 0.88, size.height * 0.88);
    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GitHubPainter extends CustomPainter {
  _GitHubPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.5), size.width * 0.48, paint);
    final cutPaint = Paint()
      ..color = const Color(0xFF0E0E10)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.65),
        size.width * 0.25, cutPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CopyPainter extends CustomPainter {
  _CopyPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final r1 = Rect.fromLTWH(size.width * 0.3, size.height * 0.3,
        size.width * 0.6, size.height * 0.6);
    canvas.drawRRect(
        RRect.fromRectAndRadius(r1, const Radius.circular(2)), paint);

    final p2 = Path()
      ..moveTo(size.width * 0.65, size.height * 0.15)
      ..lineTo(size.width * 0.15, size.height * 0.15)
      ..lineTo(size.width * 0.15, size.height * 0.65);
    canvas.drawPath(p2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CheckPainter extends CustomPainter {
  _CheckPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.5)
      ..lineTo(size.width * 0.45, size.height * 0.75)
      ..lineTo(size.width * 0.85, size.height * 0.25);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AssignToPainter extends CustomPainter {
  _AssignToPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
        Offset(size.width * 0.4, size.height * 0.35), size.width * 0.2, paint);
    canvas.drawArc(
        Rect.fromLTWH(size.width * 0.1, size.height * 0.55, size.width * 0.6,
            size.height * 0.4),
        math.pi,
        math.pi,
        true,
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AssignToMePainter extends CustomPainter {
  _AssignToMePainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
        Offset(size.width * 0.45, size.height * 0.3), size.width * 0.2, paint);
    canvas.drawArc(
        Rect.fromLTWH(size.width * 0.15, size.height * 0.55, size.width * 0.6,
            size.height * 0.4),
        math.pi,
        math.pi,
        true,
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ChangeStatusPainter extends CustomPainter {
  _ChangeStatusPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final center = Offset(size.width * 0.5, size.height * 0.5);
    canvas.drawCircle(center, size.width * 0.4, paint);
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawArc(Rect.fromCircle(center: center, radius: size.width * 0.4),
        -math.pi / 2, math.pi, true, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ChangePriorityPainter extends CustomPainter {
  _ChangePriorityPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.15, size.height * 0.6,
                size.width * 0.18, size.height * 0.3),
            const Radius.circular(1)),
        paint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.41, size.height * 0.4,
                size.width * 0.18, size.height * 0.5),
            const Radius.circular(1)),
        paint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.67, size.height * 0.2,
                size.width * 0.18, size.height * 0.7),
            const Radius.circular(1)),
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ChangeLabelsPainter extends CustomPainter {
  _ChangeLabelsPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.3)
      ..lineTo(size.width * 0.6, size.height * 0.3)
      ..lineTo(size.width * 0.85, size.height * 0.5)
      ..lineTo(size.width * 0.6, size.height * 0.7)
      ..lineTo(size.width * 0.2, size.height * 0.7)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RemoveLabelPainter extends CustomPainter {
  _RemoveLabelPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.3)
      ..lineTo(size.width * 0.6, size.height * 0.3)
      ..lineTo(size.width * 0.85, size.height * 0.5)
      ..lineTo(size.width * 0.6, size.height * 0.7)
      ..lineTo(size.width * 0.2, size.height * 0.7)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SetDueDatePainter extends CustomPainter {
  _SetDueDatePainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rect = Rect.fromLTWH(size.width * 0.15, size.height * 0.2,
        size.width * 0.7, size.height * 0.65);
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)), paint);
    canvas.drawLine(Offset(size.width * 0.15, size.height * 0.42),
        Offset(size.width * 0.85, size.height * 0.42), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ProjectsPainter extends CustomPainter {
  _ProjectsPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final s = size.width * 0.32;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.12, size.height * 0.12, s, s),
            const Radius.circular(2)),
        paint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.56, size.height * 0.12, s, s),
            const Radius.circular(2)),
        paint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.12, size.height * 0.56, s, s),
            const Radius.circular(2)),
        paint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.56, size.height * 0.56, s, s),
            const Radius.circular(2)),
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PlusPainter extends CustomPainter {
  _PlusPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(size.width * 0.5, size.height * 0.2),
        Offset(size.width * 0.5, size.height * 0.8), paint);
    canvas.drawLine(Offset(size.width * 0.2, size.height * 0.5),
        Offset(size.width * 0.8, size.height * 0.5), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TeamsPainter extends CustomPainter {
  _TeamsPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(
        Offset(size.width * 0.4, size.height * 0.35), size.width * 0.18, paint);
    canvas.drawArc(
        Rect.fromLTWH(size.width * 0.1, size.height * 0.55, size.width * 0.6,
            size.height * 0.35),
        math.pi,
        math.pi,
        false,
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DocsPainter extends CustomPainter {
  _DocsPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.15)
      ..lineTo(size.width * 0.55, size.height * 0.15)
      ..lineTo(size.width * 0.8, size.height * 0.38)
      ..lineTo(size.width * 0.8, size.height * 0.85)
      ..lineTo(size.width * 0.2, size.height * 0.85)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FeedbackPainter extends CustomPainter {
  _FeedbackPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final r = Rect.fromLTWH(2, 2, size.width - 4, size.height - 6);
    canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(3)), paint);
    final p = Path()
      ..moveTo(size.width * 0.35, size.height - 4)
      ..lineTo(size.width * 0.25, size.height - 1)
      ..lineTo(size.width * 0.5, size.height - 4);
    canvas.drawPath(p, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SupportPainter extends CustomPainter {
  _SupportPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.5), size.width * 0.42, paint);
    canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.5), size.width * 0.2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FramerButtonPainter extends CustomPainter {
  _FramerButtonPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(
                2, size.height * 0.25, size.width - 4, size.height * 0.5),
            const Radius.circular(3)),
        paint);
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
        Offset(size.width * 0.35, size.height * 0.5), 1.2, dotPaint);
    canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.5), 1.2, dotPaint);
    canvas.drawCircle(
        Offset(size.width * 0.65, size.height * 0.5), 1.2, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FramerInputPainter extends CustomPainter {
  _FramerInputPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(size.width * 0.2, size.height * 0.2),
        Offset(size.width * 0.2, size.height * 0.8), paint);
    canvas.drawLine(Offset(size.width * 0.8, size.height * 0.2),
        Offset(size.width * 0.8, size.height * 0.8), paint);
    canvas.drawLine(Offset(size.width * 0.5, size.height * 0.25),
        Offset(size.width * 0.5, size.height * 0.75), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FramerRadioPainter extends CustomPainter {
  _FramerRadioPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final c = Offset(size.width * 0.5, size.height * 0.5);
    canvas.drawCircle(c, size.width * 0.4, paint);
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(c, size.width * 0.18, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FramerBadgePainter extends CustomPainter {
  _FramerBadgePainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(
                2, size.height * 0.3, size.width - 4, size.height * 0.4),
            Radius.circular(size.height * 0.2)),
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FramerSliderPainter extends CustomPainter {
  _FramerSliderPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(2, size.height * 0.5),
        Offset(size.width - 2, size.height * 0.5), paint);
    final knobPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
        Offset(size.width * 0.4, size.height * 0.5), 3, knobPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FramerAvatarPainter extends CustomPainter {
  _FramerAvatarPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.5), size.width * 0.42, paint);
    canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.4), size.width * 0.16, paint);
    canvas.drawArc(
        Rect.fromLTWH(size.width * 0.25, size.height * 0.58, size.width * 0.5,
            size.height * 0.3),
        math.pi,
        math.pi,
        false,
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FramerContainerPainter extends CustomPainter {
  _FramerContainerPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(2, 2, size.width - 4, size.height - 4),
            const Radius.circular(3)),
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ShiftPainter extends CustomPainter {
  _ShiftPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.1)
      ..lineTo(size.width * 0.85, size.height * 0.5)
      ..lineTo(size.width * 0.65, size.height * 0.5)
      ..lineTo(size.width * 0.65, size.height * 0.9)
      ..lineTo(size.width * 0.35, size.height * 0.9)
      ..lineTo(size.width * 0.35, size.height * 0.5)
      ..lineTo(size.width * 0.15, size.height * 0.5)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
