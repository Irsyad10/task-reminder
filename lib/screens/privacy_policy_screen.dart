import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  // 🔗 Ganti URL ini dengan URL halaman privacy policy yang sudah di-host
  static const String privacyPolicyUrl =
      'https://irsyad10.github.io/task-reminder/privacy-policy.html';

  static Future<void> openPrivacyPolicy() async {
    final uri = Uri.parse(privacyPolicyUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Kebijakan Privasi',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppTheme.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primary.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.privacy_tip_rounded,
                      color: AppTheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'KitaPlan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'Terakhir diperbarui: 25 Juni 2025',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildIntro(),
            _buildSection(
              '1. Informasi yang Kami Kumpulkan',
              'Kami mengumpulkan informasi berikut saat Anda menggunakan aplikasi:',
              [
                'Informasi Akun: Alamat email dan data profil saat Anda mendaftar menggunakan email atau Google Sign-In.',
                'Data Tugas: Judul, deskripsi, tanggal tenggat, status, dan subtask dari tugas yang Anda buat.',
                'Data Notifikasi: Pengaturan pengingat dan jadwal notifikasi untuk tugas Anda.',
              ],
            ),
            _buildSection(
              '2. Penggunaan Informasi',
              'Informasi yang kami kumpulkan digunakan untuk:',
              [
                'Menyediakan dan memelihara layanan aplikasi KitaPlan.',
                'Mengelola akun dan autentikasi pengguna.',
                'Menyinkronkan data tugas Anda antar perangkat.',
                'Mengirimkan notifikasi pengingat tugas.',
                'Meningkatkan kualitas dan pengalaman pengguna.',
              ],
            ),
            _buildSection(
              '3. Penyimpanan Data',
              'Data Anda disimpan secara aman menggunakan layanan Supabase sebagai backend. Data disimpan di server yang dilindungi dengan enkripsi standar industri.',
              [],
            ),
            _buildSection(
              '4. Berbagi Data dengan Pihak Ketiga',
              'Kami tidak menjual, memperdagangkan, atau menyewakan informasi pribadi Anda kepada pihak ketiga. Layanan pihak ketiga yang kami gunakan:',
              [
                'Supabase — Autentikasi dan penyimpanan data.',
                'Google Sign-In — Opsi login yang mudah dan aman.',
                'Google Fonts — Tipografi di dalam aplikasi.',
              ],
            ),
            _buildSection(
              '5. Keamanan Data',
              'Kami mengambil langkah-langkah keamanan yang wajar untuk melindungi informasi pribadi Anda dari akses yang tidak sah, pengubahan, pengungkapan, atau penghancuran.',
              [],
            ),
            _buildSection(
              '6. Hak Pengguna',
              'Anda memiliki hak untuk:',
              [
                'Mengakses data pribadi yang kami simpan tentang Anda.',
                'Memperbarui informasi akun Anda kapan saja.',
                'Menghapus akun dan semua data terkait.',
                'Menonaktifkan notifikasi melalui pengaturan perangkat.',
              ],
            ),
            _buildSection(
              '7. Data Anak-anak',
              'Aplikasi ini tidak ditujukan untuk anak-anak di bawah usia 13 tahun. Kami tidak secara sengaja mengumpulkan informasi pribadi dari anak-anak di bawah usia 13 tahun.',
              [],
            ),
            _buildSection(
              '8. Perubahan Kebijakan',
              'Kami dapat memperbarui Kebijakan Privasi ini dari waktu ke waktu. Perubahan akan dipublikasikan di halaman ini dengan tanggal pembaruan yang baru.',
              [],
            ),
            _buildSection(
              '9. Hubungi Kami',
              'Jika Anda memiliki pertanyaan tentang Kebijakan Privasi ini, hubungi kami melalui email: kitaplan.app@gmail.com',
              [],
            ),

            const SizedBox(height: 24),

            // Open in browser button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: openPrivacyPolicy,
                icon: const Icon(Icons.open_in_browser_rounded),
                label: Text(
                  'Buka di Browser',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildIntro() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        'Kami menghargai privasi Anda dan berkomitmen untuk melindungi data pribadi yang Anda berikan. Kebijakan Privasi ini menjelaskan bagaimana kami mengumpulkan, menggunakan, dan melindungi informasi Anda.',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: AppTheme.textSecondary,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildSection(String title, String description, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
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
}
