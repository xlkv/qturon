import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../../core/errors/app_exception.dart';
import 'firebase_auth_rest.dart';

/// Firebase Storage REST client — firebase_storage plagini o'rniga.
///
/// Upload:
///   POST https://firebasestorage.googleapis.com/v0/b/{bucket}/o?name={encodedPath}&uploadType=media
///
/// Download URL format:
///   https://firebasestorage.googleapis.com/v0/b/{bucket}/o/{encodedPath}?alt=media&token={downloadToken}
class FirebaseStorageRest {
  FirebaseStorageRest({
    required this.bucket,
    required this.auth,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String bucket;
  final FirebaseAuthRest auth;
  final http.Client _client;
  static const _uuid = Uuid();

  /// `folder` masalan: `wells/abc123`. `bytes` — JPEG/PNG. Qaytaradi: download URL.
  Future<String> uploadImage({
    required String folder,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
    String? fileName,
  }) async {
    final name = fileName ?? '${_uuid.v4()}.jpg';
    final path = '$folder/$name';
    final encoded = Uri.encodeComponent(path);
    final url = Uri.parse(
      'https://firebasestorage.googleapis.com/v0/b/$bucket/o?name=$encoded&uploadType=media',
    );
    final token = await auth.getIdToken();
    final headers = <String, String>{
      'Content-Type': contentType,
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final resp = await _client.post(url, headers: headers, body: bytes);
    if (resp.statusCode != 200) {
      throw UnknownException('storage_upload_${resp.statusCode}: ${resp.body}');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final downloadToken = (data['downloadTokens'] as String?)?.split(',').first;
    return 'https://firebasestorage.googleapis.com/v0/b/$bucket/o/$encoded?alt=media${downloadToken != null ? '&token=$downloadToken' : ''}';
  }

  Future<void> deleteByUrl(String downloadUrl) async {
    // URL'dan path ajratib olamiz: ...o/{encodedPath}?alt=media&...
    final uri = Uri.parse(downloadUrl);
    final segs = uri.pathSegments;
    final idx = segs.indexOf('o');
    if (idx == -1 || idx + 1 >= segs.length) return;
    final encodedPath = segs.sublist(idx + 1).join('/');
    final url = Uri.parse('https://firebasestorage.googleapis.com/v0/b/$bucket/o/$encodedPath');
    final token = await auth.getIdToken();
    final headers = <String, String>{
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final resp = await _client.delete(url, headers: headers);
    if (resp.statusCode != 200 && resp.statusCode != 204 && resp.statusCode != 404) {
      throw UnknownException('storage_delete_${resp.statusCode}: ${resp.body}');
    }
  }
}

final firebaseStorageRestProvider = Provider<FirebaseStorageRest>((ref) {
  return FirebaseStorageRest(
    bucket: const String.fromEnvironment(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: 'agrobankcallcentertrain.firebasestorage.app',
    ),
    auth: ref.watch(firebaseAuthRestProvider),
  );
});
