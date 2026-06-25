import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'delete_account_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;
  final _nameController = TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;

  String _email = '';
  String _joinedDate = '';
  String _googleAvatarUrl = '';

  // Avatar Customization State
  String _selectedEmoji = '😊';
  Color _selectedColor = AppTheme.primary;

  // Predefined Emojis and Colors
  final List<String> _emojis = [
    '😊', '🦊', '🐱', '🐼', '🦁', '🐨', '🦄', '🚀',
    '💻', '🎨', '🎧', '🎮', '⚽', '🍕', '🔥', '🌟'
  ];

  final List<Color> _colors = [
    AppTheme.primary,
    AppTheme.secondary,
    AppTheme.statusDone,
    AppTheme.statusProgress,
    const Color(0xFFFF4B5C),
    const Color(0xFF00ADB5),
    const Color(0xFF3F72AF),
    const Color(0xFFFFD700),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      final metadata = user.userMetadata ?? {};
      
      setState(() {
        _email = user.email ?? 'Tidak diketahui';
        _nameController.text = metadata['full_name'] ?? metadata['name'] ?? '';
        _googleAvatarUrl = metadata['avatar_url'] ?? metadata['picture'] ?? '';
        
        // Load custom avatar settings
        _selectedEmoji = metadata['avatar_emoji'] ?? '😊';
        final colorHex = metadata['avatar_color'];
        _selectedColor = _parseColor(colorHex, AppTheme.primary);

        // Parse date joined
        try {
          final dt = DateTime.parse(user.createdAt);
          _joinedDate = DateFormat('dd MMMM yyyy', 'id_ID').format(dt);
        } catch (_) {
          _joinedDate = 'Tidak diketahui';
        }
      });
    }
  }

  Color _parseColor(String? hexString, Color defaultColor) {
    if (hexString == null || hexString.isEmpty) return defaultColor;
    try {
      final hex = hexString.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return defaultColor;
    }
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  Future<void> _saveChanges() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nama Lengkap tidak boleh kosong"),
          backgroundColor: AppTheme.secondary,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': name,
            'avatar_emoji': _selectedEmoji,
            'avatar_color': _colorToHex(_selectedColor),
          },
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil berhasil diperbarui"),
            backgroundColor: AppTheme.statusDone,
          ),
        );
        // Refresh local user data
        _loadUserData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal memperbarui profil: $e"),
            backgroundColor: AppTheme.secondary,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(
          'Keluar Akun?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari sesi saat ini?',
          style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal',
                style: GoogleFonts.plusJakartaSans(
                    color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Keluar',
                style: GoogleFonts.plusJakartaSans(
                    color: AppTheme.secondary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      try {
        await AuthService().signOut();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal keluar akun: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasGooglePhoto = _googleAvatarUrl.isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Profil Saya',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppTheme.background,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Header & Avatar Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.divider, width: 1),
                    ),
                    child: Column(
                      children: [
                        // Avatar Display
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _selectedColor.withOpacity(0.2),
                                border: Border.all(
                                  color: _selectedColor,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _selectedColor.withOpacity(0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  _selectedEmoji,
                                  style: const TextStyle(fontSize: 48),
                                ),
                              ),
                            ).animate().scale(delay: 100.ms, duration: 300.ms, curve: Curves.easeOutBack),
                            if (hasGooglePhoto)
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 1.5),
                                    image: DecorationImage(
                                      image: NetworkImage(_googleAvatarUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Email Text
                        Text(
                          _email,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Date Joined Text
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.divider,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Bergabung sejak $_joinedDate',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, curve: Curves.easeOutQuad),
                  
                  const SizedBox(height: 20),

                  // Avatar Customizer
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.divider, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kustomisasi Avatar',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Emoji Selector Title
                        Text(
                          'Pilih Emoji',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Emoji Selector Grid
                        SizedBox(
                          height: 48,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _emojis.length,
                            itemBuilder: (ctx, index) {
                              final emoji = _emojis[index];
                              final isSelected = emoji == _selectedEmoji;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedEmoji = emoji),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppTheme.surfaceLight : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected ? AppTheme.primary : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      emoji,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Color Selector Title
                        Text(
                          'Pilih Warna Latar',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Color Selector Row
                        SizedBox(
                          height: 44,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _colors.length,
                            itemBuilder: (ctx, index) {
                              final color = _colors[index];
                              final isSelected = color.value == _selectedColor.value;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedColor = color),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? Colors.white : Colors.transparent,
                                      width: 2,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: color.withOpacity(0.4),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                            )
                                          ]
                                        : null,
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 20,
                                        )
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1, curve: Curves.easeOutQuad),

                  const SizedBox(height: 20),

                  // Profile Details Form
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.divider, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data Pribadi',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Name Input Field
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: "Nama Lengkap",
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                          textCapitalization: TextCapitalization.words,
                          style: GoogleFonts.plusJakartaSans(color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 16),
                        // Email Input Field (Disabled)
                        TextField(
                          enabled: false,
                          controller: TextEditingController(text: _email),
                          decoration: const InputDecoration(
                            labelText: "Email Akun (Tidak dapat diubah)",
                            prefixIcon: Icon(Icons.lock_outline_rounded),
                          ),
                          style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 24),
                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : _saveChanges,
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.save_rounded),
                            label: Text(
                              _isSaving ? 'Menyimpan...' : 'Simpan Perubahan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: AppTheme.divider,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, curve: Curves.easeOutQuad),

                  const SizedBox(height: 20),

                  // Actions Section (Log out / Delete Account)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.divider, width: 1),
                    ),
                    child: Column(
                      children: [
                        // Logout Action
                        _buildSettingRow(
                          icon: Icons.logout_rounded,
                          color: AppTheme.warning,
                          title: 'Keluar Akun',
                          subtitle: 'Log out dari sesi aktif aplikasi',
                          onTap: _logout,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(),
                        ),
                        // Delete Account Action
                        _buildSettingRow(
                          icon: Icons.delete_forever_rounded,
                          color: AppTheme.secondary,
                          title: 'Hapus Akun',
                          subtitle: 'Hapus semua data & akun secara permanen',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DeleteAccountScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1, curve: Curves.easeOutQuad),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
