import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/task_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/task_card.dart';
import '../widgets/add_task_sheet.dart';
import '../screens/task_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openAddTask() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTaskSheet(),
    );
  }

  void _openTaskDetail(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskDetailScreen(task: task),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildAppBar(innerBoxIsScrolled),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _TaskList(status: TaskStatus.todo, onTap: _openTaskDetail),
            _TaskList(status: TaskStatus.onProgress, onTap: _openTaskDetail),
            _TaskList(status: TaskStatus.done, onTap: _openTaskDetail),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTask,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Tambah Tugas',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  SliverAppBar _buildAppBar(bool innerBoxIsScrolled) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      floating: false,
      backgroundColor: AppTheme.background,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: _HeaderSection(),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: _TabBar(controller: _tabController),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final total = provider.totalTasks;
    final done = provider.completedTasks;
    final progress = total > 0 ? done / total : 0.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.checklist_rounded,
                    color: AppTheme.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Task Reminder',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    '$done dari $total tugas selesai',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.divider,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppTheme.statusDone),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatChip(
                label: 'To Do',
                count: provider.todoTasks.length,
                color: AppTheme.statusTodo,
              ),
              _StatChip(
                label: 'Progress',
                count: provider.onProgressTasks.length,
                color: AppTheme.statusProgress,
              ),
              _StatChip(
                label: 'Selesai',
                count: provider.doneTasks.length,
                color: AppTheme.statusDone,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatChip(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          '$count $label',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _TabBar extends StatelessWidget {
  final TabController controller;
  const _TabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.textSecondary,
        labelStyle:
            GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w400),
        tabs: const [
          Tab(text: 'To Do'),
          Tab(text: 'Progress'),
          Tab(text: 'Done'),
        ],
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  final TaskStatus status;
  final ValueChanged<Task> onTap;

  const _TaskList({required this.status, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>().getTasksByStatus(status);

    if (tasks.isEmpty) {
      return _EmptyState(status: status);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: tasks.length,
      itemBuilder: (ctx, i) {
        final task = tasks[i];
        return TaskCard(
          key: ValueKey(task.id),
          task: task,
          onTap: () => onTap(task),
          onToggleCheckbox: () =>
              context.read<TaskProvider>().toggleCheckbox(task.id),
          onDelete: () => _confirmDelete(ctx, task),
          onStatusChanged: (s) =>
              context.read<TaskProvider>().updateStatus(task.id, s),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(
          'Hapus Tugas?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          '"${task.title}" akan dihapus permanen.',
          style:
              GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal',
                style: GoogleFonts.plusJakartaSans(
                    color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Hapus',
                style: GoogleFonts.plusJakartaSans(
                    color: AppTheme.secondary)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<TaskProvider>().deleteTask(task.id);
    }
  }
}

class _EmptyState extends StatelessWidget {
  final TaskStatus status;
  const _EmptyState({required this.status});

  @override
  Widget build(BuildContext context) {
    final (icon, message, sub) = switch (status) {
      TaskStatus.todo => (
          Icons.playlist_add_check_circle_rounded,
          'Tidak ada tugas to do',
          'Tap tombol + untuk menambah tugas baru'
        ),
      TaskStatus.onProgress => (
          Icons.timelapse_rounded,
          'Tidak ada tugas in progress',
          'Ubah status tugas menjadi On Progress'
        ),
      TaskStatus.done => (
          Icons.check_circle_outline_rounded,
          'Belum ada tugas selesai',
          'Selesaikan tugas dan centang checkbox-nya'
        ),
    };

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: AppTheme.divider),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sub,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppTheme.divider,
            ),
          ),
        ],
      ),
    );
  }
}
