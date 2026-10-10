import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color darkBlue = Color(0xFF0D47A1);
  static const Color deepNavy = Color(0xFF0A192F); // New deep color
  static const Color darkGrey = Color(0xFF212121);
  static const Color footerBg = Color(0xFF020617); // Darker footer
  
  // Premium Accents
  static const Color accentYellow = Color(0xFFFFD600);
  static const Color premiumGold = Color(0xFFC5A059); // Academic Gold
  static const Color premiumSilver = Color(0xFFE2E8F0);
  
  // Neutral Palette
  static const Color surface = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;
  static const Color textMain = Color(0xFF0F172A); // Darker for better contrast
  static const Color textMuted = Color(0xFF64748B);
  
  // Gradients
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [primaryBlue, darkBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient deepGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFC5A059), Color(0xFFE8D098)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
