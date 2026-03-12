import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/theme_notifier.dart';
import 'screens/dashboard_screen.dart';
import 'screens/monitoring_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/disease_info_screen.dart';
import 'models/detection_data.dart';

void main() {
  runApp(const CatfishDetectorApp());
}

class CatfishDetectorApp extends StatelessWidget {
  const CatfishDetectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. We use MultiProvider to inject BOTH your data and your theme logic
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DetectionProvider()),
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
      ],
      // 2. We use a Consumer here so the MaterialApp REBUILDS when the theme changes
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp(
            title: 'Catfish Disease Detector',
            debugShowCheckedModeBanner: false,
            // 3. Connect the themes from your AppTheme file
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeNotifier.themeMode, 
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const MonitoringScreen(),
    const AlertsScreen(),
    const DiseaseInfoScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.monitor_heart), label: 'Monitor'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.healing), label: 'Diseases'),
        ],
      ),
    );
  }
}