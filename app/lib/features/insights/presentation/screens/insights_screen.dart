import 'package:flutter/material.dart';
import 'package:newveg/core/theme/app_theme.dart';
import 'package:newveg/features/insights/presentation/screens/myth_detail_screen.dart';
import 'package:newveg/features/insights/presentation/screens/recipe_detail_screen.dart';

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
class _LatestNewsSection extends StatelessWidget {
  const _LatestNewsSection();

  static const List<Map<String, String>> _articles = [
    {
      'title': '5 Sumber Kalsium Nabati Terbaik Selain Susu Sapi',
      'source': 'Health Journal',
      'readTime': '3 menit baca',
      'image': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&q=80&w=200',
    },
    {
      'title': 'Bagaimana Diet Vegan Menurunkan Risiko Kolesterol',
      'source': 'NutriScience',
      'readTime': '5 menit baca',
      'image': 'https://images.unsplash.com/photo-1498837167922-ddd27525d352?auto=format&fit=crop&q=80&w=200',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _articles.length,
        itemBuilder: (context, index) {
          final article = _articles[index];
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
                    article['image']!,
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
                        article['title']!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(article['source']!, style: const TextStyle(fontSize: 10, color: AppColors.primary)),
                          Text(article['readTime']!, style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
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
  }
}

// ---------------------------------------------------------------------------
// Featured Recipes List
// ---------------------------------------------------------------------------
class _FeaturedRecipesSection extends StatelessWidget {
  const _FeaturedRecipesSection();

  static const List<Map<String, dynamic>> _recipes = [
    {
      'id': 'r1',
      'title': 'Salad Tahu Saus Kacang',
      'calories': 320,
      'prepTime': 15,
      'difficulty': 'Mudah',
      'image': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&q=80&w=400',
      'ingredients': [
        '100g Tahu putih potong dadu, panggang',
        '50g Selada segar iris tipis',
        '30g Kacang tanah sangrai, haluskan',
        '1 sdm Kecap manis organik',
        '1/2 sdt Perasan jeruk nipis',
        'Sedikit garam & cabai (sesuai selera)'
      ],
    },
    {
      'id': 'r2',
      'title': 'Curry Kentang & Wortel Gurih',
      'calories': 450,
      'prepTime': 25,
      'difficulty': 'Sedang',
      'image': 'https://images.unsplash.com/photo-1498837167922-ddd27525d352?auto=format&fit=crop&q=80&w=400',
      'ingredients': [
        '2 buah Kentang ukuran sedang, potong dadu',
        '1 buah Wortel iris melingkar',
        '200ml Santan encer nabati / santan kelapa',
        '1 sdm Bumbu kari instan alami',
        '1 batang Serai dimemarkan',
        '2 lembar Daun jeruk segar'
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recipes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final recipe = _recipes[index];
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
                    recipeId: recipe['id'] as String,
                    title: recipe['title'] as String,
                    calories: recipe['calories'] as int,
                    prepTime: recipe['prepTime'] as int,
                    difficulty: recipe['difficulty'] as String,
                    imageUrl: recipe['image'] as String,
                    ingredients: List<String>.from(recipe['ingredients'] as List),
                  ),
                ),
              );
            },
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                  child: Image.network(
                    recipe['image'] as String,
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
                            recipe['difficulty'] as String,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          recipe['title'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined, size: 14, color: AppColors.textHint),
                            const SizedBox(width: 4),
                            Text('${recipe['prepTime']} min', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            const SizedBox(width: 12),
                            const Icon(Icons.local_fire_department_rounded, size: 14, color: Color(0xFFFF7043)),
                            const SizedBox(width: 4),
                            Text('${recipe['calories']} kkal', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
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
  }
}
