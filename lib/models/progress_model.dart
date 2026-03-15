// lib/models/progress_model.dart

class ActivityResult {
  final int?     id;
  final int      profileId;    // ← which child this belongs to
  final String   activity;
  final int      score;
  final int      starsEarned;
  final DateTime completedAt;

  const ActivityResult({
    this.id,
    required this.profileId,
    required this.activity,
    required this.score,
    required this.starsEarned,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'profile_id'  : profileId,
    'activity'    : activity,
    'score'       : score,
    'stars_earned': starsEarned,
    'completed_at': completedAt.toIso8601String(),
  };

  factory ActivityResult.fromMap(Map<String, dynamic> m) => ActivityResult(
    id          : m['id'] as int?,
    profileId   : m['profile_id'] as int,
    activity    : m['activity'] as String,
    score       : m['score'] as int,
    starsEarned : m['stars_earned'] as int,
    completedAt : DateTime.parse(m['completed_at'] as String),
  );
}

class ProgressSummary {
  final int totalStars;
  final int totalActivitiesDone;
  final int levelsUnlocked;
  final Map<String, int> bestScorePerActivity;

  const ProgressSummary({
    required this.totalStars,
    required this.totalActivitiesDone,
    required this.levelsUnlocked,
    required this.bestScorePerActivity,
  });

  static const int totalLevels = 10;

  int get starsForNextLevel => 3 - (totalStars % 3);
}
