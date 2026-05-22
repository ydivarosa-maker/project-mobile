# 🚀 Quick Start - Fitur Lirik Melodya

## ⚡ Langkah Cepat Memulai

### 1. Run Aplikasi

```bash
cd c:\Users\ydiva\melodya_flutter
flutter run
```

### 2. Login atau Skip (Mode Tamu)

- Gunakan akun Google atau email untuk login
- Atau klik "Mulai Dengarkan" untuk mode tamu

### 3. Cari Lagu

- Buka tab **"Cari"** (icon search)
- Ketik nama artis atau judul lagu
- Contoh: "Ed Sheeran", "Shape of You", "Justin Bieber"

### 4. Lihat Lirik

- Cari lagu dari hasil pencarian
- **Klik ikon lirik** (🎵) di sebelah track
- Lirik akan ditampilkan dalam layar baru yang indah

### 5. Fitur Tambahan

- **+Follow**: Ikuti artis favorit
- **❤️**: Tambahkan ke favorit
- **Scroll**: Scroll untuk lirik yang panjang
- **Back**: Tekan back untuk kembali ke daftar

---

## 🧪 Test Cases

### Test 1: Lirik Populer

1. Cari: "Shape of You"
2. Artis: "Ed Sheeran"
3. ✅ Lirik harus muncul

### Test 2: Lirik Alternatif

1. Cari: "Blinding Lights"
2. Artis: "The Weeknd"
3. ✅ Lirik harus muncul

### Test 3: Lirik Tidak Ditemukan

1. Cari: "Lagu Fiksi XYZ"
2. ✅ Harus tampil pesan "Lirik tidak ditemukan"

### Test 4: Loading State

1. Klik lirik
2. ✅ Harus tampil loading indicator
3. ✅ Setelah selesai, lirik muncul

### Test 5: Error Handling

1. Matikan internet
2. Coba klik lirik
3. ✅ Harus tampil pesan error yang jelas

---

## 📁 File Structure

```
lib/
├── models/
│   └── music_track.dart          ✨ Updated (added lyrics field)
├── services/
│   ├── music_api_service.dart   (existing)
│   ├── lyrics_service.dart      ✨ BARU
│   ├── auth_service.dart        (existing)
│   └── firebase_service.dart    (existing)
├── screens/
│   ├── login_screen.dart        (existing)
│   ├── lyrics_screen.dart       ✨ BARU
│   └── settings_screen.dart     ✨ BARU
└── main.dart                     ✨ Updated (added imports & lyrics button)

📄 Dokumentasi:
├── LYRICS_FEATURE_DOCUMENTATION.md  ✨ BARU
└── QUICKSTART.md                    ✨ BARU (ini)
```

---

## 🎯 Fitur yang Tersedia

| Fitur            | Status | Keterangan                         |
| ---------------- | ------ | ---------------------------------- |
| Fetch Lyrics     | ✅     | Mengambil dari lyrics.ovh API      |
| Display Lyrics   | ✅     | UI yang menarik dengan cover art   |
| Error Handling   | ✅     | Pesan error yang jelas             |
| Loading State    | ✅     | Loading indicator                  |
| Responsive UI    | ✅     | Cocok untuk semua ukuran           |
| Offline Lyrics   | ❌     | Rencanakan untuk update berikutnya |
| Time-sync Lyrics | ❌     | Rencanakan untuk update berikutnya |
| Translate Lyrics | ❌     | Rencanakan untuk update berikutnya |

---

## 🔧 Developer Notes

### Menambah Source Lirik Lain

Jika API lyrics.ovh tidak reliable, bisa switch ke API lain:

**1. Musixmatch API** (Recommended)

```dart
// lib/services/lyrics_service.dart
const String _baseUrl = 'https://api.musixmatch.com/ws/1.1';
// Butuh API key dari https://developer.musixmatch.com/
```

**2. Genius API**

```dart
// Paling lengkap, tapi butuh OAuth
const String _baseUrl = 'https://api.genius.com/search';
```

---

## 🐛 Known Issues & Solutions

### Issue 1: Lirik tidak ditemukan untuk lagu tertentu

**Solusi**: API lyrics.ovh tidak memiliki semua lirik. Coba lagu populer terlebih dahulu.

### Issue 2: Timeout saat load lirik

**Solusi**: Cek koneksi internet, atau artis/judul memiliki karakter spesial.

### Issue 3: Loading terlalu lama

**Solusi**: Normal karena fetch dari internet. Pertimbangkan untuk cache locally.

---

## 📱 Screenshots Preview

```
🏠 Home Screen               🎵 Lyrics Screen
┌─────────────────────┐     ┌─────────────────────┐
│ Halo, User!    👤   │     │ ← Shape of You      │
├─────────────────────┤     │   Ed Sheeran   ▶️   │
│ [Featured Card]     │     ├─────────────────────┤
├─────────────────────┤     │  [Cover Art]        │
│ Baru Diputar        │     │   200 x 200         │
├─────────────────────┤     ├─────────────────────┤
│ 🎵 Shape of You     │     │  LIRIK              │
│ Ed Sheeran       [🎵]❤️| → │  The story of my    │
│                [+]      │  life comes down...│
│ 🎵 Blinding Lights   │     │  (scroll untuk lebih)
│ The Weeknd       [🎵]❤️|     └─────────────────────┘
│                [+]      │
└─────────────────────┘
```

---

## 💬 FAQ

**Q: Apakah lirik disimpan offline?**
A: Belum. Update berikutnya akan menambahkan cache lokal.

**Q: Apakah semua lagu punya lirik?**
A: Tidak. API lyrics.ovh lebih banyak punya lagu populer.

**Q: Bisakah saya edit lirik?**
A: Belum. Fitur ini bisa ditambahkan di update mendatang.

**Q: Apakah lirik bisa di-sync dengan waktu putar?**
A: Belum. Ini adalah roadmap feature untuk update berikutnya.

---

## 🎊 Selesai!

Fitur lirik sudah siap digunakan! Silahkan test dan berikan feedback.

**Happy Coding! 🚀**
