import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';

/// Konstanta ikon yang bisa disimpan dan dipulihkan
const List<int> _iconCodepoints = [
  0xe415, // Icons.playlist_play
  0xe87d, // Icons.favorite
  0xe030, // Icons.library_music
  0xe30f, // Icons.coffee
  0xe025, // Icons.album
  0xe3a9, // Icons.headphones
  0xe8b6, // Icons.star
  0xe048, // Icons.music_note
];

/// Layanan penyimpanan Playlist menggunakan Hive (NoSQL lokal)
class PlaylistService {
  static const String _boxName = 'melodya_playlists';

  static Future<void> init() async {
    await Hive.openBox(_boxName);
  }

  Box get _box => Hive.box(_boxName);

  // --- Ambil semua playlist ---
  List<Map<String, dynamic>> getAll() {
    final raw = _box.get('playlists', defaultValue: <dynamic>[]);
    return List<Map<String, dynamic>>.from(
      (raw as List).map((item) => Map<String, dynamic>.from(item as Map)),
    );
  }

  // --- Simpan semua playlist ---
  Future<void> _saveAll(List<Map<String, dynamic>> playlists) async {
    await _box.put('playlists', playlists);
  }

  // --- Tambah playlist baru ---
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

  // --- Hapus playlist berdasarkan nama ---
  Future<void> remove(String name) async {
    final all = getAll();
    all.removeWhere((pl) => pl['name'] == name);
    await _saveAll(all);
  }

  // --- Ganti nama playlist ---
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

  // --- Simpan ulang semua dari objek Playlist ---
  Future<void> saveFromList(List<Map<String, dynamic>> playlists) async {
    await _saveAll(playlists);
  }

  // --- Inisialisasi data default jika kosong ---
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

  // --- Helper: konversi iconCodepoint ke IconData ---
  static IconData iconFromCodepoint(int codepoint) {
    return IconData(codepoint, fontFamily: 'MaterialIcons');
  }
}
