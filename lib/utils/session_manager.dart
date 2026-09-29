import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Manajer sesi pengguna untuk menangani preferensi 'Ingat Saya' (Remember Me)
/// dan persistensi sesi login admin agar tidak otomatis logout.
class SessionManager {
  SessionManager._privateConstructor();
  static final SessionManager instance = SessionManager._privateConstructor();

  static const String _keyRememberMe = 'admin_remember_me';
  static const String _keySavedAdminId = 'admin_saved_id';

  SharedPreferences? _prefs;

  bool _rememberMe = false;
  String _savedAdminId = '';

  /// Status apakah opsi 'Ingat Saya' aktif
  bool get isRememberMe => _rememberMe;

  /// ID Admin / NIK yang tersimpan jika 'Ingat Saya' aktif
  String get savedAdminId => _savedAdminId;

  /// Inisialisasi preferensi sesi saat aplikasi pertama kali berjalan
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _rememberMe = _prefs?.getBool(_keyRememberMe) ?? false;
      _savedAdminId = _prefs?.getString(_keySavedAdminId) ?? '';
    } catch (e) {
      debugPrint('SessionManager init error: $e');
    }
  }

  /// Menyimpan preferensi sesi setelah login admin berhasil
  Future<void> saveSession({
    required bool rememberMe,
    required String adminId,
  }) async {
    _rememberMe = rememberMe;
    _savedAdminId = rememberMe ? adminId.trim() : '';

    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setBool(_keyRememberMe, rememberMe);
      if (rememberMe) {
        await prefs.setString(_keySavedAdminId, adminId.trim());
      } else {
        await prefs.remove(_keySavedAdminId);
      }
    } catch (e) {
      debugPrint('SessionManager saveSession error: $e');
    }
  }

  /// Mengubah status preferensi Ingat Saya secara manual
  Future<void> setRememberMe(bool value) async {
    _rememberMe = value;
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setBool(_keyRememberMe, value);
      if (!value) {
        _savedAdminId = '';
        await prefs.remove(_keySavedAdminId);
      }
    } catch (e) {
      debugPrint('SessionManager setRememberMe error: $e');
    }
  }

  /// Menghapus sesi saat admin melakukan logout manual
  Future<void> clearSession({bool keepSavedId = true}) async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      if (!keepSavedId || !_rememberMe) {
        _rememberMe = false;
        _savedAdminId = '';
        await prefs.remove(_keyRememberMe);
        await prefs.remove(_keySavedAdminId);
      }
    } catch (e) {
      debugPrint('SessionManager clearSession error: $e');
    }
  }

  /// Memeriksa apakah sesi saat ini sah dan diizinkan langsung masuk ke Dashboard
  /// tanpa harus diarahkan ke halaman login.
  bool hasActivePersistentSession() {
    // 1. Ingat Saya harus bernilai true
    if (!_rememberMe) return false;

    // 2. Sesi Supabase harus aktif dan belum kedaluwarsa
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return false;

    if (session.isExpired) {
      return false;
    }

    return true;
  }
}
