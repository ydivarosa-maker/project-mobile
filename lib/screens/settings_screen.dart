import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;
  double _volumeLevel = 0.8;
  String _audioQuality = 'Tinggi';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Audio Settings
            const Text(
              'Audio',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD946EF),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Kualitas Audio'),
              subtitle: Text(_audioQuality),
              trailing: DropdownButton<String>(
                value: _audioQuality,
                items: ['Rendah', 'Normal', 'Tinggi', 'Sangat Tinggi']
                    .map(
                      (quality) => DropdownMenuItem(
                        value: quality,
                        child: Text(quality),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _audioQuality = value);
                  }
                },
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('Volume'),
              subtitle: Slider(
                value: _volumeLevel,
                onChanged: (value) => setState(() => _volumeLevel = value),
              ),
            ),
            const SizedBox(height: 24),

            // Notifications
            const Text(
              'Notifikasi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD946EF),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Aktifkan Notifikasi'),
              value: _notificationsEnabled,
              onChanged: (value) =>
                  setState(() => _notificationsEnabled = value),
            ),
            const Divider(),

            // Display
            const Text(
              'Tampilan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD946EF),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Mode Gelap'),
              subtitle: const Text('Tema gelap untuk mata yang nyaman'),
              value: _darkModeEnabled,
              onChanged: (value) => setState(() => _darkModeEnabled = value),
            ),
            const SizedBox(height: 24),

            // About
            const Text(
              'Tentang',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD946EF),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(title: const Text('Versi'), subtitle: const Text('1.0.0')),
            const Divider(),
            ListTile(
              title: const Text('Syarat & Ketentuan'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Syarat & Ketentuan akan dibuka'),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Kebijakan Privasi'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kebijakan Privasi akan dibuka'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
