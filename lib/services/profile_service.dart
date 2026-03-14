// lib/services/profile_service.dart
//
// Saves and loads the child profile locally (offline, no internet needed).
//
// Dependencies (add to pubspec.yaml):
//   shared_preferences: ^2.2.2

import 'package:shared_preferences/shared_preferences.dart';
import '../models/child_profile.dart';

class ProfileService {
  static const _keyName = 'profile_name';
  static const _keyAge = 'profile_age';

  /// Save the child profile to local storage.
  static Future<void> saveProfile(ChildProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, profile.name);
    await prefs.setInt(_keyAge, profile.age);
  }

  /// Load the child profile. Returns null if none has been saved yet.
  static Future<ChildProfile?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_keyName);
    final age = prefs.getInt(_keyAge);
    if (name == null || age == null) return null;
    return ChildProfile(name: name, age: age);
  }

  /// Delete saved profile (for reset / re-onboarding).
  static Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyName);
    await prefs.remove(_keyAge);
  }
}