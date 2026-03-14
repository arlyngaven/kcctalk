// lib/models/child_profile.dart

class ChildProfile {
  final int?   id;   // SQLite rowid — null before first save
  final String name;
  final int    age;

  ChildProfile({this.id, required this.name, required this.age});

  /// Screen time limit in minutes based on age.
  /// Age 2 → 15 minutes, age 3 and above → 40 minutes.
  int get screenTimeLimitMinutes {
    if (age <= 2) return 15;
    return 40;
  }

  /// Human-readable label for the limit
  String get screenTimeLimitLabel {
    return '$screenTimeLimitMinutes minuto bawat araw';
  }

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'age': age,
      };

  factory ChildProfile.fromMap(Map<String, dynamic> map) {
    return ChildProfile(
      id:   map['id'] as int?,
      name: map['name'] as String,
      age:  map['age'] as int,
    );
  }
}