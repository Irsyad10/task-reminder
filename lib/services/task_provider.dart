import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';
import '../services/task_storage_service.dart';
import '../services/notification_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskStorageService _storageService = TaskStorageService();
  final NotificationService _notificationService = NotificationService();
  final _uuid = const Uuid();

  List<Task> _tasks = [];
  bool _isLoading = false;

  TaskProvider() {
    // Jalankan loadTasks jika user sudah login di awal aplikasi
    if (Supabase.instance.client.auth.currentUser != null) {
      loadTasks();
    }

    // Dengarkan perubahan status auth (login/logout)
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.tokenRefreshed) {
        loadTasks();
      } else if (event == AuthChangeEvent.signedOut) {
        _tasks = [];
        notifyListeners();
      }
    });
  }

  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;

  List<Task> get todoTasks =>
      _tasks.where((t) => t.status == TaskStatus.todo).toList();

  List<Task> get onProgressTasks =>
      _tasks.where((t) => t.status == TaskStatus.onProgress).toList();

  List<Task> get doneTasks =>
      _tasks.where((t) => t.status == TaskStatus.done).toList();

  int get totalTasks => _tasks.length;
  int get completedTasks =>
      _tasks.where((t) => t.status == TaskStatus.done).length;

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();
    _tasks = await _storageService.loadTasks();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask({
    required String title,
    String description = '',
    DateTime? deadline,
    bool scheduleNotification = false,
  }) async {
    final notifId = _notificationService.generateNotificationId();
    final task = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      deadline: deadline,
      createdAt: DateTime.now(),
      notificationId: notifId,
    );

    await _storageService.saveTask(task);

    _tasks.add(task);

    if (scheduleNotification && deadline != null) {
      final reminderTime = deadline.subtract(const Duration(hours: 1));
      await _notificationService.scheduleTaskNotification(
        id: notifId,
        title: '⏰ Deadline Mendekat!',
        body: '"$title" deadline dalam 1 jam lagi.',
        scheduledTime: reminderTime,
      );
    }

    notifyListeners();
  }

  Future<void> updateTask(Task updatedTask) async {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index == -1) return;

    await _storageService.saveTask(updatedTask);

    // Cancel old notification if deadline changed
    final oldTask = _tasks[index];
    if (oldTask.notificationId != null &&
        oldTask.deadline != updatedTask.deadline) {
      await _notificationService.cancelNotification(oldTask.notificationId!);
    }

    _tasks[index] = updatedTask;

    // Schedule new notification if deadline set
    if (updatedTask.deadline != null && updatedTask.notificationId != null) {
      final reminderTime =
          updatedTask.deadline!.subtract(const Duration(hours: 1));
      await _notificationService.scheduleTaskNotification(
        id: updatedTask.notificationId!,
        title: '⏰ Deadline Mendekat!',
        body: '"${updatedTask.title}" deadline dalam 1 jam lagi.',
        scheduledTime: reminderTime,
      );
    }

    notifyListeners();
  }

  Future<void> toggleCheckbox(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;

    final task = _tasks[index];
    final newIsChecked = !task.isChecked;
    final newStatus = newIsChecked ? TaskStatus.done : TaskStatus.todo;

    final updated = task.copyWith(
      isChecked: newIsChecked,
      status: newStatus,
    );

    await _storageService.saveTask(updated);
    _tasks[index] = updated;

    notifyListeners();
  }

  Future<void> updateStatus(String taskId, TaskStatus status) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;

    final updated = _tasks[index].copyWith(
      status: status,
      isChecked: status == TaskStatus.done,
    );

    await _storageService.saveTask(updated);
    _tasks[index] = updated;

    notifyListeners();
  }

  Future<void> deleteTask(String taskId) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);

    await _storageService.deleteTask(taskId);

    if (task.notificationId != null) {
      await _notificationService.cancelNotification(task.notificationId!);
    }

    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
  }

  List<Task> getTasksByStatus(TaskStatus status) {
    return _tasks.where((t) => t.status == status).toList();
  }
}
