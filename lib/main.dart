import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/screens.dart';
import 'utils/language_manager.dart';

Future<void> main() async {
  // Pastikan binding Flutter terinisialisasi dengan benar sebelum async
  WidgetsFlutterBinding.ensureInitialized();

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
          // Halaman pertama saat aplikasi dibuka adalah Login Screen Admin
          home: const LoginScreen(),
        );
      },
    );
  }
}