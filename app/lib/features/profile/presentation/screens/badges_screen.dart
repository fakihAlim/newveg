import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/badge_detail_dialog.dart';

final allBadgesFutureProvider = FutureProvider<List<Badge>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getAllBadges();
});

final plantLogsCountProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(databaseProvider);
  final allLogs = await db.getAllFoodLogs();
  return allLogs.where((l) => l.isPlantBased).length;
});

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  double _getBadgeProgress(Badge badge, int plantLogsCount) {
    if (badge.isUnlocked) return 1.0;
    if (badge.badgeCode == 'first_scan') {
      return 0.0;
    } else if (badge.badgeCode == 'green_streak') {
      return (plantLogsCount / 5.0).clamp(0.0, 1.0);
    } else if (badge.badgeCode == 'quiz_master') {
      return 0.0;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgesFuture = ref.watch(allBadgesFutureProvider);
    final logsCountFuture = ref.watch(plantLogsCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Pencapaian Badges'),
      ),
      body: badgesFuture.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(child: Text('Gagal memuat lencana: $err')),
        data: (badgeList) {
          return logsCountFuture.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            error: (err, _) => Center(child: Text('Error: $err')),
            data: (plantLogsCount) {
              return GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.95,
                ),
                itemCount: badgeList.length,
                itemBuilder: (context, index) {
                  final badge = badgeList[index];
                  final progress = _getBadgeProgress(badge, plantLogsCount);
                  final isUnlocked = badge.isUnlocked;

                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => BadgeDetailDialog(badge: badge),
                      );
                    },
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isUnlocked ? AppColors.primary : AppColors.divider,
                          width: isUnlocked ? 2 : 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                isUnlocked ? Colors.transparent : Colors.grey,
                                BlendMode.saturation,
                              ),
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: isUnlocked
                                      ? AppColors.primary.withValues(alpha: 0.1)
                                      : AppColors.surfaceVariant,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.emoji_events_rounded,
                                  color: Color(0xFFFFA000),
                                  size: 32,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              badge.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isUnlocked ? AppColors.textPrimary : AppColors.textHint,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            if (isUnlocked)
                              Text(
                                'Terbuka',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              )
                            else ...[
                              Text(
                                'Progress: ${(progress * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 6,
                                  backgroundColor: AppColors.divider,
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.textHint),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
