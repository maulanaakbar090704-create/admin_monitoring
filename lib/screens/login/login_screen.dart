import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/security_manager.dart';
import '../../utils/session_manager.dart';
import '../dashboard/dashboard_screen.dart';
import 'widgets/login_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedSession();
  }

  void _loadSavedSession() {
    final sessionMgr = SessionManager.instance;
    if (sessionMgr.isRememberMe) {
      _rememberMe = true;
      if (sessionMgr.savedAdminId.isNotEmpty) {
        _idController.text = sessionMgr.savedAdminId;
      }
    }
  }

  // ==========================================
  // LOGIKA LOGIN KHUSUS ADMIN DENGAN PERLINDUNGAN BRUTE FORCE
  // ==========================================
  Future<void> _handleLogin() async {
    // 0. Cek apakah sistem sedang dalam masa lockout keamanan
    if (SecurityManager.instance.isLockedOut) {
      final sec = SecurityManager.instance.remainingSeconds;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Keamanan Terkunci: Terlalu banyak percobaan gagal. Tunggu $sec detik.'),
          backgroundColor: const Color(0xFFBB0016),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Sanitasi input teks
    final rawId = _idController.text;
    final idInput = SecurityManager.instance.sanitizeInput(rawId);
    final password = _passwordController.text.trim();

    if (idInput.isEmpty || password.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID Admin dan Password wajib diisi!'),
          backgroundColor: Color(0xFFBB0016),
        ),
      );
      return;
    }

    // Otomatis tambahkan domain @telkom.com di balik layar jika user hanya mengetikkan ID
    String email = idInput.contains('@') ? idInput : '$idInput@telkom.com';

    setState(() => _isLoading = true);

    try {
      // 1. Cek Email & Password di Supabase Auth
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // 2. Tarik data profil untuk mengecek jabatan (Role)
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', response.user!.id)
          .maybeSingle();

      if (profile == null) {
        SecurityManager.instance.recordFailedLogin();
        await Supabase.instance.client.auth.signOut();
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data profil akun tidak ditemukan.'),
            backgroundColor: Color(0xFFBB0016),
          ),
        );
        return;
      }

      final role = (profile['role'] ?? '').toString().toLowerCase();

      // 3. VALIDASI HAK AKSES KETAT: Hanya role 'admin' yang diizinkan masuk!
      if (role != 'admin') {
        SecurityManager.instance.recordFailedLogin();
        await Supabase.instance.client.auth.signOut();
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Akses Ditolak! Akun ini tidak memiliki hak Administrator.'),
              backgroundColor: Color(0xFFBB0016),
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      // 4. JIKA LOLOS (ROLE ADMIN), RESET COUNTER & MASUK KE DASHBOARD
      SecurityManager.instance.recordSuccessfulLogin();

      // Simpan preferensi sesi 'Ingat Saya'
      await SessionManager.instance.saveSession(
        rememberMe: _rememberMe,
        adminId: rawId,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AdminDashboardScreen(
            promptNotificationPermission: true,
          ),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Autentikasi Admin Berhasil & Terenkripsi!'),
          backgroundColor: Colors.green,
        ),
      );
    } on AuthException catch (_) {
      SecurityManager.instance.recordFailedLogin();
      if (!mounted) return;
      setState(() => _isLoading = false);

      final attempts = SecurityManager.instance.failedAttempts;
      final remainingAttempts = SecurityManager.maxFailedAttempts - attempts;
      final errorMsg = remainingAttempts > 0
          ? 'ID Admin atau Password salah. Sisa percobaan: $remainingAttempts kali.'
          : 'Terlalu banyak percobaan salah. Login terkunci selama 60 detik!';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: const Color(0xFFBB0016),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      SecurityManager.instance.recordFailedLogin();
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(SecurityManager.instance.sanitizeErrorMessage(e)),
          backgroundColor: const Color(0xFFBB0016),
        ),
      );
    }
  }

  // ==========================================
  // DIALOG BANTUAN LUPA KATA SANDI (SUPER ADMIN)
  // ==========================================
  void _showForgotPasswordDialog() {
    final initialId = _idController.text.trim();
    final nikController = TextEditingController(text: initialId);
    bool isSubmitting = false;
    bool requestSent = false;
    String? statusMessage;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFEE2E2), width: 1.5),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Color(0xFFBB0016),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lupa Kata Sandi?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Bantuan Super Admin IT Fleet',
                          style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    const Text(
                      'Untuk keamanan akun armada dinas Telkom Akses, reset kata sandi divalidasi oleh Super Admin IT Fleet.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.4),
                    ),
                    const SizedBox(height: 16),

                    // Input ID Admin / NIK
                    const Text(
                      'ID Admin / NIK Karyawan',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nikController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: 'Contoh: admin atau NIK / ID Anda',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                        prefixIcon: const Icon(Icons.badge_outlined, size: 20, color: Color(0xFFBB0016)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFBB0016), width: 1.5),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                      ),
                    ),

                    if (statusMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: requestSent ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: requestSent ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              requestSent ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                              color: requestSent ? const Color(0xFF059669) : const Color(0xFFDC2626),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                statusMessage!,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: requestSent ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),

                    // Tombol Ajukan Reset ke Database/Super Admin
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final targetNik = nikController.text.trim();
                                if (targetNik.isEmpty) {
                                  setDialogState(() {
                                    statusMessage = 'Harap isi ID Admin / NIK Anda!';
                                    requestSent = false;
                                  });
                                  return;
                                }

                                setDialogState(() {
                                  isSubmitting = true;
                                  statusMessage = null;
                                });

                                try {
                                  // 1. Coba panggil RPC jika tersedia di Supabase
                                  bool rpcSuccess = false;
                                  try {
                                    final res = await Supabase.instance.client.rpc(
                                      'request_password_reset',
                                      params: {'p_nik': targetNik},
                                    );
                                    if (res != null) {
                                      rpcSuccess = true;
                                    }
                                  } catch (_) {
                                    rpcSuccess = false;
                                  }

                                  if (!rpcSuccess) {
                                    // Fallback: update langsung field reset_requested di profiles
                                    if (targetNik.contains('@')) {
                                      await Supabase.instance.client
                                          .from('profiles')
                                          .update({
                                            'reset_requested': true,
                                            'reset_requested_at': DateTime.now().toIso8601String(),
                                          })
                                          .eq('email', targetNik);
                                    } else {
                                      final res = await Supabase.instance.client
                                          .from('profiles')
                                          .update({
                                            'reset_requested': true,
                                            'reset_requested_at': DateTime.now().toIso8601String(),
                                          })
                                          .eq('employee_no', targetNik)
                                          .select();

                                      if (res.isEmpty) {
                                        await Supabase.instance.client
                                            .from('profiles')
                                            .update({
                                              'reset_requested': true,
                                              'reset_requested_at': DateTime.now().toIso8601String(),
                                            })
                                            .eq('email', '$targetNik@telkom.com');
                                      }
                                    }
                                  }

                                  setDialogState(() {
                                    isSubmitting = false;
                                    requestSent = true;
                                    statusMessage = 'Permintaan reset berhasil dikirim! Super Admin akan memproses akun Anda.';
                                  });
                                } catch (err) {
                                  setDialogState(() {
                                    isSubmitting = false;
                                    requestSent = false;
                                    statusMessage = 'Gagal mengajukan reset: Pastikan ID Admin / NIK Anda benar.';
                                  });
                                }
                              },
                        icon: isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                        label: Text(
                          isSubmitting ? 'Mengirim Permintaan...' : 'Kirim Pengajuan ke Admin',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBB0016),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'ATAU HUBUNGI LANGSUNG',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF9CA3AF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Tombol Hubungi via WhatsApp
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final currentNik = nikController.text.trim();
                          final message =
                              'Halo Super Admin IT Fleet Telkom Akses, saya ingin mengajukan permohonan reset kata sandi akun Admin / PIC Sistem Monitoring Kendaraan.\n\n'
                              'ID Admin / NIK: ${currentNik.isNotEmpty ? currentNik : '-'}\n'
                              'Mohon bantuannya untuk reset kata sandi. Terima kasih.';
                          final waUri = Uri.parse('https://wa.me/6281280001000?text=${Uri.encodeComponent(message)}');
                          Navigator.pop(dialogContext);
                          try {
                            if (await canLaunchUrl(waUri)) {
                              await launchUrl(waUri, mode: LaunchMode.externalApplication);
                            } else {
                              await launchUrl(waUri);
                            }
                          } catch (_) {
                            if (mounted) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Gagal membuka WhatsApp. Silakan salin kontak admin.'),
                                  backgroundColor: Color(0xFFBB0016),
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 18),
                        label: const Text(
                          'Hubungi via WhatsApp',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Tombol Salin Kontak
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Clipboard.setData(
                            const ClipboardData(
                              text:
                                  'Super Admin IT Fleet Telkom Akses\nWhatsApp: +62 812-8000-1000\nEmail: adminfleet@telkom.co.id',
                            ),
                          );
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Kontak Super Admin berhasil disalin ke clipboard!'),
                              backgroundColor: Color(0xFF16A34A),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded, size: 16, color: Color(0xFF374151)),
                        label: const Text(
                          'Salin Kontak Super Admin',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFD1D5DB)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFBB0016), // Merah Telkom
              Color(0xFF0F3567), // Biru Navy Gelap
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: math.max(0.0, constraints.maxHeight - 48),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const LoginHeader(),
                      const SizedBox(height: 28),

                      // Kartu Form Login
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Input ID Admin
                            const Text(
                              'ID ADMIN',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5C403D),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _idController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                hintText: 'Masukkan ID Admin (contoh: 12345)',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 14,
                                ),
                                prefixIcon: const Icon(
                                  Icons.badge_outlined,
                                  color: Color(0xFF0F3567),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF8F9FA),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey.shade200),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey.shade200),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFBB0016),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Input Password
                            const Text(
                              'PASSWORD',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5C403D),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 14,
                                ),
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                  color: Color(0xFF0F3567),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: const Color(0xFF5C403D),
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() => _obscurePassword = !_obscurePassword);
                                  },
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF8F9FA),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey.shade200),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey.shade200),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFBB0016),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Remember Me & Lupa Password (Sejajar dan Rapi)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() => _rememberMe = !_rememberMe);
                                  },
                                  borderRadius: BorderRadius.circular(4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: Checkbox(
                                          value: _rememberMe,
                                          activeColor: const Color(0xFFBB0016),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          side: BorderSide(color: Colors.grey.shade400),
                                          onChanged: (val) {
                                            setState(() => _rememberMe = val ?? false);
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Ingat saya',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 13,
                                          color: Color(0xFF191C1D),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _showForgotPasswordDialog,
                                  child: const Text(
                                    'Lupa Password?',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0F3567),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                             const SizedBox(height: 18),

                            // Banner Lockout Keamanan (Hitung Mundur)
                            ValueListenableBuilder<int>(
                              valueListenable: SecurityManager.instance.remainingLockoutNotifier,
                              builder: (context, remainingSec, _) {
                                if (remainingSec <= 0) return const SizedBox.shrink();
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFEF4444), width: 1.2),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.security_update_warning_rounded,
                                        color: Color(0xFFDC2626),
                                        size: 22,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'PROTEKSI BRUTE FORCE AKTIF',
                                              style: TextStyle(
                                                color: Color(0xFF991B1B),
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Terlalu banyak percobaan gagal. Silakan tunggu $remainingSec detik.',
                                              style: const TextStyle(
                                                color: Color(0xFF7F1D1D),
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                            // Tombol Login
                            ValueListenableBuilder<int>(
                              valueListenable: SecurityManager.instance.remainingLockoutNotifier,
                              builder: (context, remainingSec, _) {
                                final isLocked = remainingSec > 0;
                                final isBtnDisabled = _isLoading || isLocked;

                                return SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: isBtnDisabled ? null : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isLocked
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFFBB0016),
                                      foregroundColor: Colors.white,
                                      elevation: 1,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            isLocked
                                                ? 'TERKUNCI ($remainingSec dtk)'
                                                : 'Login',
                                            style: const TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Footer IT Support
                      Text(
                        'Mengalami kendala saat login?',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: InkWell(
                          onTap: _showForgotPasswordDialog,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.support_agent, size: 16, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Hubungi IT Support',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
