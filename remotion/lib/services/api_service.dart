import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  // FIX 1: Consistent baseUrl — use kIsWeb and defaultTargetPlatform to handle all platforms
  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost:3001';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3001';
    }
    return 'http://localhost:3001';
  }

  Future<String?> _getAuthToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return await user.getIdToken(true); // force refresh
  }

  Future<Map<String, dynamic>?> getProtectedData() async {
    final token = await _getAuthToken();
    if (token == null) return null;

    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/api/profile'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getDashboardStats() async {
    final token = await _getAuthToken();
    if (token == null) return null;

    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/api/dashboard/stats'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Fetches the complete progress data for the current user
  Future<ProgressData?> getProgressData() async {
    final token = await _getAuthToken();
    if (token == null) return null;

    try {
      final response = await http
          .get(
            Uri.parse(
              '$_baseUrl/api/progress',
            ), // FIX 2: was $baseUrl (undefined)
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ProgressData.fromJson(json); // FIX 3: no success/data wrapper
      }
      debugPrint('Error fetching progress: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('Error fetching progress: $e');
      return null;
    }
  }

  /// Marks the level up notification as seen
  Future<bool> markLevelUpSeen() async {
    final token = await _getAuthToken();
    if (token == null) return false;

    try {
      final response = await http
          .post(
            Uri.parse(
              '$_baseUrl/api/progress/level-up-seen',
            ), // FIX 4: was $baseUrl
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error marking level up seen: $e');
      return false;
    }
  }

  /// Fetches the list of exercises assigned to the patient
  Future<Map<String, dynamic>?> getAssignedExercises() async {
    final token = await _getAuthToken();
    if (token == null) return null;

    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/api/patients/exercises/assigned'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      debugPrint('Error fetching assigned exercises: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('Error fetching assigned exercises: $e');
      return null;
    }
  }

  Future<List<dynamic>> getChatMessages(String physioId) async {
    final token = await _getAuthToken();
    if (token == null) return [];

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/chat/patient-to-physio/$physioId/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['messages'] ?? [];
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching chat messages: $e');
      return [];
    }
  }

  Future<bool> sendChatMessage(String physioId, String content) async {
    final token = await _getAuthToken();
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/chat/patient-to-physio/$physioId/message'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'content': content}),
      );

      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Error sending chat message: $e');
      return false;
    }
  }
}

// ============================================================================
// Progress Data Models
// ============================================================================

class ProgressData {
  final LevelUpData levelUp;
  final RecoveryLevelData recoveryLevel;
  final StreakData streak;
  final List<TimelineItem> timeline;
  final BodyMapData bodyMap;
  final MovementQualityData movementQuality;
  final AchievementsData achievements;
  final PhysioNoteData physioNote;

  ProgressData({
    required this.levelUp,
    required this.recoveryLevel,
    required this.streak,
    required this.timeline,
    required this.bodyMap,
    required this.movementQuality,
    required this.achievements,
    required this.physioNote,
  });

  factory ProgressData.fromJson(Map<String, dynamic> json) {
    return ProgressData(
      levelUp: LevelUpData.fromJson(json['levelUp'] ?? {}),
      recoveryLevel: RecoveryLevelData.fromJson(json['recoveryLevel'] ?? {}),
      streak: StreakData.fromJson(json['streak'] ?? {}),
      timeline: (json['timeline'] as List? ?? [])
          .map((e) => TimelineItem.fromJson(e))
          .toList(),
      bodyMap: BodyMapData.fromJson(json['bodyMap'] ?? {}),
      movementQuality: MovementQualityData.fromJson(
        json['movementQuality'] ?? {},
      ),
      achievements: AchievementsData.fromJson(json['achievements'] ?? {}),
      physioNote: PhysioNoteData.fromJson(json['physioNote'] ?? {}),
    );
  }
}

class LevelUpData {
  final int currentLevel;
  final int streak;
  final String message;
  final String achievement;
  final bool showLevelUp;

  LevelUpData({
    required this.currentLevel,
    required this.streak,
    required this.message,
    required this.achievement,
    required this.showLevelUp,
  });

  factory LevelUpData.fromJson(Map<String, dynamic> json) {
    return LevelUpData(
      currentLevel: json['currentLevel'] ?? 1,
      streak: json['streak'] ?? 0,
      message: json['message'] ?? '',
      achievement: json['achievement'] ?? '',
      showLevelUp: json['showLevelUp'] ?? false,
    );
  }
}

class RecoveryLevelData {
  final int level;
  final double percentage;
  final XpData xp;
  final StatsData stats;

  RecoveryLevelData({
    required this.level,
    required this.percentage,
    required this.xp,
    required this.stats,
  });

  factory RecoveryLevelData.fromJson(Map<String, dynamic> json) {
    return RecoveryLevelData(
      level: (json['level'] as num).toInt(),
      percentage: (json['percentage'] as num).toDouble(),
      xp: XpData.fromJson(json['xp'] ?? {}),
      stats: StatsData.fromJson(json['stats'] ?? {}),
    );
  }
}

class XpData {
  final int current;
  final int max;

  XpData({required this.current, required this.max});

  factory XpData.fromJson(Map<String, dynamic> json) {
    return XpData(current: json['current'] ?? 0, max: json['max'] ?? 1000);
  }

  double get progress => max > 0 ? current / max : 0;
}

class StatsData {
  final double sleepQuality;
  final double hydration;
  final double mobility;

  StatsData({
    required this.sleepQuality,
    required this.hydration,
    required this.mobility,
  });

  factory StatsData.fromJson(Map<String, dynamic> json) {
    return StatsData(
      sleepQuality: (json['sleepQuality'] as num? ?? 0.0).toDouble(),
      hydration: (json['hydration'] as num? ?? 0.0).toDouble(),
      mobility: (json['mobility'] as num? ?? 0.0).toDouble(),
    );
  }
}

class StreakData {
  final int days;
  final bool isActive;

  StreakData({required this.days, required this.isActive});

  factory StreakData.fromJson(Map<String, dynamic> json) {
    return StreakData(
      days: (json['days'] as num).toInt(),
      isActive: json['isActive'] ?? false,
    );
  }
}

class TimelineItem {
  final String label;
  final String icon;
  final bool completed;
  final bool current;

  TimelineItem({
    required this.label,
    required this.icon,
    required this.completed,
    required this.current,
  });

  factory TimelineItem.fromJson(Map<String, dynamic> json) {
    return TimelineItem(
      label: json['label'] ?? '',
      icon: json['icon'] ?? '',
      completed: json['completed'] ?? false,
      current: json['current'] ?? false,
    );
  }
}

class BodyMapData {
  final List<BodyZone> zones;

  BodyMapData({required this.zones});

  factory BodyMapData.fromJson(Map<String, dynamic> json) {
    return BodyMapData(
      zones: (json['zones'] as List? ?? [])
          .map((e) => BodyZone.fromJson(e))
          .toList(),
    );
  }
}

class BodyZone {
  final String area;
  final String status;
  final double intensity;

  BodyZone({required this.area, required this.status, required this.intensity});

  factory BodyZone.fromJson(Map<String, dynamic> json) {
    return BodyZone(
      area: json['area'] ?? '',
      status: json['status'] ?? 'rest',
      intensity: (json['intensity'] ?? 0.0).toDouble(),
    );
  }
}

class MovementQualityData {
  final MovementStat flexibility;
  final MovementStat strength;
  final MovementStat endurance;
  final MovementStat balance;

  MovementQualityData({
    required this.flexibility,
    required this.strength,
    required this.endurance,
    required this.balance,
  });

  factory MovementQualityData.fromJson(Map<String, dynamic> json) {
    return MovementQualityData(
      flexibility: MovementStat.fromJson(json['flexibility'] ?? {}),
      strength: MovementStat.fromJson(json['strength'] ?? {}),
      endurance: MovementStat.fromJson(json['endurance'] ?? {}),
      balance: MovementStat.fromJson(json['balance'] ?? {}),
    );
  }

  List<MovementStat> toList() => [flexibility, strength, endurance, balance];
}

class MovementStat {
  final int value;
  final String label;

  MovementStat({required this.value, required this.label});

  factory MovementStat.fromJson(Map<String, dynamic> json) {
    return MovementStat(
      value: (json['value'] as num? ?? 0).toInt(),
      label: json['label'] ?? '',
    );
  }

  double get percentage => value / 100;
}

class AchievementsData {
  final int total;
  final int unlocked;
  final double progress;
  final List<Badge> badges;

  AchievementsData({
    required this.total,
    required this.unlocked,
    required this.progress,
    required this.badges,
  });

  factory AchievementsData.fromJson(Map<String, dynamic> json) {
    return AchievementsData(
      total: json['total'] ?? 0,
      unlocked: json['unlocked'] ?? 0,
      progress: (json['progress'] ?? 0.0).toDouble(),
      badges: (json['badges'] as List? ?? [])
          .map((e) => Badge.fromJson(e))
          .toList(),
    );
  }
}

class Badge {
  final String id;
  final String name;
  final String icon;
  final bool unlocked;

  Badge({
    required this.id,
    required this.name,
    required this.icon,
    required this.unlocked,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      unlocked: json['unlocked'] ?? false,
    );
  }
}

class PhysioNoteData {
  final String message;
  final String author;
  final String date;

  PhysioNoteData({
    required this.message,
    required this.author,
    required this.date,
  });

  factory PhysioNoteData.fromJson(Map<String, dynamic> json) {
    return PhysioNoteData(
      message: json['message'] ?? '',
      author: json['author'] ?? '',
      date: json['date'] ?? '',
    );
  }
}
