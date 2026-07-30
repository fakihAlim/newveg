import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:newveg/core/network/api_endpoints.dart';
import 'package:newveg/features/auth/presentation/providers/auth_provider.dart';

class CommunityPost {
  final int id;
  final int authorId;
  final String authorName;
  final String authorAvatar;
  final String imageUrl;
  final String caption;
  final int likesCount;
  final int commentsCount;
  final bool isLikedByMe;
  final String createdAt;

  CommunityPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.imageUrl,
    required this.caption,
    required this.likesCount,
    required this.commentsCount,
    required this.isLikedByMe,
    required this.createdAt,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      authorId: json['authorId'] is int ? json['authorId'] as int : int.tryParse(json['authorId'].toString()) ?? 0,
      authorName: json['authorName'] as String? ?? 'Anonymous',
      authorAvatar: json['authorAvatar'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      caption: json['caption'] as String? ?? '',
      likesCount: json['likesCount'] is int ? json['likesCount'] as int : int.tryParse(json['likesCount'].toString()) ?? 0,
      commentsCount: json['commentsCount'] is int ? json['commentsCount'] as int : int.tryParse(json['commentsCount'].toString()) ?? 0,
      isLikedByMe: json['isLikedByMe'] == true,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  CommunityPost copyWith({
    int? likesCount,
    int? commentsCount,
    bool? isLikedByMe,
  }) {
    return CommunityPost(
      id: id,
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      imageUrl: imageUrl,
      caption: caption,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      createdAt: createdAt,
    );
  }
}

class CommunityFeedState {
  final bool isLoading;
  final List<CommunityPost> posts;
  final String? errorMessage;
  final int page;
  final bool hasReachedMax;

  const CommunityFeedState({
    this.isLoading = false,
    this.posts = const [],
    this.errorMessage,
    this.page = 1,
    this.hasReachedMax = false,
  });

  CommunityFeedState copyWith({
    bool? isLoading,
    List<CommunityPost>? posts,
    String? errorMessage,
    int? page,
    bool? hasReachedMax,
  }) {
    return CommunityFeedState(
      isLoading: isLoading ?? this.isLoading,
      posts: posts ?? this.posts,
      errorMessage: errorMessage,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class CommunityFeedNotifier extends StateNotifier<CommunityFeedState> {
  final Ref _ref;
  final http.Client _client = http.Client();

  CommunityFeedNotifier(this._ref) : super(const CommunityFeedState()) {
    fetchFeed();
  }

  String? _getAuthToken() {
    return _ref.read(authProvider).token;
  }

  Future<void> fetchFeed({bool isRefresh = false}) async {
    if (state.isLoading) return;
    if (!isRefresh && state.hasReachedMax) return;

    final token = _getAuthToken();
    if (token == null) {
      state = state.copyWith(errorMessage: 'Authentication required.');
      return;
    }

    final int nextPage = isRefresh ? 1 : state.page;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final uri = Uri.parse('${ApiEndpoints.communityFeed}?page=$nextPage&limit=20');
      final response = await _client.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success'] == true && body['data'] != null) {
          final List<dynamic> list = body['data'] as List;
          final List<CommunityPost> fetchedPosts = list.map((e) => CommunityPost.fromJson(e as Map<String, dynamic>)).toList();

          state = state.copyWith(
            isLoading: false,
            posts: isRefresh ? fetchedPosts : [...state.posts, ...fetchedPosts],
            page: nextPage + 1,
            hasReachedMax: fetchedPosts.length < 20,
          );
        } else {
          state = state.copyWith(isLoading: false, errorMessage: body['message'] ?? 'Gagal memuat feed.');
        }
      } else {
        state = state.copyWith(isLoading: false, errorMessage: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Koneksi gagal: $e');
    }
  }

  /// Toggle post like (optimistic UI update)
  Future<void> toggleLike(int postId) async {
    final token = _getAuthToken();
    if (token == null) return;

    final postIndex = state.posts.indexWhere((p) => p.id == postId);
    if (postIndex == -1) return;

    final post = state.posts[postIndex];
    final originalIsLiked = post.isLikedByMe;
    final originalLikesCount = post.likesCount;

    // Optimistic Update
    final newIsLiked = !originalIsLiked;
    final newLikesCount = originalLikesCount + (newIsLiked ? 1 : -1);

    final updatedPosts = [...state.posts];
    updatedPosts[postIndex] = post.copyWith(
      isLikedByMe: newIsLiked,
      likesCount: newLikesCount,
    );
    state = state.copyWith(posts: updatedPosts);

    try {
      final response = await _client.post(
        Uri.parse(ApiEndpoints.likePost),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'post_id': postId,
          'action': newIsLiked ? 'like' : 'unlike',
        }),
      );

      if (response.statusCode != 200) {
        // Revert on server error
        _revertLike(postId, originalIsLiked, originalLikesCount);
      }
    } catch (e) {
      // Revert on connection error
      _revertLike(postId, originalIsLiked, originalLikesCount);
    }
  }

  void _revertLike(int postId, bool originalIsLiked, int originalLikesCount) {
    final postIndex = state.posts.indexWhere((p) => p.id == postId);
    if (postIndex == -1) return;

    final updatedPosts = [...state.posts];
    updatedPosts[postIndex] = updatedPosts[postIndex].copyWith(
      isLikedByMe: originalIsLiked,
      likesCount: originalLikesCount,
    );
    state = state.copyWith(posts: updatedPosts);
  }

  /// Fetch comments for a specific post
  Future<List<Map<String, dynamic>>> fetchComments(int postId) async {
    final token = _getAuthToken();
    if (token == null) return [];

    try {
      final uri = Uri.parse('${ApiEndpoints.commentPost}?post_id=$postId');
      final response = await _client.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success'] == true && body['comments'] != null) {
          return List<Map<String, dynamic>>.from(body['comments'] as List);
        }
      }
    } catch (_) {}
    return [];
  }

  /// Post a new comment and increment commentsCount in state
  Future<Map<String, dynamic>?> addComment(int postId, String commentText) async {
    final token = _getAuthToken();
    if (token == null) return null;

    try {
      final response = await _client.post(
        Uri.parse(ApiEndpoints.commentPost),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'post_id': postId,
          'comment_text': commentText,
        }),
      );

      if (response.statusCode == 201) {
        final body = json.decode(response.body);
        if (body['success'] == true && body['comment'] != null) {
          // Increment counter on UI
          final postIndex = state.posts.indexWhere((p) => p.id == postId);
          if (postIndex != -1) {
            final updatedPosts = [...state.posts];
            updatedPosts[postIndex] = updatedPosts[postIndex].copyWith(
              commentsCount: updatedPosts[postIndex].commentsCount + 1,
            );
            state = state.copyWith(posts: updatedPosts);
          }
          return body['comment'] as Map<String, dynamic>;
        }
      }
    } catch (_) {}
    return null;
  }

  /// Share a food log to the community feed
  Future<bool> shareFoodLog(int foodLogId, String caption) async {
    final token = _getAuthToken();
    if (token == null) return false;

    try {
      final response = await _client.post(
        Uri.parse(ApiEndpoints.shareLog),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'food_log_id': foodLogId,
          'caption': caption,
        }),
      );

      if (response.statusCode == 201) {
        final body = json.decode(response.body);
        if (body['success'] == true) {
          // Refresh the community feed so the new post appears instantly
          await fetchFeed(isRefresh: true);
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  /// Report a community post
  Future<bool> reportPost(int postId, String reason) async {
    final token = _getAuthToken();
    if (token == null) return false;

    try {
      final response = await _client.post(
        Uri.parse(ApiEndpoints.reportPost),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'post_id': postId,
          'reason': reason,
        }),
      );

      if (response.statusCode == 201) {
        final body = json.decode(response.body);
        return body['success'] == true;
      }
    } catch (_) {}
    return false;
  }

  /// Block a user
  Future<bool> blockUser(int blockedUserId) async {
    final token = _getAuthToken();
    if (token == null) return false;

    try {
      final response = await _client.post(
        Uri.parse(ApiEndpoints.blockUser),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'blocked_user_id': blockedUserId,
        }),
      );

      if (response.statusCode == 201) {
        final body = json.decode(response.body);
        if (body['success'] == true) {
          // Refresh feed locally to immediately hide blocked posts
          await fetchFeed(isRefresh: true);
          return true;
        }
      }
    } catch (_) {}
    return false;
  }
}

final communityFeedProvider = StateNotifierProvider<CommunityFeedNotifier, CommunityFeedState>((ref) {
  return CommunityFeedNotifier(ref);
});
