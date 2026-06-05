import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/utils/secure_storage.dart';
import '../../../data/firebase/http_callable.dart';

class AuthRepository {
  AuthRepository(this._auth, this._callable, this._storage);

  final FirebaseAuth _auth;
  final HttpCallable _callable;
  final SecureStorage _storage;

  static const _uuid = Uuid();

  Future<String> _installId() async {
    var id = await _storage.read(SecureStorageKeys.installId);
    if (id == null) {
      id = _uuid.v4();
      await _storage.write(SecureStorageKeys.installId, id);
    }
    return id;
  }

  Future<void> signInWithPassKey(String passKey, {required bool remember}) async {
    if (!RegExp(r'^\d{6}$').hasMatch(passKey)) {
      throw const ValidationException('invalid_pass_key', '6 xonali raqam kiriting');
    }

    final installId = await _installId();

    final result = await _callable.call('validatePassKey', {
      'passKey': passKey,
      'installId': installId,
    });

    final token = result['customToken'] as String?;
    if (token == null) throw const UnknownException('no_token');

    try {
      await _auth.signInWithCustomToken(token);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code, e.message);
    }

    if (remember) {
      await _storage.write(SecureStorageKeys.passKey, passKey);
    } else {
      await _storage.delete(SecureStorageKeys.passKey);
    }
  }

  Future<bool> trySilentLogin() async {
    final passKey = await _storage.read(SecureStorageKeys.passKey);
    if (passKey == null) return false;

    try {
      await signInWithPassKey(passKey, remember: true);
      return true;
    } on AppException {
      await _storage.delete(SecureStorageKeys.passKey);
      return false;
    }
  }

  Future<void> signOut() async {
    await _storage.delete(SecureStorageKeys.passKey);
    await _auth.signOut();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    FirebaseAuth.instance,
    ref.watch(httpCallableProvider),
    ref.watch(secureStorageProvider),
  );
});
