import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/utils/secure_storage.dart';

class AuthRepository {
  AuthRepository(this._auth, this._functions, this._storage);

  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;
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

    final Map<String, dynamic> data;
    try {
      final callable = _functions.httpsCallable('validatePassKey');
      final result = await callable.call<Map<Object?, Object?>>({
        'passKey': passKey,
        'installId': installId,
      });
      data = Map<String, dynamic>.from(result.data);
    } on FirebaseFunctionsException catch (e) {
      throw _mapFunctionsException(e);
    } catch (_) {
      throw const NetworkException();
    }

    final token = data['customToken'] as String?;
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

  AppException _mapFunctionsException(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'unauthenticated':
        return const AuthException('pass_key_not_found', 'Noto\'g\'ri kod');
      case 'invalid-argument':
        return const ValidationException('invalid_pass_key', '6 xonali raqam kiriting');
      case 'resource-exhausted':
        return const AuthException('rate_limited', 'Juda ko\'p urinish. Keyinroq qayta urining.');
      case 'unavailable':
      case 'deadline-exceeded':
        return const NetworkException();
      default:
        return UnknownException(e.message);
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    FirebaseAuth.instance,
    FirebaseFunctions.instanceFor(region: 'europe-west1'),
    ref.watch(secureStorageProvider),
  );
});
