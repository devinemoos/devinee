import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProjectEntry {
  final String id;
  final String title;
  final String type;
  final DateTime createdAt;

  ProjectEntry({
    required this.id,
    required this.title,
    required this.type,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'type': type,
        'createdAt': createdAt.toIso8601String(),
      };

  static ProjectEntry fromMap(Map<String, dynamic> m) => ProjectEntry(
        id: m['id'] ?? '',
        title: m['title'] ?? '',
        type: m['type'] ?? 'Проект',
        createdAt: DateTime.tryParse(m['createdAt'] ?? '') ?? DateTime.now(),
      );
}

class ProjectStorage {
  static const String _key = 'projects';

  static Future<List<ProjectEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = (jsonDecode(raw) as List).cast<dynamic>();
      final projects = list
          .map((e) => ProjectEntry.fromMap((e as Map).cast<String, dynamic>()))
          .toList();

      // новые сверху
      projects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return projects;
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(List<ProjectEntry> items) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(items.map((e) => e.toMap()).toList());
    await prefs.setString(_key, raw);
  }

  static Future<void> add(ProjectEntry p) async {
    final list = await load();
    list.insert(0, p);
    await save(list);
  }

  static Future<void> removeById(String id) async {
    final list = await load();
    list.removeWhere((e) => e.id == id);
    await save(list);
  }
}
