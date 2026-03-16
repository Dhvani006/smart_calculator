import 'package:flutter/material.dart';

/// App color constants following the dark theme design system
class AppColors {
  // Background gradients
  static const Color backgroundDark = Color(0xFF0E1621);
  static const Color backgroundLight = Color(0xFF111B27);
  
  // Primary accent colors
  static const Color accentBlue = Color(0xFF1E88FF);
  static const Color accentGreen = Color(0xFF2ECC71);
  static const Color accentOrange = Color(0xFFFF8C42);
  static const Color accentPurple = Color(0xFF9B59B6);
  
  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A94A6);
  static const Color textMuted = Color(0xFF5A6270);
  
  // Border colors
  static const Color borderColor = Color(0xFF2C3E50);
  
  // Functional colors
  static const Color error = Color(0xFFE64545);
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFFFB84D);
  
  // Card colors
  static const Color cardBackground = Color(0xFF1A2332);
  static const Color cardBackgroundLight = Color(0xFF1F2937);
  
  // Button colors
  static const Color buttonPrimary = accentBlue;
  static const Color buttonSecondary = Color(0xFF2C3E50);
  static const Color buttonDanger = error;
  
  // Glassmorphism overlay
  static Color glassOverlay = Colors.white.withOpacity(0.05);
  static Color glassOverlayStrong = Colors.white.withOpacity(0.1);
  
  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundDark, backgroundLight],
  );
  
  static LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      cardBackground.withOpacity(0.8),
      cardBackgroundLight.withOpacity(0.6),
    ],
  );
}
