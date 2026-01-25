import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/providers.dart';

/// État du thème
class ThemeState {
  final ThemeMode themeMode;

  const ThemeState({this.themeMode = ThemeMode.light});

  bool get isDarkMode => themeMode == ThemeMode.dark;

  ThemeState copyWith({ThemeMode? themeMode}) {
    return ThemeState(themeMode: themeMode ?? this.themeMode);
  }
}

/// Notifier pour gérer le thème
class ThemeNotifier extends StateNotifier<ThemeState> {
  static const String _themeKey = 'theme_mode';
  final SharedPreferences _prefs;

  ThemeNotifier(this._prefs) : super(const ThemeState()) {
    _loadTheme();
  }

  /// Charger le thème sauvegardé
  Future<void> _loadTheme() async {
    final isDark = _prefs.getBool(_themeKey) ?? false;
    state = ThemeState(themeMode: isDark ? ThemeMode.dark : ThemeMode.light);
  }

  /// Toggle entre dark et light mode
  Future<void> toggleTheme() async {
    final newMode = state.isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await _prefs.setBool(_themeKey, newMode == ThemeMode.dark);
    state = ThemeState(themeMode: newMode);
  }

  /// Définir le thème explicitement
  Future<void> setTheme(ThemeMode mode) async {
    await _prefs.setBool(_themeKey, mode == ThemeMode.dark);
    state = ThemeState(themeMode: mode);
  }
}

/// Provider pour le thème
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeNotifier(prefs);
});
