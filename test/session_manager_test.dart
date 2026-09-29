import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:admin_monitoring_telkom/utils/session_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('SessionManager default state is unremembered and empty', () async {
    final session = SessionManager.instance;
    await session.init();

    expect(session.isRememberMe, isFalse);
    expect(session.savedAdminId, isEmpty);
    expect(session.hasActivePersistentSession(), isFalse);
  });

  test('SessionManager saveSession preserves rememberMe and adminId', () async {
    final session = SessionManager.instance;
    await session.init();

    await session.saveSession(rememberMe: true, adminId: '12345');

    expect(session.isRememberMe, isTrue);
    expect(session.savedAdminId, '12345');

    // Re-init from shared preferences to test persistence
    await session.init();
    expect(session.isRememberMe, isTrue);
    expect(session.savedAdminId, '12345');
  });

  test('SessionManager saveSession with rememberMe false clears saved ID', () async {
    final session = SessionManager.instance;
    await session.init();

    await session.saveSession(rememberMe: false, adminId: '12345');

    expect(session.isRememberMe, isFalse);
    expect(session.savedAdminId, isEmpty);
  });

  test('SessionManager clearSession with keepSavedId true preserves saved ID if rememberMe was true', () async {
    final session = SessionManager.instance;
    await session.init();
    await session.saveSession(rememberMe: true, adminId: 'admin_telkom');

    await session.clearSession(keepSavedId: true);
    expect(session.savedAdminId, 'admin_telkom');
    expect(session.isRememberMe, isTrue);
  });

  test('SessionManager clearSession with keepSavedId false wipes everything', () async {
    final session = SessionManager.instance;
    await session.init();
    await session.saveSession(rememberMe: true, adminId: 'admin_telkom');

    await session.clearSession(keepSavedId: false);
    expect(session.savedAdminId, isEmpty);
    expect(session.isRememberMe, isFalse);
  });
}
