import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:music_player/models/track_model.dart';

class StorageService {
  static const String _favoritesKey = 'favorite_tracks';
  static const String _themeKey = 'is_dark_mode';

  /// Save favorite tracks list
  static Future<void> saveFavorites(List<TrackModel> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = favorites.map((track) => track.toJson()).toList();
      await prefs.setString(_favoritesKey, jsonEncode(jsonList));
    } catch (e) {
      // Silently ignore or log cache errors
    }
  }

  /// Load favorite tracks list
  static Future<List<TrackModel>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_favoritesKey);
      if (jsonString == null || jsonString.isEmpty) return [];

      final List<dynamic> decodedList = jsonDecode(jsonString);
      return decodedList
          .map((item) => TrackModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Save dark mode preference
  static Future<void> saveThemeMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode);
  }

  /// Load dark mode preference
  static Future<bool?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey);
  }
}
