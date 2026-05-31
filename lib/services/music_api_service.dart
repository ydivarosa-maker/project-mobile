import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/music_track.dart';

class MusicApiService {
  static const String _baseUrl = 'https://itunes.apple.com/search';

  // # Audiomack API Example
  // curl -X GET "https://www.audiomack.com/data-api/docs" \
  //   -H "Content-Type: application/json"
  // Note: Audiomack URL di atas adalah dokumentasi, untuk saat ini 
  // kita tetap menggunakan iTunes API untuk mendapatkan audio preview yang aman.

  Future<List<MusicTrack>> fetchTracks(String searchTerm) async {
    try {
      final encodedTerm = Uri.encodeComponent(searchTerm);
      final url = Uri.parse('$_baseUrl?term=$encodedTerm&media=music&limit=30');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];
        
        final List<MusicTrack> tracks = results
            .where((json) => json['previewUrl'] != null && json['previewUrl'].toString().isNotEmpty)
            .map((json) => MusicTrack.fromJson(json))
            .toList();

        if (tracks.isNotEmpty) {
          return tracks;
        }
      }
    } catch (e) {
      // API call failed, falls through to mock tracks
    }

    return [
      MusicTrack(
        id: '1',
        title: 'Beautiful Dawn',
        artist: 'Acoustic Breeze',
        audioUrl: 'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview125/v4/4a/eb/1e/4aeb1e8f-7f72-74cc-7f7a-1db2a32eb518/m4a.high.stream.mp4',
        imageUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=500',
      ),
      MusicTrack(
        id: '2',
        title: 'Urban Beats',
        artist: 'DJ Flow',
        audioUrl: 'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview115/v4/cd/85/6d/cd856d3a-be7d-df98-5c12-32111c1dfb7a/m4a.high.stream.mp4',
        imageUrl: 'https://images.unsplash.com/photo-1498038432885-c6f3f1b912ee?w=500',
      ),
    ];
  }
}
