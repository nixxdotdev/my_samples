import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sample_flow/features/samples/data/models/notification_item.dart';
import 'package:sample_flow/features/samples/data/models/sample_item.dart';
import 'package:sample_flow/features/samples/data/models/sample_status.dart';
import 'package:sample_flow/features/samples/data/utils/sample_utils.dart';

/// Central SQLite Database Service for offline mobile storage.
/// Manages the local SQLite database instance ('sample_flow.db') with
/// complete offline CRUD operations for samples and notifications.
class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  static const String _dbName = 'sample_flow.db';
  static const int _dbVersion = 2;

  Database? _db;

  /// Optional custom database factory (used for unit tests with sqflite_common_ffi)
  DatabaseFactory? _customFactory;
  String? _customPath;

  @visibleForTesting
  void setCustomFactory(DatabaseFactory factory, {String? path}) {
    _customFactory = factory;
    _customPath = path;
    _db = null;
  }

  Future<Database> get database async {
    if (_db != null && _db!.isOpen) {
      return _db!;
    }
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    String dbPath;
    if (_customPath != null) {
      dbPath = _customPath!;
    } else {
      final databasesPath = await getDatabasesPath();
      dbPath = p.join(databasesPath, _dbName);
    }

    final openMethod = _customFactory != null
        ? _customFactory!.openDatabase
        : openDatabase;

    return await openMethod(
      dbPath,
      options: OpenDatabaseOptions(
        version: _dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Samples Table
    await db.execute('''
      CREATE TABLE samples (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL DEFAULT 'local_creator',
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        remaining_days INTEGER NOT NULL DEFAULT 0,
        total_days INTEGER NOT NULL DEFAULT 0,
        deadline_date TEXT,
        status TEXT NOT NULL DEFAULT 'pendingApproval',
        created_at TEXT NOT NULL,
        updated_at TEXT,
        sync_status TEXT NOT NULL DEFAULT 'synced'
      )
    ''');
    await db.execute('CREATE INDEX idx_samples_status ON samples(status)');
    await db.execute('CREATE INDEX idx_samples_user ON samples(user_id)');

    // 2. Notifications Table
    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL DEFAULT 'local_creator',
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        time_ago TEXT NOT NULL,
        type TEXT NOT NULL DEFAULT 'info',
        is_read INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_notifs_user ON notifications(user_id)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE samples ADD COLUMN deadline_date TEXT;');
    }
  }

  // ================= SAMPLES CRUD =================

  /// Retrieve all samples from SQLite with optional filtering and search
  Future<List<SampleItem>> getAllSamples({
    String? status,
    String? category,
    String? search,
    String userId = 'local_creator',
  }) async {
    final db = await database;

    final whereClauses = <String>['user_id = ?'];
    final whereArgs = <dynamic>[userId];

    if (status != null && status.isNotEmpty) {
      whereClauses.add('status = ?');
      whereArgs.add(status);
    }

    if (category != null && category.isNotEmpty) {
      whereClauses.add('category = ?');
      whereArgs.add(category);
    }

    if (search != null && search.trim().isNotEmpty) {
      whereClauses.add('(title LIKE ? OR category LIKE ?)');
      final term = '%${search.trim()}%';
      whereArgs.add(term);
      whereArgs.add(term);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'samples',
      where: whereClauses.join(' AND '),
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );

    return maps.map((row) => _sampleFromRow(row)).toList();
  }

  /// Retrieve a single sample by its ID
  Future<SampleItem?> getSampleById(String id) async {
    final db = await database;
    final maps = await db.query(
      'samples',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return _sampleFromRow(maps.first);
  }

  /// Insert a new sample into SQLite
  Future<void> insertSample(
    SampleItem item, {
    String userId = 'local_creator',
  }) async {
    final db = await database;
    await db.insert(
      'samples',
      {
        'id': item.id,
        'user_id': userId,
        'title': item.title,
        'category': item.category,
        'remaining_days': item.remainingDays,
        'total_days': item.totalDays,
        'deadline_date': item.deadlineDate?.toIso8601String(),
        'status': item.status.name,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'sync_status': 'synced',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update sample status and remaining / total days / deadline date
  Future<void> updateSampleStatus(
    String id,
    SampleStatus status, {
    int? remainingDays,
    int? totalDays,
    DateTime? deadlineDate,
  }) async {
    final db = await database;
    final values = <String, dynamic>{
      'status': status.name,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (remainingDays != null) {
      values['remaining_days'] = remainingDays;
    }
    if (totalDays != null) {
      values['total_days'] = totalDays;
    }
    if (deadlineDate != null) {
      values['deadline_date'] = deadlineDate.toIso8601String();
    } else if (status != SampleStatus.approved) {
      values['deadline_date'] = null;
    }

    await db.update(
      'samples',
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete a sample by ID
  Future<void> deleteSample(String id) async {
    final db = await database;
    await db.delete(
      'samples',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get summary counts for pending, approved, and posted samples
  Future<Map<String, int>> getSampleCounts({
    String userId = 'local_creator',
  }) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        status, 
        COUNT(*) as count 
      FROM samples 
      WHERE user_id = ? 
      GROUP BY status
    ''', [userId]);

    int pending = 0;
    int approved = 0;
    int posted = 0;

    for (var row in result) {
      final s = row['status'] as String?;
      final count = (row['count'] as num?)?.toInt() ?? 0;
      if (s == SampleStatus.pendingApproval.name) {
        pending = count;
      } else if (s == SampleStatus.approved.name) {
        approved = count;
      } else if (s == SampleStatus.pendingCriteria.name) {
        posted = count;
      }
    }

    return {
      'pending': pending,
      'approved': approved,
      'posted': posted,
      'total': pending + approved + posted,
    };
  }

  SampleItem _sampleFromRow(Map<String, dynamic> row) {
    SampleStatus status = SampleStatus.pendingApproval;
    final statusStr = row['status'] as String?;
    if (statusStr != null) {
      for (var s in SampleStatus.values) {
        if (s.name == statusStr) {
          status = s;
          break;
        }
      }
    }

    final category = row['category'] as String? ?? 'Electronics & Audio';
    final deadlineStr = row['deadline_date'] as String?;
    final deadlineDate =
        deadlineStr != null ? DateTime.tryParse(deadlineStr) : null;

    int remainingDays = (row['remaining_days'] as num?)?.toInt() ?? 0;
    if (deadlineDate != null && status == SampleStatus.approved) {
      final diff = deadlineDate.difference(DateTime.now());
      remainingDays = diff.isNegative ? 0 : (diff.inMinutes / (24 * 60)).ceil();
    }

    return SampleItem(
      id: row['id'] as String,
      title: row['title'] as String,
      category: category,
      remainingDays: remainingDays,
      totalDays: (row['total_days'] as num?)?.toInt() ?? 0,
      deadlineDate: deadlineDate,
      icon: SampleUtils.getCategoryIcon(category),
      status: status,
    );
  }

  // ================= NOTIFICATIONS CRUD =================

  /// Retrieve all notifications from SQLite
  Future<List<NotificationItem>> getAllNotifications({
    String userId = 'local_creator',
  }) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notifications',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return maps.map((row) => _notificationFromRow(row)).toList();
  }

  /// Check if a notification with specific ID exists (used for milestone deduplication)
  Future<bool> hasNotification(String id) async {
    final db = await database;
    final result = await db.query(
      'notifications',
      columns: ['id'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// Insert a notification into SQLite
  Future<void> insertNotification(
    NotificationItem item, {
    String userId = 'local_creator',
  }) async {
    final db = await database;
    await db.insert(
      'notifications',
      {
        'id': item.id,
        'user_id': userId,
        'title': item.title,
        'description': item.description,
        'time_ago': item.timeAgo,
        'type': item.type ?? 'info',
        'is_read': item.isRead ? 1 : 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Mark single notification as read
  Future<void> markNotificationAsRead(String id) async {
    final db = await database;
    await db.update(
      'notifications',
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead({
    String userId = 'local_creator',
  }) async {
    final db = await database;
    await db.update(
      'notifications',
      {'is_read': 1},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// Delete notification by id
  Future<void> deleteNotification(String id) async {
    final db = await database;
    await db.delete(
      'notifications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Check if there are any unread notifications
  Future<bool> hasUnreadNotifications({
    String userId = 'local_creator',
  }) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count 
      FROM notifications 
      WHERE user_id = ? AND is_read = 0
    ''', [userId]);

    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }

  NotificationItem _notificationFromRow(Map<String, dynamic> row) {
    return NotificationItem.fromJson({
      'id': row['id'],
      'title': row['title'],
      'description': row['description'],
      'timeAgo': row['time_ago'],
      'isRead': (row['is_read'] as num?)?.toInt() == 1,
      'type': row['type'],
    });
  }

  // ================= UTILITIES =================

  /// Close database connection
  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }

  /// Clear all local data (for testing or user reset)
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('samples');
    await db.delete('notifications');
  }
}
