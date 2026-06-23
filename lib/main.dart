import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'models/music_track.dart';
import 'services/music_api_service.dart';
import 'services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/local_storage_service.dart';
import 'services/playlist_service.dart';
import 'screens/lyrics_screen.dart';

const Color kColorBackground = Color(0xFF000000);
const Color kColorSurface = Color(0xFF090009);
const Color kColorSurfaceAlt = Color(0xFF14001F);
const Color kColorAccent = Color.fromARGB(
  255,
  95,
  7,
  167,
); // keep for buttons/other accents
// Landing gradient colors (left -> middle -> right): deep purple tones
const Color kGradientStart = Color(0xFF2B0038); // very dark purple
const Color kGradientMid = Color(0xFF45006C); // deep royal purple
const Color kGradientEnd = Color(0xFF1A0038); // almost black purple
// Backwards-compatible aliases used across the file
const Color kColorAccentPurple = kGradientStart;
const Color kColorAccentCyan = kGradientMid;
const Color kColorTextSecondary = Color(0xFFB8A5D0);

class VisualizerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += size.width / 6) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    final barPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.fill;

    final int numBars = 40;
    final double barWidth = size.width / numBars;
    final List<double> heights = [
      0.2,
      0.4,
      0.3,
      0.6,
      0.5,
      0.8,
      0.7,
      0.9,
      0.5,
      0.3,
      0.6,
      0.8,
      0.4,
      0.5,
      0.7,
      0.9,
      0.8,
      0.6,
      0.4,
      0.2,
      0.3,
      0.5,
      0.4,
      0.7,
      0.6,
      0.9,
      0.8,
      0.5,
      0.4,
      0.6,
      0.8,
      0.5,
      0.3,
      0.7,
      0.6,
      0.4,
      0.3,
      0.5,
      0.2,
      0.1,
    ];

    for (int i = 0; i < numBars; i++) {
      double h = heights[i % heights.length] * 150;
      canvas.drawRect(
        Rect.fromLTWH(i * barWidth + 2, size.height - h, barWidth - 4, h),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class VisualizerBackground extends StatelessWidget {
  final Widget child;
  const VisualizerBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E1E22),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: VisualizerPainter())),
          child,
        ],
      ),
    );
  }
}

class AdaptiveLogo extends StatelessWidget {
  final double size;
  const AdaptiveLogo({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 40,
      height: size + 40,
      decoration: BoxDecoration(
        color: const Color(0xFF252529),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB286FD).withOpacity(0.15),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.music_note,
          color: const Color(0xFFE0B0FF),
          size: size,
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PlaylistService.init();
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
    this.color = kColorAccent,
    this.icon = Icons.playlist_play,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'trackTitles': List<String>.from(trackTitles),
    'colorValue': color.value,
    'iconCodepoint': icon.codePoint,
  };

  static Playlist fromMap(Map<String, dynamic> m) => Playlist(
    name: m['name'] as String? ?? 'Playlist',
    trackTitles: List<String>.from(m['trackTitles'] as List? ?? []),
    color: Color(m['colorValue'] as int? ?? kColorAccent.value),
    icon: IconData(
      m['iconCodepoint'] as int? ?? Icons.playlist_play.codePoint,
      fontFamily: 'MaterialIcons',
    ),
  );
}

class MelodyaApp extends StatefulWidget {
  const MelodyaApp({super.key});

  @override
  State<MelodyaApp> createState() => _MelodyaAppState();
}

class _MelodyaAppState extends State<MelodyaApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Melodya',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kColorBackground,
        primaryColor: kColorAccent,
        colorScheme: ColorScheme.dark(
          background: kColorBackground,
          surface: kColorSurface,
          onSurface: Colors.white,
          primary: kColorAccent,
          secondary: kColorAccentCyan,
        ),
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
    return Scaffold(
      body: VisualizerBackground(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          child: Center(
            child: SingleChildScrollView(
              child: MobileLandingLayout(onStarted: () => _goToAuth(context)),
            ),
          ),
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
  bool _started = false;

  @override
  Widget build(BuildContext context) {
    if (!_started) {
      return WelcomeScreen(
        onStarted: () {
          setState(() {
            _started = true;
          });
        },
      );
    }

    // Langsung tampilkan app setelah klik mulai
    return MobileAppLayout(
      onLogout: () async {
        setState(() {
          _started = false;
        });
      },
    );
  }
}

class SimpleStartScreen extends StatelessWidget {
  final VoidCallback onStarted;
  const SimpleStartScreen({super.key, required this.onStarted});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VisualizerBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: MobileLandingLayout(onStarted: onStarted),
            ),
          ),
        ),
      ),
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
                        color: kColorAccent,
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
                      backgroundColor: kColorAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 10,
                      shadowColor: kColorAccent.withOpacity(0.5),
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
          const AdaptiveLogo(size: 80),
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFE0B0FF), Color(0xFFB286FD)],
            ).createShader(bounds),
            child: const Text(
              'Melodya',
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Dengarkan Musik\nFavoritmu Tanpa Batas',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.2,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Jelajahi jutaan lagu, buat playlist impianmu,\ndan nikmati kualitas audio terbaik.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.white60, height: 1.5),
          ),
          const SizedBox(height: 60),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB286FD),
                foregroundColor: const Color(0xFF3B1E6D),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                elevation: 0,
              ),
              onPressed: onStarted,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Mulai Dengarkan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.chevron_right, size: 24),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Sudah punya akun? ',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              GestureDetector(
                onTap: onStarted, // Navigate on tap
                child: const Text(
                  'Masuk',
                  style: TextStyle(
                    color: Color(0xFFE0B0FF),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
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
        color: kColorSurface,
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

class _MobileAppLayoutState extends State<MobileAppLayout>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  String _selectedCategory = 'Semua';
  String _selectedLibraryTab = 'Playlists';

  // Library search state
  String _librarySearchQuery = '';
  bool _librarySearchActive = false;

  // Local services
  final AuthService _authService = AuthService();
  final LocalStorageService _localService = LocalStorageService();

  // State untuk menyimpan lagu favorit (lokal)
  Set<String> _favorites = {};
  List<MusicTrack> _favApiTracks = [];

  // State untuk artis yang diikuti (lokal)
  Set<String> _followedTitles = {};
  List<MusicTrack> _followedApiTracks = [];

  // State untuk riwayat pemutaran (lokal)
  List<MusicTrack> _recentTracks = [];

  // Playlist Service (Hive)
  final PlaylistService _playlistService = PlaylistService();

  // State untuk playlist (Hive - persistent)
  List<Playlist> _userPlaylists = [];

  // Audio Player State
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentPlayingTitle;
  MusicTrack? _currentApiTrack;
  bool _isPlaying = false;
  // Control whether the player UI (mini/full) is visible. When false, audio continues
  // but the player UI is hidden.
  bool _showPlayerUi = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  // Profile State
  Uint8List? _profileImageBytes;
  final ImagePicker _picker = ImagePicker();

  // API State
  final MusicApiService _apiService = MusicApiService();
  List<MusicTrack> _apiTracks = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  late final AnimationController _rotationController;
  late final Animation<double> _rotationAnimation;
  Timer? _debounce;
  List<String> _recentSearches = [
    'Arctic Monkeys',
    'After Hours',
    'Techno 2024',
  ];

  String get _userName => _authService.currentUserDisplayName ?? 'Pengguna';
  bool get _isGuest => _userName == 'Tamu';

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
        // Foto profil disimpan hanya di memori (in-memory)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto profil berhasil diperbarui!'),
              backgroundColor: kColorAccent,
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
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );
    _fetchMusicData('Justin Bieber');

    // Muat favorit & followed dari SharedPreferences
    _localService.getFavorites().then((tracks) {
      if (mounted) {
        setState(() {
          _favApiTracks = tracks;
          _favorites = tracks.map((t) => t.title).toSet();
        });
      }
    });
    _localService.getFollowed().then((tracks) {
      if (mounted) {
        setState(() {
          _followedApiTracks = tracks;
          _followedTitles = tracks.map((t) => t.title).toSet();
        });
      }
    });

    _loadRecentTracks();
    _loadPlaylists();

    // Listen to player state changes
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          if (_isPlaying) {
            if (!_rotationController.isAnimating) {
              _rotationController.repeat();
            }
          } else {
            _rotationController.stop();
          }
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

  void _loadRecentTracks() {
    _localService.getRecent().then((tracks) {
      if (mounted) {
        setState(() {
          _recentTracks = tracks;
        });
      }
    });
  }

  /// Muat playlist dari Hive dan update state
  Future<void> _loadPlaylists() async {
    await _playlistService.initDefaults();
    final maps = _playlistService.getAll();
    if (mounted) {
      setState(() {
        _userPlaylists = maps.map(Playlist.fromMap).toList();
      });
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _audioPlayer.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Data semua track yang tersedia
  static const List<Map<String, dynamic>> _allTracks = [
    {
      'title': 'Synthwave Eclipse',
      'subtitle': 'Artis Neon Horizon',
      'icon': Icons.music_note,
      'color': kColorAccentPurple,
      'url':
          'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview115/v4/c3/84/c4/c384c478-f7b5-fb35-46eb-5bb7d22b2707/m4a.high.stream.mp4',
    },
    {
      'title': 'GHOST',
      'subtitle': 'Artis Justin Bieber',
      'icon': Icons.music_note,
      'color': kColorAccentPurple,
      'url':
          'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview125/v4/4a/eb/1e/4aeb1e8f-7f72-74cc-7f7a-1db2a32eb518/m4a.high.stream.mp4',
    },
    {
      'title': 'SORRY',
      'subtitle': 'Artis Justin Bieber',
      'icon': Icons.library_music,
      'color': kColorAccent,
      'url':
          'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview115/v4/cd/85/6d/cd856d3a-be7d-df98-5c12-32111c1dfb7a/m4a.high.stream.mp4',
    },
    {
      'title': 'I DONT CARE',
      'subtitle': 'Artis Justin Bieber',
      'icon': Icons.album,
      'color': kColorAccentCyan,
      'url':
          'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview128/v4/31/5b/4b/315b4b1a-2009-4171-8bc4-72791448b111/m4a.high.stream.mp4',
    },
    {
      'title': 'After Hours',
      'subtitle': 'Artis The Weeknd',
      'icon': Icons.waves,
      'color': Color(0xFF8E2DE2),
      'url':
          'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview115/v4/0f/50/de/0f50decf-f6f8-9a99-b1d6-b8166c30f4e3/m4a.high.stream.mp4',
    },
    {
      'title': 'Currents',
      'subtitle': 'Artis Tame Impala',
      'icon': Icons.nightlight_round,
      'color': Color(0xFF2C3E50),
      'url':
          'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview125/v4/2e/d0/52/2ed0525d-4f11-7360-1e5b-f54f7a26f634/m4a.high.stream.mp4',
    },
    {
      'title': 'Daily Mix 1',
      'subtitle': 'Artis M83, Justice, Daft Punk',
      'icon': Icons.album,
      'color': Colors.tealAccent,
      'url':
          'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview125/v4/c5/4b/65/c54b656b-a25e-e478-bfcf-76d33306c5be/m4a.high.stream.mp4',
    },
    {
      'title': 'Late Night Jazz',
      'subtitle': 'Artis Jazz Classics',
      'icon': Icons.mic,
      'color': Colors.orangeAccent,
      'url':
          'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview125/v4/44/2c/3e/442c3e1e-21ef-d75d-313d-cd30f5a7702f/m4a.high.stream.mp4',
    },
    {
      'title': 'Experimental Void',
      'subtitle': 'Artis IDM & Ambient',
      'icon': Icons.graphic_eq,
      'color': Colors.purpleAccent,
      'url':
          'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview125/v4/e0/75/5a/e0755a57-0a4a-4e8a-e9fa-5eb71a28a211/m4a.high.stream.mp4',
    },
    {
      'title': 'Kisah Sukses',
      'subtitle': 'Podcast Motivasi',
      'icon': Icons.mic,
      'color': kColorAccentCyan,
      'url':
          'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview115/v4/58/b7/cc/58b7cc40-8809-58b1-38eb-9a2cf52a0a2d/m4a.high.stream.mp4',
    },
    {
      'title': 'Obrolan Malam',
      'subtitle': 'Podcast Horor',
      'icon': Icons.mic_external_on,
      'color': kColorAccent,
      'url':
          'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview125/v4/c3/84/c4/c384c478-f7b5-fb35-46eb-5bb7d22b2707/m4a.high.stream.mp4',
    },
    {
      'title': 'Dunia Tech',
      'subtitle': 'Podcast IT',
      'icon': Icons.headset_mic,
      'color': kColorAccentCyan,
      'url':
          'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview115/v4/cd/85/6d/cd856d3a-be7d-df98-5c12-32111c1dfb7a/m4a.high.stream.mp4',
    },
    {
      'title': 'Pagi Ceria',
      'subtitle': 'Radio FM Nasional',
      'icon': Icons.radio,
      'color': kColorAccentCyan,
      'url':
          'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview128/v4/31/5b/4b/315b4b1a-2009-4171-8bc4-72791448b111/m4a.high.stream.mp4',
    },
    {
      'title': 'Sore Santai',
      'subtitle': 'Hits Radio Lokal',
      'icon': Icons.radio,
      'color': kColorAccentPurple,
      'url':
          'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview115/v4/0f/50/de/0f50decf-f6f8-9a99-b1d6-b8166c30f4e3/m4a.high.stream.mp4',
    },
  ];

  void _toggleFavorite(String title, {MusicTrack? apiTrack}) {
    setState(() {
      if (_favorites.contains(title)) {
        _favorites.remove(title);
        _favApiTracks.removeWhere((t) => t.title == title);
        _localService.removeFavorite(title);
      } else {
        _favorites.add(title);
        if (apiTrack != null) {
          _favApiTracks.add(apiTrack);
          _localService.addFavorite(apiTrack);
        }
      }
    });
  }

  void _toggleFollow(String title, {MusicTrack? apiTrack}) {
    setState(() {
      if (_followedTitles.contains(title)) {
        _followedTitles.remove(title);
        _followedApiTracks.removeWhere((t) => t.title == title);
        _localService.removeFollowed(title);
      } else {
        _followedTitles.add(title);
        if (apiTrack != null) {
          _followedApiTracks.add(apiTrack);
          _localService.addFollowed(apiTrack);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorBackground,
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
            if (_showPlayerUi)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildMiniPlayer(),
              ),
        ],
      ),

      // Navigasi Bawah
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: kColorSurface,
        selectedItemColor: kColorAccent, // Pink
        unselectedItemColor: Colors.white54,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Library',
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Halaman 1: HOME
  // ==========================================
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 18) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getGreetingCaption() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Start your day with some energizing tunes.';
    if (hour < 18) return 'Keep the vibe going this afternoon.';
    return 'The moon is high. Perfect for some synthwave.';
  }

  Widget _buildHomeContent() {
    return SafeArea(
      bottom: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => _showUserProfile(context),
                    child: CircleAvatar(
                      key: ValueKey(
                        'home_profile_${_profileImageBytes.hashCode}',
                      ),
                      radius: 20,
                      backgroundColor: kColorAccent.withOpacity(0.2),
                      foregroundImage: _profileImageBytes != null
                          ? MemoryImage(_profileImageBytes!)
                          : null,
                      child: _profileImageBytes == null
                          ? const Icon(
                              Icons.person,
                              color: kColorAccent,
                              size: 20,
                            )
                          : null,
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Melodya',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE0B0FF), // light purple
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Greeting
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getGreetingCaption(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Category Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryChip('Semua', _selectedCategory == 'Semua'),
                    _buildCategoryChip('Musik', _selectedCategory == 'Musik'),
                    _buildCategoryChip(
                      'Podcast',
                      _selectedCategory == 'Podcast',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Featured Card / Now Playing Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _buildFeaturedCard(),
            ),

            const SizedBox(height: 30),

            // Recently Played
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recently Played',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentIndex = 2; // Pindah ke tab Library
                      });
                    },
                    child: const Text(
                      'VIEW ALL',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.tealAccent,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: _recentTracks.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada riwayat pemutaran',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      itemCount: _recentTracks.length,
                      itemBuilder: (context, index) {
                        final track = _recentTracks[index];
                        return _buildRecentCard(
                          track.title,
                          track.artist,
                          [track.color, track.color.withOpacity(0.5)],
                          track.icon,
                          track.audioUrl,
                        );
                      },
                    ),
            ),

            const SizedBox(height: 30),

            // Local Playlists
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Local Playlists',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  _buildLocalPlaylistCard(
                    'Favorites / Top Tracks',
                    Icons.favorite,
                    Colors.tealAccent,
                    _favApiTracks,
                  ),
                  const SizedBox(height: 12),
                  _buildLocalPlaylistCard(
                    'All Songs / Local Audio',
                    Icons.library_music,
                    Colors.orangeAccent,
                    [
                      ..._apiTracks,
                      ..._recentTracks.where(
                        (t) => !_apiTracks.any((a) => a.title == t.title),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildLocalPlaylistCard(
                    'Acoustic Chill',
                    Icons.coffee,
                    Colors.purpleAccent,
                    [..._apiTracks, ..._favApiTracks].where((t) {
                      final q = '${t.title} ${t.artist}'.toLowerCase();
                      return q.contains('acoustic') ||
                          q.contains('chill') ||
                          q.contains('calm') ||
                          q.contains('slow') ||
                          q.contains('jazz') ||
                          q.contains('lofi') ||
                          q.contains('soft') ||
                          q.contains('relax');
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCard(
    String title,
    String subtitle,
    List<Color> gradientColors,
    IconData defaultIcon,
    String audioUrl,
  ) {
    return GestureDetector(
      onTap: () {
        _playTrack(title, audioUrl);
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
              ),
              child: Center(
                child: Icon(
                  defaultIcon,
                  size: 50,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalPlaylistCard(
    String title,
    IconData icon,
    Color accentColor,
    List<MusicTrack> tracks,
  ) {
    final bool isThisPlaying =
        _currentPlayingTitle != null &&
        tracks.any((t) => t.title == _currentPlayingTitle) &&
        _isPlaying;
    final int count = tracks.length;
    final String subtitle = count == 0
        ? 'Belum ada lagu'
        : '$count lagu tersedia';

    return GestureDetector(
      onTap: () => _showLocalPlaylistSheet(title, accentColor, icon, tracks),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: Border(left: BorderSide(color: accentColor, width: 3)),
              ),
              child: Icon(icon, color: Colors.white54, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isThisPlaying ? accentColor : Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                if (tracks.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Belum ada lagu di playlist ini.'),
                    ),
                  );
                  return;
                }
                _playOrPause(tracks.first);
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isThisPlaying ? accentColor : Colors.white24,
                  ),
                ),
                child: Icon(
                  isThisPlaying ? Icons.pause : Icons.play_arrow,
                  color: isThisPlaying ? accentColor : Colors.white70,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom sheet yang menampilkan daftar lagu di dalam Local Playlist
  void _showLocalPlaylistSheet(
    String title,
    Color accentColor,
    IconData icon,
    List<MusicTrack> tracks,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0A000F),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Handle bar
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(14),
                        border: Border(
                          left: BorderSide(color: accentColor, width: 3),
                        ),
                      ),
                      child: Icon(icon, color: Colors.white54, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${tracks.length} lagu',
                            style: TextStyle(
                              color: accentColor.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (tracks.isNotEmpty)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                        ),
                        icon: const Icon(Icons.shuffle, size: 16),
                        label: const Text(
                          'Acak',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () {
                          final shuffled = List<MusicTrack>.from(tracks)
                            ..shuffle();
                          Navigator.pop(ctx);
                          _playOrPause(shuffled.first);
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.white10, height: 1),
              // Track list
              Expanded(
                child: tracks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icon, color: Colors.white12, size: 60),
                            const SizedBox(height: 16),
                            const Text(
                              'Belum ada lagu di sini',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Cari & putar lagu terlebih dahulu',
                              style: TextStyle(
                                color: Colors.white24,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollCtrl,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: tracks.length,
                        itemBuilder: (_, i) {
                          final track = tracks[i];
                          final bool playing =
                              _currentPlayingTitle == track.title && _isPlaying;
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 4,
                            ),
                            leading: Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    track.color,
                                    track.color.withOpacity(0.5),
                                  ],
                                ),
                              ),
                              child: playing
                                  ? const Icon(
                                      Icons.graphic_eq,
                                      color: Colors.white,
                                      size: 22,
                                    )
                                  : Icon(
                                      track.icon,
                                      color: Colors.white70,
                                      size: 20,
                                    ),
                            ),
                            title: Text(
                              track.title,
                              style: TextStyle(
                                color: playing ? accentColor : Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              track.artist,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                playing
                                    ? Icons.pause_circle
                                    : Icons.play_circle,
                                color: playing ? accentColor : Colors.white54,
                                size: 30,
                              ),
                              onPressed: () {
                                Navigator.pop(ctx);
                                _playOrPause(track);
                              },
                            ),
                            onTap: () {
                              Navigator.pop(ctx);
                              _playOrPause(track);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
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
                color: kColorSurface,
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
                        backgroundColor: kColorAccent,
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
                              color: kColorAccent,
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
                    _userName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isGuest ? 'Mode tamu' : 'Pengguna Melodya',
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
                    onTap: () async {
                      Navigator.pop(context); // Tutup modal
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsPage(),
                        ),
                      );
                      await _authService.reload();
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
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
                      await _authService.signOut();
                      if (mounted) {
                        await widget.onLogout();
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
    if (_currentPlayingTitle != null) {
      return _buildNowPlayingCard();
    }

    if (_selectedCategory == 'Podcast') {
      return Container(
        key: const ValueKey('podcast'),
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kColorAccentCyan, kColorAccent], // Biru ke Hijau
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
                child: const Icon(Icons.play_arrow, color: kColorAccentCyan),
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
            colors: [kColorAccentCyan, kColorAccent], // Pink ke Ungu
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
                child: const Icon(Icons.play_arrow, color: kColorAccent),
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
            colors: [kColorAccent, kColorAccentPurple], // Pink ke Ungu
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
                child: const Icon(Icons.play_arrow, color: kColorAccent),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildNowPlayingCard() {
    final track = _currentlyPlayingTrack;
    if (track == null) return const SizedBox.shrink();

    final String title = track.title;
    final String subtitle = 'Artis ${track.artist}';
    final Color color = track.color;
    final String imageUrl = track.imageUrl;

    return Container(
      key: const ValueKey('now_playing'),
      constraints: const BoxConstraints(minHeight: 180),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.5)],
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          RotationTransition(
            turns: _rotationAnimation,
            child: ClipOval(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(color: color.withOpacity(0.2)),
                child: imageUrl.isNotEmpty
                    ? Image.network(imageUrl, fit: BoxFit.cover)
                    : Icon(track.icon, color: Colors.white, size: 46),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Sedang Diputar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: color,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () async {
                        try {
                          if (_isPlaying) {
                            await _audioPlayer.pause();
                          } else {
                            await _audioPlayer.resume();
                          }
                        } catch (e) {
                          _handlePlayerError(e);
                        }
                      },
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 20,
                      ),
                      label: Text(_isPlaying ? 'Pause' : 'Play'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white24,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LyricsScreen(track: track),
                          ),
                        );
                      },
                      icon: const Icon(Icons.lyrics, size: 20),
                      label: const Text('Lirik'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackItemFromApi(MusicTrack track) {
    bool isCurrent = _currentPlayingTitle == track.title;

    return ListTile(
      onTap: () async {
        if (track.audioUrl.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maaf, URL audio tidak tersedia untuk lagu ini.'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
        await _playOrPause(track);
      },
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: track.color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
          image: track.imageUrl.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(track.imageUrl),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: track.imageUrl.isEmpty
            ? Icon(track.icon, color: track.color)
            : null,
      ),
      title: Text(
        track.title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isCurrent ? kColorAccent : Colors.white,
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
                  ? kColorAccent
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
                  ? kColorAccent
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
          // Kolom Pencarian
          TextField(
            controller: _searchController,
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                // Add to recent searches
                setState(() {
                  _recentSearches.remove(value);
                  _recentSearches.insert(0, value);
                  if (_recentSearches.length > 10) {
                    _recentSearches = _recentSearches.sublist(0, 10);
                  }
                });
                _fetchMusicData(value);
              }
            },
            onChanged: (value) {
              setState(() {});
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
              hintText: 'Artists, songs, or podcasts',
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 15),
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
              fillColor: const Color(0xFF1A1A2E),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Tampilkan Hasil atau Browse
          Expanded(
            child: _searchController.text.isEmpty
                ? _buildSearchBrowseView()
                : _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: kColorAccent),
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

  /// Browse view with Recent Searches + Browse All genres
  Widget _buildSearchBrowseView() {
    return ListView(
      children: [
        // --- Recent Searches ---
        if (_recentSearches.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _recentSearches.clear();
                  });
                },
                child: const Text(
                  'CLEAR ALL',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kColorAccent,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _recentSearches.map((term) {
              return _buildRecentSearchChip(term);
            }).toList(),
          ),
          const SizedBox(height: 32),
        ],

        // --- Browse All ---
        const Text(
          'Browse All',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.15,
          children: [
            _buildBrowseGenreCard(
              'Pop',
              const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
              ),
              Icons.music_note,
              imageUrl: 'assets/images/pop.jpg',
            ),
            _buildBrowseGenreCard(
              'Indie',
              const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF00BCD4), Color(0xFF4CAF50)],
              ),
              Icons.headphones,
              imageUrl: 'assets/images/indie.jpg',
            ),
            _buildBrowseGenreCard(
              'Electronic',
              const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF7B1FA2), Color(0xFFE91E63)],
              ),
              Icons.equalizer,
              imageUrl: 'assets/images/electronic.jpg',
            ),
            _buildBrowseGenreCard(
              'Chill',
              const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0288D1), Color(0xFF00BCD4)],
              ),
              Icons.waves,
              imageUrl: 'assets/images/chill.jpg',
            ),
            _buildBrowseGenreCard(
              'Jazz',
              const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF57C00), Color(0xFFFFB300)],
              ),
              Icons.piano,
              imageUrl: 'assets/images/jazz.jpg',
            ),
            _buildBrowseGenreCard(
              'Rock',
              const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFD32F2F), Color(0xFFE91E63)],
              ),
              Icons.electric_bolt,
              imageUrl: 'assets/images/rock.jpg',
            ),
          ],
        ),
        const SizedBox(height: 100), // bottom padding for mini player
      ],
    );
  }

  /// A recent search chip with clock icon and delete (x) button
  Widget _buildRecentSearchChip(String term) {
    return GestureDetector(
      onTap: () {
        _searchController.text = term;
        _fetchMusicData(term);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history, color: Colors.white54, size: 18),
            const SizedBox(width: 8),
            Text(
              term,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  _recentSearches.remove(term);
                });
              },
              child: const Icon(Icons.close, color: Colors.white38, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  /// A Browse genre card with gradient background, icon and optional image
  Widget _buildBrowseGenreCard(
    String title,
    Gradient gradient,
    IconData icon, {
    String? imageUrl,
  }) {
    return GestureDetector(
      onTap: () {
        _searchController.text = title;
        // Add to recent searches
        setState(() {
          _recentSearches.remove(title);
          _recentSearches.insert(0, title);
          if (_recentSearches.length > 10) {
            _recentSearches = _recentSearches.sublist(0, 10);
          }
        });
        _fetchMusicData(title);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Optional image on the right-bottom (like a tilted phone/album)
            if (imageUrl != null) ...[
              Positioned(
                right: -12,
                bottom: -14,
                child: Transform.rotate(
                  angle: -0.18,
                  child: Container(
                    width: 92,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: imageUrl.startsWith('assets/')
                        ? Image.asset(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(color: Colors.black26),
                          )
                        : Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(color: Colors.black26),
                          ),
                  ),
                ),
              ),
            ] else ...[
              // Background icon (large, faded)
              Positioned(
                right: -10,
                bottom: -10,
                child: Transform.rotate(
                  angle: 0.3,
                  child: Icon(
                    icon,
                    size: 80,
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
              ),
            ],
            // Genre label
            Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // Halaman 3: KOLEKSI
  // ==========================================
  // --- Audio Waveform Painter for Liked Songs Card ---
  // ignore: unused_element
  Widget _buildWaveformDecoration() {
    return CustomPaint(
      painter: _LibraryWaveformPainter(),
      size: const Size(double.infinity, 180),
    );
  }

  Widget _buildCollectionContent() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Top Header: Logo + Settings ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _showUserProfile(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7B1FA2), Color(0xFFAB47BC)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7B1FA2).withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _profileImageBytes != null
                            ? ClipOval(
                                child: Image.memory(
                                  _profileImageBytes!,
                                  fit: BoxFit.cover,
                                  width: 36,
                                  height: 36,
                                ),
                              )
                            : const Icon(
                                Icons.music_note,
                                color: Colors.white,
                                size: 18,
                              ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFE0B0FF), Color(0xFFCE93D8)],
                      ).createShader(bounds),
                      child: const Text(
                        'Melodya',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: Colors.white70,
                    size: 24,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // --- "Your Library" Title + Search/Add ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Library',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    // 🔍 Tombol Pencarian In-Library
                    IconButton(
                      icon: Icon(
                        _librarySearchActive ? Icons.search_off : Icons.search,
                        color: _librarySearchActive
                            ? const Color(0xFFCE93D8)
                            : Colors.white,
                        size: 26,
                      ),
                      onPressed: () {
                        setState(() {
                          _librarySearchActive = !_librarySearchActive;
                          if (!_librarySearchActive) _librarySearchQuery = '';
                        });
                      },
                    ),
                    // + Tombol Buat Playlist Baru
                    IconButton(
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 26,
                      ),
                      onPressed: _showCreatePlaylistDialog,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- Search Bar (muncul jika aktif) ---
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _librarySearchActive
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF9C27B0).withOpacity(0.5),
                        ),
                      ),
                      child: TextField(
                        autofocus: true,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Cari playlist, artis, album...',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.35),
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFFCE93D8),
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _librarySearchQuery = val.toLowerCase();
                          });
                          if (_selectedLibraryTab == 'Albums') {
                            if (_debounce?.isActive ?? false)
                              _debounce!.cancel();
                            _debounce = Timer(
                              const Duration(milliseconds: 500),
                              () {
                                if (val.isNotEmpty) {
                                  _fetchMusicData(val);
                                } else {
                                  setState(() {
                                    _apiTracks = [];
                                  });
                                }
                              },
                            );
                          }
                        },
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // --- Tab Chips: Playlists / Artists / Albums ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Playlists', 'Artists', 'Albums'].map((tab) {
                  final isSelected = _selectedLibraryTab == tab;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedLibraryTab = tab;
                        });
                        if (tab == 'Albums' && _librarySearchQuery.isNotEmpty) {
                          _fetchMusicData(_librarySearchQuery);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF7B1FA2)
                              : Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF9C27B0)
                                : Colors.white.withOpacity(0.15),
                            width: 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF7B1FA2,
                                    ).withOpacity(0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : [],
                        ),
                        child: Text(
                          tab,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // --- Scrollable Content (Tab-aware) ---
          Expanded(
            child: _selectedLibraryTab == 'Playlists'
                ? _buildPlaylistsTabContent()
                : _selectedLibraryTab == 'Artists'
                ? _buildArtistsTabContent()
                : _buildAlbumsTabContent(),
          ),
        ],
      ),
    );
  }

  // --- Library Playlist Item Widget ---
  Widget _buildLibraryPlaylistItem({
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required IconData icon,
    VoidCallback? onTap,
    VoidCallback? onMoreTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () {},
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.white10,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                // Album art thumbnail
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors[0].withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white.withOpacity(0.8),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                // Three-dot menu
                IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.white.withOpacity(0.4),
                    size: 20,
                  ),
                  onPressed: onMoreTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =======================================================
  // LIBRARY TAB METHODS
  // =======================================================

  // --- Playlists Tab Content (data dari Hive + recently played real) ---
  Widget _buildPlaylistsTabContent() {
    // Recently played: ambil dari _recentTracks (track API), ambil maks 3
    final recentApiTracks = _recentTracks.take(3).toList();

    // Filter semua playlist berdasarkan query pencarian
    final filteredPlaylists = _librarySearchQuery.isEmpty
        ? _userPlaylists
        : _userPlaylists
              .where(
                (pl) => pl.name.toLowerCase().contains(_librarySearchQuery),
              )
              .toList();

    // Filter recently played berdasarkan query pencarian
    final filteredRecent = _librarySearchQuery.isEmpty
        ? recentApiTracks
        : recentApiTracks
              .where(
                (t) =>
                    t.title.toLowerCase().contains(_librarySearchQuery) ||
                    t.artist.toLowerCase().contains(_librarySearchQuery),
              )
              .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Liked Songs Card (tersembunyi saat search aktif & ada query) ---
          if (_librarySearchQuery.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: _showLikedSongsDetail,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1A0030),
                        Color(0xFF2D004F),
                        Color(0xFF1A0030),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7B1FA2).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _LibraryWaveformPainter(),
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  const Color(0xFF1A0030).withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.favorite,
                                    color: Color(0xFFCE93D8),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'COLLECTION',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFCE93D8),
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Liked Songs',
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_favorites.length} tracks in your vault',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.white.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (_favApiTracks.isNotEmpty) {
                                        _playOrPause(_favApiTracks.first);
                                      } else if (_favoriteTracks.isNotEmpty) {
                                        final t = _favoriteTracks.first;
                                        _playTrack(
                                          t['title'] as String,
                                          t['url'] as String,
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Tambahkan lagu favorit terlebih dahulu ♥',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFCE93D8),
                                            Color(0xFFAB47BC),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFFAB47BC,
                                            ).withOpacity(0.5),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          if (_librarySearchQuery.isEmpty) const SizedBox(height: 28),

          // --- Recently Played Header (hanya jika ada data & tidak search kosong) ---
          if (filteredRecent.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(
                    Icons.tune,
                    color: Colors.white.withOpacity(0.7),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Recently Played',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // --- Item Recently Played (dari API tracks) ---
            ...filteredRecent.map(
              (track) => _buildLibraryPlaylistItem(
                title: track.title,
                subtitle: 'Playlist • ${track.artist}',
                gradientColors: [track.color, track.color.withOpacity(0.6)],
                icon: Icons.music_note,
                onTap: () => _playOrPause(track),
                onMoreTap: () =>
                    _showLibraryItemOptions(track.title, isUserPlaylist: false),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // --- Semua Playlist Pengguna dari Hive ---
          if (filteredPlaylists.isNotEmpty) ...[
            if (_librarySearchQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Text(
                  '${filteredPlaylists.length} playlist ditemukan',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ...filteredPlaylists.map(
              (playlist) => _buildLibraryPlaylistItem(
                title: playlist.name,
                subtitle: 'Playlist • ${playlist.trackTitles.length} tracks',
                gradientColors: [
                  playlist.color,
                  playlist.color.withOpacity(0.7),
                ],
                icon: playlist.icon,
                onTap: () => _showPlaylistDetail(playlist),
                onMoreTap: () => _showLibraryItemOptions(
                  playlist.name,
                  isUserPlaylist: true,
                  playlist: playlist,
                ),
              ),
            ),
          ] else if (filteredPlaylists.isEmpty &&
              _librarySearchQuery.isNotEmpty) ...[
            // --- Empty search result ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.04),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: const Icon(
                        Icons.search_off,
                        color: Colors.white24,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tidak ada hasil untuk "$_librarySearchQuery"',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Coba kata kunci lain atau buat playlist baru',
                      style: TextStyle(color: Colors.white24, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ] else if (filteredPlaylists.isEmpty &&
              _librarySearchQuery.isEmpty) ...[
            // --- Empty state ketika belum ada playlist sama sekali ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.04),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: const Icon(
                        Icons.queue_music,
                        color: Colors.white24,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum ada playlist',
                      style: TextStyle(color: Colors.white38, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tekan + untuk membuat playlist pertamamu',
                      style: TextStyle(color: Colors.white24, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- Artists Tab Content ---
  Widget _buildArtistsTabContent() {
    // Kelompokkan tracks yang diikuti berdasarkan nama artis
    final Map<String, List<MusicTrack>> artistMap = {};
    for (final track in _followedApiTracks) {
      artistMap.putIfAbsent(track.artist, () => []).add(track);
    }

    if (artistMap.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
                border: Border.all(color: Colors.white12),
              ),
              child: const Icon(
                Icons.person_outline,
                color: Colors.white24,
                size: 44,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Belum ada artis yang diikuti',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ikuti artis melalui halaman Search',
              style: TextStyle(color: Colors.white30, fontSize: 13),
            ),
          ],
        ),
      );
    }

    final artists = artistMap.entries.toList();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
      itemCount: artists.length,
      itemBuilder: (context, index) {
        final entry = artists[index];
        final artistName = entry.key;
        final tracks = entry.value;
        final color = tracks.first.color;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showArtistDetail(artistName, tracks),
              borderRadius: BorderRadius.circular(12),
              splashColor: Colors.white10,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [color, color.withOpacity(0.5)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: tracks.first.imageUrl.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                tracks.first.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.person,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 26,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.person,
                              color: Colors.white.withOpacity(0.8),
                              size: 26,
                            ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            artistName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${tracks.length} lagu • Diikuti',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7B1FA2).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF7B1FA2).withOpacity(0.5),
                        ),
                      ),
                      child: const Text(
                        'Diikuti',
                        style: TextStyle(
                          color: Color(0xFFCE93D8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Albums Tab Content ---
  Widget _buildAlbumsTabContent() {
    List<Map<String, dynamic>> albums = [];

    if (_librarySearchQuery.isEmpty) {
      albums = [
        {
          'title': 'Justice',
          'artist': 'Justin Bieber',
          'year': '2021',
          'color': 0xFF1E3A8A, // Warna Biru Tua
          'icon': Icons.album_rounded, // Pola Piringan Hitam
          'gradient': <Color>[const Color(0xFF1E3A8A), const Color(0xFF0D47A1)],
          'tracks': <String>['GHOST', 'SORRY', 'I DONT CARE'],
        },
        {
          'title': 'After Hours',
          'artist': 'The Weeknd',
          'year': '2020',
          'color': 0xFF6A1B9A, // Warna Ungu Cerah
          'icon': Icons.nightlight_round, // Pola Bulan Sabit
          'gradient': <Color>[const Color(0xFF6A1B9A), const Color(0xFF4A00E0)],
          'tracks': <String>['After Hours'],
        },
        {
          'title': 'Currents',
          'artist': 'Tame Impala',
          'year': '2015',
          'color': 0xFF224E6A, // Warna Ocean Blue
          'icon': Icons.waves_rounded, // Pola Gelombang
          'gradient': <Color>[const Color(0xFF224E6A), const Color(0xFF1565C0)],
          'tracks': <String>['Currents'],
        },
        {
          'title': 'Starboy',
          'artist': 'The Weeknd',
          'year': '2016',
          'color': 0xFF4A148C, // Warna Deep Purple
          'icon': Icons.bar_chart_rounded, // Pola Equalizer Bar
          'gradient': <Color>[const Color(0xFF4A148C), const Color(0xFF311B92)],
          'tracks': <String>['Starboy'],
        },
      ];
    } else {
      if (_isLoading) {
        return const Center(
          child: CircularProgressIndicator(color: kColorAccent),
        );
      }
      if (_apiTracks.isNotEmpty) {
        // Gabungkan semua hasil pencarian ke dalam satu album
        String albumTitle = _librarySearchQuery
            .split(' ')
            .map(
              (str) => str.isNotEmpty
                  ? '${str[0].toUpperCase()}${str.substring(1)}'
                  : '',
            )
            .join(' ');

        albums.add({
          'title': albumTitle,
          'artist': 'Search Result',
          'year': DateTime.now().year.toString(),
          'color': _apiTracks.first.color.value,
          'icon': Icons.album,
          'gradient': <Color>[_apiTracks.first.color, Colors.black],
          'tracks': _apiTracks.map((t) => t.title).toList(),
          'api_tracks': _apiTracks,
        });
      }

      if (albums.isEmpty) {
        return const Center(
          child: Text(
            'Tidak ada album ditemukan',
            style: TextStyle(color: Colors.white54),
          ),
        );
      }
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: albums.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Membagi menjadi 2 kolom menyamping
        crossAxisSpacing: 16, // Jarak horizontal antar kartu
        mainAxisSpacing: 16, // Jarak vertikal antar kartu
        childAspectRatio:
            0.82, // Mengatur rasio tinggi/lebar kotak kartu agar teks tidak terpotong
      ),
      itemBuilder: (context, index) {
        final album = albums[index];
        return GestureDetector(
          onTap: () {
            // Taruh fungsi pemutaran playlist/album audio di sini
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Memutar album: ${album['title']}")),
            );
            // Tetap buka detail agar tidak kehilangan fungsionalitas UI lama
            _showAlbumDetail(album);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Color(album['color'] as int),
              borderRadius: BorderRadius.circular(
                24,
              ), // Sudut melengkung halus sesuai gambar
            ),
            child: Stack(
              children: [
                // 1. ELEMEN DEKORASI LATAR BELAKANG (Ikon Transparan Samar di Pojok Kanan Atas)
                Positioned(
                  top: -15,
                  right: -15,
                  child: Icon(
                    album['icon'] as IconData,
                    size: 140,
                    color: Colors.white.withOpacity(
                      0.06,
                    ), // Opacity sangat tipis (6%) agar terkesan estetik
                  ),
                ),

                // 2. ELEMEN TEKS INFORMASI (Berada di pojok kiri bawah kartu)
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:
                        MainAxisAlignment.end, // Memaksa teks menempel di bawah
                    children: [
                      Text(
                        album['title'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        album['artist'] as String,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        album['year'] as String,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Show Liked Songs Detail ---
  void _showLikedSongsDetail() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFF0D001A),
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
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7B1FA2), Color(0xFFAB47BC)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7B1FA2).withOpacity(0.5),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Liked Songs',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_favorites.length} lagu • Koleksimu',
                            style: const TextStyle(color: Colors.white54),
                          ),
                          if (_favorites.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF7B1FA2),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  if (_favApiTracks.isNotEmpty) {
                                    _playOrPause(_favApiTracks.first);
                                  } else if (_favoriteTracks.isNotEmpty) {
                                    final t = _favoriteTracks.first;
                                    _playTrack(
                                      t['title'] as String,
                                      t['url'] as String,
                                    );
                                  }
                                },
                                icon: const Icon(
                                  Icons.play_arrow,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Putar Semua',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white10, height: 1),
              Expanded(
                child: (_favApiTracks.isEmpty && _favoriteTracks.isEmpty)
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.04),
                              ),
                              child: const Icon(
                                Icons.favorite_border,
                                color: Colors.white24,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Belum ada lagu favorit',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tekan ♥ pada lagu untuk menyimpannya di sini',
                              style: TextStyle(
                                color: Colors.white24,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          ..._favApiTracks.map(
                            (track) => _buildTrackItemFromApi(track),
                          ),
                          ..._favoriteTracks.map(
                            (t) => _buildTrackItem(
                              t['title'] as String,
                              t['subtitle'] as String,
                              t['icon'] as IconData,
                              t['color'] as Color,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Show Artist Detail ---
  void _showArtistDetail(String artistName, List<MusicTrack> tracks) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final color = tracks.first.color;
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFF0A0A14),
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
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withOpacity(0.15), Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [color, color.withOpacity(0.5)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: tracks.first.imageUrl.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                tracks.first.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.person,
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
                            artistName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${tracks.length} lagu • Diikuti',
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
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tracks.length,
                  itemBuilder: (context, i) =>
                      _buildTrackItemFromApi(tracks[i]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Show Album Detail ---
  void _showAlbumDetail(Map<String, dynamic> album) {
    final trackTitles = (album['tracks'] as List).cast<String>();
    List<dynamic> tracks = [];
    bool isApiTracks = false;

    if (album.containsKey('api_tracks')) {
      tracks = album['api_tracks'];
      isApiTracks = true;
    } else {
      tracks = _allTracks
          .where((t) => trackTitles.contains(t['title']))
          .toList();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xFF0A0A14),
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
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: album['gradient'] as List<Color>,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.black26,
                    ),
                    child: Icon(
                      album['icon'] as IconData,
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
                          album['title'] as String,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${album['artist']} • ${album['year']}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${tracks.length} lagu',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1),
            Expanded(
              child: tracks.isEmpty
                  ? const Center(
                      child: Text(
                        'Tidak ada lagu tersedia',
                        style: TextStyle(color: Colors.white38),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: tracks.length,
                      itemBuilder: (context, i) {
                        if (isApiTracks) {
                          return _buildTrackItemFromApi(
                            tracks[i] as MusicTrack,
                          );
                        } else {
                          return _buildTrackItem(
                            tracks[i]['title'] as String,
                            tracks[i]['subtitle'] as String,
                            tracks[i]['icon'] as IconData,
                            tracks[i]['color'] as Color,
                          );
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Library Item More Options (context menu ⋮) ---
  void _showLibraryItemOptions(
    String title, {
    bool isUserPlaylist = false,
    Playlist? playlist,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0D001A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SingleChildScrollView(
        child: Column(
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
            const SizedBox(height: 10),
            // Header dengan nama playlist
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7B1FA2), Color(0xFFAB47BC)],
                      ),
                    ),
                    child: Icon(
                      playlist?.icon ?? Icons.queue_music,
                      color: Colors.white,
                      size: 24,
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
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (playlist != null)
                          Text(
                            'Playlist • ${playlist.trackTitles.length} tracks',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 4),
            ListTile(
              leading: const Icon(
                Icons.play_circle_outline,
                color: Color(0xFFAB47BC),
              ),
              title: const Text(
                'Putar Sekarang',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.queue_music, color: Colors.white70),
              title: const Text(
                'Tambah ke Antrian',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined, color: Colors.white70),
              title: const Text(
                'Bagikan Playlist',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => Navigator.pop(context),
            ),
            if (isUserPlaylist && playlist != null) ...[
              ListTile(
                leading: const Icon(
                  Icons.add_circle_outline,
                  color: Color(0xFF64B5F6),
                ),
                title: const Text(
                  'Tambahkan Lagu',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'Cari & tambahkan lagu ke playlist ini',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showAddSongsToPlaylist(playlist);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: Colors.white70),
                title: const Text(
                  'Ubah Nama Playlist',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showRenamePlaylistDialog(playlist);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),
                title: const Text(
                  'Hapus Playlist',
                  style: TextStyle(color: Colors.redAccent),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  // Konfirmasi sebelum hapus
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF0D001A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: const Text(
                        'Hapus Playlist',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: Text(
                        'Apakah kamu yakin ingin menghapus playlist "$title"? Tindakan ini tidak bisa dibatalkan.',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text(
                            'Batal',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text(
                            'Hapus',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await _playlistService.remove(playlist.name);
                    await _loadPlaylists();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('"$title" dihapus dari library'),
                          backgroundColor: Colors.redAccent.withOpacity(0.8),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Dialog Tambah Lagu ke Playlist ---
  void _showAddSongsToPlaylist(Playlist playlist) {
    String searchQuery = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final allAvailable = _allTracks
              .where((t) => !playlist.trackTitles.contains(t['title']))
              .where(
                (t) =>
                    searchQuery.isEmpty ||
                    (t['title'] as String).toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                    (t['subtitle'] as String).toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ),
              )
              .toList();

          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Color(0xFF0D001A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tambahkan Lagu',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'ke ${playlist.name}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white54),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: TextField(
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Cari lagu...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white38,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                      onChanged: (v) => setSheetState(() => searchQuery = v),
                    ),
                  ),
                ),
                const Divider(color: Colors.white10, height: 1),
                Expanded(
                  child: allAvailable.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.music_off,
                                color: Colors.white12,
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                searchQuery.isEmpty
                                    ? 'Semua lagu sudah ada di playlist ini'
                                    : 'Tidak ada lagu yang cocok',
                                style: const TextStyle(
                                  color: Colors.white30,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: allAvailable.length,
                          itemBuilder: (context, index) {
                            final track = allAvailable[index];
                            final trackTitle = track['title'] as String;
                            return ListTile(
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: (track['color'] as Color).withOpacity(
                                    0.3,
                                  ),
                                ),
                                child: Icon(
                                  track['icon'] as IconData,
                                  color: track['color'] as Color,
                                  size: 22,
                                ),
                              ),
                              title: Text(
                                trackTitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                track['subtitle'] as String,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 12,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.add_circle,
                                  color: Color(0xFFAB47BC),
                                  size: 28,
                                ),
                                onPressed: () async {
                                  // Tambah lagu ke playlist via PlaylistService
                                  final all = _playlistService.getAll();
                                  final idx = all.indexWhere(
                                    (p) => p['name'] == playlist.name,
                                  );
                                  if (idx != -1) {
                                    final titles = List<String>.from(
                                      all[idx]['trackTitles'] as List,
                                    );
                                    if (!titles.contains(trackTitle)) {
                                      titles.add(trackTitle);
                                      all[idx]['trackTitles'] = titles;
                                      await _playlistService.saveFromList(all);
                                      await _loadPlaylists();
                                      setSheetState(() {});
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '"$trackTitle" ditambahkan ke ${playlist.name}',
                                            ),
                                            backgroundColor: const Color(
                                              0xFF7B1FA2,
                                            ).withOpacity(0.9),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Rename Playlist Dialog ---
  void _showRenamePlaylistDialog(Playlist playlist) {
    final ctrl = TextEditingController(text: playlist.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kColorSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Ubah Nama Playlist'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Nama baru...',
            hintStyle: TextStyle(color: Colors.white24),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: kColorAccent),
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
              backgroundColor: kColorAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              if (ctrl.text.trim().isNotEmpty) {
                final oldName = playlist.name;
                final newName = ctrl.text.trim();
                await _playlistService.rename(oldName, newName);
                await _loadPlaylists();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nama playlist berhasil diubah!'),
                    ),
                  );
                }
              }
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- Dialog Buat Playlist Baru ---
  void _showCreatePlaylistDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kColorSurface,
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
              borderSide: BorderSide(color: kColorAccent),
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
              backgroundColor: kColorAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await _playlistService.add(name: controller.text.trim());
                await _loadPlaylists();
                if (mounted) {
                  Navigator.pop(context);
                }
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
                color: kColorBackground,
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
                                playlist.color.withOpacity(0.6),
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
              ? const LinearGradient(colors: [kColorAccent, kColorAccentPurple])
              : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.white24,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: kColorAccent.withOpacity(0.4),
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
          color: color.withOpacity(0.2),
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
                color: isFav ? kColorAccent : Colors.white38,
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
      backgroundColor: kColorSurface,
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
            leading: const Icon(Icons.add_circle_outline, color: kColorAccent),
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
        backgroundColor: kColorSurface,
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

  // ==========================================
  // Player Logic & UI
  // ==========================================
  MusicTrack? get _currentlyPlayingTrack {
    if (_currentApiTrack != null) {
      return _currentApiTrack;
    }
    if (_currentPlayingTitle != null) {
      try {
        final track = _allTracks.firstWhere(
          (t) => t['title'] == _currentPlayingTitle,
        );
        return MusicTrack(
          id: track['title'] as String,
          title: track['title'] as String,
          artist: (track['subtitle'] as String).replaceAll('Artis ', ''),
          audioUrl: track['url'] as String,
          imageUrl: '',
          color: track['color'] as Color? ?? kColorAccent,
          icon: track['icon'] as IconData? ?? Icons.music_note,
        );
      } catch (e) {
        // Not found in static tracks
        return MusicTrack(
          id: _currentPlayingTitle!,
          title: _currentPlayingTitle!,
          artist: 'Unknown Artist',
          audioUrl: '',
          imageUrl: '',
        );
      }
    }
    return null;
  }

  void _handlePlayerError(dynamic e) {
    if (!mounted) return;
    final errorStr = e.toString().toLowerCase();
    if (errorStr.contains('abort') ||
        errorStr.contains('pause') ||
        errorStr.contains('interrupt')) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Gagal memutar audio: $e')));
  }

  void _playTrack(String title, String url) async {
    if (_currentPlayingTitle == title) {
      try {
        if (_isPlaying) {
          await _audioPlayer.pause();
        } else {
          await _audioPlayer.resume();
        }
      } catch (e) {
        _handlePlayerError(e);
      }
    } else {
      setState(() {
        _currentPlayingTitle = title;
        _currentApiTrack = null;
        _showPlayerUi = true;
      });
      try {
        if (url.startsWith('http')) {
          await _audioPlayer.play(UrlSource(url));
        } else {
          await _audioPlayer.play(AssetSource(url));
        }
        final trackToSave = _currentlyPlayingTrack;
        if (trackToSave != null) {
          await _localService.addRecent(trackToSave);
          _loadRecentTracks();
        }
      } catch (e) {
        _handlePlayerError(e);
      }
    }
  }

  Future<void> _playOrPause(MusicTrack track) async {
    if (_currentApiTrack?.id == track.id) {
      try {
        if (_isPlaying) {
          await _audioPlayer.pause();
          setState(() => _isPlaying = false);
        } else {
          await _audioPlayer.resume();
          setState(() => _isPlaying = true);
        }
      } catch (e) {
        _handlePlayerError(e);
      }
    } else {
      setState(() {
        _currentApiTrack = track;
        _currentPlayingTitle = track.title;
        _isPlaying = true;
        _showPlayerUi = true;
      });
      try {
        if (track.audioUrl.startsWith('http')) {
          await _audioPlayer.play(UrlSource(track.audioUrl));
        } else {
          await _audioPlayer.play(AssetSource(track.audioUrl));
        }
        await _localService.addRecent(track);
        _loadRecentTracks();
      } catch (e) {
        _handlePlayerError(e);
      }
    }
  }

  Widget _buildMiniPlayer() {
    final track = _currentlyPlayingTrack;
    if (track == null) return const SizedBox.shrink();

    final String displayTitle = track.title;
    final String displayArtist = track.artist;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0030),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: track.color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: track.color.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 4),
            child: Row(
              children: [
                // Album art circle
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LyricsScreen(track: track),
                      ),
                    );
                  },
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [track.color, track.color.withOpacity(0.5)],
                      ),
                      border: Border.all(
                        color: track.color.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: track.color.withOpacity(0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(track.icon, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        displayArtist,
                        style: TextStyle(
                          color: track.color.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Play button
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 28,
                  ),
                  color: Colors.white,
                  onPressed: () async {
                    try {
                      if (_isPlaying) {
                        await _audioPlayer.pause();
                      } else {
                        await _audioPlayer.resume();
                      }
                    } catch (e) {
                      _handlePlayerError(e);
                    }
                  },
                ),
                // Cast Icon
                IconButton(
                  icon: const Icon(Icons.cast, size: 24),
                  color: Colors.white70,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mencari perangkat untuk cast...'),
                      ),
                    );
                  },
                ),
                // Close button
                IconButton(
                  icon: const Icon(Icons.close, size: 24),
                  color: Colors.white70,
                  onPressed: () {
                    setState(() {
                      _showPlayerUi = false;
                    });
                  },
                ),
              ],
            ),
          ),
          // Progress bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Container(
                height: 3,
                width: double.infinity,
                color: Colors.white.withOpacity(0.1),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _duration.inSeconds > 0
                      ? (_position.inSeconds / _duration.inSeconds).clamp(
                          0.0,
                          1.0,
                        )
                      : 0.3,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: const LinearGradient(
                        colors: [Colors.greenAccent, Colors.lightGreenAccent],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
  String _userName = '';
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
      _userName = _prefs?.getString('local_username') ?? '';
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
            subtitle: Text(
              _userName.isEmpty ? '(Belum diatur)' : _userName,
              style: const TextStyle(color: Colors.white54),
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
            activeThumbColor: kColorAccent,
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
            activeThumbColor: kColorAccent,
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
          color: kColorAccent,
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
        backgroundColor: kColorSurface,
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
                  activeColor: const Color.fromARGB(255, 255, 60, 255),
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
    final nameController = TextEditingController(text: _userName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kColorSurface,
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
                hintText: 'Masukkan nama profil Anda',
                hintStyle: TextStyle(color: Colors.white30),
                labelStyle: TextStyle(color: Color.fromARGB(255, 255, 60, 255)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: kColorAccent),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kColorAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              final newName = nameController.text.trim();

              await _saveString('local_username', newName);
              setState(() {
                _userName = newName;
              });
              if (mounted) Navigator.pop(context);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profil berhasil diperbarui!'),
                    backgroundColor: Color.fromARGB(255, 209, 60, 255),
                  ),
                );
              }
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
        backgroundColor: kColorSurface,
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
              backgroundColor: kColorAccent,
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
        backgroundColor: kColorSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tentang Aplikasi'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AdaptiveLogo(size: 64),
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
                          color: kColorAccent,
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
              backgroundColor: kColorAccent,
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

// --- Custom Painter for Liked Songs Waveform ---
class _LibraryWaveformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw multiple wave layers for depth
    _drawWaveLayer(
      canvas,
      size,
      paint,
      [const Color(0xFF4A148C), const Color(0xFF880E4F)],
      0.7,
      [
        0.3,
        0.5,
        0.8,
        0.6,
        0.9,
        0.4,
        0.7,
        0.5,
        0.8,
        0.3,
        0.6,
        0.9,
        0.4,
        0.7,
        0.5,
        0.8,
        0.6,
        0.3,
        0.5,
        0.7,
      ],
      0.5,
    );

    _drawWaveLayer(
      canvas,
      size,
      paint,
      [const Color(0xFF7B1FA2), const Color(0xFFAD1457)],
      0.5,
      [
        0.2,
        0.6,
        0.4,
        0.8,
        0.3,
        0.7,
        0.5,
        0.9,
        0.4,
        0.6,
        0.8,
        0.3,
        0.5,
        0.7,
        0.6,
        0.4,
        0.8,
        0.5,
        0.3,
        0.7,
      ],
      0.4,
    );

    _drawWaveLayer(
      canvas,
      size,
      paint,
      [const Color(0xFFCE93D8), const Color(0xFFE91E63)],
      0.3,
      [
        0.4,
        0.7,
        0.3,
        0.9,
        0.5,
        0.8,
        0.4,
        0.6,
        0.7,
        0.3,
        0.5,
        0.8,
        0.6,
        0.4,
        0.9,
        0.3,
        0.7,
        0.5,
        0.4,
        0.6,
      ],
      0.35,
    );
  }

  void _drawWaveLayer(
    Canvas canvas,
    Size size,
    Paint paint,
    List<Color> colors,
    double opacity,
    List<double> heights,
    double maxHeightFactor,
  ) {
    final barCount = heights.length;
    final barWidth = size.width / barCount;
    final maxBarHeight = size.height * maxHeightFactor;

    paint.shader = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: colors.map((c) => c.withOpacity(opacity)).toList(),
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    for (int i = 0; i < barCount; i++) {
      final barHeight = heights[i] * maxBarHeight;
      final x = i * barWidth;
      final y = size.height * 0.55 - barHeight / 2;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 1, y, barWidth - 2, barHeight),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
