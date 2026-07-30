import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newveg/core/theme/app_theme.dart';
import 'package:newveg/core/services/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newveg/features/auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  late SharedPreferences _prefs;
  bool _loading = true;

  // Meal Alarm States
  bool _breakfastEnabled = false;
  TimeOfDay _breakfastTime = const TimeOfDay(hour: 7, minute: 0);

  bool _lunchEnabled = false;
  TimeOfDay _lunchTime = const TimeOfDay(hour: 12, minute: 0);

  bool _dinnerEnabled = false;
  TimeOfDay _dinnerTime = const TimeOfDay(hour: 18, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _breakfastEnabled = _prefs.getBool('alarm_breakfast_enabled') ?? false;
      final bfStr = _prefs.getString('alarm_breakfast_time') ?? "07:00";
      _breakfastTime = _parseTimeOfDay(bfStr);

      _lunchEnabled = _prefs.getBool('alarm_lunch_enabled') ?? false;
      final lhStr = _prefs.getString('alarm_lunch_time') ?? "12:00";
      _lunchTime = _parseTimeOfDay(lhStr);

      _dinnerEnabled = _prefs.getBool('alarm_dinner_enabled') ?? false;
      final dnStr = _prefs.getString('alarm_dinner_time') ?? "18:00";
      _dinnerTime = _parseTimeOfDay(dnStr);

      _loading = false;
    });
  }

  TimeOfDay _parseTimeOfDay(String timeStr) {
    final parts = timeStr.split(":");
    if (parts.length == 2) {
      return TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 0,
        minute: int.tryParse(parts[1]) ?? 0,
      );
    }
    return const TimeOfDay(hour: 8, minute: 0);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  Future<void> _updateAlarm({
    required String mealKey,
    required bool enabled,
    required TimeOfDay time,
    required int notificationId,
    required String title,
    required String body,
  }) async {
    // If enabling, request runtime permissions first
    if (enabled) {
      final granted = await _notificationService.requestPermissions();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Izin notifikasi ditolak. Silakan aktifkan izin notifikasi di pengaturan perangkat Anda.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        setState(() {
          if (mealKey == 'breakfast') _breakfastEnabled = false;
          if (mealKey == 'lunch') _lunchEnabled = false;
          if (mealKey == 'dinner') _dinnerEnabled = false;
        });
        return;
      }
    }

    // Persist to SharedPreferences
    await _prefs.setBool('alarm_${mealKey}_enabled', enabled);
    await _prefs.setString('alarm_${mealKey}_time', _formatTimeOfDay(time));

    // Handle Local Notification schedule/cancel
    if (enabled) {
      await _notificationService.scheduleDailyNotification(
        id: notificationId,
        title: title,
        body: body,
        hour: time.hour,
        minute: time.minute,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Alarm $title aktif pukul ${_formatTimeOfDay(time)}'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      await _notificationService.cancelNotification(notificationId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Alarm $title dinonaktifkan'),
            backgroundColor: AppColors.textSecondary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _selectTime(BuildContext context, String mealKey) async {
    TimeOfDay initialTime = const TimeOfDay(hour: 8, minute: 0);
    if (mealKey == 'breakfast') initialTime = _breakfastTime;
    if (mealKey == 'lunch') initialTime = _lunchTime;
    if (mealKey == 'dinner') initialTime = _dinnerTime;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (mealKey == 'breakfast') {
          _breakfastTime = picked;
          if (_breakfastEnabled) {
            _updateAlarm(
              mealKey: 'breakfast',
              enabled: true,
              time: _breakfastTime,
              notificationId: 101,
              title: 'Sarapan Sehat 🥞',
              body: 'Saatnya menikmati menu sarapan nabati Anda hari ini!',
            );
          } else {
            _prefs.setString('alarm_breakfast_time', _formatTimeOfDay(_breakfastTime));
          }
        } else if (mealKey == 'lunch') {
          _lunchTime = picked;
          if (_lunchEnabled) {
            _updateAlarm(
              mealKey: 'lunch',
              enabled: true,
              time: _lunchTime,
              notificationId: 102,
              title: 'Makan Siang Nabati 🥗',
              body: 'Yuk konsumsi makan siang kaya protein nabati Anda!',
            );
          } else {
            _prefs.setString('alarm_lunch_time', _formatTimeOfDay(_lunchTime));
          }
        } else if (mealKey == 'dinner') {
          _dinnerTime = picked;
          if (_dinnerEnabled) {
            _updateAlarm(
              mealKey: 'dinner',
              enabled: true,
              time: _dinnerTime,
              notificationId: 103,
              title: 'Makan Malam Sehat 🍲',
              body: 'Waktunya makan malam seimbang. Catat log makan Anda ya!',
            );
          } else {
            _prefs.setString('alarm_dinner_time', _formatTimeOfDay(_dinnerTime));
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Alarm Makan'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jadwal & Alarm Pengingat',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aktifkan pengingat harian agar pola makan nabati Anda tetap konsisten dan terjaga.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),

                  // -- Breakfast Card
                  _buildMealAlarmCard(
                    title: 'Sarapan Pagi',
                    subtitle: 'Pengingat makan pagi sehat',
                    icon: Icons.wb_sunny_rounded,
                    iconColor: const Color(0xFFFFB300),
                    enabled: _breakfastEnabled,
                    time: _breakfastTime,
                    onToggle: (val) {
                      setState(() {
                        _breakfastEnabled = val;
                      });
                      _updateAlarm(
                        mealKey: 'breakfast',
                        enabled: val,
                        time: _breakfastTime,
                        notificationId: 101,
                        title: 'Sarapan Sehat 🥞',
                        body: 'Saatnya menikmati menu sarapan nabati Anda hari ini!',
                      );
                    },
                    onTimeTap: () => _selectTime(context, 'breakfast'),
                  ),

                  const SizedBox(height: 16),

                  // -- Lunch Card
                  _buildMealAlarmCard(
                    title: 'Makan Siang',
                    subtitle: 'Pengingat makan siang bergizi',
                    icon: Icons.wb_cloudy_rounded,
                    iconColor: const Color(0xFF1E88E5),
                    enabled: _lunchEnabled,
                    time: _lunchTime,
                    onToggle: (val) {
                      setState(() {
                        _lunchEnabled = val;
                      });
                      _updateAlarm(
                        mealKey: 'lunch',
                        enabled: val,
                        time: _lunchTime,
                        notificationId: 102,
                        title: 'Makan Siang Nabati 🥗',
                        body: 'Yuk konsumsi makan siang kaya protein nabati Anda!',
                      );
                    },
                    onTimeTap: () => _selectTime(context, 'lunch'),
                  ),

                  const SizedBox(height: 16),

                  // -- Dinner Card
                  _buildMealAlarmCard(
                    title: 'Makan Malam',
                    subtitle: 'Pengingat makan malam seimbang',
                    icon: Icons.nightlight_round_rounded,
                    iconColor: const Color(0xFF5E35B1),
                    enabled: _dinnerEnabled,
                    time: _dinnerTime,
                    onToggle: (val) {
                      setState(() {
                        _dinnerEnabled = val;
                      });
                      _updateAlarm(
                        mealKey: 'dinner',
                        enabled: val,
                        time: _dinnerTime,
                        notificationId: 103,
                        title: 'Makan Malam Sehat 🍲',
                        body: 'Waktunya makan malam seimbang. Catat log makan Anda ya!',
                      );
                    },
                    onTimeTap: () => _selectTime(context, 'dinner'),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Info Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Aplikasi akan mengirimkan notifikasi pengingat tepat waktu setiap hari sesuai jadwal di atas.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => _confirmDeleteAccount(context),
                      child: const Text('Hapus Akun Saya', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMealAlarmCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool enabled,
    required TimeOfDay time,
    required ValueChanged<bool> onToggle,
    required VoidCallback onTimeTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: enabled,
                  onChanged: onToggle,
                  activeThumbColor: AppColors.primary,
                ),
              ],
            ),
            if (enabled) ...[
              const Divider(height: 24),
              InkWell(
                onTap: onTimeTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Waktu Alarm',
                        style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                      ),
                      Row(
                        children: [
                          Text(
                            _formatTimeOfDay(time),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.keyboard_arrow_right_rounded, color: AppColors.primary, size: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Akun Permanen ⚠️'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus akun Anda secara permanen? Semua data pribadi, log makanan, riwayat poin, dan postingan komunitas Anda akan dihapus dari server kami dan tidak dapat dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(context); // Close confirm dialog
              
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );

              final success = await ref.read(authProvider.notifier).deleteAccount();

              if (context.mounted) {
                Navigator.pop(context); // Close loading
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Akun Anda berhasil dihapus.'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                  Navigator.of(context).popUntil((route) => route.isFirst);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gagal menghapus akun.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Hapus Akun', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
