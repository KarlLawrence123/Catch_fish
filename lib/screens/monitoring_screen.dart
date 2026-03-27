import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/water_wave_painter.dart';

class MonitoringScreen extends StatelessWidget {
  const MonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: AppTheme.aquaticBackground,
        child: WaterWaveBackground(
          color: isDark ? AppTheme.darkPrimaryColor : AppTheme.lightPrimaryColor,
          child: SafeArea(
            child: Column(
              children: [
                _buildMonitoringHeader(context),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildGlassSensorCard(
                        context,
                        'Water Temperature',
                        '28.5°C',
                        Icons.thermostat,
                        Colors.orange,
                        'Optimal range: 25-30°C',
                      ),
                      const SizedBox(height: 16),
                      _buildGlassSensorCard(
                        context,
                        'pH Level',
                        '7.2',
                        Icons.science,
                        Colors.green,
                        'Neutral - Healthy for Catfish',
                      ),
                      const SizedBox(height: 16),
                      _buildGlassSensorCard(
                        context,
                        'Ammonia (NH3)',
                        '0.02 ppm',
                        Icons.opacity,
                        AppTheme.dangerColor,
                        'Low - Keep monitoring',
                      ),
                      const SizedBox(height: 16),
                      _buildGlassSensorCard(
                        context,
                        'Water Level',
                        '85%',
                        Icons.waves,
                        AppTheme.accentColor,
                        'Normal operating level',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonitoringHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'Live Monitoring',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          const CircleAvatar(
            radius: 4,
            backgroundColor: Colors.greenAccent,
          ),
          const SizedBox(width: 8),
          const Text('Live', style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildGlassSensorCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String statusText,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(isDark ? 0.05 : 0.3),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: color, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: Colors.white.withOpacity(0.1)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}