import 'package:flutter/material.dart';

class AddSongSheet extends StatefulWidget {
  final String playlistName;
  const AddSongSheet({super.key, this.playlistName = "Late Night Jazz"});

  @override
  State<AddSongSheet> createState() => _AddSongSheetState();
}

class _AddSongSheetState extends State<AddSongSheet> {
  String _query = '';
  final List<Map<String, dynamic>> _playlist = [];

  final List<Map<String, dynamic>> _kumpulanLagu = [
    {'id': 1, 'judul': 'Synthwave Eclipse', 'artis': 'Artis Neon Horizon'},
    {'id': 2, 'judul': 'GHOST', 'artis': 'Artis Justin Bieber'},
    {'id': 3, 'judul': 'SORRY', 'artis': 'Artis Justin Bieber'},
    {'id': 4, 'judul': 'I DONT CARE', 'artis': 'Artis Justin Bieber'},
    {'id': 5, 'judul': 'After Hours', 'artis': 'Artis The Weeknd'},
    {'id': 6, 'judul': 'Currents', 'artis': 'Artis Tame Impala'},
  ];

  void _handleTambahLagu(Map<String, dynamic> lagu) {
    setState(() {
      _playlist.add(lagu);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${lagu['judul']}" berhasil ditambahkan ke ${widget.playlistName}!'),
        backgroundColor: Colors.purple,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final laguTerfilter = _kumpulanLagu.where((lagu) {
      final judulMatch = lagu['judul'].toString().toLowerCase().contains(_query.toLowerCase());
      final artisMatch = lagu['artis'].toString().toLowerCase().contains(_query.toLowerCase());
      return judulMatch || artisMatch;
    }).toList();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF12071F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bagian Atas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tambahkan Lagu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ke ${widget.playlistName}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Input Pencarian (Search Bar)
          TextField(
            onChanged: (value) {
              setState(() {
                _query = value;
              });
            },
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Cari lagu...',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF25183A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 16),

          // Daftar Lagu
          Flexible(
            child: laguTerfilter.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'Lagu tidak ditemukan.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: laguTerfilter.length,
                    itemBuilder: (context, index) {
                      final lagu = laguTerfilter[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D1B4E),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(Icons.music_note, color: Colors.purpleAccent),
                          ),
                        ),
                        title: Text(
                          lagu['judul'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          lagu['artis'],
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.purpleAccent),
                          iconSize: 32,
                          padding: EdgeInsets.zero,
                          onPressed: () => _handleTambahLagu(lagu),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
