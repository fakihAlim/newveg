import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/onboarding_provider.dart';
import 'avatar_selection_screen.dart';

/// Screen 1: Collects gender, age, height, and weight.
class ProfileInputScreen extends ConsumerStatefulWidget {
  const ProfileInputScreen({super.key});

  @override
  ConsumerState<ProfileInputScreen> createState() => _ProfileInputScreenState();
}

class _ProfileInputScreenState extends ConsumerState<ProfileInputScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(onboardingProvider.notifier);
    final state = ref.read(onboardingProvider);

    if (state.gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih jenis kelamin terlebih dahulu'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    notifier.setAge(int.parse(_ageController.text.trim()));
    notifier.setHeight(double.parse(_heightController.text.trim()));
    notifier.setWeight(double.parse(_weightController.text.trim()));
    notifier.setCurrentStep(1);

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const AvatarSelectionScreen(),
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
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // -- Step indicator
                  _StepIndicator(currentStep: 0),
                  const SizedBox(height: 28),

                  // -- Title
                  Text('Profil Anda', style: theme.textTheme.headlineLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Lengkapi data berikut untuk memulai perjalanan pola makan nabati Anda.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),

                  // -- Gender selector
                  Text('Jenis Kelamin', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _GenderButton(
                          label: 'Pria',
                          icon: Icons.male_rounded,
                          isSelected: state.gender == 'Pria',
                          onTap: () => notifier.setGender('Pria'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _GenderButton(
                          label: 'Wanita',
                          icon: Icons.female_rounded,
                          isSelected: state.gender == 'Wanita',
                          onTap: () => notifier.setGender('Wanita'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // -- Age
                  TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Usia',
                      hintText: 'Masukkan usia Anda',
                      suffixText: 'tahun',
                      prefixIcon: Icon(Icons.cake_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Usia wajib diisi';
                      final age = int.tryParse(v.trim());
                      if (age == null || age < 10 || age > 120) {
                        return 'Masukkan usia yang valid (10-120)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // -- Height
                  TextFormField(
                    controller: _heightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Tinggi Badan',
                      hintText: 'Masukkan tinggi badan',
                      suffixText: 'cm',
                      prefixIcon: Icon(Icons.height_rounded),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Tinggi badan wajib diisi';
                      final h = double.tryParse(v.trim());
                      if (h == null || h < 50 || h > 250) {
                        return 'Masukkan tinggi yang valid (50-250 cm)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // -- Weight
                  TextFormField(
                    controller: _weightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Berat Badan',
                      hintText: 'Masukkan berat badan',
                      suffixText: 'kg',
                      prefixIcon: Icon(Icons.monitor_weight_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Berat badan wajib diisi';
                      final w = double.tryParse(v.trim());
                      if (w == null || w < 20 || w > 300) {
                        return 'Masukkan berat yang valid (20-300 kg)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),

                  // -- Next button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Lanjut Pilih Avatar'),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets
// ---------------------------------------------------------------------------

/// Gender selector button with animated active state.
class _GenderButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: Material(
        color: isSelected ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        elevation: isSelected ? 4 : 1,
        shadowColor: AppColors.cardShadow,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.divider,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 36,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
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
