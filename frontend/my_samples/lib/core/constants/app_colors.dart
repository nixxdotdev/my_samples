import 'package:flutter/material.dart';

/// Deep Marine & Electric Mint Palette
/// #AAFFC7 (Electric Mint) | #67C090 (Fresh Jade) | #215B63 (Deep Teal) | #124170 (Midnight Marine)
class AppColors {
  // Surfaces & Background
  static const Color background = Color(0xFFF2FAF6); // Soft Cool Mint Frost
  static const Color surface = Color(0xFFFFFFFF); // Crisp White Cards
  static const Color surfaceMuted = Color(0xFFE6F5EE); // Muted Mint Tint
  static const Color border = Color(0xFFCDE8DC); // Soft Jade Border

  // Brand Primaries (from user's palette)
  static const Color primary = Color(0xFF215B63); // Deep Teal
  static const Color primaryLight = Color(0xFF67C090); // Fresh Jade / Mint
  static const Color primaryDark = Color(0xFF124170); // Midnight Marine Blue
  static const Color electricMint = Color(0xFFAAFFC7); // Electric Mint Frost

  // Analytics Card Gradient (Deep Marine to Deep Teal)
  static const List<Color> analyticsGradient = [
    Color(0xFF124170), // Midnight Marine
    Color(0xFF215B63), // Deep Teal
  ];

  // Text Colors
  static const Color textPrimary = Color(0xFF0D2533); // Midnight Navy
  static const Color textSecondary = Color(0xFF4A7079); // Muted Teal Slate
  static const Color textMuted = Color(0xFF81A6AD);

  // Status & Urgency Colors
  static const Color pending = Color(0xFFF59E0B); // Amber Orange
  static const Color approved = Color(0xFF67C090); // Fresh Jade (#67C090)
  static const Color posting = Color(0xFF215B63); // Deep Teal (#215B63)
  static const Color critical = Color(0xFFEF4444); // Crimson Coral (<= 2 days)
  static const Color warning = Color(0xFFF59E0B); // Amber Warning (3-5 days)
  static const Color safe = Color(0xFF67C090); // Fresh Jade (6+ days)

  static Color getUrgencyColor(int remainingDays) {
    if (remainingDays <= 2) return critical;
    if (remainingDays <= 5) return warning;
    return safe;
  }
}
