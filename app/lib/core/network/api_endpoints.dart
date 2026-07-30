/// API endpoint dictionary for communicating with the PHP/MySQL backend on VPS.
class ApiEndpoints {
  static const String baseUrl = 'https://yodi.my.id/veg/web/api';

  // Auth endpoints
  static const String login = '$baseUrl/auth/login.php';
  static const String register = '$baseUrl/auth/register.php';
  static const String updateProfile = '$baseUrl/auth/update_profile.php';

  // Content endpoints
  static const String config = '$baseUrl/system/config.php';
  static const String news = '$baseUrl/content/news.php';
  static const String recipes = '$baseUrl/content/recipes.php';
  static const String quizzes = '$baseUrl/content/quizzes.php';
  static const String myths = '$baseUrl/content/myths.php';

  // User logs & sync
  static const String syncLogs = '$baseUrl/logs/sync.php';

  // Community endpoints
  static const String communityFeed = '$baseUrl/community/feed.php';
  static const String likePost = '$baseUrl/community/like.php';
  static const String commentPost = '$baseUrl/community/comment.php';
  static const String shareLog = '$baseUrl/community/share_log.php';
  static const String reportPost = '$baseUrl/community/report.php';
  static const String blockUser = '$baseUrl/community/block.php';
  
  // Auth Compliance
  static const String deleteAccount = '$baseUrl/auth/delete_account.php';
}
