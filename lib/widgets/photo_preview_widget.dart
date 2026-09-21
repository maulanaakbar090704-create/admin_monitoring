import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class PhotoPreviewWidget extends StatelessWidget {
  final String title;
  final String? photoPath;
  final IconData defaultIcon;
  final Color accentColor;
  final String? subtitle;

  const PhotoPreviewWidget({
    super.key,
    required this.title,
    required this.photoPath,
    this.defaultIcon = Icons.photo_camera_outlined,
    this.accentColor = const Color(0xFFBB0016),
    this.subtitle,
  });

  bool get _isNetworkUrl {
    if (photoPath == null) return false;
    final path = photoPath!.trim().toLowerCase();
    return path.startsWith('http://') || path.startsWith('https://');
  }

  bool get _isBase64 {
    if (photoPath == null) return false;
    final path = photoPath!.trim();
    return path.startsWith('data:image') || (path.length > 300 && !path.contains('/') && !path.contains('\\'));
  }

  Uint8List? _decodeBase64() {
    try {
      if (photoPath == null) return null;
      var raw = photoPath!.trim();
      if (raw.contains(',')) {
        raw = raw.split(',').last;
      }
      return base64Decode(raw);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoPath != null && photoPath!.trim().isNotEmpty;
    final isNetwork = _isNetworkUrl;
    final isBase64 = _isBase64;
    final base64Bytes = isBase64 ? _decodeBase64() : null;
    final isActualImageAvailable = isNetwork || (isBase64 && base64Bytes != null);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(defaultIcon, size: 18, color: accentColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Hanken Grotesk',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF191C1D),
                    ),
                  ),
                ),
                if (isActualImageAvailable)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2F0D9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 12, color: Color(0xFF276A3C)),
                        SizedBox(width: 4),
                        Text(
                          'Foto Terlampir',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF276A3C),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (hasPhoto)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3CD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 12, color: Color(0xFF856404)),
                        SizedBox(width: 4),
                        Text(
                          'Path Lokal',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF856404),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Tidak Ada',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEDEEEF)),

          // Image Content
          if (!hasPhoto)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Center(
                child: Column(
                  children: [
                    Icon(defaultIcon, size: 36, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text(
                      'Foto belum dilampirkan oleh peminjam.',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            )
          else if (isNetwork)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
              child: GestureDetector(
                onTap: () => _showFullScreenDialog(context, type: _PhotoType.network),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Image.network(
                      photoPath!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          height: 180,
                          color: Colors.grey.shade100,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                  : null,
                              color: const Color(0xFFBB0016),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120,
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: Text('Gagal memuat gambar dari URL', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ),
                        );
                      },
                    ),
                    Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.zoom_in, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text('Ketuk untuk Perbesar', style: TextStyle(color: Colors.white, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (isBase64 && base64Bytes != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
              child: GestureDetector(
                onTap: () => _showFullScreenDialog(context, type: _PhotoType.base64, memoryBytes: base64Bytes),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Image.memory(
                      base64Bytes,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.zoom_in, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text('Perbesar', style: TextStyle(color: Colors.white, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            // Fallback jika berupa local_storage path (belum terunggah ke Supabase Storage)
            GestureDetector(
              onTap: () => _showFullScreenDialog(context, type: _PhotoType.localStorage),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Color(0xFFFAFBFD),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(defaultIcon, color: accentColor, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (subtitle != null && subtitle!.isNotEmpty)
                                Text(
                                  subtitle!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF191C1D),
                                  ),
                                ),
                              const SizedBox(height: 2),
                              Text(
                                photoPath!.split('/').last,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                  color: Color(0xFF5C403D),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.info_outline, size: 20, color: Color(0xFF856404)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info, size: 14, color: Color(0xFF856404)),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'File tersimpan di perangkat peminjam (Bucket Supabase belum aktif)',
                              style: TextStyle(fontSize: 10, color: Color(0xFF856404), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showFullScreenDialog(
    BuildContext context, {
    required _PhotoType type,
    Uint8List? memoryBytes,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Hanken Grotesk',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),
              if (type == _PhotoType.network && photoPath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    photoPath!,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    loadingBuilder: (c, child, p) {
                      if (p == null) return child;
                      return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
                    },
                    errorBuilder: (c, e, s) => const Center(
                      child: Padding(padding: EdgeInsets.all(24), child: Text('Gagal memuat gambar')),
                    ),
                  ),
                )
              else if (type == _PhotoType.base64 && memoryBytes != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(memoryBytes, fit: BoxFit.contain),
                )
              else
                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          Icon(defaultIcon, size: 64, color: accentColor),
                          const SizedBox(height: 12),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF191C1D),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            photoPath ?? '-',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFF856404)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Foto ini berhasil diambil peminjam di HP, namun hanya nama file yang tersimpan karena Bucket Storage "bookings" di dashboard Supabase belum diaktifkan.',
                              style: TextStyle(fontSize: 11, color: Color(0xFF856404), height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Tutup', style: TextStyle(color: Color(0xFFBB0016))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _PhotoType { network, base64, localStorage }
