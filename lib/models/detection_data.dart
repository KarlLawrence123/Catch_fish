import 'package:flutter/foundation.dart';
import '../services/database_service.dart';

class DetectionData {
  final String id;
  final String diseaseName;
  final double confidence;
  final DateTime timestamp;
  final String imagePath;
  final String status; // 'healthy', 'suspicious', 'disease'
  final String? recommendedAction;
  final String severity; // 'early', 'acute', 'critical'
  final String cameraView; // 'overhead', 'underwater'

  DetectionData({
    required this.id,
    required this.diseaseName,
    required this.confidence,
    required this.timestamp,
    required this.imagePath,
    required this.status,
    this.recommendedAction,
    this.severity = 'early',
    this.cameraView = 'overhead',
  });

  factory DetectionData.fromJson(Map<String, dynamic> json) {
    return DetectionData(
      id: json['id'] ?? '',
      diseaseName: json['diseaseName'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      imagePath: json['imagePath'] ?? '',
      status: json['status'] ?? 'healthy',
      recommendedAction: json['recommendedAction'],
      severity: json['severity'] ?? 'early',
      cameraView: json['cameraView'] ?? 'overhead',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'diseaseName': diseaseName,
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
      'imagePath': imagePath,
      'status': status,
      'recommendedAction': recommendedAction,
      'severity': severity,
      'cameraView': cameraView,
    };
  }
}

class AlertData {
  final String id;
  final String title;
  final String message;
  final String severity; // 'low', 'medium', 'high'
  final DateTime timestamp;
  final String detectionId;
  bool isRead;

  AlertData({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
    required this.detectionId,
    this.isRead = false,
  });

  factory AlertData.fromJson(Map<String, dynamic> json) {
    return AlertData(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      severity: json['severity'] ?? 'low',
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      detectionId: json['detectionId'] ?? '',
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'severity': severity,
      'timestamp': timestamp.toIso8601String(),
      'detectionId': detectionId,
      'isRead': isRead,
    };
  }
}

class EnvironmentalStats {
  final double temperature; // in Celsius
  final double pH;
  final DateTime timestamp;

  EnvironmentalStats({
    required this.temperature,
    required this.pH,
    required this.timestamp,
  });
}

class DiseaseInfo {
  final String name;
  final String description;
  final List<String> symptoms;
  final List<String> causes;
  final List<String> treatment;
  final List<String> prevention;
  final String iconPath;

  DiseaseInfo({
    required this.name,
    required this.description,
    required this.symptoms,
    required this.causes,
    required this.treatment,
    required this.prevention,
    required this.iconPath,
  });
}

class DetectionProvider extends ChangeNotifier {
  List<DetectionData> _detections = [];
  List<AlertData> _alerts = [];
  String _pondStatus = 'healthy';
  int _totalAlerts = 0;
  EnvironmentalStats? _currentEnvironmentalStats;
  bool _nightModeEnabled = false;
  final DatabaseService _databaseService = DatabaseService();

  List<DetectionData> get detections => _detections;
  List<AlertData> get alerts => _alerts;
  String get pondStatus => _pondStatus;
  int get totalAlerts => _totalAlerts;
  EnvironmentalStats? get currentEnvironmentalStats =>
      _currentEnvironmentalStats;
  bool get nightModeEnabled => _nightModeEnabled;

  // Load detections from database on initialization
  Future<void> loadDetections() async {
    try {
      _detections = await _databaseService.getAllDetections();
      _updatePondStatus();
      notifyListeners();
    } catch (e) {
      print('Error loading detections: $e');
    }
  }

  void _updatePondStatus() {
    if (_detections.any((d) => d.status == 'disease')) {
      _pondStatus = 'disease';
    } else if (_detections.any((d) => d.status == 'suspicious')) {
      _pondStatus = 'suspicious';
    } else {
      _pondStatus = 'healthy';
    }
  }

  Future<void> addDetection(DetectionData detection) async {
    _detections.insert(0, detection);

    // Save to database
    try {
      await _databaseService.insertDetection(detection);
    } catch (e) {
      print('Error saving detection to database: $e');
    }

    // Create alert if disease or suspicious
    if (detection.status != 'healthy') {
      final alert = AlertData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: detection.status == 'disease'
            ? 'Disease Detected'
            : 'Suspicious Activity',
        message:
            '${detection.diseaseName} detected with ${(detection.confidence * 100).toStringAsFixed(1)}% confidence',
        severity: detection.status == 'disease' ? 'high' : 'medium',
        timestamp: DateTime.now(),
        detectionId: detection.id,
      );
      _alerts.insert(0, alert);
      
      // Note: Alert saving to database would require adding insertAlert method to DatabaseService
      // For now, alerts are kept in memory only
    }

    _updatePondStatus();
    _totalAlerts = _alerts.where((alert) => !alert.isRead).length;
    notifyListeners();
  }

  void markAlertAsRead(String alertId) {
    final alert = _alerts.firstWhere((a) => a.id == alertId);
    alert.isRead = true;
    _totalAlerts = _alerts.where((alert) => !alert.isRead).length;
    notifyListeners();
  }

  void toggleNightMode() {
    _nightModeEnabled = !_nightModeEnabled;
    notifyListeners();
  }

  void updateEnvironmentalStats(double temperature, double pH) {
    _currentEnvironmentalStats = EnvironmentalStats(
      temperature: temperature,
      pH: pH,
      timestamp: DateTime.now(),
    );
    notifyListeners();
  }
}
