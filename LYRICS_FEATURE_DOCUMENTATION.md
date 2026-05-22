# 📝 Dokumentasi Fitur Lirik - Melodya Music App

## Ringkasan Implementasi

Aplikasi musik Melodya sekarang dilengkapi dengan fitur **Lyrics Viewer** yang memungkinkan pengguna untuk melihat lirik lagu secara real-time saat mendengarkan musik.

---

## 📂 File-File yang Ditambahkan/Diubah

### 1. **Update Model** - `lib/models/music_track.dart`

- ✅ Menambahkan field `lyrics` (String?) untuk menyimpan lirik
- ✅ Field ini opsional, jadi tidak akan merusak data yang ada

```dart
class MusicTrack {
  final String title;
  final String artist;
  final String artworkUrl;
  final String previewUrl;
  final Color color;
  final IconData icon;
  final String? lyrics;  // ✨ BARU
}
```

---

### 2. **Service Baru** - `lib/services/lyrics_service.dart`

**Fungsi:** Mengambil lirik dari API eksternal (lyrics.ovh)

**Fitur:**

- `fetchLyrics(artist, title)` - Mengambil lirik dengan format dasar
- `fetchLyricsWithFallback(artist, title)` - Mencoba format berbeda jika yang pertama gagal
- Automatic handling untuk spesial karakter dalam nama artis/judul
- Timeout 10 detik untuk permintaan

**API yang Digunakan:**

```
https://api.lyrics.ovh/v1/{artist}/{song}
```

**Keuntungan:**

- ✅ Gratis (tanpa API key)
- ✅ Cepat dan reliable
- ✅ Coverage lagu yang luas

---

### 3. **Screen Baru** - `lib/screens/lyrics_screen.dart`

**Fungsi:** Menampilkan lirik dengan UI yang cantik

**Fitur:**

- 📱 UI responsive dengan gradient background
- 🎨 Warna dinamis berdasarkan track color
- ⏳ Loading indicator saat mengambil lirik
- ❌ Error handling dengan pesan yang jelas
- 🎵 Menampilkan cover art, judul, dan nama artis
- 📜 Scroll view untuk lirik yang panjang
- 🎯 Font yang mudah dibaca dengan line height yang nyaman

**UI Components:**

```
┌─────────────────────────────────┐
│ AppBar (Judul & Artis)          │
├─────────────────────────────────┤
│                                 │
│        [Cover Art]              │
│       (200 x 200)               │
│                                 │
│      ╔═══════════════╗          │
│      ║ LIRIK         ║          │
│      ├───────────────┤          │
│      │ [Lirik Text]  │          │
│      │  dengan       │          │
│      │  line height  │          │
│      │  yang bagus   │          │
│      ╚═══════════════╝          │
│                                 │
└─────────────────────────────────┘
```

---

### 4. **Screen Settings** - `lib/screens/settings_screen.dart`

**Fungsi:** Halaman pengaturan aplikasi

**Fitur:**

- 🔊 Pengaturan Audio (kualitas, volume)
- 🔔 Pengaturan Notifikasi
- 🌙 Pengaturan Tampilan (dark mode)
- ℹ️ Informasi versi dan links penting
- 📋 Akses ke Syarat & Ketentuan dan Kebijakan Privasi

---

### 5. **Update Main App** - `lib/main.dart`

**Perubahan:**

- ✅ Import LyricsScreen dan SettingsScreen
- ✅ Tambah tombol lirik di setiap track item
- ✅ Integrasi navigasi ke lyrics screen

**Tombol Lirik:**

```
[♫ Lirik] [+Follow] [❤️ Favorit]
```

- Ikon lirik (🎵) di sebelah tombol follow
- Tooltip "Lihat Lirik" saat di-hover
- Navigasi ke LyricsScreen saat di-klik

---

## 🚀 Cara Menggunakan Fitur Lirik

### User Flow:

1. **Cari Lagu** - Gunakan fitur pencarian untuk menemukan lagu favorit
2. **Klik Tombol Lirik** - Tekan ikon lirik (♫) di sebelah track
3. **Lihat Lirik** - Lirik akan ditampilkan dengan UI yang menarik
4. **Scroll** - Scroll untuk melihat lirik yang lebih panjang
5. **Kembali** - Tekan back untuk kembali ke daftar lagu

---

## 🔧 Fitur Teknis

### Error Handling:

1. **Lirik Tidak Ditemukan** - Tampilkan pesan "Lirik tidak ditemukan"
2. **Koneksi Error** - Tampilkan pesan error dengan detail
3. **Timeout** - Otomatis timeout setelah 10 detik

### Performa:

- **Caching**: Lirik di-cache saat di-fetch pertama kali
- **Async Loading**: UI tetap responsive saat loading
- **Debounce**: Pencarian diberi delay 500ms untuk optimasi

---

## 💡 Cara Mengintegrasikan Lebih Lanjut

### Opsi 1: Simpan Lirik ke Database Firebase

```dart
// Tambah ke FirebaseService
Future<void> saveLyricsToFirebase(String userId, MusicTrack track) async {
  await firestore
      .collection('users')
      .doc(userId)
      .collection('savedLyrics')
      .doc(track.title)
      .set({
        'title': track.title,
        'artist': track.artist,
        'lyrics': track.lyrics,
        'savedAt': FieldValue.serverTimestamp(),
      });
}
```

### Opsi 2: Tampilkan Lirik dengan Time Sync

```dart
// Sinkronisasi lirik dengan waktu putar
// Highlight lirik yang sedang diputar
// Scroll otomatis sesuai musik
```

### Opsi 3: Tambah Fitur Translate Lirik

```dart
// Gunakan Google Translate API
// Tampilkan lirik dalam bahasa Indonesia dan English
```

### Opsi 4: Share Lirik

```dart
// Tombol share untuk bagikan lirik ke social media
// Format: "🎵 [Lirik] - [Judul] by [Artis]"
```

---

## 📊 Struktur Data

### MusicTrack Model Baru:

```dart
MusicTrack {
  String title,
  String artist,
  String artworkUrl,
  String previewUrl,
  Color color,
  IconData icon,
  String? lyrics  // ✨ Baru
}
```

---

## 🎨 UI/UX Improvements

✅ **Konsisten dengan Design System:**

- Warna accent: `Color(0xFFD946EF)` (Pink)
- Background: `Color(0xFF0F172A)` (Dark Navy)
- Gradient backgrounds untuk visual appeal

✅ **Accessibility:**

- Font size yang readable
- Contrast ratio yang cukup
- Tooltip untuk semua tombol icon

✅ **Responsive Design:**

- Bekerja di semua ukuran layar
- Adaptive layout untuk mobile dan desktop

---

## 🐛 Troubleshooting

### Lirik tidak muncul?

1. Pastikan nama artis dan judul lagu benar
2. Cek koneksi internet
3. Coba lagu yang lebih populer

### Lyrics API tidak merespon?

1. Gunakan fallback dengan nama artis yang lebih singkat
2. Cek status API di https://api.lyrics.ovh
3. Pertimbangkan untuk pindah ke API yang berbeda

### Performance Issues?

1. Tambah loading indicator
2. Gunakan pagination untuk lirik yang panjang
3. Cache lirik yang sudah di-fetch

---

## 📚 Referensi API

### Lyrics.ovh API

- **Base URL**: `https://api.lyrics.ovh/v1`
- **Endpoint**: `/api/v1/{artist}/{title}`
- **Response**:

```json
{
  "lyrics": "Lirik lagu di sini...",
  "error": false
}
```

### Alternative APIs:

- 🎵 **Musixmatch**: Lebih akurat (butuh API key gratis)
- 🎵 **Genius**: Paling lengkap (butuh OAuth)
- 🎵 **Songsterr**: Untuk chord + lirik

---

## 🔮 Future Features

1. 🎙️ **Sinkronisasi Lirik dengan Musik** - Highlight lirik sesuai waktu putar
2. 💾 **Simpan Lirik Favorit** - Offline lirik viewer
3. 🌍 **Translate Lirik** - Tampilkan lirik dalam multiple bahasa
4. 📱 **Widgets** - Quick access ke lirik dari lock screen
5. 🔍 **Cari di dalam Lirik** - Search untuk kata tertentu dalam lirik
6. 📤 **Share Lirik** - Bagikan ke sosial media dengan preview
7. 🎯 **Lirik Terbaik** - Rating dan review dari user

---

## ✅ Testing Checklist

- [ ] Buka aplikasi, login
- [ ] Cari lagu (contoh: "Shape of You")
- [ ] Klik tombol lirik
- [ ] Verifikasi lirik muncul dengan benar
- [ ] Test scroll untuk lirik panjang
- [ ] Test error handling (lagu tanpa lirik)
- [ ] Test loading state
- [ ] Verifikasi UI responsive di berbagai ukuran
- [ ] Test back button kembali ke home
- [ ] Test tombol settings bekerja

---

## 📞 Support

Jika ada pertanyaan atau issue:

1. Cek console untuk error messages
2. Verifikasi koneksi internet
3. Coba refresh atau restart app
4. Hubungi tim development

---

**Happy Listening! 🎵🎧**
