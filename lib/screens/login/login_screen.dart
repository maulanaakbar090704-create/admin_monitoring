import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  // ==========================================
  // LOGIKA LOGIN KHUSUS ADMIN (HANYA MENGGUNAKAN ID)
  // ==========================================
  Future<void> _handleLogin() async {
    final idInput = _idController.text.trim();
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

      // 3. VALIDASI HAK AKSES: Hanya role 'admin' yang diizinkan masuk!
      if (role != 'admin') {
        await Supabase.instance.client.auth.signOut();
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Akses Ditolak! Aplikasi ini khusus untuk Admin.'),
              backgroundColor: Color(0xFFBB0016),
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      // 4. JIKA LOLOS (ROLE ADMIN), MASUK KE DASHBOARD
      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Admin Berhasil!'),
          backgroundColor: Colors.green,
        ),
      );
    } on AuthException catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal Masuk: ID Admin atau Password salah.'),
          backgroundColor: Color(0xFFBB0016),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: const Color(0xFFBB0016),
        ),
      );
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFFBB0016)),
            SizedBox(width: 8),
            Text(
              'Lupa Password?',
              style: TextStyle(
                fontFamily: 'Hanken Grotesk',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Untuk alasan keamanan akun armada dinas Telkom Akses, silakan hubungi tim IT Helpdesk atau PIC Super Admin untuk mereset kata sandi Anda.',
          style: TextStyle(fontSize: 14, color: Color(0xFF5C403D)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Tutup',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F3567),
              ),
            ),
          ),
        ],
      ),
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
                    minHeight: constraints.maxHeight - 48,
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
                            const SizedBox(height: 24),

                            // Tombol Secure Login
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFBB0016),
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
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'LOGIN ADMIN',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(Icons.arrow_forward_rounded, size: 18),
                                        ],
                                      ),
                              ),
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
