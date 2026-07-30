import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/community_provider.dart';

class ShareLogDialog extends ConsumerStatefulWidget {
  final int foodLogId;
  const ShareLogDialog({super.key, required this.foodLogId});

  @override
  ConsumerState<ShareLogDialog> createState() => _ShareLogDialogState();
}

class _ShareLogDialogState extends ConsumerState<ShareLogDialog> {
  final _textController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    final caption = _textController.text.trim();
    
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await ref
          .read(communityFeedProvider.notifier)
          .shareFoodLog(widget.foodLogId, caption);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Berhasil dibagikan ke Feed Komunitas!'),
              backgroundColor: AppColors.primary,
            ),
          );
          Navigator.pop(context, true); // Close dialog on success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal membagikan postingan.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Bagikan ke Komunitas 🌿'),
      content: _isLoading
          ? const SizedBox(
              height: 120,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tulis caption menarik untuk postingan makan sehat Anda:',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _textController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Makan siang sehat hari ini... 🥑',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
      actions: _isLoading
          ? null
          : [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: _share,
                child: const Text('Kirim'),
              ),
            ],
    );
  }
}
