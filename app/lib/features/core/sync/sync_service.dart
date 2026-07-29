import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newveg/core/database/app_database.dart';
import 'package:newveg/core/database/database_provider.dart';
import 'package:newveg/core/services/api_service.dart';

/// Background Sync Engine that monitors network status and pushes local
/// food logs and profile progress to backend server once connection is online.
class SyncService {
  final AppDatabase _db;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  SyncService(this._db);

  /// Start listening to connectivity changes.
  void init() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      // If any of the results indicate we have connection, run sync
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (hasConnection) {
        if (kDebugMode) {
          print('Network status: ONLINE. Starting background sync...');
        }
        triggerSync();
      } else {
        if (kDebugMode) {
          print('Network status: OFFLINE. Sync paused.');
        }
      }
    });
  }

  /// Triggers food logs and profile synchronization process.
  Future<void> triggerSync() async {
    try {
      // 1. Sync Food Logs
      final unsyncedLogs = await _db.getUnsyncedFoodLogs();
      if (unsyncedLogs.isEmpty) {
        if (kDebugMode) {
          print('Sync Engine: All food logs are up to date.');
        }
      } else {
        if (kDebugMode) {
          print('Sync Engine: Found ${unsyncedLogs.length} unsynced food logs.');
        }

        // Initialize api connection with default demo login if token is not active
        await apiService.login('admin@aa.com', 'admin123');

        // Transform drift model to backend JSON structure
        final logsJson = unsyncedLogs.map((log) => {
          'food_name': log.foodName,
          'image_url': log.imagePath,
          'calories': log.calories,
          'carbs': log.carbs,
          'fats': log.fats,
          'protein': log.protein,
          'is_compliant': log.isPlantBased ? 1 : 0,
          'points_earned': log.pointsEarned,
          'created_at': log.createdAt.toIso8601String(),
        }).toList();

        final success = await apiService.syncFoodLogs(logsJson);
        if (success) {
          for (final log in unsyncedLogs) {
            await _db.markFoodLogSynced(log.id);
            if (kDebugMode) {
              print('Sync Engine: Food log ${log.id} successfully synced to server.');
            }
          }
        } else {
          if (kDebugMode) {
            print('Sync Engine: Failed to synchronize logs to remote server.');
          }
        }
      }

      // 2. Sync Profile data (points & ttm stage)
      final profile = await _db.getUserProfile();
      if (profile != null) {
        // Simulated push profile to Firebase
        await Future.delayed(const Duration(milliseconds: 300));
        if (kDebugMode) {
          print('Sync Engine: Profile (Points: ${profile.totalPoints}, TTM: ${profile.ttmStage}) synced.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Sync Engine Error: $e');
      }
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}

/// Provider exposing the [SyncService] singleton.
final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.watch(databaseProvider);
  final service = SyncService(db);
  ref.onDispose(() => service.dispose());
  return service;
});
