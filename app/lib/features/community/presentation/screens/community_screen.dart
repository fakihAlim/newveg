import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:newveg/core/theme/app_theme.dart';
import 'package:newveg/features/community/presentation/screens/create_group_dialog.dart';
import 'package:newveg/features/community/presentation/providers/community_provider.dart';
import 'package:newveg/features/community/presentation/screens/comments_bottom_sheet.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _joinedGroups = ['Pejuang Nabati ITB', 'Vegenian Bandung'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openCreateGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateGroupDialog(
        onCreate: (groupName) {
          setState(() {
            _joinedGroups.add(groupName);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Grup "$groupName" berhasil dibuat! 🎉')),
          );
        },
      ),
    );
  }

  void _openJoinGroupDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gabung Grup'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Kode Grup',
            hintText: 'Masukkan 6 digit kode',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _joinedGroups.add('Grup Baru #${controller.text.trim().toUpperCase()}');
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Berhasil gabung ke grup! 🎉')),
                );
              }
            },
            child: const Text('Gabung'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Komunitas & Grup'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Discover'),
            Tab(text: 'Grup Saya'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _DiscoverFeedTab(),
          _GrupSayaTab(
            groups: _joinedGroups,
            onCreatePressed: _openCreateGroupDialog,
            onJoinPressed: _openJoinGroupDialog,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 1: Discover Feed
// ---------------------------------------------------------------------------
class _DiscoverFeedTab extends ConsumerStatefulWidget {
  const _DiscoverFeedTab();

  @override
  ConsumerState<_DiscoverFeedTab> createState() => _DiscoverFeedTabState();
}

class _DiscoverFeedTabState extends ConsumerState<_DiscoverFeedTab> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(communityFeedProvider.notifier).fetchFeed();
    }
  }

  void _showComments(int postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: CommentsBottomSheet(postId: postId),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(communityFeedProvider);
    final theme = Theme.of(context);

    if (state.posts.isEmpty && state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (state.posts.isEmpty && state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(state.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.read(communityFeedProvider.notifier).fetchFeed(isRefresh: true),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(communityFeedProvider.notifier).fetchFeed(isRefresh: true),
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.posts.length + (state.hasReachedMax ? 0 : 1),
        itemBuilder: (context, index) {
          if (index >= state.posts.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }

          final post = state.posts[index];

          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User header
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.surfaceVariant,
                    backgroundImage: post.authorAvatar.isNotEmpty
                        ? CachedNetworkImageProvider(post.authorAvatar)
                        : null,
                    child: post.authorAvatar.isEmpty
                        ? const Icon(Icons.person, color: AppColors.primary)
                        : null,
                  ),
                  title: Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    post.createdAt,
                    style: const TextStyle(fontSize: 11, color: AppColors.textHint),
                  ),
                ),
                
                // Post Image
                if (post.imageUrl.isNotEmpty)
                  ClipRRect(
                    child: CachedNetworkImage(
                      imageUrl: post.imageUrl,
                      width: double.infinity,
                      height: 240,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 240,
                        color: AppColors.surfaceVariant,
                        child: const Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 240,
                        color: AppColors.surfaceVariant,
                        child: const Icon(Icons.broken_image_rounded, size: 48, color: AppColors.textHint),
                      ),
                    ),
                  ),
                  
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (post.caption.isNotEmpty) ...[
                        Text(
                          post.caption,
                          style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                        ),
                        const Divider(height: 24),
                      ],
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              post.isLikedByMe ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: post.isLikedByMe ? AppColors.error : AppColors.textHint,
                            ),
                            onPressed: () {
                              ref.read(communityFeedProvider.notifier).toggleLike(post.id);
                            },
                          ),
                          Text('${post.likesCount} Suka', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 24),
                          IconButton(
                            icon: const Icon(Icons.comment_outlined, color: AppColors.textHint),
                            onPressed: () => _showComments(post.id),
                          ),
                          Text('${post.commentsCount} Komentar', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 2: Grup Saya
// ---------------------------------------------------------------------------
class _GrupSayaTab extends StatelessWidget {
  final List<String> groups;
  final VoidCallback onCreatePressed;
  final VoidCallback onJoinPressed;

  const _GrupSayaTab({
    required this.groups,
    required this.onCreatePressed,
    required this.onJoinPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onCreatePressed,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Buat Grup'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onJoinPressed,
                  icon: const Icon(Icons.group_add_rounded),
                  label: const Text('Gabung Grup'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Grup yang Anda Ikuti',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: groups.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final groupName = groups[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.divider),
                ),
                child: ExpansionTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.group_rounded, color: Colors.white),
                  ),
                  title: Text(groupName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Lihat Papan Peringkat Harian', style: TextStyle(fontSize: 12)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(),
                          const Text(
                            'Papan Peringkat Poin (Leaderboard)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                          ),
                          const SizedBox(height: 8),
                          _LeaderboardItem(rank: 1, name: 'Budi Raharjo', points: 1550, isUser: false),
                          _LeaderboardItem(rank: 2, name: 'Anda', points: 1200, isUser: true),
                          _LeaderboardItem(rank: 3, name: 'Citra Dewi', points: 980, isUser: false),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

class _LeaderboardItem extends StatelessWidget {
  final int rank;
  final String name;
  final int points;
  final bool isUser;

  const _LeaderboardItem({
    required this.rank,
    required this.name,
    required this.points,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                '#$rank',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: rank == 1 ? const Color(0xFFFFA000) : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                name,
                style: TextStyle(
                  fontWeight: isUser ? FontWeight.bold : FontWeight.normal,
                  color: isUser ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Text(
            '$points Poin',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isUser ? AppColors.primary : AppColors.textPrimary,
            ),
          )
        ],
      ),
    );
  }
}
