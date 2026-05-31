import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggleCheckbox;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final ValueChanged<TaskStatus> onStatusChanged;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggleCheckbox,
    required this.onDelete,
    required this.onTap,
    required this.onStatusChanged,
  });

  Color get _statusColor {
    switch (task.status) {
      case TaskStatus.todo:
        return AppTheme.statusTodo;
      case TaskStatus.onProgress:
        return AppTheme.statusProgress;
      case TaskStatus.done:
        return AppTheme.statusDone;
    }
  }

  IconData get _statusIcon {
    switch (task.status) {
      case TaskStatus.todo:
        return Icons.radio_button_unchecked_rounded;
      case TaskStatus.onProgress:
        return Icons.timelapse_rounded;
      case TaskStatus.done:
        return Icons.check_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _statusColor.withOpacity(0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: _statusColor.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Left accent bar
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  color: _statusColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Checkbox
                    GestureDetector(
                      onTap: onToggleCheckbox,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(top: 2, right: 12),
                        decoration: BoxDecoration(
                          color: task.isChecked
                              ? AppTheme.statusDone
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: task.isChecked
                                ? AppTheme.statusDone
                                : AppTheme.textSecondary,
                            width: 2,
                          ),
                        ),
                        child: task.isChecked
                            ? const Icon(Icons.check_rounded,
                                size: 16, color: Colors.white)
                            : null,
                      ),
                    ),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: task.isChecked
                                  ? AppTheme.textSecondary
                                  : AppTheme.textPrimary,
                              decoration: task.isChecked
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: AppTheme.textSecondary,
                            ),
                          ),
                          if (task.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              task.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          // Bottom row: deadline + status
                          Row(
                            children: [
                              if (task.deadline != null) ...[
                                _DeadlineChip(task: task),
                                const SizedBox(width: 8),
                              ],
                              _StatusBadge(
                                status: task.status,
                                color: _statusColor,
                                icon: _statusIcon,
                                onChanged: onStatusChanged,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Delete button
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                      style: IconButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(32, 32),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeadlineChip extends StatelessWidget {
  final Task task;
  const _DeadlineChip({required this.task});

  @override
  Widget build(BuildContext context) {
    final bool isOverdue = task.isOverdue;
    final bool isDueToday = task.isDueToday;

    Color chipColor;
    if (isOverdue) {
      chipColor = AppTheme.secondary;
    } else if (isDueToday) {
      chipColor = AppTheme.warning;
    } else {
      chipColor = AppTheme.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: chipColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time_rounded, size: 11, color: chipColor),
          const SizedBox(width: 4),
          Text(
            isOverdue
                ? 'Terlambat'
                : isDueToday
                    ? 'Hari ini'
                    : DateFormat('dd MMM, HH:mm').format(task.deadline!),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TaskStatus status;
  final Color color;
  final IconData icon;
  final ValueChanged<TaskStatus> onChanged;

  const _StatusBadge({
    required this.status,
    required this.color,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showStatusPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
            Text(
              status.label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.arrow_drop_down_rounded, size: 14, color: color),
          ],
        ),
      ),
    );
  }

  void _showStatusPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ubah Status',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...TaskStatus.values.map((s) {
              final isSelected = s == status;
              final sColor = s == TaskStatus.todo
                  ? AppTheme.statusTodo
                  : s == TaskStatus.onProgress
                      ? AppTheme.statusProgress
                      : AppTheme.statusDone;
              return ListTile(
                onTap: () {
                  onChanged(s);
                  Navigator.pop(ctx);
                },
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: sColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    s == TaskStatus.todo
                        ? Icons.radio_button_unchecked_rounded
                        : s == TaskStatus.onProgress
                            ? Icons.timelapse_rounded
                            : Icons.check_circle_rounded,
                    color: sColor,
                    size: 20,
                  ),
                ),
                title: Text(
                  s.label,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppTheme.textPrimary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_rounded,
                        color: AppTheme.primary, size: 20)
                    : null,
              );
            }),
          ],
        ),
      ),
    );
  }
}
