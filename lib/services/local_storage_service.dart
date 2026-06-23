import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/music_track.dart';

/// Pengganti FirebaseService – menyimpan data secara lokal dengan SharedPreferences.
class LocalStorageService {
  static const String _favKey = 'local_favorites';
  static const String _followedKey = 'local_followed';
  static const String _recentKey = 'local_recent';

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
    return decoded
        .map((m) => _trackFromMap(m as Map<String, dynamic>))
        .toList();
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
    await prefs.setString(
      _followedKey,
      jsonEncode(list.map(_trackToMap).toList()),
    );
  }

  Future<void> removeFollowed(String trackTitle) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getFollowed();
    list.removeWhere((t) => t.title == trackTitle);
    await prefs.setString(
      _followedKey,
      jsonEncode(list.map(_trackToMap).toList()),
    );
  }

  Future<List<MusicTrack>> getFollowed() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_followedKey);
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded
        .map((m) => _trackFromMap(m as Map<String, dynamic>))
        .toList();
  }

  // ============================================================
  // PROFILE IMAGE  (hanya in-memory, tidak disimpan permanen)
  // ============================================================

  // Tidak ada upload/download – foto profil disimpan di state widget
  // sebagai Uint8List (_profileImageBytes).

  // ============================================================
  // RECENTLY PLAYED
  // ============================================================

  Future<void> addRecent(MusicTrack track) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getRecent();

    // Hapus jika sudah ada agar bisa dinaikkan ke paling atas
    list.removeWhere((t) => t.title == track.title);

    // Tambahkan di urutan pertama (paling baru)
    list.insert(0, track);

    // Batasi maksimum 15 riwayat
    if (list.length > 15) {
      list.removeLast();
    }

    await prefs.setString(
      _recentKey,
      jsonEncode(list.map(_trackToMap).toList()),
    );
  }

  Future<List<MusicTrack>> getRecent() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_recentKey);
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded
        .map((m) => _trackFromMap(m as Map<String, dynamic>))
        .toList();
  }

  // ============================================================
  // HELPER
  // ============================================================

  Map<String, dynamic> _trackToMap(MusicTrack t) => {
    'id': t.id,
    'title': t.title,
    'artist': t.artist,
    'imageUrl': t.imageUrl,
    'audioUrl': t.audioUrl,
    'color': t.color.value,
    'icon': t.icon.codePoint,
  };

  MusicTrack _trackFromMap(Map<String, dynamic> m) => MusicTrack(
    id: m['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
    title: m['title'] ?? 'Unknown Title',
    artist: m['artist'] ?? 'Unknown Artist',
    imageUrl: m['imageUrl'] ?? '',
    audioUrl: m['audioUrl'] ?? '',
    color: m['color'] != null
        ? Color(m['color'] as int)
        : const Color(0xFFD946EF),
    icon: m['icon'] != null
        ? IconData(m['icon'] as int, fontFamily: 'MaterialIcons')
        : Icons.music_note,
  );
}
