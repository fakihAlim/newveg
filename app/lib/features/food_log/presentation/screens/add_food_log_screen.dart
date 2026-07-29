import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/food_log_provider.dart';
import 'food_log_result_sheet.dart';

/// Screen for adding a new food log entry.
///
/// Flow: Pick image → Select meal type → Analyze with AI → Review → Save.
class AddFoodLogScreen extends ConsumerStatefulWidget {
  const AddFoodLogScreen({super.key});

  @override
  ConsumerState<AddFoodLogScreen> createState() => _AddFoodLogScreenState();
}

class _AddFoodLogScreenState extends ConsumerState<AddFoodLogScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();

    // Reset state when entering the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(foodLogProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked != null) {
        ref.read(foodLogProvider.notifier).setImage(File(picked.path));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil gambar: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _analyzeFood() async {
    await ref.read(foodLogProvider.notifier).analyzeFood();

    if (!mounted) return;
    final state = ref.read(foodLogProvider);

    if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error!),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _saveAndShowResult() async {
    final points = await ref.read(foodLogProvider.notifier).saveFoodLog();

    if (!mounted) return;
    final state = ref.read(foodLogProvider);

    if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error!),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Show result bottom sheet
    final result = state.analysisResult;
    if (result == null) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FoodLogResultSheet(
        result: result,
        pointsEarned: points,
      ),
    );

    if (!mounted) return;
    Navigator.of(context).pop(true); // Return to dashboard with refresh signal
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(foodLogProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Tambah Log Makanan'),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -- Image section
                _buildImageSection(state, theme),
                const SizedBox(height: 24),

                // -- Meal type selector
                Text('Jenis Makanan', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                _buildMealTypeSelector(state),
                const SizedBox(height: 24),

                // -- Analyze button
                if (state.imageFile != null && state.analysisResult == null)
                  _buildAnalyzeButton(state),

                // -- Analysis loading
                if (state.isAnalyzing) _buildAnalyzingIndicator(theme),

                // -- Analysis result
                if (state.analysisResult != null)
                  _buildResultCard(state, theme),

                const SizedBox(height: 24),

                // -- Save button
                if (state.canSave) _buildSaveButton(state),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Image Section
  // ---------------------------------------------------------------------------

  Widget _buildImageSection(dynamic state, ThemeData theme) {
    if (state.imageFile != null) {
      return _buildImagePreview(state, theme);
    }
    return _buildImagePickerButtons(theme);
  }

  Widget _buildImagePickerButtons(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.divider,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_rounded,
            size: 56,
            color: AppColors.primary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Foto makanan Anda',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Ambil foto atau pilih dari galeri untuk dianalisis AI',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _ImagePickerButton(
                  icon: Icons.camera_alt_rounded,
                  label: 'Kamera',
                  onTap: () => _pickImage(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ImagePickerButton(
                  icon: Icons.photo_library_rounded,
                  label: 'Galeri',
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(dynamic state, ThemeData theme) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.file(
            state.imageFile!,
            width: double.infinity,
            height: 240,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Row(
            children: [
              _CircleActionButton(
                icon: Icons.camera_alt_rounded,
                onTap: () => _pickImage(ImageSource.camera),
              ),
              const SizedBox(width: 8),
              _CircleActionButton(
                icon: Icons.photo_library_rounded,
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              const SizedBox(width: 8),
              _CircleActionButton(
                icon: Icons.close_rounded,
                color: AppColors.error,
                onTap: () => ref.read(foodLogProvider.notifier).clearImage(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Meal Type Selector
  // ---------------------------------------------------------------------------

  Widget _buildMealTypeSelector(dynamic state) {
    const mealTypes = [
      ('Breakfast', Icons.free_breakfast_rounded),
      ('Lunch', Icons.lunch_dining_rounded),
      ('Dinner', Icons.dinner_dining_rounded),
      ('Snack', Icons.cookie_rounded),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: mealTypes.map((meal) {
        final isSelected = state.mealType == meal.$1;
        return _MealTypeChip(
          label: meal.$1,
          icon: meal.$2,
          isSelected: isSelected,
          onTap: () =>
              ref.read(foodLogProvider.notifier).setMealType(meal.$1),
        );
      }).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // Analyze Button
  // ---------------------------------------------------------------------------

  Widget _buildAnalyzeButton(dynamic state) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: state.canAnalyze ? _analyzeFood : null,
        icon: const Icon(Icons.auto_awesome_rounded, size: 22),
        label: const Text('Analisis dengan AI'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1565C0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Analyzing Indicator
  // ---------------------------------------------------------------------------

  Widget _buildAnalyzingIndicator(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Use Lottie network animation for scanning
          SizedBox(
            height: 120,
            child: Lottie.network(
              'https://lottie.host/1b5a6b2a-32e5-45e7-a1b6-1e7c4e0cc2a6/qDKljpVkLr.json',
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Menganalisis makanan...',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'AI sedang mengidentifikasi nutrisi dan kepatuhan diet',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Result Card
  // ---------------------------------------------------------------------------

  Widget _buildResultCard(dynamic state, ThemeData theme) {
    final result = state.analysisResult!;
    final isCompliant = result.isCompliant;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompliant
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.error.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isCompliant ? AppColors.primary : AppColors.error)
                .withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compliance badge
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isCompliant
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCompliant
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      size: 18,
                      color: isCompliant ? AppColors.primary : AppColors.error,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isCompliant ? 'Sesuai Diet' : 'Tidak Sesuai',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color:
                            isCompliant ? AppColors.primary : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                isCompliant ? '+50 Poin' : '-20 Poin',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isCompliant ? AppColors.primary : AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Food name
          Text(
            result.foodName,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Macros grid
          Row(
            children: [
              _MacroChip(
                label: 'Kalori',
                value: '${result.calories.toInt()}',
                unit: 'kkal',
                color: const Color(0xFFFF7043),
              ),
              const SizedBox(width: 8),
              _MacroChip(
                label: 'Karbo',
                value: '${result.carbs.toInt()}',
                unit: 'g',
                color: const Color(0xFFFFB74D),
              ),
              const SizedBox(width: 8),
              _MacroChip(
                label: 'Lemak',
                value: '${result.fats.toInt()}',
                unit: 'g',
                color: const Color(0xFF4FC3F7),
              ),
              const SizedBox(width: 8),
              _MacroChip(
                label: 'Protein',
                value: '${result.protein.toInt()}',
                unit: 'g',
                color: const Color(0xFF81C784),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Save Button
  // ---------------------------------------------------------------------------

  Widget _buildSaveButton(dynamic state) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: state.isSaving ? null : _saveAndShowResult,
        icon: state.isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.save_rounded, size: 22),
        label: Text(state.isSaving ? 'Menyimpan...' : 'Simpan Log Makanan'),
      ),
    );
  }
}

// =============================================================================
// Private Widgets
// =============================================================================

class _ImagePickerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImagePickerButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      elevation: 1,
      shadowColor: AppColors.cardShadow,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, size: 28, color: AppColors.primary),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CircleActionButton({
    required this.icon,
    required this.onTap,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}

class _MealTypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _MealTypeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _MacroChip({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              unit,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
