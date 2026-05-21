import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/music_track.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ============================================================
  // FAVORITES
  // ============================================================

  // Simpan lagu ke favorit
  Future<void> addFavorite(String userId, MusicTrack track) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(_sanitizeKey(track.title))
        .set({
      'title': track.title,
      'artist': track.artist,
      'artworkUrl': track.artworkUrl,
      'previewUrl': track.previewUrl,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  // Hapus lagu dari favorit
  Future<void> removeFavorite(String userId, String trackTitle) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(_sanitizeKey(trackTitle))
        .delete();
  }

  // Stream real-time daftar favorit
  Stream<List<MusicTrack>> getFavoritesStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MusicTrack(
                  title: doc['title'] ?? '',
                  artist: doc['artist'] ?? '',
                  artworkUrl: doc['artworkUrl'] ?? '',
                  previewUrl: doc['previewUrl'] ?? '',
                ))
            .toList());
  }

  // ============================================================
  // FOLLOWED ARTISTS/TRACKS
  // ============================================================

  // Ikuti artis/lagu
  Future<void> addFollowed(String userId, MusicTrack track) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('followed')
        .doc(_sanitizeKey(track.title))
        .set({
      'title': track.title,
      'artist': track.artist,
      'artworkUrl': track.artworkUrl,
      'previewUrl': track.previewUrl,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  // Berhenti mengikuti
  Future<void> removeFollowed(String userId, String trackTitle) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('followed')
        .doc(_sanitizeKey(trackTitle))
        .delete();
  }

  // Stream real-time artis yang diikuti
  Stream<List<MusicTrack>> getFollowedStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('followed')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MusicTrack(
                  title: doc['title'] ?? '',
                  artist: doc['artist'] ?? '',
                  artworkUrl: doc['artworkUrl'] ?? '',
                  previewUrl: doc['previewUrl'] ?? '',
                ))
            .toList());
  }

  // ============================================================
  // PLAYLISTS
  // ============================================================

  // Simpan playlist
  Future<void> savePlaylist(
      String userId, String name, List<String> trackTitles) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('playlists')
        .doc(_sanitizeKey(name))
        .set({
      'name': name,
      'trackTitles': trackTitles,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Hapus playlist
  Future<void> deletePlaylist(String userId, String name) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('playlists')
        .doc(_sanitizeKey(name))
        .delete();
  }

  // Stream real-time daftar playlist
  Stream<List<Map<String, dynamic>>> getPlaylistsStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('playlists')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'name': doc['name'] ?? '',
                  'trackTitles':
                      List<String>.from(doc['trackTitles'] ?? []),
                })
            .toList());
  }

  // ============================================================
  // PROFILE IMAGE
  // ============================================================

  // Upload foto profil ke Firebase Storage
  Future<String> uploadProfileImage(String userId, Uint8List imageBytes) async {
    final ref = _storage.ref().child('profiles/$userId/avatar.jpg');
    final uploadTask = await ref.putData(
      imageBytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await uploadTask.ref.getDownloadURL();
  }

  // Ambil URL foto profil
  Future<String?> getProfileImageUrl(String userId) async {
    try {
      final ref = _storage.ref().child('profiles/$userId/avatar.jpg');
      return await ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // PROFILE DATA
  // ============================================================

  // Simpan nama pengguna
  Future<void> saveUserProfile(String userId, String displayName) async {
    await _db.collection('users').doc(userId).set({
      'displayName': displayName,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Ambil data profil
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.data();
  }

  // ============================================================
  // HELPER
  // ============================================================

  // Bersihkan karakter khusus untuk dijadikan document ID Firestore
  String _sanitizeKey(String key) {
    return key.replaceAll(RegExp(r'[\/\.\#\$\[\]]'), '_').toLowerCase();
  }
}
