import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The app logo: gold "levels" bars on the app teal, matching the launcher
/// icon. Drawn in code, so it needs no image asset and stays sharp at any size.
class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 46});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: primaryTeal,
          borderRadius: BorderRadius.circular(size * 0.3),
        ),
        child: CustomPaint(painter: _LogoPainter()),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  // Everything below is in the 1024 x 1024 design space of the icon.
  static const Color _gold = Color(0xFFFBBF24);

  // left, top, width, height
  static const List<Rect> _bars = [
    Rect.fromLTWH(157, 520, 110, 260),
    Rect.fromLTWH(307, 400, 110, 380),
    Rect.fromLTWH(457, 300, 110, 480),
    Rect.fromLTWH(607, 400, 110, 380),
    Rect.fromLTWH(757, 520, 110, 260),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // Centre the artwork (its middle is at y = 498) and leave some padding.
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(size.width / 1024 * 0.8);
    canvas.translate(-512, -498);

    final gold = Paint()..color = _gold;
    for (final bar in _bars) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(bar, const Radius.circular(16)),
        gold,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(505, 170, 14, 140),
        const Radius.circular(7),
      ),
      gold,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(120, 800, 784, 26),
        const Radius.circular(13),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
