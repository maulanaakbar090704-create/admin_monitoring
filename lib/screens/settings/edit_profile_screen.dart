import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/language_manager.dart';

class EditProfileScreen extends StatefulWidget {
  final String initialName;
  final String initialRole;

  const EditProfileScreen({
    super.key,
    required this.initialName,
    required this.initialRole,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  late TextEditingController _nameController;
  late TextEditingController _nikController;
  late TextEditingController _phoneController;

  String _email = '';
  bool _isLoading = true;
  bool _isSaving = false;

  final List<String> _avatarOptions = [
    'https://lh3.googleusercontent.com/aida-public/AB6AXuB3gv5lyQbE3v1zuGLRFxEmDCNvVRallpivUIpVuBXmd2V3paDa8UflN7A7x7pK67Rgjs8Fdid2i0B6xP7VBz9ia_rRqPz1r-I48SbcuyUDVgkUD50Dfr2mL58NPssBKNQDrY2YGUO7hbHx0XMiF5ZD2kIXGOXyavtXOeaYUBeZ4qBYbDAulHJcVqbTXy89KNZm2sYyJOgWzlt-G8IMySO_Q1-XIC0EX36z5mnV5XZPPesqTO1JCeY',
    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150',
    'https://images.unsplash.com/photo-1628157582853-a796fa650a6a?w=150',
  ];
  int _selectedAvatarIndex = 0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _nikController = TextEditingController();
    _phoneController = TextEditingController();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nikController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        _email = user.email ?? 'admin@telkom.com';

        final response = await supabase
            .from('profiles')
            .select('full_name, employee_no, phone_number')
            .eq('id', user.id)
            .maybeSingle();

        if (response != null && mounted) {
          setState(() {
            _nameController.text = response['full_name'] ?? widget.initialName;
            _nikController.text = response['employee_no'] ?? '';
            _phoneController.text = response['phone_number'] ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final lm = LanguageManager.instance;

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User tidak terautentikasi.');
      }

      await supabase.from('profiles').update({
        'full_name': _nameController.text.trim(),
        'employee_no': _nikController.text.trim(),
        'phone_number': _phoneController.text.trim(),
      }).eq('id', user.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Text(lm.t('profile_saved')),
            ],
          ),
          backgroundColor: const Color(0xFF1B873F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      // Kembalikan status sukses ke halaman sebelumnya agar data ter-refresh
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${lm.t('error')}: $e'),
          backgroundColor: const Color(0xFFBB0016),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showAvatarSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Foto Avatar',
                style: TextStyle(
                  fontFamily: 'Hanken Grotesk',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF191C1D),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pilih gambar avatar yang ingin ditampilkan di profil Anda.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_avatarOptions.length, (index) {
                  final isSelected = _selectedAvatarIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedAvatarIndex = index);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFBB0016)
                              : Colors.grey.shade300,
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(3),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(_avatarOptions[index]),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
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
          lm.t('edit_profile'),
          style: const TextStyle(
            fontFamily: 'Hanken Grotesk',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFBB0016)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Avatar Header Card
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF0F3567),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(
                                _avatarOptions[_selectedAvatarIndex],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _showAvatarSelector,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFBB0016),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _showAvatarSelector,
                      icon: const Icon(Icons.photo_library_outlined, size: 16),
                      label: const Text(
                        'Ubah Avatar',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF0F3567),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Card Form Input
                    Container(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Role Badge
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFBB0016).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.admin_panel_settings,
                                      color: Color(0xFFBB0016),
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      lm.t('profile_role'),
                                      style: const TextStyle(
                                        color: Color(0xFFBB0016),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Admin Fleet & Monitoring',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF5C403D),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Nama Lengkap
                          Text(
                            lm.t('profile_name'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Color(0xFF191C1D),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.person_outline, size: 20),
                              hintText: 'Masukkan nama lengkap',
                              filled: true,
                              fillColor: const Color(0xFFF8F9FA),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFF0F3567),
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Nama lengkap wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // NIK / Nomor Karyawan
                          Text(
                            lm.t('profile_nik'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Color(0xFF191C1D),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nikController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                              hintText: 'Contoh: 090704 / NIK Telkom',
                              filled: true,
                              fillColor: const Color(0xFFF8F9FA),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFF0F3567),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Telepon / WhatsApp
                          Text(
                            lm.t('profile_phone'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Color(0xFF191C1D),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                              hintText: 'Contoh: 081234567890',
                              filled: true,
                              fillColor: const Color(0xFFF8F9FA),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFF0F3567),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Email (Read-only)
                          Text(
                            lm.t('profile_email'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.email_outlined,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _email.isEmpty ? 'admin@telkom.com' : _email,
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.lock_outline, color: Colors.grey, size: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Tombol Simpan
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBB0016),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isSaving ? null : _saveProfile,
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.save_outlined, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    lm.t('save'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
