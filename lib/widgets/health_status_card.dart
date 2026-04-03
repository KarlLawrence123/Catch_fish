import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HealthStatusCard extends StatelessWidget {
  final String status;
  final VoidCallback? onTap;

  const HealthStatusCard({super.key, required this.status, this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = AppTheme.getHealthStatusColor(status);

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // The "Blur" effect
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(30),
            border:
                Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: statusColor.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Use a more vibrant icon/image container
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor.withOpacity(0.1),
                ),
                child:
                    Icon(Icons.warning_rounded, color: statusColor, size: 40),
              ),
              const SizedBox(height: 12),
              Text(
                "Disease Detected",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
              const Text(
                "Immediate action required for Backyard Pond #1",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
