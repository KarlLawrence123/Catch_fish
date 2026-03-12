import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/health_status_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
                Text('Catfish Disease Detector', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
                Text('Backyard Pond #1', style: TextStyle(color: Colors.blueGrey[400])),
                const SizedBox(height: 25),

                // Main Status
                const HealthStatusCard(status: 'disease'),
                const SizedBox(height: 20),

                // Stats Row
                Row(
                  children: [
                    _buildSmallStatCard('Latest: Columnaris', '85% Conf.', AppTheme.dangerColor),
                    const SizedBox(width: 15),
                    _buildSmallStatCard('Total Alerts', '2', AppTheme.dangerColor),
                  ],
                ),
                const SizedBox(height: 30),

                // Quick Actions
                const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  children: [
                    QuickActionButton(icon: Icons.monitor_heart, label: 'Monitoring', color: Colors.blue, onTap: () {}),
                    QuickActionButton(icon: Icons.notifications, label: 'Alerts', color: Colors.red, onTap: () {}),
                    QuickActionButton(icon: Icons.history, label: 'History', color: Colors.teal, onTap: () {}),
                    QuickActionButton(icon: Icons.camera_alt, label: 'Scan Fish', color: Colors.cyan, onTap: () {}),
                  ],
                ),
              ],
            ),
          ),
        ),
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
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}