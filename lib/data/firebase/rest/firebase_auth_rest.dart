import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/errors/app_exception.dart';

/// Firebase Auth — REST orqali (Identity Toolkit + Secure Token API).
///
/// Sabab: firebase_auth Flutter plagini Windows desktop'da 740MB C++ SDK talab qiladi.
/// Pure-Dart REST yondashuv hamma platformada tez va kichik.
///
/// Token persistence: SharedPreferences (`auth.idToken`, `auth.refreshToken`, `auth.uid`, `auth.expiresAt`).
class FirebaseAuthRest {
  FirebaseAuthRest({
    required this.apiKey,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String apiKey;
  final http.Client _client;
  final StreamController<String?> _uidController = StreamController.broadcast();

  static const _kIdToken = 'auth.idToken';
  static const _kRefreshToken = 'auth.refreshToken';
  static const _kUid = 'auth.uid';
  static const _kExpiresAt = 'auth.expiresAt';

  String? _idTokenCache;
  String? _refreshTokenCache;
  String? _uidCache;
  DateTime? _expiresAtCache;

  /// Sign-in/sign-out hodisalari oqimi (uid yoki null).
  Stream<String?> authStateChanges() async* {
    await _loadFromPrefs();
    yield _uidCache;
    yield* _uidController.stream;
  }

  String? get currentUid => _uidCache;

  Future<void> _loadFromPrefs() async {
    if (_uidCache != null) return;
    final prefs = await SharedPreferences.getInstance();
    _idTokenCache = prefs.getString(_kIdToken);
    _refreshTokenCache = prefs.getString(_kRefreshToken);
    _uidCache = prefs.getString(_kUid);
    final exp = prefs.getString(_kExpiresAt);
    _expiresAtCache = exp == null ? null : DateTime.tryParse(exp);
  }

  Future<void> _save({
    required String idToken,
    required String refreshToken,
    required String uid,
    required DateTime expiresAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kIdToken, idToken);
    await prefs.setString(_kRefreshToken, refreshToken);
    await prefs.setString(_kUid, uid);
    await prefs.setString(_kExpiresAt, expiresAt.toIso8601String());
    _idTokenCache = idToken;
    _refreshTokenCache = refreshToken;
    _uidCache = uid;
    _expiresAtCache = expiresAt;
    _uidController.add(uid);
  }

  Future<void> _clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kIdToken);
    await prefs.remove(_kRefreshToken);
    await prefs.remove(_kUid);
    await prefs.remove(_kExpiresAt);
    _idTokenCache = null;
    _refreshTokenCache = null;
    _uidCache = null;
    _expiresAtCache = null;
    _uidController.add(null);
  }

  /// Custom token bilan sign-in.
  Future<void> signInWithCustomToken(String customToken) async {
    final url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken?key=$apiKey',
    );
    final resp = await _client.post(
      url,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'token': customToken, 'returnSecureToken': true}),
    );
    if (resp.statusCode != 200) {
      throw AuthException('sign_in_failed', _parseError(resp.body));
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final idToken = data['idToken'] as String?;
    final refreshToken = data['refreshToken'] as String?;
    final expiresIn = data['expiresIn'] as String?;
    if (idToken == null || refreshToken == null || expiresIn == null) {
      throw AuthException('sign_in_bad_response', 'Server javobi to\'liq emas: ${data.keys.join(",")}');
    }

    // localId ba'zida bo'lmasligi mumkin — uid'ni JWT idToken'dan ajratib olamiz.
    var uid = data['localId'] as String?;
    uid ??= _extractUidFromJwt(idToken);
    if (uid == null) {
      throw const AuthException('sign_in_no_uid');
    }

    await _save(
      idToken: idToken,
      refreshToken: refreshToken,
      uid: uid,
      expiresAt: DateTime.now().add(Duration(seconds: int.parse(expiresIn))),
    );
  }

  String? _extractUidFromJwt(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length < 2) return null;
      var payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      while (payload.length % 4 != 0) {
        payload += '=';
      }
      final json = utf8.decode(base64.decode(payload));
      final claims = jsonDecode(json) as Map<String, dynamic>;
      return (claims['user_id'] as String?) ?? (claims['sub'] as String?);
    } catch (_) {
      return null;
    }
  }

  /// Joriy ID token (kerak bo'lsa avtomatik refresh qiladi).
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    await _loadFromPrefs();
    if (_idTokenCache == null || _refreshTokenCache == null) return null;
    final now = DateTime.now();
    final expiresSoon = _expiresAtCache == null ||
        now.isAfter(_expiresAtCache!.subtract(const Duration(minutes: 5)));
    if (forceRefresh || expiresSoon) {
      await _refresh();
    }
    return _idTokenCache;
  }

  Future<void> _refresh() async {
    final rt = _refreshTokenCache;
    if (rt == null) return;
    final url = Uri.parse(
      'https://securetoken.googleapis.com/v1/token?key=$apiKey',
    );
    final resp = await _client.post(
      url,
      headers: const {'Content-Type': 'application/x-www-form-urlencoded'},
      body: 'grant_type=refresh_token&refresh_token=$rt',
    );
    if (resp.statusCode != 200) {
      await _clear();
      throw AuthException('refresh_failed', _parseError(resp.body));
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final newId = data['id_token'] as String;
    final newRt = data['refresh_token'] as String;
    final uid = (data['user_id'] as String?) ?? _uidCache!;
    final expires = DateTime.now().add(
      Duration(seconds: int.parse(data['expires_in'] as String)),
    );
    await _save(
      idToken: newId,
      refreshToken: newRt,
      uid: uid,
      expiresAt: expires,
    );
  }

  Future<void> signOut() async {
    await _clear();
  }

  String _parseError(String body) {
    try {
      final m = jsonDecode(body) as Map<String, dynamic>;
      final err = m['error'];
      if (err is Map) {
        return (err['message'] as String?) ?? body;
      }
      return body;
    } catch (_) {
      return body;
    }
  }
}

final firebaseAuthRestProvider = Provider<FirebaseAuthRest>((ref) {
  return FirebaseAuthRest(apiKey: const String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'AIzaSyAT7YnjO7q1eRLZhJmh0Juw2E2uG7rZ2ZQ',
  ));
});
