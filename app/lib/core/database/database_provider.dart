import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// Provides a singleton [AppDatabase] instance across the app via Riverpod.
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});
