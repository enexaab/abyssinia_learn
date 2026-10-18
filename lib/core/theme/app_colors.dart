import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF00AD2E);
  static const Color primaryDark = Color(0xFF007A21);
  static const Color primaryLight = Color(0xFFE6F7EA);
  static const Color primarySoft = Color(0xFFF2FBF4);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF6F8F7);
  static const Color border = Color(0xFFE3E8E5);
  static const Color textPrimary = Color(0xFF14231A);
  static const Color textSecondary = Color(0xFF5E6E64);
  static const Color textMuted = Color(0xFF93A19A);
  static const Color error = Color(0xFFE5484D);
  static const Color warning = Color(0xFFF5A623);
  static const Color skin = Color(0xFFF2C6A0);
  static const Color navy = Color(0xFF1D3B2A);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF12C13F), Color(0xFF00AD2E), Color(0xFF008F26)],
  );
}
