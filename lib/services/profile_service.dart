// lib/services/profile_service.dart
//
// Multi-profile support — bawat bata ay may sariling account.
// Gumagamit ng SQLite para sa profiles at shared_preferences para sa active session.
//
// DESIGN:
//   - Lahat ng profiles ay naka-save sa SQLite (profiles table).
//   - "active_profile_id" sa shared_preferences → kung sino ang naka-login.
//   - logout() → clears active_profile_id lang (data ng lahat ay ligtas).
//   - Tap lang para mag-switch — walang PIN na kailangan.
//
// Dependencies:
//   shared_preferences: ^2.2.2
//   sqflite: ^2.3.2
//   path: ^1.9.0

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/child_profile.dart';

class ProfileService {
  static const _keyActiveId  = 'active_profile_id';

  static Database? _db;

  // ─── Database init ────────────────────────────────────────────────────────

  static Future<Database> get _database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath   = await getDatabasesPath();
    final fullPath = p.join(dbPath, 'kcc_profiles.db');
    return openDatabase(
      fullPath,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE profiles (
            id    INTEGER PRIMARY KEY AUTOINCREMENT,
            name  TEXT    NOT NULL,
            age   INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  // ─── Profile CRUD ─────────────────────────────────────────────────────────

  /// Save a new profile and mark it as active. Returns the profile with its id.
  static Future<ChildProfile> saveProfile(ChildProfile profile) async {
    final db   = await _database;
    final id   = await db.insert('profiles', {'name': profile.name, 'age': profile.age});
    final saved = ChildProfile(id: id, name: profile.name, age: profile.age);
    await _setActiveId(id);
    return saved;
  }

  /// Update an existing profile's name and age.
  static Future<void> updateProfile(ChildProfile profile) async {
    final db = await _database;
    await db.update(
      'profiles',
      {'name': profile.name, 'age': profile.age},
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  /// Load all saved profiles ordered by creation time.
  static Future<List<ChildProfile>> loadAllProfiles() async {
    final db   = await _database;
    final rows = await db.query('profiles', orderBy: 'id ASC');
    return rows.map(ChildProfile.fromMap).toList();
  }

  /// Load a single profile by id. Returns null if not found.
  static Future<ChildProfile?> loadProfileById(int id) async {
    final db   = await _database;
    final rows = await db.query('profiles', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return ChildProfile.fromMap(rows.first);
  }

  /// Delete one profile. Does NOT affect other profiles or their progress.
  static Future<void> deleteProfile(int id) async {
    final db = await _database;
    await db.delete('profiles', where: 'id = ?', whereArgs: [id]);
    final activeId = await getActiveProfileId();
    if (activeId == id) await logout();
  }

  /// Returns true if at least one profile has been saved.
  static Future<bool> hasAnyProfile() async {
    final profiles = await loadAllProfiles();
    return profiles.isNotEmpty;
  }

  // ─── Session ──────────────────────────────────────────────────────────────

  /// Log in as a specific profile.
  static Future<void> loginAs(int profileId) async {
    await _setActiveId(profileId);
  }

  /// Soft logout: clears the active session. All profile data stays intact.
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyActiveId);
  }

  /// Returns true if there is an active session.
  static Future<bool> isLoggedIn() async {
    return (await getActiveProfileId()) != null;
  }

  /// Returns the id of the active profile, or null if logged out.
  static Future<int?> getActiveProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyActiveId);
  }

  /// Returns the full ChildProfile of the active session, or null.
  static Future<ChildProfile?> loadActiveProfile() async {
    final id = await getActiveProfileId();
    if (id == null) return null;
    return loadProfileById(id);
  }

  static Future<void> _setActiveId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyActiveId, id);
  }
}