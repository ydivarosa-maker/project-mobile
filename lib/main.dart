import 'package:flutter/material.dart';

void main() {
  runApp(const MelodyaApp());
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
  String _selectedCategory = 'Untukmu';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        // IndexedStack digunakan agar halaman bisa berganti sesuai _currentIndex
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomeContent(), // Index 0
            _buildSearchContent(), // Index 1
            _buildCollectionContent(), // Index 2
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
                  radius: 22,
                  backgroundColor: const Color(0xFFD946EF).withOpacity(0.2),
                  child: const Icon(Icons.person, color: Color(0xFFD946EF), size: 24),
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
                _buildCategoryChip('Untukmu', _selectedCategory == 'Untukmu'),
                _buildCategoryChip('Podcast', _selectedCategory == 'Podcast'),
                _buildCategoryChip('Radio', _selectedCategory == 'Radio'),
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
      backgroundColor: Colors.transparent,
      builder: (context) {
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
              const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFFD946EF),
                child: Icon(Icons.person, size: 40, color: Colors.white),
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
                  decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
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
    } else if (_selectedCategory == 'Radio') {
      return Container(
        key: const ValueKey('radio'),
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
              'Radio 99.9 FM',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const Text('Siaran langsung musik hits', style: TextStyle(color: Colors.white)),
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
      // Untukmu
      return Container(
        key: const ValueKey('untukmu'),
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
    if (_selectedCategory == 'Podcast') {
      return ListView(
        key: const ValueKey('podcast_list'),
        padding: const EdgeInsets.all(20),
        children: [
          _buildTrackItem('Kisah Sukses', 'Podcast Motivasi', Icons.mic, const Color(0xFF3B82F6)),
          _buildTrackItem('Obrolan Malam', 'Podcast Horor', Icons.mic_external_on, const Color(0xFF10B981)),
          _buildTrackItem('Dunia Tech', 'Podcast IT', Icons.headset_mic, const Color(0xFFF59E0B)),
        ],
      );
    } else if (_selectedCategory == 'Radio') {
      return ListView(
        key: const ValueKey('radio_list'),
        padding: const EdgeInsets.all(20),
        children: [
          _buildTrackItem('Pagi Ceria', 'Radio FM Nasional', Icons.radio, const Color(0xFFF59E0B)),
          _buildTrackItem('Sore Santai', 'Hits Radio Lokal', Icons.radio, const Color(0xFFEF4444)),
        ],
      );
    } else {
      return ListView(
        key: const ValueKey('untukmu_list'),
        padding: const EdgeInsets.all(20),
        children: [
          _buildTrackItem('Melodi Cinta', 'Artis A', Icons.music_note, const Color(0xFF8B5CF6)),
          _buildTrackItem('Senja Hari', 'Band Indie', Icons.library_music, const Color(0xFFD946EF)),
          _buildTrackItem('Pagi Cerah', 'Penyanyi C', Icons.album, const Color(0xFF3B82F6)),
        ],
      );
    }
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
            decoration: InputDecoration(
              hintText: 'Artis, lagu, atau podcast',
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Jelajahi Genre',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Kotak-kotak Genre
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
      ),
    );
  }

  // ==========================================
  // Halaman 3: KOLEKSI
  // ==========================================
  Widget _buildCollectionContent() {
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
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD946EF), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.favorite, color: Colors.white),
                  ),
                  title: const Text(
                    'Lagu yang Disukai',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('128 lagu'),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Komponen tambahan pendukung
  Widget _buildCategoryChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
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
                    color: const Color(0xFFD946EF).withOpacity(0.4),
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
    return ListTile(
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
      trailing: const Icon(Icons.more_vert, color: Colors.white54),
    );
  }

  Widget _buildGenreCard(String title, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
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
    );
  }
}
