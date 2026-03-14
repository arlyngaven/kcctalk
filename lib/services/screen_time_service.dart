// lib/services/screen_time_service.dart
//
// Tracks how many seconds the child has used the app today.
// Resets automatically when the calendar date changes.
//
// Dependencies (add to pubspec.yaml):
//   shared_preferences: ^2.2.2

import 'package:shared_preferences/shared_preferences.dart';

class ScreenTimeService {
  static const _keyUsageSeconds = 'usage_seconds';
  static const _keyLastDate = 'last_date';

  /// Returns how many seconds have been used today.
  static Future<int> getUsedSecondsToday() async {
    final prefs = await SharedPreferences.getInstance();
    _maybeResetForNewDay(prefs);
    return prefs.getInt(_keyUsageSeconds) ?? 0;
  }

  /// Call this every second while the app is in the foreground.
  static Future<void> addOneSecond() async {
    final prefs = await SharedPreferences.getInstance();
    _maybeResetForNewDay(prefs);
    final current = prefs.getInt(_keyUsageSeconds) ?? 0;
    await prefs.setInt(_keyUsageSeconds, current + 1);
  }

  /// Returns true if the child has exceeded their daily limit.
  static Future<bool> isLimitReached(int limitMinutes) async {
    final used = await getUsedSecondsToday();
    return used >= limitMinutes * 60;
  }

  /// Remaining seconds today. Never goes below 0.
  static Future<int> remainingSeconds(int limitMinutes) async {
    final used = await getUsedSecondsToday();
    final total = limitMinutes * 60;
    final remaining = total - used;
    return remaining < 0 ? 0 : remaining;
  }

  static void _maybeResetForNewDay(SharedPreferences prefs) {
    final today = _todayString();
    final lastDate = prefs.getString(_keyLastDate);
    if (lastDate != today) {
      prefs.setInt(_keyUsageSeconds, 0);
      prefs.setString(_keyLastDate, today);
    }
  }

  static String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }
}