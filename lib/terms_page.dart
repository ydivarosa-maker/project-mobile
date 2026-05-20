import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Syarat & Ketentuan'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Syarat dan Ketentuan Penggunaan Melodya',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tanggal Efektif: 20 Mei 2026',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 30),
            _buildSection(
              'I. Penerimaan Persyaratan',
              'Dengan menggunakan aplikasi Melodya, Anda menyetujui untuk terikat oleh syarat dan ketentuan ini. Jika Anda tidak setuju dengan salah satu bagian dari syarat ini, Anda tidak dapat menggunakan layanan kami.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              'II. Penggunaan Layanan',
              'Anda setuju untuk menggunakan layanan Melodya hanya untuk tujuan yang sah dan sesuai dengan semua hukum dan peraturan yang berlaku. Anda tidak diperkenankan menggunakan layanan ini untuk:\n\n• Melanggar hak kekayaan intelektual\n• Melakukan aktivitas yang merugikan atau mengganggu\n• Mengakses konten yang dilindungi tanpa otorisasi',
            ),
            const SizedBox(height: 20),
            _buildSection(
              'III. Konten dan Musik',
              'Melodya menyediakan akses ke konten musik melalui berbagai sumber. Kami tidak bertanggung jawab atas keakuratan, keaslian, atau ketersediaan konten tersebut. Penggunaan musik di aplikasi ini mematuhi lisensi dan perjanjian yang berlaku.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              'IV. Privasi Pengguna',
              'Informasi pribadi Anda akan dilindungi sesuai dengan kebijakan privasi kami. Kami mengumpulkan data untuk meningkatkan pengalaman pengguna dan tidak akan membagikan data Anda kepada pihak ketiga tanpa persetujuan Anda.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              'V. Pembatasan Tanggung Jawab',
              'Melodya disediakan "apa adanya" tanpa garansi apapun. Kami tidak bertanggung jawab atas kerugian apapun yang timbul dari penggunaan atau ketidakmampuan menggunakan layanan ini, termasuk kehilangan data, keuntungan, atau kerusakan lainnya.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              'VI. Modifikasi Layanan',
              'Kami berhak untuk memodifikasi, menambah, atau menghapus fitur layanan kapan saja tanpa pemberitahuan sebelumnya. Kami juga berhak untuk mengakhiri akses pengguna jika melanggar syarat dan ketentuan ini.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              'VII. Hukum yang Berlaku',
              'Syarat dan ketentuan ini diatur oleh dan ditafsirkan sesuai dengan hukum Indonesia, tanpa memperhatikan prinsip-prinsip konflik hukumnya.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              'VIII. Hubungi Kami',
              'Jika Anda memiliki pertanyaan atau kekhawatiran tentang syarat dan ketentuan ini, silakan hubungi kami di support@melodya.app',
            ),
            const SizedBox(height: 40),
            const Text(
              'Dengan menggunakan Melodya, Anda telah membaca, memahami, dan setuju dengan semua syarat dan ketentuan yang tercantum di atas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD946EF),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          content,
          style: const TextStyle(
            color: Colors.white70,
            height: 1.5,
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }
}
