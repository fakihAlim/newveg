import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../dashboard/presentation/screens/navigation_wrapper.dart';
import '../providers/onboarding_provider.dart';

/// Screen 4: Interactive TTM Questionnaire.
///
/// Questions are sourced from [ttmQuestionsProvider] which currently returns
/// default local questions but is designed to be swapped with server-fetched
/// data in the future.
class TtmQuestionnaireScreen extends ConsumerStatefulWidget {
  const TtmQuestionnaireScreen({super.key});

  @override
  ConsumerState<TtmQuestionnaireScreen> createState() =>
      _TtmQuestionnaireScreenState();
}

class _TtmQuestionnaireScreenState
    extends ConsumerState<TtmQuestionnaireScreen>
    with SingleTickerProviderStateMixin {
  /// Stores the selected score for each question, keyed by question index.
  final Map<int, int> _answers = {};
  int _currentQuestionIndex = 0;
  bool _isSaving = false;

  late AnimationController _animController;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _selectAnswer(int questionIndex, int score) {
    setState(() {
      _answers[questionIndex] = score;
    });
  }

  void _goToNextQuestion(int totalQuestions) {
    if (_currentQuestionIndex < totalQuestions - 1) {
      _animController.reset();
      setState(() {
        _currentQuestionIndex++;
      });
      _animController.forward();
    }
  }

  void _goToPreviousQuestion() {
    if (_currentQuestionIndex > 0) {
      _animController.reset();
      setState(() {
        _currentQuestionIndex--;
      });
      _animController.forward();
    }
  }

  Future<void> _onSubmit(List<TtmQuestion> questions) async {
    // Validate all questions answered
    if (_answers.length < questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan jawab semua pertanyaan terlebih dahulu'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Calculate total score and determine TTM stage
      final totalScore = _answers.values.fold<int>(0, (sum, v) => sum + v);
      final stage = determineTtmStage(totalScore);

      final notifier = ref.read(onboardingProvider.notifier);
      notifier.setTtmStage(stage);

      // Save profile to SQLite
      await notifier.saveProfile();

      if (!mounted) return;

      // Navigate to dashboard navigation wrapper, clearing the onboarding stack
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => NavigationWrapper(initialTtmStage: stage),
        ),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan profil: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final questions = ref.watch(ttmQuestionsProvider);
    final theme = Theme.of(context);
    final currentQuestion = questions[_currentQuestionIndex];
    final isLastQuestion = _currentQuestionIndex == questions.length - 1;
    final currentAnswer = _answers[_currentQuestionIndex];
    final allAnswered = _answers.length == questions.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _currentQuestionIndex > 0
              ? _goToPreviousQuestion
              : () => Navigator.of(context).pop(),
        ),
        title: const Text('Kuesioner TTM'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // -- Step indicator (step 4 of onboarding)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: _StepIndicator(currentStep: 3),
            ),
            const SizedBox(height: 4),

            // -- Question progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'Pertanyaan ${_currentQuestionIndex + 1}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    ' / ${questions.length}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // -- Question progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / questions.length,
                  backgroundColor: AppColors.divider,
                  color: AppColors.primary,
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // -- Question & options
            Expanded(
              child: FadeTransition(
                opacity: _slideAnim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0),
                    end: Offset.zero,
                  ).animate(_slideAnim),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question text
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.help_outline_rounded,
                                color: AppColors.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  currentQuestion.text,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    height: 1.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Options
                        ...List.generate(currentQuestion.options.length, (i) {
                          final option = currentQuestion.options[i];
                          final isSelected = currentAnswer == option.score;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _OptionTile(
                              label: option.label,
                              index: i,
                              isSelected: isSelected,
                              onTap: () => _selectAnswer(
                                  _currentQuestionIndex, option.score),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // -- Bottom navigation
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Row(
                children: [
                  // Previous button
                  if (_currentQuestionIndex > 0)
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: _goToPreviousQuestion,
                          icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          label: const Text('Sebelumnya'),
                        ),
                      ),
                    ),
                  if (_currentQuestionIndex > 0) const SizedBox(width: 12),

                  // Next / Submit button
                  Expanded(
                    flex: _currentQuestionIndex > 0 ? 1 : 1,
                    child: SizedBox(
                      height: 52,
                      child: isLastQuestion
                          ? ElevatedButton(
                              onPressed: _isSaving
                                  ? null
                                  : (allAnswered
                                      ? () => _onSubmit(questions)
                                      : null),
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('Simpan & Lanjut'),
                                        SizedBox(width: 8),
                                        Icon(Icons.check_circle_outline_rounded,
                                            size: 20),
                                      ],
                                    ),
                            )
                          : ElevatedButton(
                              onPressed: currentAnswer != null
                                  ? () => _goToNextQuestion(questions.length)
                                  : null,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Selanjutnya'),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, size: 20),
                                ],
                              ),
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

// ---------------------------------------------------------------------------
// Widgets
// ---------------------------------------------------------------------------

class _OptionTile extends StatelessWidget {
  final String label;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  static const _letters = ['A', 'B', 'C', 'D', 'E'];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Letter badge
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  _letters[index],
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color:
                      isSelected ? AppColors.primary : AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}

/// Horizontal step indicator showing 4 onboarding steps.
class _StepIndicator extends StatelessWidget {
  final int currentStep;

  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (index) {
        final isActive = index <= currentStep;
        final isCurrent = index == currentStep;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: isActive
                  ? (isCurrent ? AppColors.primary : AppColors.primaryLight)
                  : AppColors.divider,
            ),
          ),
        );
      }),
    );
  }
}
