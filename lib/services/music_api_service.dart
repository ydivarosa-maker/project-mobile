import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/music_track.dart';

class MusicApiService {
  static const String _baseUrl = 'https://itunes.apple.com/search';

  Future<List<MusicTrack>> fetchTracks(String searchTerm) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?term=$searchTerm&entity=song&limit=30'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        return results.map((json) => MusicTrack.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat lagu dari iTunes');
      }
    } catch (e) {
      throw Exception('Koneksi bermasalah: $e');
    }
  }
}
