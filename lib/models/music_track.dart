import 'package:flutter/material.dart';

class MusicTrack {
  final String id;
  final String title;
  final String artist;
  final String audioUrl;
  final String imageUrl;
  final Color color;
  final IconData icon;
  final String? lyrics;

  MusicTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.audioUrl,
    required this.imageUrl,
    this.color = const Color(0xFFD946EF),
    this.icon = Icons.music_note,
    this.lyrics,
  });

  factory MusicTrack.fromJson(Map<String, dynamic> json) {
    return MusicTrack(
      id: json['trackId']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['trackName'] ?? 'Unknown Title',
      artist: json['artistName'] ?? 'Unknown Artist',
      imageUrl: json['artworkUrl100'] ?? '',
      audioUrl: json['previewUrl'] ?? '',
      color:
          Colors.primaries[(json['trackId']?.hashCode ?? 0).abs() %
              Colors.primaries.length],
    );
  }
}
