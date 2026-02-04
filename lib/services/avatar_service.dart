import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

class AvatarService {
  static const _key = 'user_avatar_base64';

  /// Save avatar bytes (base64) to local preferences
  static Future<void> saveAvatar(Uint8List bytes) async {
    final prefs = await SharedPreferences.getInstance();
    final b64 = base64Encode(bytes);
    await prefs.setString(_key, b64);
  }

  /// Load avatar bytes from preferences
  static Future<Uint8List?> loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final b64 = prefs.getString(_key);
    if (b64 == null || b64.isEmpty) return null;
    try {
      return base64Decode(b64);
    } catch (_) {
      return null;
    }
  }

  /// Clear saved avatar
  static Future<void> clearAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
