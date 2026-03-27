import 'package:flutter/material.dart';
import 'dart:math' as math;

class OceanBackground extends StatefulWidget {
  final Widget child;
  final bool isDarkMode;

  const OceanBackground({
    super.key,
    required this.child,
    this.isDarkMode = false,
  });

  @override
  State<OceanBackground> createState() => _OceanBackgroundState();
}

class _OceanBackgroundState extends State<OceanBackground>
    with TickerProviderStateMixin {
  late AnimationController _fishController;
  late AnimationController _bubbleController;

  @override
  void initState() {
    super.initState();

    _fishController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _fishController.dispose();
    _bubbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Ocean Background with Gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: widget.isDarkMode
                  ? [
                      const Color(0xFF001F3F), // Deep ocean blue
                      const Color(0xFF003366), // Dark blue
                      const Color(0xFF004080), // Medium dark blue
                      const Color(0xFF0052A3), // Lighter dark blue
                    ]
                  : [
                      const Color(0xFF1A4D6D), // Light ocean blue
                      const Color(0xFF2E7D9A),
                      const Color(0xFF4FA8C5),
                      const Color(0xFF7BC9E3),
                    ],
            ),
          ),
        ),

        // Animated Fish
        ...List.generate(
          widget.isDarkMode ? 6 : 5,
          (index) => _buildAnimatedFish(index),
        ),

        // Animated Bubbles
        ...List.generate(15, (index) => _buildBubble(index)),

        // Content
        widget.child,
      ],
    );
  }

  Widget _buildAnimatedFish(int index) {
    final random = math.Random(index);
    final startY = random.nextDouble() * 0.6 + 0.1;
    final size = random.nextDouble() * 30 + 40; // Larger fish
    final swimSpeed = random.nextDouble() * 0.3 + 0.7; // Varied speeds

    return AnimatedBuilder(
      animation: _fishController,
      builder: (context, child) {
        final progress =
            (_fishController.value * swimSpeed + (index * 0.15)) % 1.0;
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        // Swimming motion: sine wave for vertical movement
        final verticalWave = math.sin(progress * math.pi * 3) * 40;

        // Tail fin movement: subtle rotation
        final tailWiggle = math.sin(progress * math.pi * 8) * 0.05;

        // Slight body tilt when changing direction
        final bodyTilt = math.sin(progress * math.pi * 2) * 0.03;

        return Positioned(
          left: progress * (screenWidth + 150) - 75,
          top: screenHeight * startY + verticalWave,
          child: Opacity(
            opacity: widget.isDarkMode ? 0.8 : 0.7,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..rotateZ(bodyTilt + tailWiggle)
                ..scale(progress > 0.5 ? -1.0 : 1.0, 1.0),
              child: Image.asset(
                widget.isDarkMode
                    ? 'assets/images/Adobe Express - file.png' // Blue catfish for dark mode
                    : 'assets/images/download.png', // New brown catfish for light mode
                width: size,
                height: size,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBubble(int index) {
    final random = math.Random(index * 100);
    final startX = random.nextDouble();
    final size = random.nextDouble() * 15 + 5;

    return AnimatedBuilder(
      animation: _bubbleController,
      builder: (context, child) {
        final progress = (_bubbleController.value + (index * 0.1)) % 1.0;
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        return Positioned(
          left: screenWidth * startX + math.sin(progress * math.pi * 2) * 20,
          bottom: progress * (screenHeight + 50) - 50,
          child: Opacity(
            opacity: widget.isDarkMode ? 0.4 : 0.3,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.5),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
