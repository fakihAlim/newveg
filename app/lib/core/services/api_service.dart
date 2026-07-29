import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Service to communicate with the PHP RESTful API backend on the VPS server
class ApiService {
  static const String baseUrl = 'https://yodi.my.id/veg/web/api';
  
  // Stores current authenticated JWT token
  String? _token;

  /// Update active authentication token
  void setToken(String? token) {
    _token = token;
  }

  /// Sends a batch of offline food logs to the MySQL database via REST API
  Future<bool> syncFoodLogs(List<Map<String, dynamic>> logsJson) async {
    if (_token == null) {
      if (kDebugMode) {
        print('API Service: Cannot sync logs, user token is missing.');
      }
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logs/sync.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({'logs': logsJson}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          if (kDebugMode) {
            print('API Service: Sync success! Total points: ${data['total_points']}');
          }
          return true;
        }
      }
      if (kDebugMode) {
        print('API Service: Sync failed with status: ${response.statusCode}, response: ${response.body}');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('API Service Connection Error: $e');
      }
      return false;
    }
  }

  /// Authenticate user credentials and retrieve JWT token
  Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['token'] != null) {
          _token = data['token'];
          return _token;
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('API Service Login Error: $e');
      }
      return null;
    }
  }
}

// Global singleton instance
final apiService = ApiService();
