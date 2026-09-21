import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/language_manager.dart';
import '../common/custom_bottom_nav.dart';
import '../login/login_screen.dart';
import 'about_app_screen.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';
import 'help_center_screen.dart';
import 'language_settings_screen.dart';
import 'notification_settings_screen.dart';
import 'widgets/settings_item_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final supabase = Supabase.instance.client;

  String _adminName = 'Memuat...';
  String _adminRole = 'Mengambil data...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAdminProfile();
  }

  // Tarik data profil admin dari Supabase
  Future<void> _fetchAdminProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final response = await supabase
          .from('profiles')
          .select('full_name, employee_no')
          .eq('id', user.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _adminName = response?['full_name'] ?? 'Maulana Akbar';
          _adminRole = response?['employee_no'] != null
              ? 'Admin / NIK: ${response!['employee_no']}'
              : 'Admin Magang - SV Universitas Pakuan';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetch profile: $e');
      if (mounted) {
        setState(() {
          _adminName = 'Maulana Akbar';
          _adminRole = 'Admin Magang - SV Universitas Pakuan';
          _isLoading = false;
        });
      }
    }
  }

  // Buka halaman Edit Profil dan refresh data jika ada perubahan
  Future<void> _openEditProfile() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          initialName: _adminName,
          initialRole: _adminRole,
        ),
      ),
    );

    if (updated == true) {
      _fetchAdminProfile();
    }
  }

  // Fungsi Logout Supabase Real dengan Konfirmasi
  Future<void> _handleLogout() async {
    final lm = LanguageManager.instance;

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.logout, color: Color(0xFFBB0016), size: 22),
            const SizedBox(width: 8),
            Text(
              lm.t('logout_confirm_title'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Text(
          lm.t('logout_confirm_desc'),
          style: const TextStyle(fontSize: 14, color: Color(0xFF5C403D)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(lm.t('cancel'), style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBB0016),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(lm.t('logout')),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    try {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFFBB0016)),
        ),
      );

      await supabase.auth.signOut();

      if (!mounted) return;

      Navigator.pop(context); // Hapus loading dialog

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );

      debugPrint('Berhasil Log Out');
    } catch (e) {
      if (mounted) Navigator.pop(context);
      debugPrint('Error Logout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final lm = LanguageManager.instance;

    return ValueListenableBuilder<AppLanguage>(
      valueListenable: lm.currentLanguageNotifier,
      builder: (context, currentLang, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            elevation: 4,
            shadowColor: Colors.black.withValues(alpha: 0.08),
            backgroundColor: const Color(0xFF0F3567),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F3567), Color(0xFFBB0016)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.settings, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  lm.t('settings_title'),
                  style: const TextStyle(
                    fontFamily: 'Hanken Grotesk',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: const AdminBottomNav(currentIndex: 3),
          body: ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              // Profil Header (Dapat diklik untuk langsung buka Edit Profil)
              InkWell(
                onTap: _openEditProfile,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE1E3E4)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          const CircleAvatar(
                            radius: 32,
                            backgroundImage: NetworkImage(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuB3gv5lyQbE3v1zuGLRFxEmDCNvVRallpivUIpVuBXmd2V3paDa8UflN7A7x7pK67Rgjs8Fdid2i0B6xP7VBz9ia_rRqPz1r-I48SbcuyUDVgkUD50Dfr2mL58NPssBKNQDrY2YGUO7hbHx0XMiF5ZD2kIXGOXyavtXOeaYUBeZ4qBYbDAulHJcVqbTXy89KNZm2sYyJOgWzlt-G8IMySO_Q1-XIC0EX36z5mnV5XZPPesqTO1JCeY',
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Color(0xFFBB0016),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isLoading ? lm.t('loading') : _adminName,
                              style: const TextStyle(
                                fontFamily: 'Hanken Grotesk',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF191C1D),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isLoading ? lm.t('loading') : _adminRole,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: Color(0xFF5C403D),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey, size: 22),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                lm.t('account'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              SettingsItemTile(
                icon: Icons.person_outline,
                title: lm.t('edit_profile'),
                onTap: _openEditProfile,
              ),
              SettingsItemTile(
                icon: Icons.lock_outline,
                title: lm.t('change_password'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChangePasswordScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              Text(
                lm.t('preferences'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              SettingsItemTile(
                icon: Icons.notifications_none,
                title: lm.t('notifications'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationSettingsScreen(),
                    ),
                  );
                },
              ),
              SettingsItemTile(
                icon: Icons.language,
                title: lm.t('language'),
                trailing: lm.currentLanguageDisplayName,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LanguageSettingsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              Text(
                lm.t('help_and_info'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              SettingsItemTile(
                icon: Icons.help_outline,
                title: lm.t('help_center'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HelpCenterScreen(),
                    ),
                  );
                },
              ),
              SettingsItemTile(
                icon: Icons.info_outline,
                title: lm.t('about_app'),
                trailing: 'v1.0.0',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutAppScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Tombol Logout
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFDAD6),
                    foregroundColor: const Color(0xFFBA1A1A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.logout),
                  label: Text(
                    lm.t('logout'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  onPressed: _handleLogout,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
