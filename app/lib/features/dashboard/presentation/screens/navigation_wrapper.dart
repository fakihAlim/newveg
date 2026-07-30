import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newveg/core/theme/app_theme.dart';
import 'package:newveg/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:newveg/features/insights/presentation/screens/insights_screen.dart';
import 'package:newveg/features/food_log/presentation/screens/add_food_log_screen.dart';

import 'package:newveg/features/community/presentation/screens/community_screen.dart';
import 'package:newveg/features/profile/presentation/screens/profile_screen.dart';

/// Main navigation container managing the bottom bar tabs.
class NavigationWrapper extends ConsumerStatefulWidget {
  final String initialTtmStage;
  const NavigationWrapper({super.key, required this.initialTtmStage});

  @override
  ConsumerState<NavigationWrapper> createState() => _NavigationWrapperState();
}

final navigationIndexProvider = StateProvider<int>((ref) => 0);

class _NavigationWrapperState extends ConsumerState<NavigationWrapper> {
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(ttmStage: widget.initialTtmStage),
      const InsightsScreen(),
      const AddFoodLogScreen(),
      const CommunityScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            ref.read(navigationIndexProvider.notifier).state = index;
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textHint,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.lightbulb_outline_rounded),
              activeIcon: Icon(Icons.lightbulb_rounded),
              label: 'Insights',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt_outlined),
              activeIcon: Icon(Icons.camera_alt_rounded),
              label: 'Kamera',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline_rounded),
              activeIcon: Icon(Icons.people_rounded),
              label: 'Komunitas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
