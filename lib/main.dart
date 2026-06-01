import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart'; // 🔥 tambahan

import 'services/notification_service.dart';
import 'services/task_provider.dart';
import 'screens/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 INIT LOCALE (WAJIB untuk intl)
  await initializeDateFormatting('id_ID', null);

  // Load ENV
  await dotenv.load();

  // Init Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize notification service
  await NotificationService().initialize();

  runApp(
    ChangeNotifierProvider(
      create: (_) => TaskProvider()..loadTasks(),
      child: const TaskReminderApp(),
    ),
  );
}

class TaskReminderApp extends StatelessWidget {
  const TaskReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Reminder',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,

      // 🔥 tambahan biar pakai bahasa Indonesia
      locale: const Locale('id', 'ID'),

      home: const AuthWrapper(),
    );
  }
}

// 🔐 AUTH WRAPPER (AUTO LOGIN CHECK)
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      return const HomeScreen(); // sudah login
    } else {
      return LoginScreen(); // belum login
    }
  }
}
