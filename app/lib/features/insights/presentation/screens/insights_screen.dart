import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newveg/core/theme/app_theme.dart';
import 'package:newveg/features/insights/presentation/screens/myth_detail_screen.dart';
import 'package:newveg/features/insights/presentation/screens/recipe_detail_screen.dart';
import 'package:newveg/features/content/presentation/providers/content_provider.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights & Edukasi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -- Myth vs Fact Card
            Text(
              'Mitos vs Fakta',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const _MythFactCard(),
            const SizedBox(height: 24),

            // -- Latest News Section
            Text(
              'Artikel Kesehatan Terbaru',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const _LatestNewsSection(),
            const SizedBox(height: 24),

            // -- Featured Recipes
            Text(
              'Resep Berbasis Nabati',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const _FeaturedRecipesSection(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Myth vs Fact Card Widget
// ---------------------------------------------------------------------------
class _MythFactCard extends StatelessWidget {
  const _MythFactCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'MITOS',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.help_outline_rounded, color: AppColors.textHint),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '“Pola makan nabati tidak menyediakan cukup protein untuk membangun otot.”',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MythDetailScreen(
                        myth: 'Pola makan nabati tidak menyediakan cukup protein untuk membangun otot.',
                        fact: 'Banyak bahan nabati seperti tempe, tahu, kacang-kacangan, dan lentil kaya akan protein lengkap asam amino yang sangat efektif untuk hipertrofi otot.',
                        explanation: 'Protein nabati sangat mampu menunjang pertumbuhan otot. Banyak atlet elit dunia beralih ke pola makan 100% plant-based dan membuktikan performa serta massa otot mereka tetap prima. Yang terpenting adalah mengonsumsi berbagai variasi sumber protein nabati untuk memenuhi kebutuhan profil asam amino harian tubuh.',
                      ),
                    ),
                  );
                },
                child: const Text('Buka Kebenaran ➔'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Latest News Horizontal List
// ---------------------------------------------------------------------------
class _LatestNewsSection extends ConsumerWidget {
  const _LatestNewsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(remoteNewsProvider);

    return newsAsync.when(
      data: (articles) {
        if (articles.isEmpty) {
          return const SizedBox(
            height: 100,
            child: Center(child: Text('Tidak ada artikel kesehatan terbaru.')),
          );
        }

        return SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              final title = article['title'] as String? ?? '';
              final category = article['category'] as String? ?? 'Nutrition';
              final content = article['content'] as String? ?? '';
              final rawImage = article['image_url'] as String? ?? '';
              final imageUrl = rawImage.startsWith('http')
                  ? rawImage
                  : 'https://yodi.my.id/veg/web/$rawImage';

              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 70,
                          height: 70,
                          color: AppColors.surfaceVariant,
                          child: const Icon(Icons.article, color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(category, style: const TextStyle(fontSize: 10, color: AppColors.primary)),
                              const Text('3 mnt baca', style: TextStyle(fontSize: 10, color: AppColors.textHint)),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(
        height: 110,
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (e, _) => const SizedBox(
        height: 100,
        child: Center(child: Text('Gagal memuat artikel')),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Featured Recipes List
// ---------------------------------------------------------------------------
class _FeaturedRecipesSection extends ConsumerWidget {
  const _FeaturedRecipesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(remoteRecipesProvider);

    return recipesAsync.when(
      data: (recipes) {
        if (recipes.isEmpty) {
          return const SizedBox(
            height: 120,
            child: Center(child: Text('Tidak ada resep berbasis nabati.')),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recipes.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            final title = recipe['title'] as String? ?? '';
            final calories = (recipe['calories'] as num?)?.toInt() ?? 0;
            final prepTime = (recipe['prep_time_mins'] as num?)?.toInt() ?? 0;
            final difficulty = recipe['difficulty'] as String? ?? 'Easy';
            final rawImage = recipe['image_url'] as String? ?? '';
            final imageUrl = rawImage.startsWith('http')
                ? rawImage
                : 'https://yodi.my.id/veg/web/$rawImage';
            
            // Handle ingredients field, fallback to static if not a list
            final dynamic rawIngredients = recipe['ingredients'];
            final List<String> ingredientsList = rawIngredients is List
                ? List<String>.from(rawIngredients)
                : ['Bahan dapat dilihat di detail resep.'];

            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.divider),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RecipeDetailScreen(
                        recipeId: (recipe['id'] ?? index).toString(),
                        title: title,
                        calories: calories,
                        prepTime: prepTime,
                        difficulty: difficulty,
                        imageUrl: imageUrl,
                        ingredients: ingredientsList,
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                      child: Image.network(
                        imageUrl,
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 110,
                          height: 110,
                          color: AppColors.surfaceVariant,
                          child: const Icon(Icons.restaurant, color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                difficulty,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.timer_outlined, size: 14, color: AppColors.textHint),
                                const SizedBox(width: 4),
                                Text('$prepTime min', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                const SizedBox(width: 12),
                                const Icon(Icons.local_fire_department_rounded, size: 14, color: Color(0xFFFF7043)),
                                const SizedBox(width: 4),
                                Text('$calories kkal', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const SizedBox(
        height: 150,
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (e, _) => const SizedBox(
        height: 120,
        child: Center(child: Text('Gagal memuat resep berbasis nabati.')),
      ),
    );
  }
}
