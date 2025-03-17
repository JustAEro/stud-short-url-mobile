import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String tokenKey = 'auth_token';

  Future<void> login(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  Future<bool> isAuthenticated() async {
    // final prefs = await SharedPreferences.getInstance();
    // return prefs.getString(tokenKey) != null;
    return true;
  }
}