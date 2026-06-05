/// Sodda GeoPoint — cloud_firestore'ning GeoPoint'i o'rniga ishlatamiz
/// (firebase plugin'lar olib tashlandi).
class GeoPoint {
  const GeoPoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  /// Firestore REST format: `{geoPointValue: {latitude: ..., longitude: ...}}`
  Map<String, dynamic> toFirestoreValue() => {
        'geoPointValue': {
          'latitude': latitude,
          'longitude': longitude,
        },
      };

  static GeoPoint? fromFirestoreValue(Map<String, dynamic>? value) {
    final gp = value?['geoPointValue'] as Map<String, dynamic>?;
    if (gp == null) return null;
    return GeoPoint(
      (gp['latitude'] as num?)?.toDouble() ?? 0,
      (gp['longitude'] as num?)?.toDouble() ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is GeoPoint && other.latitude == latitude && other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);
}
