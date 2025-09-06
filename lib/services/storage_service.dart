import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress.dart';
import '../models/game_settings.dart';

class StorageService {
  static const String _userProgressKey = 'user_progress';
  static const String _gameSettingsKey = 'game_settings';
  
  static SharedPreferences? _prefs;

  /// Initialize SharedPreferences
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Save user progress
  static Future<bool> saveProgress(UserProgress progress) async {
    await init();
    final jsonString = jsonEncode(progress.toJson());
    return _prefs!.setString(_userProgressKey, jsonString);
  }

  /// Load user progress
  static Future<UserProgress?> loadProgress() async {
    await init();
    final jsonString = _prefs!.getString(_userProgressKey);
    
    if (jsonString == null) return null;
    
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserProgress.fromJson(json);
    } catch (e) {
      // If there's an error parsing, return null (fresh start)
      print('Error loading progress: $e');
      return null;
    }
  }

  /// Save game settings
  static Future<bool> saveGameSettings(GameSettings settings) async {
    await init();
    final jsonString = jsonEncode(settings.toJson());
    return _prefs!.setString(_gameSettingsKey, jsonString);
  }

  /// Load game settings
  static Future<GameSettings?> loadGameSettings() async {
    await init();
    final jsonString = _prefs!.getString(_gameSettingsKey);
    
    if (jsonString == null) return null;
    
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return GameSettings.fromJson(json);
    } catch (e) {
      print('Error loading game settings: $e');
      return null;
    }
  }

  /// Clear all stored data
  static Future<bool> clearAll() async {
    await init();
    return _prefs!.clear();
  }

  /// Clear just the progress data
  static Future<bool> clearProgress() async {
    await init();
    return _prefs!.remove(_userProgressKey);
  }

  /// Clear just the settings
  static Future<bool> clearSettings() async {
    await init();
    return _prefs!.remove(_gameSettingsKey);
  }

  /// Check if user has played before
  static Future<bool> hasPlayedBefore() async {
    final progress = await loadProgress();
    return progress != null;
  }

  /// Get a specific setting value
  static Future<T?> getSetting<T>(String key) async {
    await init();
    
    if (T == String) {
      return _prefs!.getString(key) as T?;
    } else if (T == int) {
      return _prefs!.getInt(key) as T?;
    } else if (T == bool) {
      return _prefs!.getBool(key) as T?;
    } else if (T == double) {
      return _prefs!.getDouble(key) as T?;
    }
    
    return null;
  }

  /// Set a specific setting value
  static Future<bool> setSetting<T>(String key, T value) async {
    await init();
    
    if (T == String) {
      return _prefs!.setString(key, value as String);
    } else if (T == int) {
      return _prefs!.setInt(key, value as int);
    } else if (T == bool) {
      return _prefs!.setBool(key, value as bool);
    } else if (T == double) {
      return _prefs!.setDouble(key, value as double);
    }
    
    return false;
  }
}
