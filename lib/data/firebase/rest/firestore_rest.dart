import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/errors/app_exception.dart';
import '../../../core/models/geo_point.dart';
import 'firebase_auth_rest.dart';

/// Firestore REST client — auth, cloud_firestore plagini o'rniga.
///
/// Asosiy metodlar:
/// - getDoc(path)
/// - setDoc(path, fields, {merge})
/// - updateDoc(path, fields)
/// - deleteDoc(path)
/// - listDocs(collectionPath)
/// - runQuery(parentPath, structuredQuery)
/// - streamDoc(path, {interval}) — polling
/// - streamCollection(collectionPath, {interval}) — polling
class FirestoreRest {
  FirestoreRest({
    required this.projectId,
    required this.auth,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String projectId;
  final FirebaseAuthRest auth;
  final http.Client _client;

  String get _base =>
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)';

  Future<Map<String, String>> _headers() async {
    final token = await auth.getIdToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ---------- Public API ----------

  /// `path` masalan: `users/abc123` yoki `cities/xyz/wells/well1`.
  Future<DocSnapshot?> getDoc(String path) async {
    final resp = await _client.get(
      Uri.parse('$_base/documents/$path'),
      headers: await _headers(),
    );
    if (resp.statusCode == 404) return null;
    if (resp.statusCode != 200) throw _err(resp);
    final raw = jsonDecode(resp.body) as Map<String, dynamic>;
    return _parseDoc(raw);
  }

  /// Yangi yoki mavjud doc. Auto-ID kerak bo'lsa, `path` ga `?` belgilash.
  Future<DocSnapshot> setDoc(
    String path,
    Map<String, Object?> data, {
    bool merge = false,
  }) async {
    final uri = Uri.parse(
      '$_base/documents/$path${merge ? '?updateMask.fieldPaths=${data.keys.join('&updateMask.fieldPaths=')}' : ''}',
    );
    final resp = await _client.patch(
      uri,
      headers: await _headers(),
      body: jsonEncode({'fields': _encodeFields(data)}),
    );
    if (resp.statusCode != 200) throw _err(resp);
    final raw = jsonDecode(resp.body) as Map<String, dynamic>;
    return _parseDoc(raw)!;
  }

  /// Auto-ID bilan yangi doc qo'shish. `collectionPath`: masalan, `cities`.
  Future<DocSnapshot> addDoc(String collectionPath, Map<String, Object?> data) async {
    final uri = Uri.parse('$_base/documents/$collectionPath');
    final resp = await _client.post(
      uri,
      headers: await _headers(),
      body: jsonEncode({'fields': _encodeFields(data)}),
    );
    if (resp.statusCode != 200) throw _err(resp);
    final raw = jsonDecode(resp.body) as Map<String, dynamic>;
    return _parseDoc(raw)!;
  }

  Future<void> deleteDoc(String path) async {
    final resp = await _client.delete(
      Uri.parse('$_base/documents/$path'),
      headers: await _headers(),
    );
    if (resp.statusCode != 200) throw _err(resp);
  }

  /// Collection'dagi hamma doc'lar (kichik collection'lar uchun).
  Future<List<DocSnapshot>> listDocs(String collectionPath) async {
    final docs = <DocSnapshot>[];
    String? pageToken;
    do {
      final uri = Uri.parse(
        '$_base/documents/$collectionPath${pageToken != null ? '?pageToken=$pageToken' : ''}',
      );
      final resp = await _client.get(uri, headers: await _headers());
      if (resp.statusCode == 404) return docs;
      if (resp.statusCode != 200) throw _err(resp);
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      final docsRaw = (body['documents'] as List?) ?? const [];
      for (final d in docsRaw) {
        final s = _parseDoc(d as Map<String, dynamic>);
        if (s != null) docs.add(s);
      }
      pageToken = body['nextPageToken'] as String?;
    } while (pageToken != null);
    return docs;
  }

  /// Stream — periodic polling + distinct (faqat updateTime/data o'zgarganda emit qiladi).
  Stream<DocSnapshot?> streamDoc(
    String path, {
    Duration interval = const Duration(seconds: 10),
  }) async* {
    DocSnapshot? last;
    yield last = await getDoc(path);
    final timer = Stream.periodic(interval);
    await for (final _ in timer) {
      try {
        final snap = await getDoc(path);
        if (snap?.updateTime != last?.updateTime) {
          yield last = snap;
        }
      } catch (_) {
        // Xatoni yutamiz, keyingi iteratsiya qayta urinadi.
      }
    }
  }

  Stream<List<DocSnapshot>> streamCollection(
    String collectionPath, {
    Duration interval = const Duration(seconds: 10),
  }) async* {
    List<DocSnapshot> last;
    yield last = await listDocs(collectionPath);
    final timer = Stream.periodic(interval);
    await for (final _ in timer) {
      try {
        final docs = await listDocs(collectionPath);
        if (!_sameSnapshots(docs, last)) {
          yield last = docs;
        }
      } catch (_) {}
    }
  }

  bool _sameSnapshots(List<DocSnapshot> a, List<DocSnapshot> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i].updateTime != b[i].updateTime) {
        return false;
      }
    }
    return true;
  }

  // ---------- Encoding helpers ----------

  Map<String, dynamic> _encodeFields(Map<String, Object?> data) {
    final out = <String, dynamic>{};
    data.forEach((k, v) {
      out[k] = _encodeValue(v);
    });
    return out;
  }

  Map<String, dynamic> _encodeValue(Object? v) {
    if (v == null) return {'nullValue': null};
    if (v is bool) return {'booleanValue': v};
    if (v is int) return {'integerValue': v.toString()};
    if (v is double) return {'doubleValue': v};
    if (v is String) return {'stringValue': v};
    if (v is DateTime) return {'timestampValue': v.toUtc().toIso8601String()};
    if (v is GeoPoint) return v.toFirestoreValue();
    if (v is List) {
      return {
        'arrayValue': {
          'values': v.map((e) => _encodeValue(e)).toList(),
        },
      };
    }
    if (v is Map) {
      return {
        'mapValue': {
          'fields': _encodeFields(v.cast<String, Object?>()),
        },
      };
    }
    throw ArgumentError('Unsupported value type: ${v.runtimeType}');
  }

  Object? _decodeValue(Map<String, dynamic>? value) {
    if (value == null) return null;
    if (value.containsKey('nullValue')) return null;
    if (value.containsKey('booleanValue')) return value['booleanValue'] as bool;
    if (value.containsKey('integerValue')) {
      final s = value['integerValue'];
      return s is int ? s : int.parse(s as String);
    }
    if (value.containsKey('doubleValue')) {
      return (value['doubleValue'] as num).toDouble();
    }
    if (value.containsKey('stringValue')) return value['stringValue'] as String;
    if (value.containsKey('timestampValue')) {
      return DateTime.parse(value['timestampValue'] as String);
    }
    if (value.containsKey('geoPointValue')) {
      final gp = value['geoPointValue'] as Map<String, dynamic>;
      return GeoPoint(
        (gp['latitude'] as num?)?.toDouble() ?? 0,
        (gp['longitude'] as num?)?.toDouble() ?? 0,
      );
    }
    if (value.containsKey('arrayValue')) {
      final vs = (value['arrayValue'] as Map<String, dynamic>)['values'] as List?;
      return (vs ?? const [])
          .map((e) => _decodeValue(e as Map<String, dynamic>))
          .toList(growable: false);
    }
    if (value.containsKey('mapValue')) {
      final fields = (value['mapValue'] as Map<String, dynamic>)['fields'] as Map<String, dynamic>?;
      return _decodeFields(fields ?? const {});
    }
    return null;
  }

  Map<String, Object?> _decodeFields(Map<String, dynamic> fields) {
    final out = <String, Object?>{};
    fields.forEach((k, v) {
      out[k] = _decodeValue(v as Map<String, dynamic>);
    });
    return out;
  }

  DocSnapshot? _parseDoc(Map<String, dynamic> raw) {
    final name = raw['name'] as String?;
    if (name == null) return null;
    final id = name.split('/').last;
    final fields = raw['fields'] as Map<String, dynamic>?;
    return DocSnapshot(
      id: id,
      path: name,
      data: fields == null ? <String, Object?>{} : _decodeFields(fields),
      createTime: _parseTime(raw['createTime']),
      updateTime: _parseTime(raw['updateTime']),
    );
  }

  DateTime? _parseTime(Object? v) {
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  AppException _err(http.Response resp) {
    if (resp.statusCode == 403) return const PermissionDeniedException();
    if (resp.statusCode == 404) return const NotFoundException();
    return UnknownException('firestore_${resp.statusCode}: ${resp.body}');
  }
}

class DocSnapshot {
  const DocSnapshot({
    required this.id,
    required this.path,
    required this.data,
    this.createTime,
    this.updateTime,
  });

  final String id;
  final String path;
  final Map<String, Object?> data;
  final DateTime? createTime;
  final DateTime? updateTime;

  bool get exists => data.isNotEmpty;
}

final firestoreRestProvider = Provider<FirestoreRest>((ref) {
  return FirestoreRest(
    projectId: const String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: 'agrobankcallcentertrain',
    ),
    auth: ref.watch(firebaseAuthRestProvider),
  );
});
