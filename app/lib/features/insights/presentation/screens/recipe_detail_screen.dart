import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newveg/core/database/app_database.dart';
import 'package:newveg/core/database/database_provider.dart';
import 'package:newveg/core/theme/app_theme.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final String recipeId;
  final String title;
  final int calories;
  final int prepTime;
  final String difficulty;
  final String imageUrl;
  final List<String> ingredients;

  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
    required this.title,
    required this.calories,
    required this.prepTime,
    required this.difficulty,
    required this.imageUrl,
    required this.ingredients,
  });

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  late final List<bool> _checkedIngredients;
  bool _isBookmarked = false;
  bool _isTried = false;

  @override
  void initState() {
    super.initState();
    _checkedIngredients = List<bool>.filled(widget.ingredients.length, false);
    _checkBookmarkStatus();
  }

  Future<void> _checkBookmarkStatus() async {
    final db = ref.read(databaseProvider);
    final bookmarked = await db.isRecipeBookmarked(widget.recipeId);
    if (mounted) {
      setState(() {
        _isBookmarked = bookmarked;
      });
    }
  }

  Future<void> _toggleBookmark() async {
    final db = ref.read(databaseProvider);
    if (_isBookmarked) {
      await db.deleteBookmarkedRecipe(widget.recipeId);
      if (mounted) {
        setState(() {
          _isBookmarked = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resep dihapus dari bookmark')),
        );
      }
    } else {
      await db.insertBookmarkedRecipe(
        BookmarkedRecipesCompanion(
          recipeId: drift.Value(widget.recipeId),
          title: drift.Value(widget.title),
          imageUrl: drift.Value(widget.imageUrl),
          calories: drift.Value(widget.calories),
          prepTime: drift.Value(widget.prepTime),
          savedAt: drift.Value(DateTime.now()),
        ),
      );
      if (mounted) {
        setState(() {
          _isBookmarked = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resep berhasil disimpan ke bookmark!')),
        );
      }
    }
  }

  bool get _allChecked => _checkedIngredients.every((checked) => checked);

  Future<void> _onTryRecipe() async {
    if (!_allChecked || _isTried) return;

    final db = ref.read(databaseProvider);
    final profile = await db.getUserProfile();
    if (profile != null) {
      await db.addPoints(profile.id, 100); // Reward +100 points for trying a recipe!
      if (mounted) {
        setState(() {
          _isTried = true;
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hebat! 🎉'),
            content: const Text('Anda telah menyelesaikan resep ini dan mendapatkan +100 Poin!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              )
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: _isBookmarked ? AppColors.primary : AppColors.textPrimary,
            ),
            onPressed: _toggleBookmark,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            Image.network(
              widget.imageUrl,
              width: double.infinity,
              height: 240,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: double.infinity,
                height: 240,
                color: AppColors.surfaceVariant,
                child: const Icon(Icons.restaurant, size: 64, color: AppColors.primary),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Difficulty Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          widget.difficulty,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 18, color: AppColors.textHint),
                          const SizedBox(width: 4),
                          Text('${widget.prepTime} min', style: theme.textTheme.bodyMedium),
                          const SizedBox(width: 16),
                          const Icon(Icons.local_fire_department_rounded, size: 18, color: Color(0xFFFF7043)),
                          const SizedBox(width: 4),
                          Text('${widget.calories} kkal', style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(widget.title, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const Divider(height: 32),

                  // Ingredients Checkbox List
                  Text('Bahan-bahan', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Centang semua bahan untuk menandai resep sebagai "Sudah Dicoba".', style: theme.textTheme.bodySmall),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.ingredients.length,
                    itemBuilder: (context, index) {
                      return CheckboxListTile(
                        value: _checkedIngredients[index],
                        onChanged: _isTried
                            ? null
                            : (val) {
                                setState(() {
                                  _checkedIngredients[index] = val ?? false;
                                });
                              },
                        title: Text(widget.ingredients[index]),
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: AppColors.primary,
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // Try Recipe Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: (_allChecked && !_isTried) ? _onTryRecipe : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isTried ? AppColors.textHint : AppColors.primary,
                        disabledBackgroundColor: AppColors.divider,
                      ),
                      child: Text(
                        _isTried ? 'Telah Dicoba ✓' : 'Sudah Dicoba',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
