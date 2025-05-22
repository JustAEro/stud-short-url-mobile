import 'package:shared_preferences/shared_preferences.dart';
import 'package:stud_short_url_mobile/clients/dio_client.dart';
import 'package:stud_short_url_mobile/services/token_service.dart';

class AuthService {
  final TokenService _tokenService = TokenService();

  final _dio = DioClient().dio;

  final String baseUrl = '/api/v1/auth';

  Future<bool> login(String login, String password) async {
    final response = await _dio.post(
      '$baseUrl/login',
      data: {'login': login, 'password': password},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = response.data;
      final token = data['accessToken'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(TokenService.tokenKey, token);
      return true;
    }

    return false;
  }

  Future<bool> register(String login, String password) async {
    final response = await _dio.post(
      '$baseUrl/register',
      data: {'login': login, 'password': password},
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  Future<void> logout() async {
    // final token = await getToken();
    // if (token == null) return;

    // await http.post(
    //   Uri.parse('$baseUrl/logout'),
    //   headers: {'Authorization': 'Bearer $token'},
    // );

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(TokenService.tokenKey);
  }

  Future<bool> isAuthenticated() async {
    final token = await _tokenService.getToken();
    if (token == null) return false;

    final response = await _dio.get('$baseUrl/me');

    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    final token = await TokenService().getToken();
    if (token == null) return null;

    final response = await _dio.get('$baseUrl/me');

    if (response.statusCode == 200) {
      return response.data;
    }
    return null;
  }
}
