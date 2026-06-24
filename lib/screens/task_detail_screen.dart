import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/task_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/add_task_sheet.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    // Watch for changes to this task
    final updatedTask = context.watch<TaskProvider>().tasks.firstWhere(
          (t) => t.id == task.id,
          orElse: () => task,
        );

    final statusColor = updatedTask.status == TaskStatus.todo
        ? AppTheme.statusTodo
        : updatedTask.status == TaskStatus.onProgress
            ? AppTheme.statusProgress
            : AppTheme.statusDone;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Detail Tugas',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _openEdit(context, updatedTask),
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Edit',
          ),
          IconButton(
            onPressed: () => _confirmDelete(context, updatedTask),
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppTheme.secondary),
            tooltip: 'Hapus',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            _StatusBanner(status: updatedTask.status, color: statusColor),
            const SizedBox(height: 20),

            // Title
            Text(
              updatedTask.title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                decoration: updatedTask.isChecked
                    ? TextDecoration.lineThrough
                    : null,
                decorationColor: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Info cards row
            Row(
              children: [
                _InfoTile(
                  icon: Icons.calendar_today_rounded,
                  label: 'Dibuat',
                  value: DateFormat('dd MMM yyyy').format(updatedTask.createdAt),
                ),
                const SizedBox(width: 12),
                _InfoTile(
                  icon: updatedTask.isOverdue
                      ? Icons.warning_rounded
                      : Icons.access_alarm_rounded,
                  label: 'Deadline',
                  value: updatedTask.deadline != null
                      ? DateFormat('dd MMM yyyy\nHH:mm')
                          .format(updatedTask.deadline!)
                      : 'Tidak ada',
                  iconColor: updatedTask.isOverdue
                      ? AppTheme.secondary
                      : AppTheme.primary,
                ),
              ],
            ),

            if (updatedTask.description.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Deskripsi',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Text(
                  updatedTask.description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                    height: 1.6,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Checkbox toggle
            _CheckboxTile(
              task: updatedTask,
              onToggle: () => context.read<TaskProvider>().toggleCheckbox(updatedTask.id),
            ),

            const SizedBox(height: 16),

            // Status changer
            Text(
              'Ubah Status',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            _StatusChanger(
              current: updatedTask.status,
              onChanged: (s) =>
                  context.read<TaskProvider>().updateStatus(updatedTask.id, s),
            ),
          ],
        ),
      ),
    );
  }

  void _openEdit(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTaskSheet(task: task),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text('Hapus Tugas?',
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        content: Text(
          'Tugas "${task.title}" akan dihapus permanen.',
          style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal',
                style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Hapus',
                style: GoogleFonts.plusJakartaSans(color: AppTheme.secondary)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await context.read<TaskProvider>().deleteTask(task.id);
        if (context.mounted) Navigator.pop(context);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus tugas: $e'),
              backgroundColor: AppTheme.secondary,
            ),
          );
        }
      }
    }
  }
}

class _StatusBanner extends StatelessWidget {
  final TaskStatus status;
  final Color color;
  const _StatusBanner({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status == TaskStatus.todo
                ? Icons.radio_button_unchecked_rounded
                : status == TaskStatus.onProgress
                    ? Icons.timelapse_rounded
                    : Icons.check_circle_rounded,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            status.label,
            style: GoogleFonts.plusJakartaSans(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor = AppTheme.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckboxTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  const _CheckboxTile({required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: task.isChecked
              ? AppTheme.statusDone.withOpacity(0.08)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: task.isChecked
                ? AppTheme.statusDone.withOpacity(0.4)
                : AppTheme.divider,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: task.isChecked ? AppTheme.statusDone : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: task.isChecked
                      ? AppTheme.statusDone
                      : AppTheme.textSecondary,
                  width: 2,
                ),
              ),
              child: task.isChecked
                  ? const Icon(Icons.check_rounded,
                      size: 18, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            Text(
              task.isChecked ? 'Tugas selesai dikerjakan' : 'Tandai sebagai selesai',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: task.isChecked
                    ? AppTheme.statusDone
                    : AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChanger extends StatelessWidget {
  final TaskStatus current;
  final ValueChanged<TaskStatus> onChanged;
  const _StatusChanger({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TaskStatus.values.map((s) {
        final isSelected = s == current;
        final color = s == TaskStatus.todo
            ? AppTheme.statusTodo
            : s == TaskStatus.onProgress
                ? AppTheme.statusProgress
                : AppTheme.statusDone;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: s != TaskStatus.done ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.15) : AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : AppTheme.divider,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  s.label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected ? color : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
