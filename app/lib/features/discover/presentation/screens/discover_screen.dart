import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newveg/core/database/database_provider.dart';
import 'package:newveg/core/database/app_database.dart';
import 'package:newveg/core/theme/app_theme.dart';
import 'package:newveg/features/discover/presentation/screens/daily_quiz_screen.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  // Mock quest completeness statuses for today
  final Map<String, (int current, int target, bool completed)> _questProgress = {
    'Log Makanan': (1, 3, false),
    'Coba Resep Baru': (0, 1, false),
    'Pelajari Mitos vs Fakta': (1, 1, true),
  };

  List<String> _getQuestsForTtmStage(String ttmStage) {
    switch (ttmStage) {
      case 'Precontemplation':
        return [
          'Baca 1 Artikel Mitos vs Fakta',
          'Lihat Menu Resep Nabati hari ini',
          'Pelajari Manfaat Pola Makan Nabati'
        ];
      case 'Contemplation':
        return [
          'Baca 1 Artikel Nutrisi',
          'Pilih 1 Resep untuk dicoba nanti',
          'Catat 1 Makanan Nabati hari ini'
        ];
      case 'Preparation':
        return [
          'Pilih Menu Diet Nabati Anda',
          'Centang 3 Bahan Resep Baru',
          'Log Makanan Sarapan Anda'
        ];
      case 'Action':
        return [
          'Log Makanan 3 Kali hari ini',
          'Coba Resep Baru Nabati',
          'Centang Semua Bahan Resep'
        ];
      case 'Maintenance':
        return [
          'Pertahankan Log Makanan selama 5 hari',
          'Bagikan Resep Nabati Favorit',
          'Selesaikan Kuis Nutrisi Harian'
        ];
      default:
        return [
          'Log Makanan hari ini',
          'Coba Resep Baru',
          'Pelajari Mitos vs Fakta'
        ];
    }
  }

  Future<void> _completeQuest(String questKey, int points) async {
    final progress = _questProgress[questKey];
    if (progress == null || progress.$3) return;

    final db = ref.read(databaseProvider);
    final profile = await db.getUserProfile();
    if (profile != null) {
      await db.addPoints(profile.id, points);
      setState(() {
        _questProgress[questKey] = (progress.$2, progress.$2, true);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Misi Selesai! Anda mendapatkan +$points Poin! 🎉'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover & Misi'),
      ),
      body: FutureBuilder<UserProfile?>(
        future: db.getUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final profile = snapshot.data;
          final ttmStage = profile?.ttmStage ?? 'Precontemplation';
          final quests = _getQuestsForTtmStage(ttmStage);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -- Daily Quiz Card Banner
                const _DailyQuizBannerCard(),
                const SizedBox(height: 24),

                // -- Misi Harian Section
                Text(
                  'Misi Harian Anda',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Berdasarkan tahap TTM: $ttmStage',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 12),

                // -- Quests List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: quests.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final questTitle = quests[index];
                    // Map quests titles to our mock state
                    final mockKey = _questProgress.keys.elementAt(index % _questProgress.length);
                    final progress = _questProgress[mockKey]!;

                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.divider),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: progress.$3
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : AppColors.surfaceVariant,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            progress.$3 ? Icons.star_rounded : Icons.star_border_rounded,
                            color: progress.$3 ? AppColors.primary : AppColors.textHint,
                          ),
                        ),
                        title: Text(
                          questTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            decoration: progress.$3 ? TextDecoration.lineThrough : null,
                            color: progress.$3 ? AppColors.textHint : AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          'Kemajuan: ${progress.$1}/${progress.$2}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        trailing: progress.$3
                            ? const Text(
                                'Selesai',
                                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                              )
                            : OutlinedButton(
                                onPressed: () => _completeQuest(mockKey, 30),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  minimumSize: Size.zero,
                                ),
                                child: const Text('Klaim'),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Daily Quiz Card Banner Widget
// ---------------------------------------------------------------------------
class _DailyQuizBannerCard extends StatelessWidget {
  const _DailyQuizBannerCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.quiz_rounded, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'KUIS NUTRISI HARIAN',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Uji pengetahuan gizi nabati Anda hari ini & dapatkan poin tambahan!',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DailyQuizScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                elevation: 0,
              ),
              child: const Text('Mulai Kuis Sekarang'),
            ),
          )
        ],
      ),
    );
  }
}
