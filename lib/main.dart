import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/screens.dart';
import 'utils/language_manager.dart';
import 'utils/network_manager.dart';
import 'utils/gps_requirement_manager.dart';
import 'utils/session_manager.dart';
import 'widgets/app_requirement_guard.dart';

Future<void> main() async {
  // Pastikan binding Flutter terinisialisasi dengan benar sebelum async
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi pendeteksi Jaringan & GPS Wajib
  await NetworkManager.instance.init();
  await GpsRequirementManager.instance.init();

  // Inisialisasi preferensi sesi admin (Ingat Saya)
  await SessionManager.instance.init();

  // Inisialisasi Supabase (Gunakan URL dan Anon Key yang SAMA PERSIS dengan project peminjam)
  await Supabase.initialize(
    url: 'https://jwybjxbwzcweiumokrrd.supabase.co',
    publishableKey: 'sb_publishable_okOPH2sIycoC39rsgACBDA_Yg8atOpj',
  );

  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: LanguageManager.instance.currentLanguageNotifier,
      builder: (context, currentLang, _) {
        return MaterialApp(
          key: ValueKey(currentLang),
          title: 'Admin Panel - Telkom Monitoring',
          debugShowCheckedModeBanner: false,
          // Mengatur tema dasar aplikasi
          theme: ThemeData(
            primaryColor: const Color(0xFFBB0016),
            scaffoldBackgroundColor: const Color(0xFFF8F9FA),
            fontFamily: 'Inter',
          ),
          // Guard global: Wajib Jaringan & Wajib GPS aktif
          builder: (context, child) => AppRequirementGuard(
            child: child ?? const SizedBox.shrink(),
          ),
          // Gerbang otentikasi awal (cek persistensi Ingat Saya & sesi aktif)
          home: const AuthGate(),
        );
      },
    );
  }
}

/// Gerbang otentikasi untuk menentukan apakah langsung masuk ke Dashboard
/// atau harus login terlebih dahulu berdasarkan preferensi 'Ingat Saya'.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late bool _checked;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    final sessionMgr = SessionManager.instance;
    final auth = Supabase.instance.client.auth;

    // Jika Ingat Saya tidak aktif atau tidak ada sesi Supabase, langsung arahkan ke LoginScreen
    if (!sessionMgr.isRememberMe || auth.currentSession == null) {
      _checked = true;
      _isAuthenticated = false;
      // Pastikan sesi lama di Supabase dibersihkan jika Ingat Saya dinonaktifkan
      if (auth.currentSession != null) {
        unawaited(auth.signOut());
      }
    } else {
      _checked = false;
      _validateSession();
    }
  }

  Future<void> _validateSession() async {
    final auth = Supabase.instance.client.auth;
    final session = auth.currentSession;

    if (session == null || session.isExpired) {
      if (mounted) {
        setState(() {
          _isAuthenticated = false;
          _checked = true;
        });
      }
      return;
    }

    try {
      // Verifikasi role admin
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', session.user.id)
          .maybeSingle();

      final role = (profile?['role'] ?? '').toString().toLowerCase();
      if (role == 'admin') {
        if (mounted) {
          setState(() {
            _isAuthenticated = true;
            _checked = true;
          });
        }
        return;
      } else {
        await auth.signOut();
      }
    } catch (e) {
      // Jika terjadi kendala jaringan sesaat saat membuka aplikasi,
      // namun sesi lokal masih ada & Ingat Saya aktif, tetap izinkan masuk ke Dashboard
      debugPrint('AuthGate network check note: $e');
      if (mounted) {
        setState(() {
          _isAuthenticated = true;
          _checked = true;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isAuthenticated = false;
        _checked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_checked) {
      return const Scaffold(
        backgroundColor: Color(0xFFBB0016),
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    if (_isAuthenticated) {
      return const AdminDashboardScreen();
    }

    return const LoginScreen();
  }
}