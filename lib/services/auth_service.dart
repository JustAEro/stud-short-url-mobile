import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String tokenKey = 'auth_token';
  final String baseUrl =
      '${dotenv.env['API_URL']}/api/v1/auth';

  Future<bool> login(String login, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'login': login, 'password': password}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['accessToken'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(tokenKey, token);
      return true;
    }

    return false;
  }

  Future<bool> register(String login, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'login': login, 'password': password}),
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  Future<void> logout() async {
    final token = await getToken();
    if (token == null) return;

    await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    if (token == null) return false;

    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    final token = await getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }
}
