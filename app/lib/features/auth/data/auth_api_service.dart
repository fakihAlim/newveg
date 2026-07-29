import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newveg/core/network/api_endpoints.dart';

/// Service layer handling authentication HTTP requests.
class AuthApiService {
  final http.Client _client;

  AuthApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Authenticate with email & password.
  /// Returns a Map with success status, token, and user profile data.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse(ApiEndpoints.login),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        final body = json.decode(response.body);
        return {
          'success': false,
          'message': body['message'] ?? 'Login gagal. Silakan coba lagi.'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server: $e'
      };
    }
  }

  /// Register new user account.
  /// Returns a Map with success status, token, and created user profile data.
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse(ApiEndpoints.register),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'full_name': fullName,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 210) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        final body = json.decode(response.body);
        return {
          'success': false,
          'message': body['message'] ?? 'Pendaftaran gagal. Silakan coba lagi.'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server: $e'
      };
    }
  }
}
