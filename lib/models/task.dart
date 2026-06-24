import 'dart:convert';

enum TaskStatus { todo, onProgress, done }

extension TaskStatusExtension on TaskStatus {
  String get label {
    switch (this) {
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.onProgress:
        return 'On Progress';
      case TaskStatus.done:
        return 'Done';
    }
  }

  String get value {
    switch (this) {
      case TaskStatus.todo:
        return 'todo';
      case TaskStatus.onProgress:
        return 'onProgress';
      case TaskStatus.done:
        return 'done';
    }
  }

  static TaskStatus fromString(String value) {
    switch (value) {
      case 'onProgress':
        return TaskStatus.onProgress;
      case 'done':
        return TaskStatus.done;
      default:
        return TaskStatus.todo;
    }
  }
}

class Task {
  final String id;
  String title;
  String description;
  TaskStatus status;
  bool isChecked;
  DateTime? deadline;
  DateTime createdAt;
  int? notificationId;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.status = TaskStatus.todo,
    this.isChecked = false,
    this.deadline,
    required this.createdAt,
    this.notificationId,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    bool? isChecked,
    DateTime? deadline,
    DateTime? createdAt,
    int? notificationId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      isChecked: isChecked ?? this.isChecked,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      notificationId: notificationId ?? this.notificationId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.value,
      'isChecked': isChecked,
      'deadline': deadline?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'notificationId': notificationId,
    };
  }

  Map<String, dynamic> toSupabaseJson(String userId) {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'status': status.value,
      'is_done': isChecked,
      'deadline': deadline?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'notification_id': notificationId,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      status: TaskStatusExtension.fromString(json['status'] as String? ?? 'todo'),
      isChecked: json['isChecked'] as bool? ?? json['is_done'] as bool? ?? false,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now(),
      notificationId: json['notificationId'] as int? ?? json['notification_id'] as int?,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory Task.fromJsonString(String jsonString) =>
      Task.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);

  bool get isOverdue {
    if (deadline == null || status == TaskStatus.done) return false;
    return DateTime.now().isAfter(deadline!);
  }

  bool get isDueToday {
    if (deadline == null) return false;
    final now = DateTime.now();
    return deadline!.year == now.year &&
        deadline!.month == now.month &&
        deadline!.day == now.day;
  }
}
