import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/detection_data.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'catfish_detector.db');

    return openDatabase(
      path,
      version: 2, // Incremented version for schema update
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create detections table
    await db.execute('''
      CREATE TABLE detections (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        detection_id TEXT UNIQUE NOT NULL,
        disease_name TEXT NOT NULL,
        confidence REAL NOT NULL,
        severity TEXT NOT NULL,
        camera_view TEXT NOT NULL,
        image_path TEXT,
        image_data BLOB,
        status TEXT NOT NULL,
        recommended_action TEXT,
        timestamp TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Create health logs table
    await db.execute('''
      CREATE TABLE health_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pond_name TEXT,
        notes TEXT,
        status TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Create alerts table
    await db.execute('''
      CREATE TABLE alerts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        alert_id TEXT UNIQUE NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        severity TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        detection_id TEXT,
        is_read INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Create indexes for better query performance
    await db.execute(
        'CREATE INDEX idx_detections_timestamp ON detections(timestamp)');
    await db.execute(
        'CREATE INDEX idx_detections_severity ON detections(severity)');
    await db.execute(
        'CREATE INDEX idx_health_logs_timestamp ON health_logs(timestamp)');
    await db.execute('CREATE INDEX idx_alerts_timestamp ON alerts(timestamp)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add image_data BLOB column for storing captured images offline
      await db.execute('ALTER TABLE detections ADD COLUMN image_data BLOB');
    }
  }

  // Detection operations
  Future<int> insertDetection(DetectionData detection,
      {List<int>? imageBytes}) async {
    final db = await database;
    return db.insert(
      'detections',
      {
        'detection_id': detection.id,
        'disease_name': detection.diseaseName,
        'confidence': detection.confidence,
        'severity': detection.severity,
        'camera_view': detection.cameraView,
        'image_path': detection.imagePath,
        'image_data': imageBytes, // Store image as BLOB for offline access
        'status': detection.status,
        'recommended_action': detection.recommendedAction,
        'timestamp': detection.timestamp.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get image data from detection
  Future<List<int>?> getDetectionImage(String detectionId) async {
    final db = await database;
    final result = await db.query(
      'detections',
      columns: ['image_data'],
      where: 'detection_id = ?',
      whereArgs: [detectionId],
    );

    if (result.isNotEmpty && result.first['image_data'] != null) {
      return result.first['image_data'] as List<int>;
    }
    return null;
  }

  Future<List<DetectionData>> getAllDetections() async {
    final db = await database;
    final maps = await db.query(
      'detections',
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return DetectionData(
        id: maps[i]['detection_id'] as String,
        diseaseName: maps[i]['disease_name'] as String,
        confidence: maps[i]['confidence'] as double,
        timestamp: DateTime.parse(maps[i]['timestamp'] as String),
        imagePath: maps[i]['image_path'] as String,
        status: maps[i]['status'] as String,
        recommendedAction: maps[i]['recommended_action'] as String?,
        severity: maps[i]['severity'] as String,
        cameraView: maps[i]['camera_view'] as String,
      );
    });
  }

  Future<List<DetectionData>> getDetectionsBySeverity(String severity) async {
    final db = await database;
    final maps = await db.query(
      'detections',
      where: 'severity = ?',
      whereArgs: [severity],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return DetectionData(
        id: maps[i]['detection_id'] as String,
        diseaseName: maps[i]['disease_name'] as String,
        confidence: maps[i]['confidence'] as double,
        timestamp: DateTime.parse(maps[i]['timestamp'] as String),
        imagePath: maps[i]['image_path'] as String,
        status: maps[i]['status'] as String,
        recommendedAction: maps[i]['recommended_action'] as String?,
        severity: maps[i]['severity'] as String,
        cameraView: maps[i]['camera_view'] as String,
      );
    });
  }

  Future<List<DetectionData>> getDetectionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final maps = await db.query(
      'detections',
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return DetectionData(
        id: maps[i]['detection_id'] as String,
        diseaseName: maps[i]['disease_name'] as String,
        confidence: maps[i]['confidence'] as double,
        timestamp: DateTime.parse(maps[i]['timestamp'] as String),
        imagePath: maps[i]['image_path'] as String,
        status: maps[i]['status'] as String,
        recommendedAction: maps[i]['recommended_action'] as String?,
        severity: maps[i]['severity'] as String,
        cameraView: maps[i]['camera_view'] as String,
      );
    });
  }

  Future<int> updateDetection(DetectionData detection) async {
    final db = await database;
    return db.update(
      'detections',
      {
        'disease_name': detection.diseaseName,
        'confidence': detection.confidence,
        'severity': detection.severity,
        'camera_view': detection.cameraView,
        'image_path': detection.imagePath,
        'status': detection.status,
        'recommended_action': detection.recommendedAction,
      },
      where: 'detection_id = ?',
      whereArgs: [detection.id],
    );
  }

  Future<int> deleteDetection(String detectionId) async {
    final db = await database;
    return db.delete(
      'detections',
      where: 'detection_id = ?',
      whereArgs: [detectionId],
    );
  }

  // Health log operations
  Future<int> insertHealthLog({
    required String pondName,
    required String notes,
    required String status,
  }) async {
    final db = await database;
    return db.insert(
      'health_logs',
      {
        'pond_name': pondName,
        'notes': notes,
        'status': status,
        'timestamp': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<List<Map<String, dynamic>>> getAllHealthLogs() async {
    final db = await database;
    return db.query(
      'health_logs',
      orderBy: 'timestamp DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getHealthLogsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    return db.query(
      'health_logs',
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'timestamp DESC',
    );
  }

  Future<int> deleteHealthLog(int id) async {
    final db = await database;
    return db.delete(
      'health_logs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Alert operations
  Future<int> insertAlert({
    required String alertId,
    required String title,
    required String message,
    required String severity,
    required String? detectionId,
  }) async {
    final db = await database;
    return db.insert(
      'alerts',
      {
        'alert_id': alertId,
        'title': title,
        'message': message,
        'severity': severity,
        'detection_id': detectionId,
        'is_read': 0,
        'timestamp': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllAlerts() async {
    final db = await database;
    return db.query(
      'alerts',
      orderBy: 'timestamp DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getUnreadAlerts() async {
    final db = await database;
    return db.query(
      'alerts',
      where: 'is_read = ?',
      whereArgs: [0],
      orderBy: 'timestamp DESC',
    );
  }

  Future<int> markAlertAsRead(String alertId) async {
    final db = await database;
    return db.update(
      'alerts',
      {'is_read': 1},
      where: 'alert_id = ?',
      whereArgs: [alertId],
    );
  }

  Future<int> deleteAlert(String alertId) async {
    final db = await database;
    return db.delete(
      'alerts',
      where: 'alert_id = ?',
      whereArgs: [alertId],
    );
  }

  // Statistics
  Future<Map<String, int>> getStatistics() async {
    final db = await database;

    final totalDetections = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM detections'),
        ) ??
        0;

    final criticalCount = Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM detections WHERE severity = ?',
            ['critical'],
          ),
        ) ??
        0;

    final acuteCount = Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM detections WHERE severity = ?',
            ['acute'],
          ),
        ) ??
        0;

    final earlyCount = Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM detections WHERE severity = ?',
            ['early'],
          ),
        ) ??
        0;

    return {
      'total': totalDetections,
      'critical': criticalCount,
      'acute': acuteCount,
      'early': earlyCount,
    };
  }

  // Clear all data
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('detections');
    await db.delete('health_logs');
    await db.delete('alerts');
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
