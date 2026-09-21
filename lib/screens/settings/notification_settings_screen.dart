import 'package:flutter/material.dart';
import '../../utils/language_manager.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  // Preferensi notifikasi admin
  bool _newBookingAlert = true;
  bool _geofenceAlert = true;
  bool _trackingUpdate = true;
  bool _soundVibration = true;
  bool _emailDigest = false;

  void _triggerTestNotification() {
    final lm = LanguageManager.instance;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active,
                color: Color(0xFFBB0016),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lm.t('notif_test_success'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const Text(
                    'Peringatan armada & peminjaman aktif berjalan dengan normal.',
                    style: TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F3567),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'OK',
          textColor: const Color(0xFFFFF078),
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE1E3E4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        activeThumbColor: const Color(0xFFBB0016),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF191C1D),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            description,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lm = LanguageManager.instance;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          lm.t('notif_title'),
          style: const TextStyle(
            fontFamily: 'Hanken Grotesk',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // Banner informasi
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE1E3E4)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_active_outlined,
                  color: Color(0xFFBB0016),
                  size: 28,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Pusat Pemberitahuan Admin',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF191C1D),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Sesuaikan jenis pemberitahuan operasional armada yang ingin Anda terima.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Text(
            'OPERASIONAL ARMADA',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),

          _buildSwitchItem(
            icon: Icons.assignment_turned_in_outlined,
            iconColor: const Color(0xFF0F3567),
            title: lm.t('notif_booking_title'),
            description: lm.t('notif_booking_desc'),
            value: _newBookingAlert,
            onChanged: (val) => setState(() => _newBookingAlert = val),
          ),

          _buildSwitchItem(
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFBB0016),
            title: lm.t('notif_geofence_title'),
            description: lm.t('notif_geofence_desc'),
            value: _geofenceAlert,
            onChanged: (val) => setState(() => _geofenceAlert = val),
          ),

          _buildSwitchItem(
            icon: Icons.location_on_outlined,
            iconColor: Colors.teal,
            title: lm.t('notif_tracking_title'),
            description: lm.t('notif_tracking_desc'),
            value: _trackingUpdate,
            onChanged: (val) => setState(() => _trackingUpdate = val),
          ),

          const SizedBox(height: 16),
          const Text(
            'SUARA & SISTEM',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),

          _buildSwitchItem(
            icon: Icons.volume_up_outlined,
            iconColor: Colors.deepOrange,
            title: lm.t('notif_sound_title'),
            description: lm.t('notif_sound_desc'),
            value: _soundVibration,
            onChanged: (val) => setState(() => _soundVibration = val),
          ),

          _buildSwitchItem(
            icon: Icons.mark_email_read_outlined,
            iconColor: Colors.indigo,
            title: lm.t('notif_email_title'),
            description: lm.t('notif_email_desc'),
            value: _emailDigest,
            onChanged: (val) => setState(() => _emailDigest = val),
          ),

          const SizedBox(height: 24),

          // Tombol Uji Notifikasi
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0F3567),
                side: const BorderSide(color: Color(0xFF0F3567), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.send_outlined, size: 18),
              label: Text(
                lm.t('notif_test_btn'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              onPressed: _triggerTestNotification,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
