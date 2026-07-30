import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newveg/core/database/database_provider.dart';
import 'package:newveg/core/database/app_database.dart';
import 'package:newveg/core/theme/app_theme.dart';
import 'package:newveg/features/core/sync/sync_service.dart';
import 'package:newveg/features/auth/presentation/screens/auth_gate.dart';
import 'package:newveg/core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: '.env');

  // Initialize notifications service
  await NotificationService().init();

  runApp(const ProviderScope(child: NewVegApp()));
}

/// Profile loader provider to check if onboarding is already completed.
final userProfileFutureProvider = FutureProvider<UserProfile?>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getUserProfile();
});

/// Reactive sync initializer provider
final syncInitProvider = Provider<void>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  syncService.init();
});

class NewVegApp extends ConsumerWidget {
  const NewVegApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize network status monitoring and background sync
    ref.watch(syncInitProvider);

    return MaterialApp(
      title: 'NewVeg — Plant-Based Diet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}
