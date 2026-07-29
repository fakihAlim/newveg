import 'package:flutter/material.dart' hide Badge;
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import 'package:newveg/core/database/app_database.dart';
import 'package:newveg/core/theme/app_theme.dart';

class BadgeDetailDialog extends StatelessWidget {
  final Badge badge;
  const BadgeDetailDialog({super.key, required this.badge});

  Future<void> _shareBadge(BuildContext context) async {
    final text = 'Saya baru saja membuka lencana "${badge.title}" di aplikasi diet nabati NewVeg! 🌱\n"${badge.description}"';
    // ignore: deprecated_member_use
    await Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnlocked = badge.isUnlocked;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lottie trophy / star animation
          SizedBox(
            height: 140,
            child: isUnlocked
                ? Lottie.network(
                    'https://lottie.host/e3e74127-b498-44f4-b578-ade1b1e67c58/nRPpnfNLhM.json',
                    repeat: false,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.emoji_events_rounded,
                      size: 80,
                      color: Color(0xFFFFA000),
                    ),
                  )
                : const Icon(
                    Icons.lock_rounded,
                    size: 80,
                    color: AppColors.textHint,
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            badge.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            badge.description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            isUnlocked ? 'Status: Terbuka! 🎉' : 'Status: Terkunci 🔒',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isUnlocked ? AppColors.primary : AppColors.textHint,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Tutup'),
                ),
              ),
              if (isUnlocked) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _shareBadge(context),
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: const Text('Bagikan'),
                  ),
                ),
              ]
            ],
          )
        ],
      ),
    );
  }
}
