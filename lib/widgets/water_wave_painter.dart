import 'dart:math' as math;
import 'package:flutter/material.dart';

class WaterWaveBackground extends StatefulWidget {
  final Widget child;
  final Color color;

  const WaterWaveBackground({super.key, required this.child, this.color = const Color(0xFF0277BD)});

  @override
  State<WaterWaveBackground> createState() => _WaterWaveBackgroundState();
}

class _WaterWaveBackgroundState extends State<WaterWaveBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: WavePainter(
                waveAnimation: _controller.value,
                color: widget.color.withOpacity(0.05),
              ),
              child: Container(),
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class WavePainter extends CustomPainter {
  final double waveAnimation;
  final Color color;

  WavePainter({required this.waveAnimation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path();

    path.moveTo(0, size.height * 0.8);

    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        size.height * 0.8 + math.sin((i / size.width * 2 * math.pi) + (waveAnimation * 2 * math.pi)) * 20,
      );
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}