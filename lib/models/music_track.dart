import 'package:flutter/material.dart';

class MusicTrack {
  final String title;
  final String artist;
  final String artworkUrl;
  final String previewUrl;
  final Color color;
  final IconData icon;
  final String? lyrics;

  MusicTrack({
    required this.title,
    required this.artist,
    required this.artworkUrl,
    required this.previewUrl,
    this.color = const Color(0xFFD946EF),
    this.icon = Icons.music_note,
    this.lyrics,
  });

  factory MusicTrack.fromJson(Map<String, dynamic> json) {
    return MusicTrack(
      title: json['trackName'] ?? 'Unknown Title',
      artist: json['artistName'] ?? 'Unknown Artist',
      artworkUrl: json['artworkUrl100'] ?? '',
      previewUrl: json['previewUrl'] ?? '',
      color:
          Colors.primaries[(json['trackId']?.hashCode ?? 0).abs() %
              Colors.primaries.length],
    );
  }
}
