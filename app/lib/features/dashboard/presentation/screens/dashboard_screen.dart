import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import '../../../../core/database/database_provider.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../food_log/presentation/providers/food_log_provider.dart';
import '../../../discover/presentation/screens/discover_screen.dart';
import '../../../profile/presentation/screens/settings_screen.dart';
import '../../../community/presentation/widgets/share_log_dialog.dart';

/// Active date state provider for horizontal calendar filtering
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

class DashboardScreen extends ConsumerStatefulWidget {
  final String ttmStage;

  const DashboardScreen({super.key, required this.ttmStage});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  // Hardcoded daily target values for nutrition progress
  static const double calorieTarget = 2000.0;
  static const double carbTarget = 250.0;
  static const double fatTarget = 70.0;
  static const double proteinTarget = 65.0;

  // Daily plant-based inspiration quotes list
  static const List<String> _inspirationQuotes = [
    "Pola makan nabati bukan hanya tentang apa yang Anda kurangi, tetapi tentang kehidupan yang Anda tambahkan. 🌿",
    "Setiap suapan makanan berbasis nabati adalah investasi terbaik bagi kesehatan tubuh dan kelestarian bumi kita. 🌍",
    "Mulailah dari hal kecil. Satu piring nabati hari ini membawa perubahan besar untuk esok hari. 🌱",
    "Kesehatan sejati berakar dari alam. Nikmati kesegaran dan energi dari tumbuhan utuh setiap hari. 🌸",
    "Menyayangi diri sendiri dimulai dari apa yang kita konsumsi. Pilihlah nutrisi terbaik dari alam. 🥕"
  ];

  String _getDailyQuote() {
    final day = DateTime.now().day;
    return _inspirationQuotes[day % _inspirationQuotes.length];
  }


  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final theme = Theme.of(context);

    // Watch food logs specifically for the selected date
    final foodLogsFuture = ref.watch(foodLogsByDateProvider(selectedDate));

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<UserProfile?>(
          future: db.getUserProfile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            final profile = snapshot.data;
            if (profile == null) {
              return const Center(child: Text('Profil tidak ditemukan.'));
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(selectedDateProvider);
                ref.invalidate(todayFoodLogsProvider);
              },
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // -- Header Greeting & Settings
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${profile.gender == "Pria" ? "Bro" : "Sis"} 👋',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Tahap TTM: ${profile.ttmStage}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // -- Horizontal Date Selector
                    _HorizontalCalendar(),
                    const SizedBox(height: 24),

                    // -- Daily Nutrition Progress (calculated against target)
                    foodLogsFuture.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                      error: (err, _) => Text('Error loading stats: $err'),
                      data: (logs) {
                        double totalCalories = 0;
                        double totalCarbs = 0;
                        double totalFats = 0;
                        double totalProtein = 0;

                        for (final log in logs) {
                          totalCalories += log.calories;
                          totalCarbs += log.carbs;
                          totalFats += log.fats;
                          totalProtein += log.protein;
                        }

                        return _NutritionSummaryCard(
                          calories: totalCalories,
                          carbs: totalCarbs,
                          fats: totalFats,
                          protein: totalProtein,
                          calorieTarget: calorieTarget,
                          carbTarget: carbTarget,
                          fatTarget: fatTarget,
                          proteinTarget: proteinTarget,
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // -- Inspiration Card
                    _InspirationQuoteCard(quote: _getDailyQuote()),
                    const SizedBox(height: 16),

                    // -- Quests & Quiz Banner
                    Card(
                      elevation: 0,
                      color: AppColors.primary.withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: AppColors.primary, width: 1),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const DiscoverScreen()),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.star_rounded, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Misi Harian & Kuis',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: AppColors.primaryDark,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      'Selesaikan misi gizi dan dapatkan koin!',
                                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    )
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primary, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // -- Daily Food Log List header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Log Makanan Harian',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat('d MMMM yyyy').format(selectedDate),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // -- Daily Food Log List
                    foodLogsFuture.when(
                      loading: () => const SizedBox(),
                      error: (err, _) => const SizedBox(),
                      data: (logs) {
                        if (logs.isEmpty) {
                          return _buildEmptyState(theme);
                        }
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: logs.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final log = logs[index];
                            return _FoodLogListItem(log: log);
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_outlined,
            size: 48,
            color: AppColors.textHint.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada makanan yang dicatat',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Gunakan kamera untuk memindai hidangan Anda.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Date logs provider
// ---------------------------------------------------------------------------
final foodLogsByDateProvider =
    FutureProvider.family<List<FoodLog>, DateTime>((ref, date) {
  final db = ref.watch(databaseProvider);
  return db.getFoodLogsByDate(date);
});

// ---------------------------------------------------------------------------
// Horizontal Calendar Selector Widget
// ---------------------------------------------------------------------------
class _HorizontalCalendar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final today = DateTime.now();

    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14, // Past 7 days and next 6 days
        itemBuilder: (context, index) {
          final date = today.subtract(Duration(days: 7 - index));
          final isSelected = date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;

          return GestureDetector(
            onTap: () {
              ref.read(selectedDateProvider.notifier).state = date;
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              width: 55,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.divider,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date).toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white.withValues(alpha: 0.8) : AppColors.textHint,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('d').format(date),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Nutrition Progress Card Widget
// ---------------------------------------------------------------------------
class _NutritionSummaryCard extends StatelessWidget {
  final double calories;
  final double carbs;
  final double fats;
  final double protein;

  final double calorieTarget;
  final double carbTarget;
  final double fatTarget;
  final double proteinTarget;

  const _NutritionSummaryCard({
    required this.calories,
    required this.carbs,
    required this.fats,
    required this.protein,
    required this.calorieTarget,
    required this.carbTarget,
    required this.fatTarget,
    required this.proteinTarget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final caloriePercent = (calories / calorieTarget).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nutrisi Harian', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              // Circular progress for Calories
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CircularProgressIndicator(
                      value: caloriePercent,
                      strokeWidth: 8,
                      backgroundColor: AppColors.surfaceVariant,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${calories.toInt()}',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '/${calorieTarget.toInt()} kkal',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(width: 24),
              // Linear bar progress for Macros (Carbs, Fats, Protein)
              Expanded(
                child: Column(
                  children: [
                    _MacroProgressBar(
                      label: 'Karbohidrat',
                      current: carbs,
                      target: carbTarget,
                      color: const Color(0xFFFFB74D),
                    ),
                    const SizedBox(height: 10),
                    _MacroProgressBar(
                      label: 'Lemak',
                      current: fats,
                      target: fatTarget,
                      color: const Color(0xFF4FC3F7),
                    ),
                    const SizedBox(height: 10),
                    _MacroProgressBar(
                      label: 'Protein',
                      current: protein,
                      target: proteinTarget,
                      color: const Color(0xFF81C784),
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class _MacroProgressBar extends StatelessWidget {
  final String label;
  final double current;
  final double target;
  final Color color;

  const _MacroProgressBar({
    required this.label,
    required this.current,
    required this.target,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (current / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            Text('${current.toInt()}/${target.toInt()}g', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 6,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        )
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Inspiration Quote Card Widget
// ---------------------------------------------------------------------------
class _InspirationQuoteCard extends StatelessWidget {
  final String quote;
  const _InspirationQuoteCard({required this.quote});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.format_quote_rounded, color: AppColors.primary, size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              quote,
              style: const TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: AppColors.primaryDark,
                height: 1.5,
              ),
            ),
          )
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Food Log List Item Widget
// ---------------------------------------------------------------------------
class _FoodLogListItem extends ConsumerWidget {
  final FoodLog log;
  const _FoodLogListItem({required this.log});

  void _showShareDialog(BuildContext context, WidgetRef ref, int foodLogId) {
    showDialog(
      context: context,
      builder: (context) => ShareLogDialog(foodLogId: foodLogId),
    );
  }

  void _showLogDetail(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              
              // Food Photo
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: log.imagePath.startsWith('/') || log.imagePath.contains(':') || log.imagePath.contains('\\')
                    ? Image.file(
                        File(log.imagePath),
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                      )
                    : _buildImagePlaceholder(),
              ),
              const SizedBox(height: 20),
              
              // Food Name & Type
              Text(
                log.foodName,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Kategori: ${log.mealType}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              
              // Points Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: log.isPlantBased
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  log.isPlantBased ? 'Sesuai Diet (🌿 +${log.pointsEarned} Pts)' : 'Tidak Sesuai (⚠️ -${log.pointsEarned.abs()} Pts)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: log.isPlantBased ? AppColors.primary : AppColors.error,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Macros Breakdown
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
                    _MacroDetailItem(
                      label: 'Kalori',
                      value: '${log.calories.toInt()} kkal',
                      color: const Color(0xFFFF7043),
                    ),
                    _MacroDetailItem(
                      label: 'Karbo',
                      value: '${log.carbs.toInt()} g',
                      color: const Color(0xFFFFB74D),
                    ),
                    _MacroDetailItem(
                      label: 'Lemak',
                      value: '${log.fats.toInt()} g',
                      color: const Color(0xFF4FC3F7),
                    ),
                    _MacroDetailItem(
                      label: 'Protein',
                      value: '${log.protein.toInt()} g',
                      color: const Color(0xFF81C784),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Actions
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Tutup'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.share_rounded, size: 18),
                        onPressed: () {
                          Navigator.pop(context); // Close bottom sheet
                          _showShareDialog(context, ref, log.id);
                        },
                        label: const Text('Bagikan'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 220,
      color: AppColors.surfaceVariant,
      child: const Icon(Icons.restaurant_rounded, size: 64, color: AppColors.primary),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompliant = log.isPlantBased;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showLogDetail(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: log.imagePath.startsWith('/') || log.imagePath.contains(':') || log.imagePath.contains('\\')
                    ? Image.file(
                        File(log.imagePath),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _buildPlaceholderIcon(),
                      )
                    : _buildPlaceholderIcon(),
              ),
              const SizedBox(width: 12),
              // Food details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.foodName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${log.calories.toInt()} kkal · C: ${log.carbs.toInt()}g P: ${log.protein.toInt()}g F: ${log.fats.toInt()}g',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Compliant status badge & points
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCompliant
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isCompliant ? '+50 Pts' : '-20 Pts',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isCompliant ? AppColors.primary : AppColors.error,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    log.mealType,
                    style: const TextStyle(fontSize: 11, color: AppColors.textHint),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      width: 50,
      height: 50,
      color: AppColors.surfaceVariant,
      child: const Icon(Icons.restaurant_rounded, color: AppColors.primary, size: 24),
    );
  }
}

class _MacroDetailItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroDetailItem({
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
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textHint),
        ),
      ],
    );
  }
}
