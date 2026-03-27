import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/health_status_card.dart';
import '../models/detection_data.dart';
import '../services/notification_service.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int)? onNavigate;

  const DashboardScreen({super.key, this.onNavigate});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForCriticalAlerts();
    });
  }

  void _checkForCriticalAlerts() {
    final provider = Provider.of<DetectionProvider>(context, listen: false);
    if (provider.detections.isNotEmpty) {
      final latest = provider.detections.first;
      if (latest.severity == 'critical') {
        NotificationService().showCriticalAlert(
          context,
          title: 'CRITICAL ALERT',
          message:
              '${latest.diseaseName} detected with ${(latest.confidence * 100).toStringAsFixed(1)}% confidence. Immediate action required!',
          severity: 'critical',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.aquaticBackground,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text('Catfish Disease Detector',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.blueGrey[900])),
                Text('Backyard Pond #1',
                    style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[400]
                            : Colors.blueGrey[400])),
                const SizedBox(height: 25),

                // Main Status
                const HealthStatusCard(status: 'disease'),
                const SizedBox(height: 20),

                // Critical Alert Banner
                Consumer<DetectionProvider>(
                  builder: (context, provider, _) {
                    if (provider.detections.isNotEmpty &&
                        provider.detections.first.severity == 'critical') {
                      return _buildCriticalAlertBanner(
                          provider.detections.first);
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // Stats Row with Detection Info
                Consumer<DetectionProvider>(
                  builder: (context, provider, _) {
                    if (provider.detections.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    final latest = provider.detections.first;
                    return Column(
                      children: [
                        Row(
                          children: [
                            _buildSmallStatCard(
                              'Latest: ${latest.diseaseName}',
                              '${(latest.confidence * 100).toStringAsFixed(1)}%',
                              AppTheme.dangerColor,
                            ),
                            const SizedBox(width: 15),
                            _buildSmallStatCard(
                              'Severity',
                              latest.severity.toUpperCase(),
                              _getSeverityColor(latest.severity),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),

                // Quick Actions
                Text('Quick Actions',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black)),
                const SizedBox(height: 15),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  children: [
                    QuickActionButton(
                      icon: Icons.monitor_heart,
                      label: 'Monitoring',
                      color: Colors.blue,
                      onTap: () {
                        widget.onNavigate?.call(1);
                      },
                    ),
                    QuickActionButton(
                      icon: Icons.notifications,
                      label: 'Alerts',
                      color: Colors.red,
                      onTap: () {
                        widget.onNavigate?.call(3);
                      },
                    ),
                    QuickActionButton(
                      icon: Icons.history,
                      label: 'Logs',
                      color: Colors.teal,
                      onTap: () {
                        widget.onNavigate?.call(2);
                      },
                    ),
                    QuickActionButton(
                      icon: Icons.camera_alt,
                      label: 'Scan Fish',
                      color: Colors.cyan,
                      onTap: () {
                        widget.onNavigate?.call(1);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCriticalAlertBanner(DetectionData detection) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.red.withOpacity(0.1),
        border: Border.all(color: Colors.red, width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CRITICAL SEVERITY',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${detection.diseaseName} - Immediate action required',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
            Text(value,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'acute':
        return Colors.orange;
      case 'early':
        return Colors.yellow;
      default:
        return Colors.green;
    }
  }
}
