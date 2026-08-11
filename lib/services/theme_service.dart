import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A full color palette for one visual theme of the app.
class AppTheme {
  final String id;
  final String name;
  final String description;

  final Color background;        // main screen background
  final Color headerBackground;  // app bar / header panel
  final Color accent;            // primary buttons, selected rod, links
  final Color secondaryAccent;   // gold-style highlight, best-move badges
  final Color dotColorA;         // falling-dots accent color 1
  final Color dotColorB;         // falling-dots accent color 2

  const AppTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.background,
    required this.headerBackground,
    required this.accent,
    required this.secondaryAccent,
    required this.dotColorA,
    required this.dotColorB,
  });
}

/// Default theme — dark purple + black + dark maroon.
const AppTheme midnightMaroon = AppTheme(
  id: "midnight_maroon",
  name: "Midnight Maroon",
  description: "Dark purple, black & deep maroon",
  background: Color(0xFF0B0210),
  headerBackground: Color(0xFF1A0B2E),
  accent: Color(0xFF8E2A45),
  secondaryAccent: Color(0xFFD4AF37),
  dotColorA: Color(0xFF6A1B9A),
  dotColorB: Color(0xFF8E2A45),
);

/// Custom theme #1 — dark blue + black + dark pink.
const AppTheme oceanPink = AppTheme(
  id: "ocean_pink",
  name: "Ocean Pink",
  description: "Dark blue, black & deep pink",
  background: Color(0xFF060912),
  headerBackground: Color(0xFF0B1B33),
  accent: Color(0xFFAD1457),
  secondaryAccent: Color(0xFF29B6F6),
  dotColorA: Color(0xFF1565C0),
  dotColorB: Color(0xFFAD1457),
);

/// Custom theme #2 (chosen to match the puzzle/mastery-certificate vibe) —
/// deep emerald + black + gold, echoing the certificate's own gold accents.
const AppTheme emeraldGold = AppTheme(
  id: "emerald_gold",
  name: "Emerald Gold",
  description: "Deep emerald, black & gold — matches your certificate",
  background: Color(0xFF060F0B),
  headerBackground: Color(0xFF0F2A22),
  accent: Color(0xFF2E7D32),
  secondaryAccent: Color(0xFFD4AF37),
  dotColorA: Color(0xFF2E7D32),
  dotColorB: Color(0xFFD4AF37),
);

class ThemeService {
  ThemeService._internal();
  static final ThemeService instance = ThemeService._internal();

  static const List<AppTheme> all = [midnightMaroon, oceanPink, emeraldGold];

  /// Listenable current theme — wrap any widget that needs to react to
  /// theme changes in a ValueListenableBuilder<AppTheme> on this.
  final ValueNotifier<AppTheme> current = ValueNotifier(midnightMaroon);

  static const _prefsKey = "selected_theme_id";

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString(_prefsKey);
      if (id != null) {
        final match = all.where((t) => t.id == id);
        if (match.isNotEmpty) {
          current.value = match.first;
        }
      }
    } catch (_) {
      // If prefs aren't available for some reason, just keep the default.
    }
  }

  Future<void> setTheme(AppTheme theme) async {
    current.value = theme;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, theme.id);
    } catch (_) {}
  }
}
