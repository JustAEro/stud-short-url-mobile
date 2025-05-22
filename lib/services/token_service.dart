import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static const String tokenKey = 'auth_token';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(TokenService.tokenKey);
  }
}