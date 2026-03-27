import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/detection_data.dart';
import '../theme/app_theme.dart';

class DualStreamMonitoringScreen extends StatefulWidget {
  const DualStreamMonitoringScreen({super.key});

  @override
  State<DualStreamMonitoringScreen> createState() =>
      _DualStreamMonitoringScreenState();
}

class _DualStreamMonitoringScreenState
    extends State<DualStreamMonitoringScreen> {
  bool _showOverheadView = true;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dual-Stream Monitoring'),
        backgroundColor: isDarkMode 
            ? const Color(0xFF1A237E)
            : const Color(0xFF0277BD),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<DetectionProvider>(
            builder: (context, provider, _) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Tooltip(
                  message: provider.nightModeEnabled
                      ? 'Night Mode: ON'
                      : 'Night Mode: OFF',
                  child: IconButton(
                    icon: Icon(
                      provider.nightModeEnabled
                          ? Icons.nightlight
                          : Icons.light_mode,
                      color: provider.nightModeEnabled
                          ? Colors.amber
                          : Colors.grey,
                    ),
                    onPressed: () {
                      provider.toggleNightMode();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'IR LED ${provider.nightModeEnabled ? 'ON' : 'OFF'}',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
                    const Color(0xFF001F3F),
                    const Color(0xFF003366),
                    const Color(0xFF004080),
                  ]
                : [
                    const Color(0xFFF0F9FF),
                    const Color(0xFFE1F5FE),
                  ],
          ),
        ),
        child: Consumer<DetectionProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Dual Stream Views
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Overhead View
                      _buildCameraView(
                        title: 'Overhead View',
                        subtitle: 'Checking for Columnaris & swimming behavior',
                        icon: Icons.videocam,
                        isActive: _showOverheadView,
                        onTap: () {
                          setState(() => _showOverheadView = true);
                        },
                      ),
                      const SizedBox(height: 16),
                      // Underwater (NoIR) View
                      _buildCameraView(
                        title: 'Underwater (NoIR) View',
                        subtitle: 'Detecting Fin Rot & White Spot Disease',
                        icon: Icons.water,
                        isActive: !_showOverheadView,
                        onTap: () {
                          setState(() => _showOverheadView = false);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Latest Detection
                _buildLatestDetection(provider),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
        ),
      ),
    );
  }

  Widget _buildCameraView({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? Colors.blue : Colors.grey[300]!,
            width: isActive ? 2 : 1,
          ),
          color: isActive ? Colors.blue.withOpacity(0.05) : Colors.transparent,
        ),
        child: Column(
          children: [
            // Camera Feed Placeholder
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                color: Colors.grey[800],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 48,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Camera Feed',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Camera Info
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        icon,
                        size: 20,
                        color: isActive ? Colors.blue : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              subtitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'ACTIVE',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestDetection(DetectionProvider provider) {
    if (provider.detections.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey[100],
          ),
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No detections yet',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    final latest = provider.detections.first;
    final statusColor = AppTheme.getHealthStatusColor(latest.status);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: statusColor.withOpacity(0.3)),
          color: statusColor.withOpacity(0.05),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Latest Detection',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    latest.severity.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              latest.diseaseName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Confidence',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${(latest.confidence * 100).toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Camera View',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      latest.cameraView == 'overhead'
                          ? 'Overhead'
                          : 'Underwater',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      _formatTime(latest.timestamp),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            if (latest.recommendedAction != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, size: 16, color: statusColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        latest.recommendedAction!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
