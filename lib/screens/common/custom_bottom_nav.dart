import 'package:flutter/material.dart';
import '../../utils/language_manager.dart';
import '../screens.dart';

class AdminBottomNav extends StatelessWidget {
  final int currentIndex;

  const AdminBottomNav({
    super.key,
    required this.currentIndex,
  });

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = const AdminDashboardScreen();
        break;
      case 1:
        nextScreen = const TrackingScreen();
        break;
      case 2:
        nextScreen = const HistoryScreen();
        break;
      case 3:
        nextScreen = const SettingsScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => nextScreen,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lm = LanguageManager.instance;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onItemTapped(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: const Color(0xFFBB0016),
        unselectedItemColor: const Color(0xFF254779),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.dashboard), label: lm.t('nav_dashboard')),
          BottomNavigationBarItem(icon: const Icon(Icons.explore), label: lm.t('nav_tracking')),
          BottomNavigationBarItem(icon: const Icon(Icons.history), label: lm.t('nav_history')),
          BottomNavigationBarItem(icon: const Icon(Icons.settings), label: lm.t('nav_settings')),
        ],
      ),
    );
  }
}
