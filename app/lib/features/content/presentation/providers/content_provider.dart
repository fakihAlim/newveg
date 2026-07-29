import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newveg/features/content/data/remote_content_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Service provider
final remoteContentServiceProvider = Provider<RemoteContentService>((ref) {
  return RemoteContentService();
});

// System config future provider
final systemConfigProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(remoteContentServiceProvider);
  final config = await service.fetchSystemConfig();
  
  // Dynamic override of local Gemini API Key if returned by the server
  if (config.containsKey('GEMINI_API_KEY') && config['GEMINI_API_KEY'].toString().isNotEmpty) {
    dotenv.env['GEMINI_API_KEY'] = config['GEMINI_API_KEY'].toString();
  }
  return config;
});

// News article list provider
final remoteNewsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(remoteContentServiceProvider);
  return service.fetchNews();
});

// Recipe list provider
final remoteRecipesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(remoteContentServiceProvider);
  return service.fetchRecipes();
});

// Today's Quiz provider
final remoteQuizProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(remoteContentServiceProvider);
  return service.fetchQuizzes();
});

// Myths list provider
final remoteMythsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(remoteContentServiceProvider);
  return service.fetchMyths();
});
