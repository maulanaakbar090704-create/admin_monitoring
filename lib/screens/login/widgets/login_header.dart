import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo Telkom Akses dalam Card Putih Bersih
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/telkom_akses_logo.png',
            height: 44,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.business_rounded,
                size: 44,
                color: Color(0xFFBB0016),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Admin Panel',
          style: TextStyle(
            fontFamily: 'Hanken Grotesk',
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Corporate Car Monitoring System',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.85),
            letterSpacing: 0.2,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
