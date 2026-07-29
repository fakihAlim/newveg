import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newveg/core/database/database_provider.dart';
import 'package:newveg/core/theme/app_theme.dart';
import 'package:newveg/features/content/presentation/providers/content_provider.dart';

class DailyQuizScreen extends ConsumerStatefulWidget {
  const DailyQuizScreen({super.key});

  @override
  ConsumerState<DailyQuizScreen> createState() => _DailyQuizScreenState();
}

class _DailyQuizScreenState extends ConsumerState<DailyQuizScreen> {
  int? _selectedOptionIndex;
  bool _isSubmitted = false;

  Future<void> _submitAnswer(int index, int correctIndex, int pointsReward) async {
    if (_isSubmitted) return;

    setState(() {
      _selectedOptionIndex = index;
      _isSubmitted = true;
    });

    final isCorrect = index == correctIndex;
    if (isCorrect) {
      final db = ref.read(databaseProvider);
      final profile = await db.getUserProfile();
      if (profile != null) {
        await db.addPoints(profile.id, pointsReward); // Reward points dynamically
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quizAsync = ref.watch(remoteQuizProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kuis Harian'),
      ),
      body: quizAsync.when(
        data: (quizzes) {
          if (quizzes.isEmpty) {
            return const Center(child: Text('Kuis hari ini belum tersedia.'));
          }

          final quiz = quizzes.first;
          final question = quiz['question'] as String? ?? '';
          final options = [
            quiz['option_a'] as String? ?? '',
            quiz['option_b'] as String? ?? '',
            quiz['option_c'] as String? ?? '',
            quiz['option_d'] as String? ?? '',
          ];
          
          final correctOptStr = quiz['correct_option'] as String? ?? 'A';
          final correctIndex = {'A': 0, 'B': 1, 'C': 2, 'D': 3}[correctOptStr] ?? 0;
          final explanation = quiz['explanation'] as String? ?? '';
          final pointsReward = int.tryParse(quiz['points_reward']?.toString() ?? '10') ?? 10;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question Progress
                const Text(
                  'Pertanyaan Hari Ini',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.1),
                ),
                const SizedBox(height: 12),
                Text(
                  question,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Options List
                Expanded(
                  child: ListView.separated(
                    itemCount: options.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final optionText = options[index];
                      final isSelected = _selectedOptionIndex == index;
                      final isCorrect = index == correctIndex;

                      Color itemColor = AppColors.surface;
                      Color borderColor = AppColors.divider;
                      Widget? suffixIcon;

                      if (_isSubmitted) {
                        if (isCorrect) {
                          itemColor = AppColors.primary.withValues(alpha: 0.08);
                          borderColor = AppColors.primary;
                          suffixIcon = Icon(Icons.check_circle_rounded, color: AppColors.primary);
                        } else if (isSelected) {
                          itemColor = AppColors.error.withValues(alpha: 0.08);
                          borderColor = AppColors.error;
                          suffixIcon = Icon(Icons.cancel_rounded, color: AppColors.error);
                        }
                      } else if (isSelected) {
                        borderColor = AppColors.primary;
                      }

                      return GestureDetector(
                        onTap: () => _submitAnswer(index, correctIndex, pointsReward),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: itemColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor, width: isSelected || (_isSubmitted && isCorrect) ? 2 : 1),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  optionText,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: _isSubmitted && isCorrect ? AppColors.primaryDark : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              // ignore: use_null_aware_elements
                              if (suffixIcon != null) suffixIcon,
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Explanation Section
                if (_isSubmitted) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedOptionIndex == correctIndex ? 'Jawaban Anda Benar! 🎉 (+$pointsReward Poin)' : 'Jawaban Kurang Tepat 😅',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _selectedOptionIndex == correctIndex ? AppColors.primary : AppColors.error,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          explanation,
                          style: const TextStyle(fontSize: 13, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Close Button
                if (_isSubmitted)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Selesai & Kembali'),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => const Center(
          child: Text('Gagal memuat kuis.'),
        ),
      ),
    );
  }
}
