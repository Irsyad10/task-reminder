import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/task_provider.dart';
import '../theme/app_theme.dart';

class AddTaskSheet extends StatefulWidget {
  final Task? task; // null = add, non-null = edit

  const AddTaskSheet({super.key, this.task});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  DateTime? _deadline;
  bool _scheduleNotification = true;
  TaskStatus _status = TaskStatus.todo;

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController =
        TextEditingController(text: widget.task?.description ?? '');
    _deadline = widget.task?.deadline;
    _status = widget.task?.status ?? TaskStatus.todo;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.primary,
            surface: AppTheme.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_deadline ?? now),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.primary,
            surface: AppTheme.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (time == null || !mounted) return;

    setState(() {
      _deadline = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul tugas tidak boleh kosong')),
      );
      return;
    }

    final provider = context.read<TaskProvider>();

    if (isEditing) {
      final updated = widget.task!.copyWith(
        title: title,
        description: _descController.text.trim(),
        deadline: _deadline,
        status: _status,
        isChecked: _status == TaskStatus.done,
      );
      await provider.updateTask(updated);
    } else {
      await provider.addTask(
        title: title,
        description: _descController.text.trim(),
        deadline: _deadline,
        scheduleNotification: _scheduleNotification,
      );
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
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
          const SizedBox(height: 20),
          Text(
            isEditing ? 'Edit Tugas' : 'Tambah Tugas Baru',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          // Title
          _buildLabel('Judul Tugas *'),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            autofocus: !isEditing,
            style: GoogleFonts.plusJakartaSans(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Contoh: Selesaikan laporan bulanan',
              prefixIcon:
                  Icon(Icons.task_alt_rounded, color: AppTheme.textSecondary),
            ),
          ),
          const SizedBox(height: 16),

          // Description
          _buildLabel('Deskripsi'),
          const SizedBox(height: 8),
          TextField(
            controller: _descController,
            maxLines: 3,
            style: GoogleFonts.plusJakartaSans(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Tambahkan detail tugas di sini...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),

          // Deadline
          _buildLabel('Deadline & Waktu'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickDeadline,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      color: AppTheme.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _deadline != null
                          ? DateFormat('EEEE, dd MMMM yyyy – HH:mm', 'id')
                              .format(_deadline!)
                          : 'Pilih tanggal & waktu deadline',
                      style: GoogleFonts.plusJakartaSans(
                        color: _deadline != null
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (_deadline != null)
                    GestureDetector(
                      onTap: () => setState(() => _deadline = null),
                      child: const Icon(Icons.close_rounded,
                          color: AppTheme.textSecondary, size: 18),
                    ),
                ],
              ),
            ),
          ),

          // Notification toggle
          if (!isEditing && _deadline != null) ...[
            const SizedBox(height: 12),
            _NotificationToggle(
              value: _scheduleNotification,
              onChanged: (v) => setState(() => _scheduleNotification = v),
            ),
          ],

          // Status (editing only)
          if (isEditing) ...[
            const SizedBox(height: 16),
            _buildLabel('Status'),
            const SizedBox(height: 8),
            _StatusSelector(
              selected: _status,
              onChanged: (s) => setState(() => _status = s),
            ),
          ],

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                isEditing ? 'Simpan Perubahan' : 'Tambah Tugas',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _NotificationToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _NotificationToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            value
                ? Icons.notifications_active_rounded
                : Icons.notifications_off_outlined,
            color: value ? AppTheme.warning : AppTheme.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Ingatkan 1 jam sebelum deadline',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}

class _StatusSelector extends StatelessWidget {
  final TaskStatus selected;
  final ValueChanged<TaskStatus> onChanged;
  const _StatusSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TaskStatus.values.map((s) {
        final isSelected = s == selected;
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
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.15) : AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? color : Colors.transparent,
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
