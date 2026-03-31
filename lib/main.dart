import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/theme_notifier.dart';
import 'screens/dashboard_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/disease_info_screen.dart';
import 'screens/dual_stream_monitoring_screen.dart';
import 'screens/health_logs_screen.dart';
import 'screens/login_screen.dart';
import 'screens/gallery_screen.dart';
import 'models/detection_data.dart';
import 'services/database_service.dart';
import 'services/auth_service.dart';
import 'widgets/ocean_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite Database
  final db = DatabaseService();
  await db.database;

  // Initialize Auth Service (offline mode)
  final authService = AuthService();
  await authService.initialize();

  runApp(const CatfishDetectorApp());
}

class CatfishDetectorApp extends StatelessWidget {
  const CatfishDetectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. We use MultiProvider to inject BOTH your data and your theme logic
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          final provider = DetectionProvider();
          provider.loadDetections(); // Load saved detections from database
          return provider;
        }),
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
            home: const LoginScreen(),
            routes: {
              '/home': (context) => const MainScreen(),
              '/gallery': (context) => const GalleryScreen(),
            },
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

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(onNavigate: _onNavigate),
      const DualStreamMonitoringScreen(),
      const HealthLogsScreen(),
      const AlertsScreen(),
      const GalleryScreen(),
      const DiseaseInfoScreen(),
    ];
    // No sample data initialization - app will show real detections only
  }

  void _onNavigate(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.themeMode == ThemeMode.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.waves, size: 24),
            const SizedBox(width: 8),
            Text(
              _getScreenTitle(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          // Theme Toggle Button
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: Colors.white,
              ),
              tooltip: isDarkMode
                  ? 'Light Mode (Shallow Ocean)'
                  : 'Dark Mode (Deep Ocean)',
              onPressed: () {
                themeNotifier.toggleTheme();
              },
            ),
          ),
        ],
      ),
      body: OceanBackground(
        isDarkMode: isDarkMode,
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
                    const Color(0xFF001F3F).withOpacity(0.95),
                    const Color(0xFF003366).withOpacity(0.98),
                  ]
                : [
                    const Color(0xFF4FA8C5).withOpacity(0.95),
                    const Color(0xFF2E7D9A).withOpacity(0.98),
                  ],
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.6),
          selectedFontSize: 12,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(
                icon: Icon(Icons.videocam), label: 'Monitor'),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today), label: 'Logs'),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications), label: 'Alerts'),
            BottomNavigationBarItem(
                icon: Icon(Icons.photo_library), label: 'Gallery'),
            BottomNavigationBarItem(
                icon: Icon(Icons.healing), label: 'Diseases'),
          ],
        ),
      ),
    );
  }

  String _getScreenTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Monitor';
      case 2:
        return 'Health Logs';
      case 3:
        return 'Alerts';
      case 4:
        return 'Gallery';
      case 5:
        return 'Diseases';
      default:
        return 'Catfish Detector';
    }
  }
}
