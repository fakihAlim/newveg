import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newveg/core/network/api_endpoints.dart';
import 'package:flutter/foundation.dart';

/// Service class responsible for fetching content and config variables from VPS API.
class RemoteContentService {
  final http.Client _client;

  RemoteContentService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch dynamic configurations (Gemini API Key, Free Scan Limits, etc.)
  Future<Map<String, dynamic>> fetchSystemConfig() async {
    try {
      final response = await _client.get(Uri.parse(ApiEndpoints.config));
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success'] == true && body['settings'] != null) {
          return body['settings'] as Map<String, dynamic>;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('RemoteContentService: Error fetching config: $e');
      }
    }
    return {};
  }

  /// Fetch all news articles from MySQL backend
  Future<List<Map<String, dynamic>>> fetchNews() async {
    try {
      final response = await _client.get(Uri.parse(ApiEndpoints.news));
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success'] == true && body['news'] != null) {
          return List<Map<String, dynamic>>.from(body['news'] as List);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('RemoteContentService: Error fetching news: $e');
      }
    }
    return [];
  }

  /// Fetch all recipes from MySQL database
  Future<List<Map<String, dynamic>>> fetchRecipes() async {
    try {
      final response = await _client.get(Uri.parse(ApiEndpoints.recipes));
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success'] == true && body['recipes'] != null) {
          return List<Map<String, dynamic>>.from(body['recipes'] as List);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('RemoteContentService: Error fetching recipes: $e');
      }
    }
    return [];
  }

  /// Fetch quizzes from database
  Future<List<Map<String, dynamic>>> fetchQuizzes() async {
    try {
      final response = await _client.get(Uri.parse(ApiEndpoints.quizzes));
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success'] == true && body['quizzes'] != null) {
          return List<Map<String, dynamic>>.from(body['quizzes'] as List);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('RemoteContentService: Error fetching quizzes: $e');
      }
    }
    return [];
  }

  /// Fetch myths from database
  Future<List<Map<String, dynamic>>> fetchMyths() async {
    try {
      final response = await _client.get(Uri.parse(ApiEndpoints.myths));
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success'] == true && body['myths'] != null) {
          return List<Map<String, dynamic>>.from(body['myths'] as List);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('RemoteContentService: Error fetching myths: $e');
      }
    }
    return [];
  }
}
