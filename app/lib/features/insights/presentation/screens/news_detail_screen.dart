import 'package:flutter/material.dart';
import 'package:newveg/core/theme/app_theme.dart';

class NewsDetailScreen extends StatelessWidget {
  final String title;
  final String content;
  final String category;
  final String imageUrl;

  const NewsDetailScreen({
    super.key,
    required this.title,
    required this.content,
    required this.category,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Collapsible Header Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'news_image_$title',
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.surfaceVariant,
                    child: const Icon(Icons.article, size: 64, color: AppColors.primary),
                  ),
                ),
              ),
            ),
          ),
          
          // Article Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      category.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Title
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Date and Reading Time Metadata
                  const Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 16, color: AppColors.textHint),
                      SizedBox(width: 6),
                      Text(
                        '3 mnt baca • Edukasi Gizi',
                        style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 20),
                  
                  // Article body content
                  Text(
                    content,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.7,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
