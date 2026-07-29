import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/onboarding_provider.dart';
import 'ttm_questionnaire_screen.dart';

/// Data model for a diet option card.
class _DietOption {
  final String key;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;

  const _DietOption({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });
}

const _dietOptions = [
  _DietOption(
    key: 'Strict Vegan',
    title: 'Strict Vegan',
    subtitle: '100% berbasis nabati — tanpa produk hewani sama sekali.',
    icon: Icons.eco_rounded,
    accentColor: Color(0xFF2E7D32),
  ),
  _DietOption(
    key: 'Lacto-Ovo Vegetarian',
    title: 'Lacto-Ovo Vegetarian',
    subtitle: 'Nabati + telur & produk susu. Tanpa daging dan ikan.',
    icon: Icons.egg_alt_rounded,
    accentColor: Color(0xFFFF8F00),
  ),
  _DietOption(
    key: 'Ovo-Vegetarian',
    title: 'Ovo-Vegetarian',
    subtitle: 'Nabati + telur. Tanpa daging, ikan, dan produk susu.',
    icon: Icons.egg_rounded,
    accentColor: Color(0xFF5C6BC0),
  ),
  _DietOption(
    key: 'Flexitarian',
    title: 'Flexitarian',
    subtitle: 'Tahap transisi — sebagian besar nabati dengan sedikit hewani.',
    icon: Icons.swap_horiz_rounded,
    accentColor: Color(0xFF00897B),
  ),
];

/// Screen 3: Diet preference selector with descriptive cards.
class DietPreferenceScreen extends ConsumerStatefulWidget {
  const DietPreferenceScreen({super.key});

  @override
  ConsumerState<DietPreferenceScreen> createState() =>
      _DietPreferenceScreenState();
}

class _DietPreferenceScreenState extends ConsumerState<DietPreferenceScreen>
    with SingleTickerProviderStateMixin {
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
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onNext() {
    final state = ref.read(onboardingProvider);
    if (!state.isDietSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih preferensi diet terlebih dahulu'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    ref.read(onboardingProvider.notifier).setCurrentStep(3);
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const TtmQuestionnaireScreen(),
        transitionsBuilder: (_, anim, _, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeInOut)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedDiet = ref.watch(onboardingProvider).dietPreference;
    final notifier = ref.read(onboardingProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Preferensi Diet'),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              // -- Step indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: _StepIndicator(currentStep: 2),
              ),
              const SizedBox(height: 8),

              // -- Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preferensi Diet Anda',
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pilih tingkat toleransi pola makan berbasis nabati yang sesuai dengan Anda.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // -- Diet options
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _dietOptions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final option = _dietOptions[index];
                    final isSelected = selectedDiet == option.key;
                    return _DietCard(
                      option: option,
                      isSelected: isSelected,
                      onTap: () => notifier.setDietPreference(option.key),
                    );
                  },
                ),
              ),

              // -- Bottom button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _onNext,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Mulai Kuesioner Tahap TTM'),
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
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets
// ---------------------------------------------------------------------------

class _DietCard extends StatelessWidget {
  final _DietOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _DietCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? option.accentColor.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? option.accentColor : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: option.accentColor.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Icon container
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected
                    ? option.accentColor.withValues(alpha: 0.15)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                option.icon,
                size: 28,
                color: isSelected ? option.accentColor : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 16),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? option.accentColor
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    option.subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Check indicator
            if (isSelected)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: option.accentColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
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
