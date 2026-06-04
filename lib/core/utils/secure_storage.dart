import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageKeys {
  SecureStorageKeys._();
  static const String passKey = 'auth.passKey';
  static const String installId = 'app.installId';
}

class SecureStorage {
  SecureStorage(this._storage);

  final FlutterSecureStorage _storage;

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  Future<void> delete(String key) => _storage.delete(key: key);

  Future<void> clearAll() => _storage.deleteAll();
}

final secureStorageProvider = Provider<SecureStorage>((ref) {
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  return SecureStorage(storage);
});
