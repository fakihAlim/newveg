import 'package:flutter/material';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newveg/core/theme/app_theme.dart';
import 'package:newveg/features/auth/presentation/providers/auth_provider.dart';
import 'package:newveg/features/auth/presentation/screens/login_screen.dart';
import 'package:newveg/features/onboarding/presentation/screens/profile_input_screen.dart';
import 'package:newveg/features/dashboard/presentation/screens/navigation_wrapper.dart';

/// Gatekeeper component validating credentials and navigating to onboarding or dashboard
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (!authState.isAuthenticated) {
      return const LoginScreen();
    }

    final profile = authState.profile;
    
    // If user has authenticated but demographic details are not set yet, route to Onboarding
    if (profile == null || profile.gender == null || profile.height == null) {
      return const ProfileInputScreen();
    }

    // Fully authenticated and onboarded -> Dashboard
    return NavigationWrapper(initialTtmStage: profile.ttmStage ?? 'Precontemplation');
  }
}
