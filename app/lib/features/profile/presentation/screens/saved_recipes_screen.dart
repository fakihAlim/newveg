import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../insights/presentation/screens/recipe_detail_screen.dart';

final savedRecipesFutureProvider = FutureProvider<List<BookmarkedRecipe>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getBookmarkedRecipes();
});

class SavedRecipesScreen extends ConsumerWidget {
  const SavedRecipesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final savedRecipesFuture = ref.watch(savedRecipesFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resep Tersimpan'),
      ),
      body: savedRecipesFuture.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(child: Text('Gagal memuat resep tersimpan: $err')),
        data: (recipes) {
          if (recipes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bookmark_outline_rounded, size: 64, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada resep yang disimpan',
                    style: theme.textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.divider),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      recipe.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 60,
                        height: 60,
                        color: AppColors.surfaceVariant,
                        child: const Icon(Icons.restaurant, color: AppColors.textHint),
                      ),
                    ),
                  ),
                  title: Text(
                    recipe.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: Text(
                    '${recipe.calories.toInt()} kkal • ${recipe.prepTime} menit',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.bookmark_remove_rounded, color: AppColors.error),
                    onPressed: () async {
                      final db = ref.read(databaseProvider);
                      await db.deleteBookmarkedRecipe(recipe.recipeId);
                      ref.invalidate(savedRecipesFutureProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Resep dihapus dari simpanan.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RecipeDetailScreen(
                          recipeId: recipe.recipeId,
                          title: recipe.title,
                          calories: recipe.calories,
                          prepTime: recipe.prepTime,
                          difficulty: 'Easy',
                          imageUrl: recipe.imageUrl,
                          ingredients: const [
                            'Bahan resep tersimpan (Muat ulang detail resep untuk list lengkap).'
                          ],
                        ),
                      ),
                    ).then((_) => ref.invalidate(savedRecipesFutureProvider));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
