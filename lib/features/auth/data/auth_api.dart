import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthApi {
  AuthApi({String? baseUrl}) : _baseUrl = baseUrl ?? const String.fromEnvironment('AUTH_API_URL', defaultValue: 'http://localhost:4000');

  final String _baseUrl;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/login');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? pilotId,
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/register');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'pilotId': pilotId,
      }),
    );
    return _decode(response);
  }

  static Map<String, dynamic> _decode(http.Response response) {
    final jsonBody = response.body.isEmpty ? <String, dynamic>{} : (jsonDecode(response.body) as Map<String, dynamic>);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonBody;
    }
    throw Exception(jsonBody['message']?.toString() ?? 'Request failed (${response.statusCode})');
  }
}
