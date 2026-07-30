import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/services/gemini_vision_service.dart';
import '../../../../core/theme/app_theme.dart';

/// Bottom sheet displaying the food analysis result with animated point feedback.
class FoodLogResultSheet extends StatelessWidget {
  final FoodAnalysisResult result;
  final int pointsEarned;

  const FoodLogResultSheet({
    super.key,
    required this.result,
    required this.pointsEarned,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompliant = result.isCompliant;
    final isPositive = pointsEarned > 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // -- Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // -- Lottie animation
          SizedBox(
            height: 140,
            child: Lottie.network(
              isCompliant
                  ? 'https://lottie.host/e3e74127-b498-44f4-b578-ade1b1e67c58/nRPpnfNLhM.json'
                  : 'https://lottie.host/a5920fe3-dae1-4c76-99c3-4aec6c27a302/wqNMjpVJkN.json',
              repeat: false,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Icon(
                isCompliant
                    ? Icons.check_circle_rounded
                    : Icons.warning_rounded,
                size: 80,
                color: isCompliant ? AppColors.primary : AppColors.error,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // -- Title
          Text(
            isCompliant ? 'Makanan Sesuai Diet! 🌱' : 'Tidak Sesuai Diet ⚠️',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: isCompliant ? AppColors.primary : AppColors.error,
            ),
          ),
          const SizedBox(height: 8),

          // -- Food name
          Text(
            result.foodName,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // -- Points badge
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isPositive
                    ? [AppColors.primary, AppColors.primaryLight]
                    : [AppColors.error, const Color(0xFFEF5350)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (isPositive ? AppColors.primary : AppColors.error)
                      .withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive ? Icons.star_rounded : Icons.remove_circle_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '${isPositive ? '+' : ''}$pointsEarned Poin',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // -- Macro summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MacroItem(
                  label: 'Kalori',
                  value: '${result.calories.toInt()} kkal',
                  color: const Color(0xFFFF7043),
                ),
                _MacroItem(
                  label: 'Karbo',
                  value: '${result.carbs.toInt()} g',
                  color: const Color(0xFFFFB74D),
                ),
                _MacroItem(
                  label: 'Lemak',
                  value: '${result.fats.toInt()} g',
                  color: const Color(0xFF4FC3F7),
                ),
                _MacroItem(
                  label: 'Protein',
                  value: '${result.protein.toInt()} g',
                  color: const Color(0xFF81C784),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // -- Close button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kembali ke Dashboard'),
            ),
          ),
          const SizedBox(height: 16),
          // -- Health Disclaimer
          const Text(
            'Estimasi AI untuk panduan nutrisi, bukan nasihat medis.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textHint,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textHint,
          ),
        ),
      ],
    );
  }
}
