import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/errors/app_exception.dart';

/// Cloud Functions callable'lariga HTTP REST orqali murojaat qiluvchi wrapper.
///
/// Sabab: `cloud_functions` Flutter plugin Windows desktopni qo'llab-quvvatlamaydi.
/// Bu wrapper esa pure-Dart (`http` paketi) bo'lgani uchun barcha platformalarda ishlaydi.
///
/// Callable Cloud Function HTTP shartlari:
/// - URL: `https://<region>-<project>.cloudfunctions.net/<function>`
/// - Method: POST
/// - Body: `{"data": {...}}`
/// - Response (200): `{"result": {...}}`
/// - Response (4xx/5xx): `{"error": {"status": "...", "message": "..."}}`
/// - Auth: Bearer `<idToken>` headerda (foydalanuvchi sign-in qilingan bo'lsa).
class HttpCallable {
  HttpCallable({
    required this.projectId,
    required this.region,
    FirebaseAuth? auth,
    http.Client? client,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _client = client ?? http.Client();

  final String projectId;
  final String region;
  final FirebaseAuth _auth;
  final http.Client _client;

  Uri _urlFor(String name) {
    return Uri.parse('https://$region-$projectId.cloudfunctions.net/$name');
  }

  /// Callable Cloud Function'ni chaqirib, javob `result` qiymatini qaytaradi.
  Future<Map<String, dynamic>> call(
    String name,
    Map<String, dynamic> data, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final url = _urlFor(name);
    final headers = <String, String>{'Content-Type': 'application/json'};

    final user = _auth.currentUser;
    if (user != null) {
      final token = await user.getIdToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    final http.Response resp;
    try {
      resp = await _client
          .post(url, headers: headers, body: jsonEncode({'data': data}))
          .timeout(timeout);
    } on TimeoutException {
      throw const NetworkException('timeout');
    } catch (_) {
      throw const NetworkException();
    }

    Map<String, dynamic> body;
    try {
      body = jsonDecode(resp.body) as Map<String, dynamic>;
    } catch (_) {
      throw UnknownException('bad_response_${resp.statusCode}');
    }

    if (resp.statusCode != 200) {
      final error = body['error'];
      if (error is Map) {
        final status = (error['status'] as String?) ?? 'UNKNOWN';
        final message = error['message'] as String?;
        throw _mapStatus(status, message);
      }
      throw UnknownException('http_${resp.statusCode}');
    }

    final result = body['result'];
    if (result is Map) {
      return Map<String, dynamic>.from(result);
    }
    return <String, dynamic>{};
  }

  AppException _mapStatus(String status, String? message) {
    switch (status) {
      case 'UNAUTHENTICATED':
        return AuthException(message ?? 'pass_key_not_found');
      case 'INVALID_ARGUMENT':
        return ValidationException(message ?? 'invalid_pass_key');
      case 'RESOURCE_EXHAUSTED':
        return AuthException(message ?? 'rate_limited');
      case 'PERMISSION_DENIED':
        return const PermissionDeniedException();
      case 'NOT_FOUND':
        return const NotFoundException();
      case 'UNAVAILABLE':
      case 'DEADLINE_EXCEEDED':
        return const NetworkException();
      default:
        return UnknownException(message ?? status);
    }
  }
}

final httpCallableProvider = Provider<HttpCallable>((ref) {
  return HttpCallable(
    projectId: 'agrobankcallcentertrain',
    region: 'europe-west1',
  );
});
