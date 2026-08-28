import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Uygulama genelinde kullanılan renk ve stil sabitleri.
class OrjandaRenkleri {
  static const Color arkaPlan = Color(0xFF131C11);
  static const Color kart = Color(0xFF1C2819);
  static const Color yazi = Color(0xFFEEF0E8);
  static const Color yaziSoluk = Color(0xFF8F9A89);
  static const Color cizgi = Color(0xFF3A4636);
  static const Color turuncu = Color(0xFFE2703A);
  static const Color yesil = Color(0xFF2E7D32);
  static const Color acikYesil = Color(0xFF4CAF6F);
  static const Color kirmizi = Color(0xFFE05252);
}

ThemeData orjandaTemasi() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: OrjandaRenkleri.arkaPlan,
    colorScheme: base.colorScheme.copyWith(
      primary: OrjandaRenkleri.turuncu,
      secondary: OrjandaRenkleri.acikYesil,
      surface: OrjandaRenkleri.kart,
    ),
    textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: OrjandaRenkleri.yazi,
      displayColor: OrjandaRenkleri.yazi,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: OrjandaRenkleri.kart,
      hintStyle: TextStyle(color: OrjandaRenkleri.yaziSoluk),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: OrjandaRenkleri.turuncu),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: OrjandaRenkleri.turuncu),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: OrjandaRenkleri.turuncu, width: 2),
      ),
    ),
  );
}
