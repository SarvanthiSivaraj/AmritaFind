class AuthService {
  // Simple in-memory demo auth flag. Replace with real auth integration.
  static bool isLoggedIn = false;

  static Future<void> login() async {
    isLoggedIn = true;
  }

  static Future<void> logout() async {
    isLoggedIn = false;
  }
}
