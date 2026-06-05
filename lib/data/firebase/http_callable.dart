import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/errors/app_exception.dart';
import 'rest/firebase_auth_rest.dart';

/// Cloud Functions callable'larini HTTP REST orqali chaqirish.
class HttpCallable {
  HttpCallable({
    required this.projectId,
    required this.region,
    required this.auth,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String projectId;
  final String region;
  final FirebaseAuthRest auth;
  final http.Client _client;

  Uri _urlFor(String name) =>
      Uri.parse('https://$region-$projectId.cloudfunctions.net/$name');

  Future<Map<String, dynamic>> call(
    String name,
    Map<String, dynamic> data, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final token = await auth.getIdToken();
    if (token != null) headers['Authorization'] = 'Bearer $token';

    final http.Response resp;
    try {
      resp = await _client
          .post(_urlFor(name), headers: headers, body: jsonEncode({'data': data}))
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
    return result is Map ? Map<String, dynamic>.from(result) : <String, dynamic>{};
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
    projectId: const String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: 'agrobankcallcentertrain',
    ),
    region: 'europe-west1',
    auth: ref.watch(firebaseAuthRestProvider),
  );
});
