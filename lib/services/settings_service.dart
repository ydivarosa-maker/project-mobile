import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _audioQualityKey = 'audioQuality';
  static const String _dataSaverKey = 'dataSaverEnabled';
  static const String _notificationsKey = 'notificationsEnabled';
  static const String _userNameKey = 'userName';
  static const String _userEmailKey = 'userEmail';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Audio Quality
  String getAudioQuality() {
    return _prefs.getString(_audioQualityKey) ?? 'Tinggi';
  }

  Future<void> setAudioQuality(String quality) async {
    await _prefs.setString(_audioQualityKey, quality);
  }

  // Data Saver
  bool isDataSaverEnabled() {
    return _prefs.getBool(_dataSaverKey) ?? false;
  }

  Future<void> setDataSaverEnabled(bool enabled) async {
    await _prefs.setBool(_dataSaverKey, enabled);
  }

  // Notifications
  bool areNotificationsEnabled() {
    return _prefs.getBool(_notificationsKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_notificationsKey, enabled);
  }

  // User Profile
  String getUserName() {
    return _prefs.getString(_userNameKey) ?? 'Divaa';
  }

  Future<void> setUserName(String name) async {
    await _prefs.setString(_userNameKey, name);
  }

  String getUserEmail() {
    return _prefs.getString(_userEmailKey) ?? 'divaa@example.com';
  }

  Future<void> setUserEmail(String email) async {
    await _prefs.setString(_userEmailKey, email);
  }

  // Get bitrate based on quality and data saver
  int getBitrate() {
    final isDataSaver = isDataSaverEnabled();
    final quality = getAudioQuality();

    if (isDataSaver) {
      return 64; // Low bitrate for data saver
    }

    switch (quality) {
      case 'Otomatis':
        return 128;
      case 'Rendah':
        return 96;
      case 'Normal':
        return 128;
      case 'Tinggi':
        return 192;
      case 'Sangat Tinggi':
        return 256;
      default:
        return 128;
    }
  }
}
