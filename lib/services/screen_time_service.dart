// lib/services/screen_time_service.dart
//
// Tracks how many seconds each child has used the app today.
// Per-profile: each child's screen time is stored separately.
// Resets automatically when the calendar date changes.
//
// KEY FORMAT:
//   usage_seconds_<profileId>   — seconds used today by this profile
//   last_date_<profileId>       — last recorded date for this profile
//
// HOW PAUSE/RESUME WORKS:
//   - The timer in HomeScreen calls addOneSecond() every second
//     ONLY while the app is in the foreground (AppLifecycleState.resumed).
//   - When the app is backgrounded/closed, the timer is paused automatically
//     via the WidgetsBindingObserver in HomeScreen.
//   - On next open, getUsedSecondsToday() returns the saved value — the
//     countdown continues from exactly where it left off.
//   - At midnight, _maybeResetForNewDay() zeroes out the counter.
//
// Dependencies:
//   shared_preferences: ^2.2.2

import 'package:shared_preferences/shared_preferences.dart';

class ScreenTimeService {
  /// Returns the shared_preferences key for this profile's usage.
  static String _keyUsage(int profileId) => 'usage_seconds_$profileId';
  static String _keyDate(int profileId)  => 'last_date_$profileId';

  /// How many seconds this profile has used the app today.
  static Future<int> getUsedSecondsToday(int profileId) async {
    final prefs = await SharedPreferences.getInstance();
    await _maybeResetForNewDay(prefs, profileId);
    return prefs.getInt(_keyUsage(profileId)) ?? 0;
  }

  /// Call this every second while the app is in the foreground.
  /// Only called when AppLifecycleState.resumed — so closing/backgrounding
  /// the app automatically pauses the count.
  static Future<void> addOneSecond(int profileId) async {
    final prefs = await SharedPreferences.getInstance();
    await _maybeResetForNewDay(prefs, profileId);
    final current = prefs.getInt(_keyUsage(profileId)) ?? 0;
    await prefs.setInt(_keyUsage(profileId), current + 1);
  }

  /// Remaining seconds for this profile today. Never below 0.
  static Future<int> remainingSeconds(int profileId, int limitMinutes) async {
    final used  = await getUsedSecondsToday(profileId);
    final total = limitMinutes * 60;
    final rem   = total - used;
    return rem < 0 ? 0 : rem;
  }

  /// Returns true if this profile has hit their daily limit.
  static Future<bool> isLimitReached(int profileId, int limitMinutes) async {
    final used = await getUsedSecondsToday(profileId);
    return used >= limitMinutes * 60;
  }

  /// Clear today's usage for this profile (e.g. for testing / manual reset).
  static Future<void> resetToday(int profileId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUsage(profileId), 0);
  }

  // ─── Private ──────────────────────────────────────────────────────────────

  static Future<void> _maybeResetForNewDay(
      SharedPreferences prefs, int profileId) async {
    final today    = _todayString();
    final lastDate = prefs.getString(_keyDate(profileId));
    if (lastDate != today) {
      await prefs.setInt(_keyUsage(profileId), 0);
      await prefs.setString(_keyDate(profileId), today);
    }
  }

  static String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2,'0')}-'
           '${now.day.toString().padLeft(2,'0')}';
  }
}