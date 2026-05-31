import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskStorageService {
  static const String _tasksKey = 'tasks';

  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_tasksKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((e) => Task.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = tasks.map((t) => t.toJson()).toList();
    await prefs.setString(_tasksKey, jsonEncode(jsonList));
  }
}
