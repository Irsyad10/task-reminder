import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_reminder/main.dart';

class MockLocalStorage extends LocalStorage {
  const MockLocalStorage();
  @override
  Future<void> initialize() async {}
  @override
  Future<String?> accessToken() async => null;
  @override
  Future<bool> hasAccessToken() async => false;
  @override
  Future<void> persistSession(String session) async {}
  @override
  Future<void> removePersistedSession() async {}
}

class MockGotrueAsyncStorage extends GotrueAsyncStorage {
  const MockGotrueAsyncStorage();
  @override
  Future<String?> getItem({required String key}) async => null;
  @override
  Future<void> setItem({required String key, required String value}) async {}
  @override
  Future<void> removeItem({required String key}) async {}
}

void main() {
  setUpAll(() async {
    try {
      await Supabase.initialize(
        url: 'https://placeholder-project.supabase.co',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBsYWNlaG9sZGVyIiwicm9sZSI6ImFub24iLCJpYXQiOjE1OTg4ODAwMDAsImV4cCI6MTkwNDQ2NDAwMH0.placeholder',
        authOptions: const FlutterAuthClientOptions(
          localStorage: MockLocalStorage(),
          pkceAsyncStorage: MockGotrueAsyncStorage(),
        ),
      );
    } catch (_) {}
  });

  testWidgets('Smoke test - App builds and displays LoginScreen by default', (WidgetTester tester) async {
    await tester.pumpWidget(const KitaPlanApp());
    
    // Expect to see the LoginScreen because session is null
    expect(find.text('Login'), findsWidgets);
  });
}
