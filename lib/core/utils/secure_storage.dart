import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageKeys {
  SecureStorageKeys._();
  static const String passKey = 'auth.passKey';
  static const String installId = 'app.installId';
}

/// Note: SharedPreferences-backed, NOT actually encrypted.
/// See pubspec.yaml comment for context (Windows + ATL).
/// Pass-key himoyasi Firebase custom token tomonida.
class SecureStorage {
  SecureStorage(this._prefsFuture);

  final Future<SharedPreferences> _prefsFuture;

  Future<String?> read(String key) async {
    final prefs = await _prefsFuture;
    return prefs.getString(key);
  }

  Future<void> write(String key, String value) async {
    final prefs = await _prefsFuture;
    await prefs.setString(key, value);
  }

  Future<void> delete(String key) async {
    final prefs = await _prefsFuture;
    await prefs.remove(key);
  }

  Future<void> clearAll() async {
    final prefs = await _prefsFuture;
    await prefs.clear();
  }
}

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage(SharedPreferences.getInstance());
});
