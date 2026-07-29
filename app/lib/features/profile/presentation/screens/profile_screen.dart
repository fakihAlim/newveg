import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newveg/core/database/database_provider.dart';
import 'package:newveg/core/database/app_database.dart';
import 'package:newveg/core/theme/app_theme.dart';
import 'package:newveg/features/profile/presentation/widgets/badge_detail_dialog.dart';
import 'package:newveg/features/insights/presentation/screens/recipe_detail_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Mifflin-St Jeor Equation calculation
  double _calculateCalorieAdvice(UserProfile profile) {
    final double weight = profile.weight ?? 60.0;
    final double height = profile.height ?? 165.0;
    final int age = profile.age ?? 25;
    final isMale = profile.gender == 'Pria';

    double bmr = (10 * weight) + (6.25 * height) - (5 * age);
    if (isMale) {
      bmr += 5;
    } else {
      bmr -= 161;
    }
    // Assume sedentary activity level multiplier of 1.2
    return bmr * 1.2;
  }

  double _calculateBmi(UserProfile profile) {
    final double weight = profile.weight ?? 60.0;
    final double heightInMeters = (profile.height ?? 165.0) / 100.0;
    return weight / (heightInMeters * heightInMeters);
  }

  String _getBmiCategory(double bmi) {
    if (bmi < 18.5) return 'Kurus (Underweight)';
    if (bmi < 24.9) return 'Normal (Healthy)';
    if (bmi < 29.9) return 'Kelebihan Berat Badan';
    return 'Obesitas';
  }

  Color _getBmiColor(double bmi) {
    if (bmi < 18.5) return const Color(0xFF4FC3F7);
    if (bmi < 24.9) return AppColors.primary;
    if (bmi < 29.9) return const Color(0xFFFFB74D);
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final theme = Theme.of(context);

    final bookmarksFuture = ref.watch(_bookmarkedRecipesFutureProvider);
    final badgesFuture = ref.watch(_badgesFutureProvider);
    final logsCountFuture = ref.watch(_plantLogsCountFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
      ),
      body: FutureBuilder<UserProfile?>(
        future: db.getUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final profile = snapshot.data;
          if (profile == null) {
            return const Center(child: Text('Profil tidak ditemukan'));
          }

          final bmi = _calculateBmi(profile);
          final bmiCategory = _getBmiCategory(bmi);
          final bmiColor = _getBmiColor(bmi);
          final calorieAdvice = _calculateCalorieAdvice(profile);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -- Header
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Text(
                          profile.gender == 'Pria' ? '👨' : '👩',
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        profile.gender == 'Pria' ? 'Bro Vegenian' : 'Sis Vegenian',
                        style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        profile.dietPreference ?? 'Strict Vegan',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // -- BMI & Calorie Advice Card (Mifflin-St Jeor)
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: AppColors.divider),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Saran Nutrisi & BMI', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const Divider(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('BMI Anda', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                  Text(
                                    bmi.toStringAsFixed(1),
                                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: bmiColor),
                                  ),
                                  Text(
                                    bmiCategory,
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: bmiColor),
                                  ),
                                ],
                              ),
                            ),
                            Container(width: 1, height: 60, color: AppColors.divider),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Target Kalori Harian', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                  Text(
                                    '${calorieAdvice.toInt()}',
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                  const Text('kkal (Mifflin-St Jeor)', style: TextStyle(fontSize: 11, color: AppColors.textHint)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // -- Carbon Footprint Card
                logsCountFuture.when(
                  loading: () => const SizedBox(),
                  error: (_, _) => const SizedBox(),
                  data: (count) {
                    final co2Saved = count * 1.5;
                    return Card(
                      elevation: 0,
                      color: const Color(0xFFE8F5E9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.1)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.co2_rounded, color: AppColors.primary, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Dampak Karbon Anda',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryDark),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Anda menghemat ~${co2Saved.toStringAsFixed(1)} kg CO2 dengan memilih hidangan plant-based!',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // -- Etalase Lencana (Badges Grid)
                Text('Etalase Lencana', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                badgesFuture.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Gagal memuat lencana: $e'),
                  data: (badgeList) {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: badgeList.length,
                      itemBuilder: (context, index) {
                        final badge = badgeList[index];
                        return _BadgeWidget(badge: badge);
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),

                // -- Bookmarked Recipes Section
                Text('Resep yang Disimpan', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                bookmarksFuture.when(
                  loading: () => const SizedBox(),
                  error: (e, _) => Text('Gagal memuat bookmark: $e'),
                  data: (bookmarks) {
                    if (bookmarks.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: const Center(
                          child: Text(
                            'Belum ada resep yang disimpan.',
                            style: TextStyle(color: AppColors.textHint, fontSize: 13),
                          ),
                        ),
                      );
                    }

                    return SizedBox(
                      height: 130,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: bookmarks.length,
                        itemBuilder: (context, index) {
                          final bookmark = bookmarks[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => RecipeDetailScreen(
                                    recipeId: bookmark.recipeId,
                                    title: bookmark.title,
                                    calories: bookmark.calories,
                                    prepTime: bookmark.prepTime,
                                    difficulty: 'Mudah', // Default fallback
                                    imageUrl: bookmark.imageUrl,
                                    ingredients: const [
                                      'Bahan resep tersimpan (Muat ulang detail resep untuk list lengkap).'
                                    ],
                                  ),
                                ),
                              ).then((_) => ref.invalidate(_bookmarkedRecipesFutureProvider));
                            },
                            child: Container(
                              width: 140,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    child: Image.network(
                                      bookmark.imageUrl,
                                      width: 140,
                                      height: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Container(
                                        width: 140,
                                        height: 70,
                                        color: AppColors.surfaceVariant,
                                        child: const Icon(Icons.restaurant, color: AppColors.primary),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      bookmark.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private Providers
// ---------------------------------------------------------------------------
final _bookmarkedRecipesFutureProvider = FutureProvider<List<BookmarkedRecipe>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getBookmarkedRecipes();
});

final _badgesFutureProvider = FutureProvider<List<Badge>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getAllBadges();
});

final _plantLogsCountFutureProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(databaseProvider);
  final allLogs = await db.getAllFoodLogs();
  return allLogs.where((l) => l.isPlantBased).length;
});

// ---------------------------------------------------------------------------
// Badge Card Widget
// ---------------------------------------------------------------------------
class _BadgeWidget extends StatelessWidget {
  final Badge badge;
  const _BadgeWidget({required this.badge});

  @override
  Widget build(BuildContext context) {
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
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.divider),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Grayscale if locked
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  badge.isUnlocked ? Colors.transparent : Colors.grey,
                  BlendMode.saturation,
                ),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFA000), size: 28),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                badge.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: badge.isUnlocked ? AppColors.textPrimary : AppColors.textHint,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                badge.isUnlocked ? 'Terbuka' : 'Terkunci',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: badge.isUnlocked ? AppColors.primary : AppColors.textHint,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
