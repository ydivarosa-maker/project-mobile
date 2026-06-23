import 'package:shared_preferences/shared_preferences.dart';

/// AuthService lokal – menggantikan Firebase Auth.
/// Menyimpan nama pengguna secara lokal di SharedPreferences.
class AuthService {
  static const String _userNameKey = 'local_username';
  static const String _isLoggedInKey = 'local_is_logged_in';

  String? _displayName;
  bool _loggedIn = false;

  AuthService() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _displayName = prefs.getString(_userNameKey);
    _loggedIn = prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> reload() async {
    await _loadFromPrefs();
  }

  Future<void> updateDisplayName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    _displayName = name.trim();
    await prefs.setString(_userNameKey, _displayName ?? '');
  }

  // Getter kompatibel dengan kode lama
  String? get currentUserDisplayName => _displayName;
  bool get isLoggedIn => _loggedIn;

  /// Login lokal dengan nama pengguna
  Future<void> signInWithName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    _displayName = name.trim();
    _loggedIn = true;
    await prefs.setString(_userNameKey, _displayName ?? '');
    await prefs.setBool(_isLoggedInKey, true);
  }

  /// Logout
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    _displayName = null;
    _loggedIn = false;
    await prefs.remove(_userNameKey);
    await prefs.setBool(_isLoggedInKey, false);
  }
}
