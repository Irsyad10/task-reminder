import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';

class TaskStorageService {
  final _supabase = Supabase.instance.client;

  Future<List<Task>> loadTasks() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    final response = await _supabase
        .from('tasks')
        .select()
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((e) => Task.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveTask(Task task) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _supabase.from('tasks').upsert(task.toSupabaseJson(user.id));
  }

  Future<void> deleteTask(String taskId) async {
    await _supabase.from('tasks').delete().eq('id', taskId);
  }
}
