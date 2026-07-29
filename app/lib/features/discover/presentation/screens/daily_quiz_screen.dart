import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newveg/core/database/database_provider.dart';
import 'package:newveg/core/theme/app_theme.dart';

class DailyQuizScreen extends ConsumerStatefulWidget {
  const DailyQuizScreen({super.key});

  @override
  ConsumerState<DailyQuizScreen> createState() => _DailyQuizScreenState();
}

class _DailyQuizScreenState extends ConsumerState<DailyQuizScreen> {
  int? _selectedOptionIndex;
  bool _isSubmitted = false;

  static const String _question = 'Mana di antara sumber nabati berikut yang mengandung zat besi paling tinggi per 100 gram?';
  static const List<String> _options = [
    'Bayam Merah',
    'Tempe Murni',
    'Kacang Kedelai Rebus',
    'Biji Labu (Pumpkin Seeds)'
  ];
  static const int _correctIndex = 3; // Biji Labu (Pumpkin Seeds) has ~8.8mg of iron per 100g, higher than bayam / tempe
  static const String _explanation = 'Biji Labu (Pumpkin Seeds) adalah salah satu superfood nabati terbaik dengan kandungan zat besi mencapai sekitar 8.8 mg per 100 gram, jauh lebih tinggi daripada bayam merah (~2.7 mg) dan tempe murni (~2.6 mg).';

  Future<void> _submitAnswer(int index) async {
    if (_isSubmitted) return;

    setState(() {
      _selectedOptionIndex = index;
      _isSubmitted = true;
    });

    final isCorrect = index == _correctIndex;
    if (isCorrect) {
      final db = ref.read(databaseProvider);
      final profile = await db.getUserProfile();
      if (profile != null) {
        await db.addPoints(profile.id, 50); // Reward +50 points
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kuis Harian'),
      ),
      body: Padding(
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
              _question,
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
                itemCount: _options.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final optionText = _options[index];
                  final isSelected = _selectedOptionIndex == index;
                  final isCorrect = index == _correctIndex;

                  Color itemColor = AppColors.surface;
                  Color borderColor = AppColors.divider;
                  Widget? suffixIcon;

                  if (_isSubmitted) {
                    if (isCorrect) {
                      itemColor = AppColors.primary.withValues(alpha: 0.08);
                      borderColor = AppColors.primary;
                      suffixIcon = const Icon(Icons.check_circle_rounded, color: AppColors.primary);
                    } else if (isSelected) {
                      itemColor = AppColors.error.withValues(alpha: 0.08);
                      borderColor = AppColors.error;
                      suffixIcon = const Icon(Icons.cancel_rounded, color: AppColors.error);
                    }
                  } else if (isSelected) {
                    borderColor = AppColors.primary;
                  }

                  return GestureDetector(
                    onTap: () => _submitAnswer(index),
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
                      _selectedOptionIndex == _correctIndex ? 'Jawaban Anda Benar! 🎉 (+50 Poin)' : 'Jawaban Kurang Tepat 😅',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _selectedOptionIndex == _correctIndex ? AppColors.primary : AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _explanation,
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
      ),
    );
  }
}
