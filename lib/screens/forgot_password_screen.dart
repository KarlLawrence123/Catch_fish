import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../services/auth_service.dart';
import '../providers/theme_notifier.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  late TextEditingController _emailController;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  late AnimationController _fishController;
  late AnimationController _bubbleController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();

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
    _emailController.dispose();
    _fishController.dispose();
    _bubbleController.dispose();
    super.dispose();
  }

  void _handlePasswordReset() async {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email');
      return;
    }

    if (!email.contains('@')) {
      setState(() => _errorMessage = 'Please enter a valid email');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      await authService.sendPasswordResetEmail(email);

      setState(() => _successMessage =
          'Account verified! Please contact your administrator to reset your password.');

      // Clear email field
      _emailController.clear();

      // Navigate back after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.themeMode == ThemeMode.dark;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          themeNotifier.toggleTheme();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isDarkMode
                    ? '☀️ Switching to Light Mode'
                    : '🌙 Switching to Dark Mode',
                style: const TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.bold),
              ),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.white,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        backgroundColor: Colors.white.withOpacity(0.9),
        child: Icon(
          isDarkMode ? Icons.light_mode : Icons.dark_mode,
          color: isDarkMode ? Colors.orange : Colors.blue[900],
          size: 28,
        ),
      ),
      body: Stack(
        children: [
          // Ocean Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDarkMode
                    ? [
                        const Color(0xFF001F3F),
                        const Color(0xFF003366),
                        const Color(0xFF004080),
                        const Color(0xFF0052A3),
                      ]
                    : [
                        const Color(0xFF1A4D6D),
                        const Color(0xFF2E7D9A),
                        const Color(0xFF4FA8C5),
                        const Color(0xFF7BC9E3),
                      ],
              ),
            ),
          ),

          // Animated Fish/Creatures
          ...List.generate(
            isDarkMode ? 6 : 5,
            (index) => _buildAnimatedFish(index, isDarkMode),
          ),

          // Animated Bubbles
          ...List.generate(15, (index) => _buildBubble(index, isDarkMode)),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Back Button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Header
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Reset Password 🔑',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter your email to receive a password reset link',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Error Message
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        border: Border.all(color: Colors.red.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Success Message
                  if (_successMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        border:
                            Border.all(color: Colors.green.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _successMessage!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (_errorMessage != null || _successMessage != null)
                    const SizedBox(height: 20),

                  // Email Field
                  Text(
                    'Email Address',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    enabled: !_isLoading,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'farmer@example.com',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: Colors.blue[700],
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 32),

                  // Send Reset Link Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF0D47A1),
                          const Color(0xFF1976D2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handlePasswordReset,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Send Reset Link 📧',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What happens next?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '1. We\'ll send a password reset link to your email\n2. Click the link in the email\n3. Create a new password\n4. Sign in with your new password',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedFish(int index, bool isDarkMode) {
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
            opacity: isDarkMode ? 0.8 : 0.7,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..rotateZ(bodyTilt + tailWiggle)
                ..scale(progress > 0.5 ? -1.0 : 1.0, 1.0),
              child: Image.asset(
                isDarkMode
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

  Widget _buildBubble(int index, bool isDarkMode) {
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
            opacity: isDarkMode ? 0.4 : 0.3,
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
