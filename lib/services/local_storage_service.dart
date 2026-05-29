import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/music_track.dart';

/// Pengganti FirebaseService – menyimpan data secara lokal dengan SharedPreferences.
class LocalStorageService {
  static const String _favKey = 'local_favorites';
  static const String _followedKey = 'local_followed';

  // ============================================================
  // FAVORITES
  // ============================================================

  Future<void> addFavorite(MusicTrack track) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getFavorites();
    if (!list.any((t) => t.title == track.title)) {
      list.add(track);
    }
    await prefs.setString(_favKey, jsonEncode(list.map(_trackToMap).toList()));
  }

  Future<void> removeFavorite(String trackTitle) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getFavorites();
    list.removeWhere((t) => t.title == trackTitle);
    await prefs.setString(_favKey, jsonEncode(list.map(_trackToMap).toList()));
  }

  Future<List<MusicTrack>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_favKey);
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded.map((m) => _trackFromMap(m as Map<String, dynamic>)).toList();
  }

  // ============================================================
  // FOLLOWED ARTISTS/TRACKS
  // ============================================================

  Future<void> addFollowed(MusicTrack track) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getFollowed();
    if (!list.any((t) => t.title == track.title)) {
      list.add(track);
    }
    await prefs.setString(_followedKey, jsonEncode(list.map(_trackToMap).toList()));
  }

  Future<void> removeFollowed(String trackTitle) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getFollowed();
    list.removeWhere((t) => t.title == trackTitle);
    await prefs.setString(_followedKey, jsonEncode(list.map(_trackToMap).toList()));
  }

  Future<List<MusicTrack>> getFollowed() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_followedKey);
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded.map((m) => _trackFromMap(m as Map<String, dynamic>)).toList();
  }

  // ============================================================
  // PROFILE IMAGE  (hanya in-memory, tidak disimpan permanen)
  // ============================================================

  // Tidak ada upload/download – foto profil disimpan di state widget
  // sebagai Uint8List (_profileImageBytes).

  // ============================================================
  // HELPER
  // ============================================================

  Map<String, dynamic> _trackToMap(MusicTrack t) => {
        'title': t.title,
        'artist': t.artist,
        'artworkUrl': t.artworkUrl,
        'previewUrl': t.previewUrl,
      };

  MusicTrack _trackFromMap(Map<String, dynamic> m) => MusicTrack(
        title: m['title'] ?? '',
        artist: m['artist'] ?? '',
        artworkUrl: m['artworkUrl'] ?? '',
        previewUrl: m['previewUrl'] ?? '',
      );
}
