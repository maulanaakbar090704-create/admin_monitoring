import 'package:flutter/material.dart';
import '../../utils/language_manager.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  late AppLanguage _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = LanguageManager.instance.currentLanguage;
  }

  void _onLanguageSelected(AppLanguage lang) {
    setState(() {
      _selectedLanguage = lang;
    });

    LanguageManager.instance.setLanguage(lang);

    final lm = LanguageManager.instance;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              '${lm.t('language')}: ${lm.currentLanguageDisplayName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1B873F),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildLanguageOption({
    required AppLanguage language,
    required String flag,
    required String name,
    required String nativeName,
  }) {
    final isSelected = _selectedLanguage == language;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? const Color(0xFFBB0016) : const Color(0xFFE1E3E4),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? const Color(0xFFBB0016).withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          alignment: Alignment.center,
          child: Text(
            flag,
            style: const TextStyle(fontSize: 22),
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 15,
            color: isSelected ? const Color(0xFFBB0016) : const Color(0xFF191C1D),
          ),
        ),
        subtitle: Text(
          nativeName,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? const Color(0xFF5C403D) : Colors.grey,
          ),
        ),
        trailing: isSelected
            ? Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFFBB0016),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              )
            : Icon(Icons.circle_outlined, color: Colors.grey.shade400, size: 22),
        onTap: () => _onLanguageSelected(language),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
          lm.t('language'),
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
                  Icons.translate,
                  color: Color(0xFF0F3567),
                  size: 26,
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pilihan Bahasa / Language',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF191C1D),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Perubahan bahasa akan langsung diterapkan pada seluruh menu antarmuka aplikasi.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          _buildLanguageOption(
            language: AppLanguage.id,
            flag: '🇮🇩',
            name: 'Bahasa Indonesia',
            nativeName: 'Bahasa resmi Indonesia (Default)',
          ),

          _buildLanguageOption(
            language: AppLanguage.en,
            flag: '🇬🇧',
            name: 'English',
            nativeName: 'English (United Kingdom / International)',
          ),

          _buildLanguageOption(
            language: AppLanguage.su,
            flag: '🌾',
            name: 'Basa Sunda',
            nativeName: 'Basa Wewengkon Jawa Barat / Bogor',
          ),

          _buildLanguageOption(
            language: AppLanguage.jv,
            flag: '🏛️',
            name: 'Basa Jawa',
            nativeName: 'Basa Daerah Jawa Tengah & Jawa Timur',
          ),
        ],
      ),
    );
  }
}
