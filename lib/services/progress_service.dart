// lib/services/progress_service.dart
//
// Stores activity results per profile. Every query requires a profileId
// so progress is fully separated between children.
//
// Dependencies:
//   sqflite: ^2.3.2
//   path: ^1.9.0

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/progress_model.dart';

class ProgressService {
  static Database? _db;

  // ─── Init ─────────────────────────────────────────────────────────────────

  static Future<Database> get _database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath   = await getDatabasesPath();
    final fullPath = p.join(dbPath, 'kcc_progress.db');
    return openDatabase(
      fullPath,
      version: 2,
      onCreate: (db, _) => _createTables(db),
      onUpgrade: (db, oldV, newV) async {
        // v1 → v2: add profile_id column
        if (oldV < 2) {
          await db.execute(
              'ALTER TABLE activity_results ADD COLUMN profile_id INTEGER NOT NULL DEFAULT 0');
        }
      },
    );
  }

  static Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE activity_results (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id    INTEGER NOT NULL,
        activity      TEXT    NOT NULL,
        score         INTEGER NOT NULL DEFAULT 0,
        stars_earned  INTEGER NOT NULL DEFAULT 0,
        completed_at  TEXT    NOT NULL
      )
    ''');
    // Index para mabilis ang per-profile queries
    await db.execute(
        'CREATE INDEX idx_profile ON activity_results (profile_id)');
  }

  // ─── Write ────────────────────────────────────────────────────────────────

  /// Save one completed activity attempt for a specific profile.
  static Future<int> saveResult(ActivityResult result) async {
    final db = await _database;
    return db.insert('activity_results', result.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ─── Read (all scoped to profileId) ──────────────────────────────────────

  /// All attempts for this profile, newest first.
  static Future<List<ActivityResult>> getAllResults(int profileId) async {
    final db   = await _database;
    final rows = await db.query('activity_results',
        where: 'profile_id = ?',
        whereArgs: [profileId],
        orderBy: 'completed_at DESC');
    return rows.map(ActivityResult.fromMap).toList();
  }

  /// Total stars for this profile.
  static Future<int> getTotalStars(int profileId) async {
    final db  = await _database;
    final res = await db.rawQuery(
        'SELECT COALESCE(SUM(stars_earned), 0) AS total '
        'FROM activity_results WHERE profile_id = ?', [profileId]);
    return (res.first['total'] as num).toInt();
  }

  /// Number of distinct activities completed by this profile.
  static Future<int> getActivitiesDone(int profileId) async {
    final db  = await _database;
    final res = await db.rawQuery(
        'SELECT COUNT(DISTINCT activity) AS cnt '
        'FROM activity_results WHERE profile_id = ?', [profileId]);
    return (res.first['cnt'] as num).toInt();
  }

  /// Best score per activity for this profile.
  static Future<Map<String, int>> getBestScores(int profileId) async {
    final db   = await _database;
    final rows = await db.rawQuery(
        'SELECT activity, MAX(score) AS best FROM activity_results '
        'WHERE profile_id = ? GROUP BY activity', [profileId]);
    return {
      for (final r in rows)
        r['activity'] as String: (r['best'] as num).toInt()
    };
  }

  /// Full aggregated summary for this profile.
  static Future<ProgressSummary> getSummary(int profileId) async {
    final stars      = await getTotalStars(profileId);
    final activities = await getActivitiesDone(profileId);
    final bestScores = await getBestScores(profileId);
    final levels     = (stars ~/ 3).clamp(1, ProgressSummary.totalLevels);
    return ProgressSummary(
      totalStars           : stars,
      totalActivitiesDone  : activities,
      levelsUnlocked       : levels,
      bestScorePerActivity : bestScores,
    );
  }

  // ─── Reset ────────────────────────────────────────────────────────────────

  /// Delete all progress for one profile only. Other profiles are untouched.
  static Future<void> clearForProfile(int profileId) async {
    final db = await _database;
    await db.delete('activity_results',
        where: 'profile_id = ?', whereArgs: [profileId]);
  }

  /// Delete ALL progress for ALL profiles (full reset).
  static Future<void> clearAll() async {
    final db = await _database;
    await db.delete('activity_results');
  }

  static Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
