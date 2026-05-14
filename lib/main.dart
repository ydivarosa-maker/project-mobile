import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'models/music_track.dart';
import 'services/music_api_service.dart';

void main() {
  runApp(const MelodyaApp());
}

class Playlist {
  final String name;
  final List<String> trackTitles;
  final Color color;
  final IconData icon;

  Playlist({
    required this.name,
    this.trackTitles = const [],
    this.color = const Color(0xFFD946EF),
    this.icon = Icons.playlist_play,
  });
}

class MelodyaApp extends StatelessWidget {
  const MelodyaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Melodya Landing Page',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primaryColor: const Color(0xFFD946EF),
      ),
      home: const ResponsiveLandingPage(),
    );
  }
}



class ResponsiveLandingPage extends StatelessWidget {
  const ResponsiveLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengecek apakah ukuran layar cukup besar (misal komputer/tablet besar)
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.5, -0.5),
            radius: 1.5,
            colors: [
              Color(0xFF8B5CF6), // Ungu (Purple)
              Color(0xFF0F172A), // Warna dasar gelap
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: isDesktop ? const DesktopLayout() : const MobileAppLayout(),
      ),
    );
  }
}

class DesktopLayout extends StatelessWidget {
  const DesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Teks di Kiri (Hero Text)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Logo dari Melodya
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          'https://cdn-icons-png.flaticon.com/512/3844/3844724.png',
                          width: 50,
                          height: 50,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.music_note,
                                color: Color(0xFFD946EF),
                                size: 50,
                              ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Melodya',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Dengarkan Musik\nFavoritmu Tanpa Batas',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Jelajahi jutaan lagu, buat playlist impianmu, dan nikmati kualitas audio terbaik kapan saja, di mana saja.',
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD946EF), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Mulai mendengarkan musik...'),
                            backgroundColor: Color(0xFFD946EF),
                          ),
                        );
                      },
                      child: const Text(
                        'Mulai Dengarkan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Mockup HP di Kanan
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            child: PhoneMockup(),
          ),
        ],
      ),
    );
  }
}

class PhoneMockup extends StatelessWidget {
  const PhoneMockup({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 650,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white24, width: 8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 30,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: const ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(32)),
        child: MobileAppLayout(),
      ),
    );
  }
}

class MobileAppLayout extends StatefulWidget {
  const MobileAppLayout({super.key});

  @override
  State<MobileAppLayout> createState() => _MobileAppLayoutState();
}

class _MobileAppLayoutState extends State<MobileAppLayout> {
  int _currentIndex = 0;
  String _selectedCategory = 'Semua';

  // State untuk menyimpan lagu favorit (berdasarkan judul lagu)
  final Set<String> _favorites = {};

  // State untuk menyimpan playlist buatan pengguna
  final List<Playlist> _userPlaylists = [
    Playlist(
      name: 'Hits Indonesia',
      trackTitles: ['GHOST', 'SORRY'],
      color: const Color(0xFF8B5CF6),
    ),
  ];

  // Audio Player State
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentPlayingTitle;
  MusicTrack? _currentApiTrack; // Simpan data lagu dari API yang sedang diputar
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  // Profile State
  Uint8List? _profileImageBytes;
  final ImagePicker _picker = ImagePicker();

  // API State
  final MusicApiService _apiService = MusicApiService();
  List<MusicTrack> _apiTracks = [];
  List<MusicTrack> _favApiTracks = []; // Simpan objek lagu favorit dari API
  Set<String> _followedTitles = {}; // Judul lagu yang diikuti
  List<MusicTrack> _followedApiTracks = []; // Objek lagu yang diikuti
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  Future<void> _fetchMusicData(String query) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final tracks = await _apiService.fetchTracks(query);
      setState(() {
        _apiTracks = tracks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil data: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final Uint8List bytes = await image.readAsBytes();
        setState(() {
          _profileImageBytes = bytes;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto profil berhasil diperbarui!'),
              backgroundColor: Color(0xFFD946EF),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil gambar: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchMusicData('Justin Bieber'); // Kembali ke iTunes untuk akses lagu populer
    // Listen to player state changes
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          _duration = newDuration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          _position = newPosition;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Data semua track yang tersedia
  static const List<Map<String, dynamic>> _allTracks = [
    {
      'title': 'GHOST',
      'subtitle': 'Artis Justin Bieber',
      'icon': Icons.music_note,
      'color': Color(0xFF8B5CF6),
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'
    },
    {
      'title': 'SORRY',
      'subtitle': 'Artis Justin Bieber',
      'icon': Icons.library_music,
      'color': Color(0xFFD946EF),
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3'
    },
    {
      'title': 'I DONT CARE',
      'subtitle': 'Artis Justin Bieber',
      'icon': Icons.album,
      'color': Color(0xFF3B82F6),
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3'
    },
    {
      'title': 'Kisah Sukses',
      'subtitle': 'Podcast Motivasi',
      'icon': Icons.mic,
      'color': Color(0xFF3B82F6),
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3'
    },
    {
      'title': 'Obrolan Malam',
      'subtitle': 'Podcast Horor',
      'icon': Icons.mic_external_on,
      'color': Color(0xFF10B981),
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3'
    },
    {
      'title': 'Dunia Tech',
      'subtitle': 'Podcast IT',
      'icon': Icons.headset_mic,
      'color': Color(0xFFF59E0B),
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3'
    },
    {
      'title': 'Pagi Ceria',
      'subtitle': 'Radio FM Nasional',
      'icon': Icons.radio,
      'color': Color(0xFFF59E0B),
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3'
    },
    {
      'title': 'Sore Santai',
      'subtitle': 'Hits Radio Lokal',
      'icon': Icons.radio,
      'color': Color(0xFFEF4444),
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3'
    },
  ];

  void _toggleFavorite(String title, {MusicTrack? apiTrack}) {
    setState(() {
      if (_favorites.contains(title)) {
        _favorites.remove(title);
        if (apiTrack != null) {
          _favApiTracks.removeWhere((t) => t.title == title);
        }
      } else {
        _favorites.add(title);
        if (apiTrack != null) {
          _favApiTracks.add(apiTrack);
        }
      }
    });
  }

  void _toggleFollow(String title, {MusicTrack? apiTrack}) {
    setState(() {
      if (_followedTitles.contains(title)) {
        _followedTitles.remove(title);
        if (apiTrack != null) {
          _followedApiTracks.removeWhere((t) => t.title == title);
        }
      } else {
        _followedTitles.add(title);
        if (apiTrack != null) {
          _followedApiTracks.add(apiTrack);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        // IndexedStack digunakan agar halaman bisa berganti sesuai _currentIndex
        child: Stack(
          children: [
            IndexedStack(
              index: _currentIndex,
              children: [
                _buildHomeContent(), // Index 0
                _buildSearchContent(), // Index 1
                _buildCollectionContent(), // Index 2
              ],
            ),
            // Mini Player di atas navigasi bawah
            if (_currentPlayingTitle != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildMiniPlayer(),
              ),
          ],
        ),
      ),

      // Navigasi Bawah (Home, Cari, Koleksi)
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1E293B),
        selectedItemColor: const Color(0xFFD946EF), // Pink
        unselectedItemColor: Colors.white54,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Mengubah state index saat tombol ditekan
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Cari'),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Koleksi',
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Halaman 1: HOME
  // ==========================================
  Widget _buildHomeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Halo Divaa!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () => _showUserProfile(context),
                child: CircleAvatar(
                  key: ValueKey('home_profile_${_profileImageBytes.hashCode}'),
                  radius: 22,
                  backgroundColor: const Color(0xFFD946EF).withValues(alpha: 0.2),
                  foregroundImage: _profileImageBytes != null ? MemoryImage(_profileImageBytes!) : null,
                  child: _profileImageBytes == null
                      ? const Icon(Icons.person, color: Color(0xFFD946EF), size: 24)
                      : null,
                ),
              ),
            ],
          ),
        ),

        // Kategori
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip('Semua', _selectedCategory == 'Semua'),
                _buildCategoryChip('Musik, Mengikuti', _selectedCategory == 'Musik, Mengikuti'),
                _buildCategoryChip('Podcast, mengikuti', _selectedCategory == 'Podcast, mengikuti'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Kartu Utama (Featured Music)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _buildFeaturedCard(),
          ),
        ),

        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Baru Diputar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        // Daftar Lagu (List)
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _buildListItems(),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // Fitur User Profil Modal Bottom Sheet
  // ==========================================
  void _showUserProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    children: [
                      CircleAvatar(
                        key: ValueKey('modal_profile_${_profileImageBytes.hashCode}'),
                        radius: 40,
                        backgroundColor: const Color(0xFFD946EF),
                        foregroundImage: _profileImageBytes != null ? MemoryImage(_profileImageBytes!) : null,
                        child: _profileImageBytes == null
                            ? const Icon(Icons.person, size: 40, color: Colors.white)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () async {
                            await _pickImage();
                            setModalState(() {}); // Rebuild modal UI
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFD946EF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
              const SizedBox(height: 16),
              const Text(
                'Halo Divaa!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 4),
              const Text('divaa@example.com', style: TextStyle(color: Colors.white54)),
              const SizedBox(height: 24),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.settings, color: Colors.white),
                ),
                title: const Text('Pengaturan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.logout, color: Colors.redAccent),
                ),
                title: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 20),
            ],
          ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // Komponen Berubah Sesuai Kategori
  // ==========================================
  Widget _buildFeaturedCard() {
    if (_selectedCategory == 'Podcast, mengikuti') {
      return Container(
        key: const ValueKey('podcast'),
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3B82F6), Color(0xFF10B981)], // Biru ke Hijau
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(
              'Podcast Inspiratif',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const Text('Ngobrol santai penuh makna', style: TextStyle(color: Colors.white)),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.play_arrow, color: Color(0xFF3B82F6)),
              ),
            ),
          ],
        ),
      );
    } else if (_selectedCategory == 'Musik, Mengikuti') {
      return Container(
        key: const ValueKey('musik'),
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF59E0B), Color(0xFFEF4444)], // Orange ke Merah
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(
              'Musik Favorit',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const Text('Artis yang Anda ikuti', style: TextStyle(color: Colors.white)),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.play_arrow, color: Color(0xFFEF4444)),
              ),
            ),
          ],
        ),
      );
    } else {
      // Semua
      return Container(
        key: const ValueKey('semua'),
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFD946EF), Color(0xFF8B5CF6)], // Pink ke Ungu
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(
              'Pop Terkini',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const Text('Lagu pop paling hits hari ini', style: TextStyle(color: Colors.white)),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.play_arrow, color: Color(0xFFD946EF)),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildListItems() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFD946EF)),
      );
    }

    List<MusicTrack> displayTracks = _apiTracks;
    if (_selectedCategory == 'Musik, Mengikuti') {
      displayTracks = _followedApiTracks;
    }

    if (displayTracks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.music_note_outlined, color: Colors.white24, size: 64),
            const SizedBox(height: 16),
            Text(
              _selectedCategory == 'Musik, Mengikuti' 
                  ? 'Belum ada lagu yang diikuti' 
                  : 'Tidak ada lagu ditemukan', 
              style: const TextStyle(color: Colors.white54)
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      key: ValueKey('api_list_$_selectedCategory'),
      padding: const EdgeInsets.all(20),
      itemCount: displayTracks.length,
      itemBuilder: (context, index) {
        final track = displayTracks[index];
        return _buildTrackItemFromApi(track);
      },
    );
  }

  Widget _buildTrackItemFromApi(MusicTrack track) {
    bool isCurrent = _currentPlayingTitle == track.title;

    return ListTile(
      onTap: () async {
        if (track.previewUrl.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maaf, Spotify tidak menyediakan pratinjau audio untuk lagu ini.'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
        if (isCurrent && _isPlaying) {
          await _audioPlayer.pause();
        } else {
          setState(() {
            _currentPlayingTitle = track.title;
            _currentApiTrack = track;
          });
          await _audioPlayer.play(UrlSource(track.previewUrl));
        }
      },
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: track.color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
          image: track.artworkUrl.isNotEmpty
              ? DecorationImage(image: NetworkImage(track.artworkUrl), fit: BoxFit.cover)
              : null,
        ),
        child: track.artworkUrl.isEmpty
            ? Icon(track.icon, color: track.color)
            : null,
      ),
      title: Text(
        track.title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isCurrent ? const Color(0xFFD946EF) : Colors.white,
        ),
      ),
      subtitle: Text(track.artist, style: const TextStyle(color: Colors.white54)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              _followedTitles.contains(track.title) ? Icons.check_circle : Icons.add_circle_outline,
              color: _followedTitles.contains(track.title) ? const Color(0xFF10B981) : Colors.white54,
            ),
            onPressed: () => _toggleFollow(track.title, apiTrack: track),
          ),
          IconButton(
            icon: Icon(
              _favorites.contains(track.title) ? Icons.favorite : Icons.favorite_border,
              color: _favorites.contains(track.title) ? const Color(0xFFD946EF) : Colors.white54,
            ),
            onPressed: () => _toggleFavorite(track.title, apiTrack: track),
          ),
        ],
      ),
    );
  }

  // Daftar lagu favorit untuk halaman Koleksi
  List<Map<String, dynamic>> get _favoriteTracks {
    return _allTracks.where((t) => _favorites.contains(t['title'])).toList();
  }

  // ==========================================
  // Halaman 2: PENCARIAN
  // ==========================================
  Widget _buildSearchContent() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cari',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Kolom Pencarian
          TextField(
            controller: _searchController,
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                _fetchMusicData(value);
              }
            },
            onChanged: (value) {
              setState(() {}); // Rebuild to update suffix icon and show results area
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () {
                if (value.isNotEmpty) {
                  _fetchMusicData(value);
                } else {
                  setState(() {
                    _apiTracks = [];
                  });
                }
              });
            },
            decoration: InputDecoration(
              hintText: 'Artis, lagu, atau podcast',
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white54),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _apiTracks = [];
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Tampilkan Hasil atau Genre
          Expanded(
            child: _searchController.text.isEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Jelajahi Genre',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.5,
                          children: [
                            _buildGenreCard('Pop', const Color(0xFFD946EF)),
                            _buildGenreCard('Rock', const Color(0xFF8B5CF6)),
                            _buildGenreCard('Hip Hop', const Color(0xFF3B82F6)),
                            _buildGenreCard('Jazz', const Color(0xFF10B981)),
                          ],
                        ),
                      ),
                    ],
                  )
                : _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFD946EF)))
                    : _apiTracks.isEmpty
                        ? const Center(child: Text('Tidak ada hasil ditemukan', style: TextStyle(color: Colors.white54)))
                        : ListView.builder(
                            itemCount: _apiTracks.length,
                            itemBuilder: (context, index) {
                              final track = _apiTracks[index];
                              return _buildTrackItemFromApi(track);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Halaman 3: KOLEKSI
  // ==========================================
  Widget _buildCollectionContent() {
    final favTracks = _favoriteTracks;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Koleksi Kamu',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // --- Header Lagu Favorit ---
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD946EF), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.favorite, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lagu yang Disukai',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    ),
                    Text(
                      '${_favorites.length} lagu',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // --- Daftar lagu favorit ---
          Expanded(
            child: _favorites.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 64,
                          color: const Color(0xFFD946EF).withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Belum ada lagu favorit',
                          style: TextStyle(fontSize: 16, color: Colors.white54),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tekan ❤️ pada lagu di halaman Home\nuntuk menambahkannya ke sini.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.white38),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    children: [
                      // Render Favorit Statis
                      ..._allTracks
                          .where((t) => _favorites.contains(t['title']) && !_favApiTracks.any((at) => at.title == t['title']))
                          .map((track) => _buildTrackItem(
                                track['title'] as String,
                                track['subtitle'] as String,
                                track['icon'] as IconData,
                                track['color'] as Color,
                              )),
                      // Render Favorit API
                      ..._favApiTracks.map((track) => _buildTrackItemFromApi(track)),
                      const SizedBox(height: 16),
                      ListTile(
                        onTap: _showCreatePlaylistDialog,
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                        title: const Text(
                          'Buat Playlist Baru',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ListTile(
                        onTap: _showSpotifyImportDialog,
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1DB954).withValues(alpha: 0.2), // Spotify Green
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.import_export, color: Color(0xFF1DB954)),
                        ),
                        title: const Text(
                          'Impor Album Spotify',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Playlist Kamu',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ..._userPlaylists.map((playlist) => _buildPlaylistTile(playlist)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // --- Widget Playlist Tile ---
  Widget _buildPlaylistTile(Playlist playlist) {
    return ListTile(
      onTap: () => _showPlaylistDetail(playlist),
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: playlist.color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(playlist.icon, color: playlist.color),
      ),
      title: Text(playlist.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('${playlist.trackTitles.length} lagu', style: const TextStyle(color: Colors.white54)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
    );
  }

  // --- Dialog Buat Playlist Baru ---
  void _showCreatePlaylistDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Buat Playlist Baru'),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Nama playlist',
            hintStyle: TextStyle(color: Colors.white24),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD946EF))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD946EF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _userPlaylists.add(Playlist(name: controller.text));
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- Detail Playlist Modal ---
  void _showPlaylistDetail(Playlist playlist) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final playlistTracks = _allTracks.where((t) => playlist.trackTitles.contains(t['title'])).toList();
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10))),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [playlist.color, playlist.color.withValues(alpha: 0.6)]),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(playlist.icon, color: Colors.white, size: 40),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(playlist.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('${playlist.trackTitles.length} lagu • Oleh Divaa', style: const TextStyle(color: Colors.white54)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  Expanded(
                    child: playlistTracks.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.music_off, size: 64, color: Colors.white10),
                                const SizedBox(height: 16),
                                const Text('Playlist ini masih kosong', style: TextStyle(color: Colors.white38)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: playlistTracks.length,
                            itemBuilder: (context, index) {
                              final track = playlistTracks[index];
                              return _buildTrackItem(
                                track['title'],
                                track['subtitle'],
                                track['icon'],
                                track['color'],
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  // Komponen tambahan pendukung
  Widget _buildCategoryChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
        // Fetch data based on category
        String query = label;
        if (label == 'Semua') query = 'Top Hits';
        if (label == 'Musik, Mengikuti') query = 'Justin Bieber';
        if (label == 'Podcast, mengikuti') query = 'Podcast';
        _fetchMusicData(query);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? null : Colors.white10,
          gradient: isSelected
              ? const LinearGradient(colors: [Color(0xFFD946EF), Color(0xFF8B5CF6)])
              : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.transparent : Colors.white24),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFD946EF).withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTrackItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    final isFav = _favorites.contains(title);
    final track = _allTracks.firstWhere((t) => t['title'] == title);
    return ListTile(
      onTap: () => _playTrack(title, track['url'] as String),
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tombol Favorite
          GestureDetector(
            onTap: () => _toggleFavorite(title),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                key: ValueKey(isFav),
                color: isFav ? const Color(0xFFD946EF) : Colors.white38,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white54),
            onPressed: () => _showTrackOptions(title),
          ),
        ],
      ),
    );
  }

  void _showTrackOptions(String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10))),
          ListTile(
            leading: const Icon(Icons.add_circle_outline, color: Color(0xFFD946EF)),
            title: const Text('Tambah ke Playlist'),
            onTap: () {
              Navigator.pop(context);
              _showAddToPlaylistDialog(title);
            },
          ),
          ListTile(
            leading: const Icon(Icons.share, color: Colors.white70),
            title: const Text('Bagikan'),
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showAddToPlaylistDialog(String trackTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Pilih Playlist'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _userPlaylists.length,
            itemBuilder: (context, index) {
              final playlist = _userPlaylists[index];
              return ListTile(
                leading: Icon(playlist.icon, color: playlist.color),
                title: Text(playlist.name),
                onTap: () {
                  setState(() {
                    if (!playlist.trackTitles.contains(trackTitle)) {
                      playlist.trackTitles.add(trackTitle);
                    }
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Berhasil ditambahkan ke ${playlist.name}')),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGenreCard(String title, Color color) {
    return GestureDetector(
      onTap: () {
        _searchController.text = title;
        _fetchMusicData(title);
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // Player Logic & UI
  // ==========================================
  void _playTrack(String title, String url) async {
    if (_currentPlayingTitle == title) {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.resume();
      }
    } else {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
      setState(() {
        _currentPlayingTitle = title;
        _currentApiTrack = null;
      });
    }
  }

  Widget _buildMiniPlayer() {
    // Cari track di data statis jika tidak ada di data API yang sedang diputar
    Map<String, dynamic>? staticTrack;
    if (_currentApiTrack == null) {
      try {
        staticTrack = _allTracks.firstWhere((t) => t['title'] == _currentPlayingTitle);
      } catch (e) {
        staticTrack = null;
      }
    }

    final String title = _currentApiTrack?.title ?? staticTrack?['title'] ?? 'Unknown';
    final String subtitle = _currentApiTrack?.artist ?? staticTrack?['subtitle'] ?? 'Unknown';
    final Color color = _currentApiTrack?.color ?? staticTrack?['color'] ?? const Color(0xFFD946EF);
    final IconData icon = _currentApiTrack?.icon ?? staticTrack?['icon'] ?? Icons.music_note;
    final String? artworkUrl = _currentApiTrack?.artworkUrl;

    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    image: artworkUrl != null && artworkUrl.isNotEmpty
                        ? DecorationImage(image: NetworkImage(artworkUrl), fit: BoxFit.cover)
                        : null,
                  ),
                  child: artworkUrl == null || artworkUrl.isEmpty
                      ? Icon(icon, color: color)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                iconSize: 40,
                color: const Color(0xFFD946EF),
                onPressed: () {
                  if (_isPlaying) {
                    _audioPlayer.pause();
                  } else {
                    _audioPlayer.resume();
                  }
                },
              ),
            ],
          ),
          // Progress Bar
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
              activeTrackColor: const Color(0xFFD946EF),
              inactiveTrackColor: Colors.white10,
              thumbColor: const Color(0xFFD946EF),
            ),
            child: Slider(
              value: _position.inSeconds.toDouble(),
              max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1.0,
              onChanged: (value) {
                _audioPlayer.seek(Duration(seconds: value.toInt()));
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Simulasi Impor Spotify ---
  void _showSpotifyImportDialog() {
    final controller = TextEditingController(text: 'https://api.spotify.com/v1/albums/4aawyAB9vmq7uU72jRu96y');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.library_music, color: Color(0xFF1DB954)),
            const SizedBox(width: 10),
            const Text('Spotify Album URL'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Masukkan endpoint Spotify API untuk mengimpor daftar lagu.',
              style: TextStyle(fontSize: 13, color: Colors.white54),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(
                labelText: 'API Link',
                labelStyle: TextStyle(color: Color(0xFF1DB954)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1DB954))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1DB954),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _simulateSpotifyFetch(controller.text);
            },
            child: const Text('Impor', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _simulateSpotifyFetch(String url) {
    // Simulasi loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF1DB954))),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context); // Close loading
        setState(() {
          _userPlaylists.add(Playlist(
            name: 'Spotify Album: Justice',
            trackTitles: ['GHOST', 'SORRY', 'I DONT CARE'],
            color: const Color(0xFF1DB954),
            icon: Icons.album,
          ));
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Album berhasil diimpor dari Spotify!')),
        );
      }
    });
  }
}
