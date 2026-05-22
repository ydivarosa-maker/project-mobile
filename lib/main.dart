import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/music_track.dart';
import 'services/music_api_service.dart';
import 'services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/firebase_service.dart';
import 'screens/login_screen.dart';
import 'screens/lyrics_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: kIsWeb
          ? const FirebaseOptions(
              apiKey: 'dummy-api-key',
              appId: '1:1234567890:web:dummy',
              messagingSenderId: '1234567890',
              projectId: 'dummy-project',
              storageBucket: 'dummy-bucket',
            )
          : null,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
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

class MelodyaApp extends StatefulWidget {
  const MelodyaApp({super.key});

  @override
  State<MelodyaApp> createState() => _MelodyaAppState();
}

class _MelodyaAppState extends State<MelodyaApp> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Melodya',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primaryColor: const Color(0xFFD946EF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onStarted;
  const WelcomeScreen({super.key, required this.onStarted});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.5, -0.5),
            radius: 1.5,
            colors: [Color(0xFF8B5CF6), Color(0xFF0F172A)],
            stops: [0.0, 1.0],
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          child: isDesktop
              ? DesktopLayout(onStarted: () => _goToAuth(context))
              : MobileLandingLayout(onStarted: () => _goToAuth(context)),
        ),
      ),
    );
  }

  void _goToAuth(BuildContext context) {
    onStarted();
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService authService = AuthService();
  bool _developerBypass = false;

  @override
  Widget build(BuildContext context) {
    if (_developerBypass) {
      return MobileAppLayout(
        onLogout: () async {
          setState(() {
            _developerBypass = false;
          });
        },
      );
    }

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Menunggu status auth
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0F172A),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFD946EF)),
            ),
          );
        }
        // User sudah login → tampilkan app
        if (snapshot.hasData && snapshot.data != null) {
          return MobileAppLayout(
            onLogout: () async {
              await authService.signOut();
            },
          );
        }
        // Belum login → tampilkan WelcomeScreen dengan tombol mulai langsung ke landing app
        return WelcomeScreen(
          onStarted: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MobileAppLayout(
                  onLogout: () async {
                    await authService.signOut();
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class DesktopLayout extends StatelessWidget {
  final VoidCallback onStarted;
  const DesktopLayout({super.key, required this.onStarted});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.music_note,
                        color: Color(0xFFD946EF),
                        size: 50,
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
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD946EF),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 10,
                      shadowColor: const Color(
                        0xFFD946EF,
                      ).withValues(alpha: 0.5),
                    ),
                    onPressed: onStarted,
                    child: const Text(
                      'Mulai Dengarkan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: PhoneMockup(
              onLogout: onStarted,
            ), // Gunakan callback untuk logout di mockup
          ),
        ],
      ),
    );
  }
}

class MobileLandingLayout extends StatelessWidget {
  final VoidCallback onStarted;
  const MobileLandingLayout({super.key, required this.onStarted});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.music_note, color: Color(0xFFD946EF), size: 80),
          const SizedBox(height: 24),
          const Text(
            'Melodya',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Dengarkan Musik\nFavoritmu Tanpa Batas',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.2,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Jelajahi jutaan lagu, buat playlist impianmu, dan nikmati kualitas audio terbaik.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 60),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD946EF),
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 10,
              shadowColor: const Color(0xFFD946EF).withValues(alpha: 0.5),
            ),
            onPressed: onStarted,
            child: const Text(
              'Mulai Dengarkan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PhoneMockup extends StatefulWidget {
  final FutureOr<void> Function() onLogout;
  const PhoneMockup({super.key, required this.onLogout});

  @override
  State<PhoneMockup> createState() => _PhoneMockupState();
}

class _PhoneMockupState extends State<PhoneMockup> {
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
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(32)),
        child: MobileAppLayout(onLogout: widget.onLogout),
      ),
    );
  }
}

class MobileAppLayout extends StatefulWidget {
  final FutureOr<void> Function() onLogout;
  const MobileAppLayout({super.key, required this.onLogout});

  @override
  State<MobileAppLayout> createState() => _MobileAppLayoutState();
}

class _MobileAppLayoutState extends State<MobileAppLayout> {
  int _currentIndex = 0;
  String _selectedCategory = 'Semua';

  // Firebase services
  final AuthService _authService = AuthService();
  final FirebaseService _firebaseService = FirebaseService();

  // State untuk menyimpan lagu favorit (dari Firestore)
  Set<String> _favorites = {};
  List<MusicTrack> _favApiTracks = [];

  // State untuk artis yang diikuti (dari Firestore)
  Set<String> _followedTitles = {};
  List<MusicTrack> _followedApiTracks = [];

  // State untuk playlist (dari Firestore)
  final List<Playlist> _userPlaylists = [
    Playlist(
      name: 'Hits Indonesia',
      trackTitles: ['GHOST', 'SORRY'],
      color: const Color(0xFF8B5CF6),
    ),
  ];

  // Stream subscriptions
  StreamSubscription? _favSubscription;
  StreamSubscription? _followedSubscription;

  // Audio Player State
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentPlayingTitle;
  MusicTrack? _currentApiTrack;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  // Profile State
  Uint8List? _profileImageBytes;
  String? _profileImageUrl; // URL dari Firebase Storage
  final ImagePicker _picker = ImagePicker();

  // API State
  final MusicApiService _apiService = MusicApiService();
  List<MusicTrack> _apiTracks = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  String get _userId => _authService.currentUser?.uid ?? '';
  bool get _isAnonymous => _authService.currentUser?.isAnonymous ?? true;

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengambil data: $e')));
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
        // Upload ke Firebase Storage jika bukan anonymous
        if (!_isAnonymous && _userId.isNotEmpty) {
          try {
            final url = await _firebaseService.uploadProfileImage(
              _userId,
              bytes,
            );
            setState(() {
              _profileImageUrl = url;
            });
          } catch (_) {
            // Upload gagal, tetap tampilkan gambar lokal
          }
        }
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengambil gambar: $e')));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchMusicData('Justin Bieber');

    // Subscribe ke Firestore stream favorit
    if (_userId.isNotEmpty) {
      _favSubscription = _firebaseService.getFavoritesStream(_userId).listen((
        tracks,
      ) {
        if (mounted) {
          setState(() {
            _favApiTracks = tracks;
            _favorites = tracks.map((t) => t.title).toSet();
          });
        }
      });

      // Subscribe ke Firestore stream followed
      _followedSubscription = _firebaseService
          .getFollowedStream(_userId)
          .listen((tracks) {
            if (mounted) {
              setState(() {
                _followedApiTracks = tracks;
                _followedTitles = tracks.map((t) => t.title).toSet();
              });
            }
          });

      // Ambil foto profil dari Firebase Storage
      _firebaseService.getProfileImageUrl(_userId).then((url) {
        if (url != null && mounted) {
          setState(() => _profileImageUrl = url);
        }
      });
    }

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
    _favSubscription?.cancel();
    _followedSubscription?.cancel();
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
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
    },
    {
      'title': 'SORRY',
      'subtitle': 'Artis Justin Bieber',
      'icon': Icons.library_music,
      'color': Color(0xFFD946EF),
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
    },
    {
      'title': 'I DONT CARE',
      'subtitle': 'Artis Justin Bieber',
      'icon': Icons.album,
      'color': Color(0xFF3B82F6),
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
    },
    {
      'title': 'Kisah Sukses',
      'subtitle': 'Podcast Motivasi',
      'icon': Icons.mic,
      'color': Color(0xFF3B82F6),
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
    },
    {
      'title': 'Obrolan Malam',
      'subtitle': 'Podcast Horor',
      'icon': Icons.mic_external_on,
      'color': Color(0xFF10B981),
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
    },
    {
      'title': 'Dunia Tech',
      'subtitle': 'Podcast IT',
      'icon': Icons.headset_mic,
      'color': Color(0xFFF59E0B),
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
    },
    {
      'title': 'Pagi Ceria',
      'subtitle': 'Radio FM Nasional',
      'icon': Icons.radio,
      'color': Color(0xFFF59E0B),
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',
    },
    {
      'title': 'Sore Santai',
      'subtitle': 'Hits Radio Lokal',
      'icon': Icons.radio,
      'color': Color(0xFFEF4444),
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
    },
  ];

  void _toggleFavorite(String title, {MusicTrack? apiTrack}) {
    setState(() {
      if (_favorites.contains(title)) {
        _favorites.remove(title);
        _favApiTracks.removeWhere((t) => t.title == title);
      } else {
        _favorites.add(title);
        if (apiTrack != null) _favApiTracks.add(apiTrack);
      }
    });
    // Simpan ke Firestore jika bukan anonymous
    if (!_isAnonymous && _userId.isNotEmpty && apiTrack != null) {
      if (_favorites.contains(title)) {
        _firebaseService.addFavorite(_userId, apiTrack);
      } else {
        _firebaseService.removeFavorite(_userId, title);
      }
    }
  }

  void _toggleFollow(String title, {MusicTrack? apiTrack}) {
    setState(() {
      if (_followedTitles.contains(title)) {
        _followedTitles.remove(title);
        _followedApiTracks.removeWhere((t) => t.title == title);
      } else {
        _followedTitles.add(title);
        if (apiTrack != null) _followedApiTracks.add(apiTrack);
      }
    });
    // Simpan ke Firestore jika bukan anonymous
    if (!_isAnonymous && _userId.isNotEmpty && apiTrack != null) {
      if (_followedTitles.contains(title)) {
        _firebaseService.addFollowed(_userId, apiTrack);
      } else {
        _firebaseService.removeFollowed(_userId, title);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
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
            Positioned(bottom: 0, left: 0, right: 0, child: _buildMiniPlayer()),
        ],
      ),

      // Navigasi Bawah
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1E293B),
        selectedItemColor: const Color(0xFFD946EF), // Pink
        unselectedItemColor: Colors.white54,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
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
              Row(
                children: [
                  const SizedBox(width: 8), // Placeholder untuk alignment
                  const SizedBox(width: 8),
                  Text(
                    'Halo, ${_isAnonymous ? 'Tamu' : (_authService.currentUser?.displayName?.split(' ').first ?? _authService.currentUser?.email?.split('@').first ?? 'User')}!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _showUserProfile(context),
                child: CircleAvatar(
                  key: ValueKey(
                    'home_profile_${_profileImageBytes.hashCode}_$_profileImageUrl',
                  ),
                  radius: 22,
                  backgroundColor: const Color(
                    0xFFD946EF,
                  ).withValues(alpha: 0.2),
                  foregroundImage: _profileImageBytes != null
                      ? MemoryImage(_profileImageBytes!)
                      : (_profileImageUrl != null
                            ? NetworkImage(_profileImageUrl!) as ImageProvider
                            : null),
                  child:
                      (_profileImageBytes == null && _profileImageUrl == null)
                      ? const Icon(
                          Icons.person,
                          color: Color(0xFFD946EF),
                          size: 24,
                        )
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
                _buildCategoryChip('Musik', _selectedCategory == 'Musik'),
                _buildCategoryChip('Podcast', _selectedCategory == 'Podcast'),
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
                        key: ValueKey(
                          'modal_profile_${_profileImageBytes.hashCode}',
                        ),
                        radius: 40,
                        backgroundColor: const Color(0xFFD946EF),
                        foregroundImage: _profileImageBytes != null
                            ? MemoryImage(_profileImageBytes!)
                            : null,
                        child: _profileImageBytes == null
                            ? const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white,
                              )
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
                            child: const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isAnonymous
                        ? 'Tamu'
                        : (_authService.currentUser?.displayName ??
                              'Melodya User'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isAnonymous
                        ? 'Mode tamu'
                        : (_authService.currentUser?.email ?? ''),
                    style: const TextStyle(color: Colors.white54),
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.settings, color: Colors.white),
                    ),
                    title: const Text(
                      'Pengaturan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.white54,
                    ),
                    onTap: () {
                      Navigator.pop(context); // Tutup modal
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.logout, color: Colors.redAccent),
                    ),
                    title: const Text(
                      'Keluar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.white54,
                    ),
                    onTap: () async {
                      Navigator.pop(context); // Tutup modal
                      await _authService.signOut(); // Firebase sign out
                      if (mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => WelcomeScreen(
                              onStarted: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          (route) => false,
                        );
                      }
                    },
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
    if (_selectedCategory == 'Podcast') {
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
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              'Ngobrol santai penuh makna',
              style: TextStyle(color: Colors.white),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow, color: Color(0xFF3B82F6)),
              ),
            ),
          ],
        ),
      );
    } else if (_selectedCategory == 'Musik') {
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
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              'Artis yang Anda ikuti',
              style: TextStyle(color: Colors.white),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
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
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              'Lagu pop paling hits hari ini',
              style: TextStyle(color: Colors.white),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
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
    if (_selectedCategory == 'Musik') {
      displayTracks = _followedApiTracks;
    }

    if (displayTracks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.music_note_outlined,
              color: Colors.white24,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _selectedCategory == 'Musik'
                  ? 'Belum ada lagu yang diikuti'
                  : 'Tidak ada lagu ditemukan',
              style: const TextStyle(color: Colors.white54),
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
              content: Text(
                'Maaf, Spotify tidak menyediakan pratinjau audio untuk lagu ini.',
              ),
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
              ? DecorationImage(
                  image: NetworkImage(track.artworkUrl),
                  fit: BoxFit.cover,
                )
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
      subtitle: Text(
        track.artist,
        style: const TextStyle(color: Colors.white54),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.lyrics, color: Colors.white54),
            tooltip: 'Lihat Lirik',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LyricsScreen(track: track),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              _followedTitles.contains(track.title)
                  ? Icons.check_circle
                  : Icons.add_circle_outline,
              color: _followedTitles.contains(track.title)
                  ? const Color(0xFF10B981)
                  : Colors.white54,
            ),
            onPressed: () => _toggleFollow(track.title, apiTrack: track),
          ),
          IconButton(
            icon: Icon(
              _favorites.contains(track.title)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: _favorites.contains(track.title)
                  ? const Color(0xFFD946EF)
                  : Colors.white54,
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
          Row(
            children: [
              const SizedBox(width: 8), // Placeholder untuk alignment
              const SizedBox(width: 8),
              const Text(
                'Cari',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ],
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
              setState(
                () {},
              ); // Rebuild to update suffix icon and show results area
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFD946EF)),
                  )
                : _apiTracks.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada hasil ditemukan',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
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
          Row(
            children: [
              const SizedBox(width: 8), // Placeholder untuk alignment
              const SizedBox(width: 8),
              const Text(
                'Koleksi Kamu',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ],
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
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lagu yang Disukai',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${_favorites.length} lagu',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
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
                          .where(
                            (t) =>
                                _favorites.contains(t['title']) &&
                                !_favApiTracks.any(
                                  (at) => at.title == t['title'],
                                ),
                          )
                          .map(
                            (track) => _buildTrackItem(
                              track['title'] as String,
                              track['subtitle'] as String,
                              track['icon'] as IconData,
                              track['color'] as Color,
                            ),
                          ),
                      // Render Favorit API
                      ..._favApiTracks.map(
                        (track) => _buildTrackItemFromApi(track),
                      ),
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
                            color: const Color(
                              0xFF1DB954,
                            ).withValues(alpha: 0.2), // Spotify Green
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.import_export,
                            color: Color(0xFF1DB954),
                          ),
                        ),
                        title: const Text(
                          'Impor Album Spotify',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Playlist Kamu',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._userPlaylists.map(
                        (playlist) => _buildPlaylistTile(playlist),
                      ),
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
      title: Text(
        playlist.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${playlist.trackTitles.length} lagu',
        style: const TextStyle(color: Colors.white54),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.white54,
      ),
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
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFD946EF)),
            ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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
            final playlistTracks = _allTracks
                .where((t) => playlist.trackTitles.contains(t['title']))
                .toList();
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                playlist.color,
                                playlist.color.withValues(alpha: 0.6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            playlist.icon,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                playlist.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${playlist.trackTitles.length} lagu • Oleh Divaa',
                                style: const TextStyle(color: Colors.white54),
                              ),
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
                                Icon(
                                  Icons.music_off,
                                  size: 64,
                                  color: Colors.white10,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Playlist ini masih kosong',
                                  style: TextStyle(color: Colors.white38),
                                ),
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
          },
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
        if (label == 'Semua') query = 'Justin Bieber';
        if (label == 'Musik') query = 'Justin Bieber';
        if (label == 'Podcast') query = 'Podcast';
        _fetchMusicData(query);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? null : Colors.white10,
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFD946EF), Color(0xFF8B5CF6)],
                )
              : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.white24,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFD946EF).withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
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
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.add_circle_outline,
              color: Color(0xFFD946EF),
            ),
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
                    SnackBar(
                      content: Text('Berhasil ditambahkan ke ${playlist.name}'),
                    ),
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
        staticTrack = _allTracks.firstWhere(
          (t) => t['title'] == _currentPlayingTitle,
        );
      } catch (e) {
        staticTrack = null;
      }
    }

    final String title =
        _currentApiTrack?.title ?? staticTrack?['title'] ?? 'Unknown';
    final String subtitle =
        _currentApiTrack?.artist ?? staticTrack?['subtitle'] ?? 'Unknown';
    final Color color =
        _currentApiTrack?.color ??
        staticTrack?['color'] ??
        const Color(0xFFD946EF);
    final IconData icon =
        _currentApiTrack?.icon ?? staticTrack?['icon'] ?? Icons.music_note;
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
                        ? DecorationImage(
                            image: NetworkImage(artworkUrl),
                            fit: BoxFit.cover,
                          )
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  _isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                ),
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
              max: _duration.inSeconds.toDouble() > 0
                  ? _duration.inSeconds.toDouble()
                  : 1.0,
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
    final controller = TextEditingController(
      text: 'https://api.spotify.com/v1/albums/4aawyAB9vmq7uU72jRu96y',
    );
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
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF1DB954)),
                ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF1DB954)),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context); // Close loading
        setState(() {
          _userPlaylists.add(
            Playlist(
              name: 'Spotify Album: Justice',
              trackTitles: ['GHOST', 'SORRY', 'I DONT CARE'],
              color: const Color(0xFF1DB954),
              icon: Icons.album,
            ),
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Album berhasil diimpor dari Spotify!')),
        );
      }
    });
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _dataSaverEnabled = false;
  String _audioQuality = 'Tinggi';
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = _prefs?.getBool('notificationsEnabled') ?? true;
      _dataSaverEnabled = _prefs?.getBool('dataSaverEnabled') ?? false;
      _audioQuality = _prefs?.getString('audioQuality') ?? 'Tinggi';
    });
  }

  Future<void> _saveBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  Future<void> _saveString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan'), centerTitle: true),
      body: ListView(
        children: [
          _buildSectionHeader('Akun'),
          ListTile(
            leading: const Icon(Icons.person_outline, color: Colors.white70),
            title: const Text('Profil'),
            subtitle: const Text(
              'Divaa, divaa@example.com',
              style: TextStyle(color: Colors.white54),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.white54),
            onTap: _showEditProfileDialog,
          ),
          const Divider(color: Colors.white10),
          _buildSectionHeader('Kualitas Audio'),
          ListTile(
            leading: const Icon(Icons.high_quality, color: Colors.white70),
            title: const Text('Kualitas Streaming'),
            subtitle: Text(
              _audioQuality,
              style: const TextStyle(color: Colors.white54),
            ),
            onTap: _showAudioQualityDialog,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.data_usage, color: Colors.white70),
            title: const Text('Mode Hemat Data'),
            subtitle: const Text(
              'Mengurangi kualitas audio untuk menghemat kuota',
              style: TextStyle(color: Colors.white54),
            ),
            value: _dataSaverEnabled,
            activeThumbColor: const Color(0xFFD946EF),
            onChanged: (value) {
              setState(() {
                _dataSaverEnabled = value;
              });
              _saveBool('dataSaverEnabled', value);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value
                        ? 'Mode Hemat Data aktif. Kualitas audio diturunkan.'
                        : 'Mode Hemat Data dimatikan.',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          const Divider(color: Colors.white10),
          _buildSectionHeader('Notifikasi'),
          SwitchListTile(
            secondary: const Icon(
              Icons.notifications_none,
              color: Colors.white70,
            ),
            title: const Text('Notifikasi Aplikasi'),
            subtitle: const Text(
              'Dapatkan info lagu baru dan update lainnya',
              style: TextStyle(color: Colors.white54),
            ),
            value: _notificationsEnabled,
            activeThumbColor: const Color(0xFFD946EF),
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
              _saveBool('notificationsEnabled', value);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value
                        ? 'Notifikasi telah diaktifkan.'
                        : 'Notifikasi telah dimatikan.',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          const Divider(color: Colors.white10),
          _buildSectionHeader('Tentang'),
          const ListTile(
            leading: Icon(Icons.info_outline, color: Colors.white70),
            title: Text('Versi Aplikasi'),
            trailing: Text('v1.2.0', style: TextStyle(color: Colors.white54)),
          ),
          ListTile(
            leading: const Icon(
              Icons.description_outlined,
              color: Colors.white70,
            ),
            title: const Text('Syarat & Ketentuan'),
            onTap: _showTermsDialog,
          ),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.white70),
            title: const Text('Tentang Aplikasi'),
            onTap: _showAboutAppDialog,
          ),
          const SizedBox(height: 40),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Melodya Music Player\nDibuat dengan ❤️ untuk pecinta musik',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFFD946EF),
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  void _showAudioQualityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Pilih Kualitas Audio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Otomatis', 'Rendah', 'Normal', 'Tinggi', 'Sangat Tinggi']
              .map((quality) {
                return RadioListTile<String>(
                  title: Text(
                    quality,
                    style: const TextStyle(color: Colors.white),
                  ),
                  value: quality,
                  groupValue: _audioQuality,
                  activeColor: const Color(0xFFD946EF),
                  onChanged: (value) {
                    setState(() {
                      _audioQuality = value!;
                    });
                    _saveString('audioQuality', value!);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Kualitas streaming diatur ke $value'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                );
              })
              .toList(),
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: 'Divaa');
    final emailController = TextEditingController(text: 'divaa@example.com');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Nama',
                labelStyle: TextStyle(color: Color(0xFFD946EF)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD946EF)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Color(0xFFD946EF)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD946EF)),
                ),
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
              backgroundColor: const Color(0xFFD946EF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profil berhasil diperbarui!'),
                  backgroundColor: Color(0xFFD946EF),
                ),
              );
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Syarat & Ketentuan'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '1. Penggunaan Layanan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Melodya Music Player adalah aplikasi streaming musik yang memungkinkan Anda mendengarkan lagu favorit Anda.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 16),
                const Text(
                  '2. Hak Cipta',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Semua konten musik di aplikasi ini dilindungi oleh hak cipta. Pengguna hanya dapat menggunakan konten untuk keperluan pribadi.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 16),
                const Text(
                  '3. Batasan Tanggung Jawab',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Kami tidak bertanggung jawab atas gangguan layanan atau kehilangan data yang terjadi. Gunakan aplikasi ini atas risiko Anda sendiri.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 16),
                const Text(
                  '4. Perubahan Ketentuan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Kami berhak mengubah syarat dan ketentuan ini kapan saja tanpa pemberitahuan sebelumnya.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD946EF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAboutAppDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tentang Aplikasi'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.music_note,
                  color: Color(0xFFD946EF),
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Melodya Music Player',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'v1.2.0',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Aplikasi musik streaming terbaik dengan koleksi jutaan lagu dari seluruh dunia.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Fitur Utama:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD946EF),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• Streaming musik berkualitas tinggi\n• Playlist pribadi dan playlist komunitas\n• Rekomendasi lagu berdasarkan preferensi\n• Sinkronisasi antar perangkat\n• Mode offline',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Dikembangkan dengan ❤️\nUntuk pecinta musik di seluruh dunia',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD946EF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
