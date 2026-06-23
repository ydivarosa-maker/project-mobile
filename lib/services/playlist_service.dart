import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// PlaylistService menggunakan `SharedPreferences` sebagai pengganti Hive.
class PlaylistService {
  static const String _prefsKey = 'melodya_playlists_storage';
  static late SharedPreferences _prefs;

  /// Inisialisasi: dipanggil sekali di startup
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  List<Map<String, dynamic>> getAll() {
    final raw = _prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    try {
      final decoded = json.decode(raw) as List<dynamic>;
      return List<Map<String, dynamic>>.from(
        decoded.map((e) => Map<String, dynamic>.from(e as Map)),
      );
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  Future<void> _saveAll(List<Map<String, dynamic>> playlists) async {
    final encoded = json.encode(playlists);
    await _prefs.setString(_prefsKey, encoded);
  }

  Future<void> add({
    required String name,
    List<String> trackTitles = const [],
    int colorValue = 0xFF2B0038,
    int iconCodepoint = 0xe415,
  }) async {
    final all = getAll();
    all.add({
      'name': name,
      'trackTitles': List<String>.from(trackTitles),
      'colorValue': colorValue,
      'iconCodepoint': iconCodepoint,
    });
    await _saveAll(all);
  }

  Future<void> remove(String name) async {
    final all = getAll();
    all.removeWhere((pl) => pl['name'] == name);
    await _saveAll(all);
  }

  Future<void> rename(String oldName, String newName) async {
    final all = getAll();
    for (final pl in all) {
      if (pl['name'] == oldName) {
        pl['name'] = newName;
        break;
      }
    }
    await _saveAll(all);
  }

  Future<void> saveFromList(List<Map<String, dynamic>> playlists) async {
    await _saveAll(playlists);
  }

  Future<void> initDefaults() async {
    if (getAll().isEmpty) {
      await _saveAll([
        {
          'name': 'Late Night Jazz',
          'trackTitles': [],
          'colorValue': 0xFF1A237E,
          'iconCodepoint': 0xe415,
        },
        {
          'name': 'Techno Pulse',
          'trackTitles': [],
          'colorValue': 0xFFB71C1C,
          'iconCodepoint': 0xe415,
        },
        {
          'name': 'Focus Deep',
          'trackTitles': [],
          'colorValue': 0xFF1B5E20,
          'iconCodepoint': 0xe415,
        },
        {
          'name': 'Classic Vinyls',
          'trackTitles': [],
          'colorValue': 0xFF4E342E,
          'iconCodepoint': 0xe030,
        },
        {
          'name': 'Workout Mix',
          'trackTitles': [],
          'colorValue': 0xFFE65100,
          'iconCodepoint': 0xe3a9,
        },
      ]);
    }
  }

  static IconData iconFromCodepoint(int codepoint) {
    return IconData(codepoint, fontFamily: 'MaterialIcons');
  }
}
