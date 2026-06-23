import 'dart:convert';
import 'package:http/http.dart' as http;

class LyricsService {
  static const String _baseUrl = 'https://api.lyrics.ovh/v1';

  /// Mengambil lirik dari API menggunakan nama artist dan judul lagu
  Future<String?> fetchLyrics(String artist, String title) async {
    try {
      // Bersihkan nama artist dan judul untuk URL
      final cleanArtist = artist.replaceAll(RegExp(r'[^\w\s]'), '').trim();
      final cleanTitle = title.replaceAll(RegExp(r'[^\w\s]'), '').trim();

      final response = await http
          .get(Uri.parse('$_baseUrl/$cleanArtist/$cleanTitle'))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Permintaan lirik timeout'),
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('lyrics') && data['lyrics'] != null) {
          return data['lyrics'] as String;
        }
      } else if (response.statusCode == 404) {
        // Lirik tidak ditemukan
        return null;
      } else {
        throw Exception('Gagal memuat lirik (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Koneksi bermasalah saat mengambil lirik: $e');
    }
    return null;
  }

  /// Alternatif: Mengambil lirik dengan mencoba format berbeda
  Future<String?> fetchLyricsWithFallback(String artist, String title) async {
    try {
      // Coba format pertama
      var lyrics = await fetchLyrics(artist, title);
      if (lyrics != null) return lyrics;

      // Coba format dengan hanya kata pertama dari artist
      final artistFirstWord = artist.split(' ').first;
      lyrics = await fetchLyrics(artistFirstWord, title);
      if (lyrics != null) return lyrics;

      return null;
    } catch (e) {
      return null;
    }
  }
}
