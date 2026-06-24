import 'dart:math' as math;
import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final bool isLoading;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.label = 'Masuk dengan Google',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFF1A1928), // surface color
          side: const BorderSide(color: Color(0xFF2E2D45), width: 1.5), // divider color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          foregroundColor: Colors.white,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const GoogleLogoWidget(size: 22),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFFF5F5F5), // textPrimary
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class GoogleLogoWidget extends StatelessWidget {
  final double size;
  const GoogleLogoWidget({super.key, this.size = 24.0});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: const _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w / 4.5
      ..strokeCap = StrokeCap.butt;

    final rect = Rect.fromLTWH(
      paint.strokeWidth / 2,
      paint.strokeWidth / 2,
      w - paint.strokeWidth,
      h - paint.strokeWidth,
    );

    const double degToRad = math.pi / 180;

    // Draw Red: Top Arc
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -140 * degToRad, 100 * degToRad, false, paint);

    // Draw Amber: Left Arc
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 140 * degToRad, 80 * degToRad, false, paint);

    // Draw Green: Bottom Arc
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 45 * degToRad, 95 * degToRad, false, paint);

    // Draw Blue: Right Arc
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -40 * degToRad, 85 * degToRad, false, paint);

    // Draw Blue inner horizontal bar
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    final barRect = Rect.fromLTWH(
      w / 2,
      h / 2 - paint.strokeWidth / 2,
      w / 2 - paint.strokeWidth / 2,
      paint.strokeWidth,
    );
    canvas.drawRect(barRect, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
