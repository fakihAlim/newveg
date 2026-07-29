import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/onboarding_provider.dart';
import 'diet_preference_screen.dart';

/// Data class for avatar items rendered in the grid.
class _AvatarItem {
  final String key;
  final String label;
  final IconData icon;
  final Color bgColor;

  const _AvatarItem({
    required this.key,
    required this.label,
    required this.icon,
    required this.bgColor,
  });
}

/// The 8 plant/flower-themed avatars available for selection.
const _avatars = [
  _AvatarItem(
    key: 'sunflower',
    label: 'Bunga Matahari',
    icon: Icons.local_florist_rounded,
    bgColor: Color(0xFFFFF8E1),
  ),
  _AvatarItem(
    key: 'leaf',
    label: 'Daun Hijau',
    icon: Icons.eco_rounded,
    bgColor: Color(0xFFE8F5E9),
  ),
  _AvatarItem(
    key: 'tulip',
    label: 'Tulip',
    icon: Icons.filter_vintage_rounded,
    bgColor: Color(0xFFFCE4EC),
  ),
  _AvatarItem(
    key: 'tree',
    label: 'Pohon',
    icon: Icons.park_rounded,
    bgColor: Color(0xFFE0F2F1),
  ),
  _AvatarItem(
    key: 'sprout',
    label: 'Kecambah',
    icon: Icons.grass_rounded,
    bgColor: Color(0xFFF1F8E9),
  ),
  _AvatarItem(
    key: 'cactus',
    label: 'Kaktus',
    icon: Icons.yard_rounded,
    bgColor: Color(0xFFF3E5F5),
  ),
  _AvatarItem(
    key: 'forest',
    label: 'Hutan',
    icon: Icons.forest_rounded,
    bgColor: Color(0xFFE8EAF6),
  ),
  _AvatarItem(
    key: 'herb',
    label: 'Herbal',
    icon: Icons.spa_rounded,
    bgColor: Color(0xFFFFF3E0),
  ),
];

/// Screen 2: Grid-based avatar selection with animated selection indicator.
class AvatarSelectionScreen extends ConsumerStatefulWidget {
  const AvatarSelectionScreen({super.key});

  @override
  ConsumerState<AvatarSelectionScreen> createState() =>
      _AvatarSelectionScreenState();
}

class _AvatarSelectionScreenState extends ConsumerState<AvatarSelectionScreen>
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
    if (!state.isAvatarSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih avatar terlebih dahulu'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    ref.read(onboardingProvider.notifier).setCurrentStep(2);
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const DietPreferenceScreen(),
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
    final selectedAvatar = ref.watch(onboardingProvider).avatarPath;
    final notifier = ref.read(onboardingProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Pilih Avatar'),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              // -- Step indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: _StepIndicator(currentStep: 1),
              ),
              const SizedBox(height: 8),

              // -- Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilih Avatar Anda',
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pilih ikon tanaman favorit sebagai avatar profil Anda.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // -- Avatar grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _avatars.length,
                  itemBuilder: (context, index) {
                    final avatar = _avatars[index];
                    final isSelected = selectedAvatar == avatar.key;
                    return _AvatarCard(
                      avatar: avatar,
                      isSelected: isSelected,
                      onTap: () => notifier.setAvatar(avatar.key),
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
                        Text('Lanjut ke Preferensi Diet'),
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

class _AvatarCard extends StatelessWidget {
  final _AvatarItem avatar;
  final bool isSelected;
  final VoidCallback onTap;

  const _AvatarCard({
    required this.avatar,
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
        decoration: BoxDecoration(
          color: avatar.bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: isSelected ? 3 : 0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedScale(
                    scale: isSelected ? 1.15 : 1.0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      avatar.icon,
                      size: 52,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    avatar.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            // -- Check badge
            if (isSelected)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
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
