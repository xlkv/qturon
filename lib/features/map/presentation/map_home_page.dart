import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/auth/permissions_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/application/current_user_provider.dart';
import '../../pipes/data/pipe_repository.dart';
import '../../pipes/domain/pipe.dart';
import '../../wells/data/well_repository.dart';
import '../../wells/domain/well.dart';

enum _AddMode { none, well, pipe }

class MapHomePage extends ConsumerStatefulWidget {
  const MapHomePage({super.key});

  static const _defaultCenter = LatLng(41.31151, 69.27974);
  static const _defaultZoom = 12.0;

  @override
  ConsumerState<MapHomePage> createState() => _MapHomePageState();
}

class _MapHomePageState extends ConsumerState<MapHomePage> {
  final MapController _map = MapController();
  _AddMode _mode = _AddMode.none;
  final List<LatLng> _drawingPoints = [];

  // Hover/cursor uchun.
  Offset? _cursorScreen;
  LatLng? _cursorLatLng;

  // Joriy zoom — label ko'rinishini boshqaradi.
  double _zoom = MapHomePage._defaultZoom;

  // Tappable polylines uchun (pipe.id).
  final LayerHitNotifier<String> _pipeHit = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    final perms = ref.watch(permissionsProvider);
    final wellsAsync = ref.watch(wellsStreamProvider);
    final pipesAsync = ref.watch(pipesStreamProvider);
    final pipes = pipesAsync.valueOrNull ?? const [];
    final wells = wellsAsync.valueOrNull ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle()),
        actions: [
          if (_mode != _AddMode.none)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _cancelAdd,
              tooltip: 'Bekor qil',
            )
          else
            IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () => context.push('/profile'),
              tooltip: 'Profil',
            ),
        ],
      ),
      drawer: const _AppDrawer(),
      body: Stack(
        children: [
          MouseRegion(
            onHover: (e) {
              setState(() => _cursorScreen = e.localPosition);
              try {
                _cursorLatLng = _map.camera.pointToLatLng(
                  math.Point(e.localPosition.dx, e.localPosition.dy),
                );
              } catch (_) {}
            },
            onExit: (_) => setState(() {
              _cursorScreen = null;
              _cursorLatLng = null;
            }),
            child: FlutterMap(
              mapController: _map,
              options: MapOptions(
                initialCenter: MapHomePage._defaultCenter,
                initialZoom: MapHomePage._defaultZoom,
                minZoom: 3,
                maxZoom: 19,
                onTap: (tapPos, latLng) => _onMapTap(latLng),
                onPositionChanged: (pos, _) {
                  if (pos.zoom != _zoom) {
                    setState(() => _zoom = pos.zoom);
                  }
                },
              ),
              children: [
                const _YandexTileLayer(),

                // Mavjud turbalar — tappable.
                GestureDetector(
                  onTap: _mode != _AddMode.none ? null : _handlePipeTap,
                  child: PolylineLayer<String>(
                    hitNotifier: _pipeHit,
                    polylines: [
                      for (final p in pipes)
                        Polyline<String>(
                          points: [
                            for (final pt in p.points)
                              LatLng(pt.latitude, pt.longitude),
                          ],
                          strokeWidth: 5,
                          color: p.status.color,
                          hitValue: p.id,
                        ),
                    ],
                  ),
                ),

                // Chizilayotgan polyline preview.
                if (_drawingPoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [
                          ..._drawingPoints,
                          if (_mode == _AddMode.pipe && _cursorLatLng != null) _cursorLatLng!,
                        ],
                        strokeWidth: 3,
                        color: Theme.of(context).colorScheme.primary,
                        pattern: StrokePattern.dashed(segments: const [10, 6]),
                      ),
                    ],
                  ),

                // Drawing nuqtalar.
                if (_drawingPoints.isNotEmpty)
                  MarkerLayer(
                    markers: [
                      for (var i = 0; i < _drawingPoints.length; i++)
                        Marker(
                          point: _drawingPoints[i],
                          width: 22,
                          height: 22,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${i + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                // Turba labellari — Yandex-style: polyline ustida burilgan, faqat yetarli zoom'da.
                if (_zoom >= 14)
                  MarkerLayer(
                    rotate: false,
                    markers: [
                      for (final p in pipes)
                        if (p.points.length >= 2) _pipeLabelMarker(p),
                    ],
                  ),

                // Kolodets markerlari — clustering bilan.
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: 60,
                    size: const Size(44, 44),
                    padding: const EdgeInsets.all(40),
                    disableClusteringAtZoom: 16,
                    markers: [
                      for (final w in wells)
                        Marker(
                          point: LatLng(w.location.latitude, w.location.longitude),
                          width: 48,
                          height: 48,
                          child: _WellMarker(
                            well: w,
                            onTap: _mode == _AddMode.none
                                ? () => context.push('/wells/${w.id}')
                                : null,
                          ),
                        ),
                    ],
                    builder: (context, markers) {
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: const [
                            BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 2)),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${markers.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Cursor yonida masofa (chizish paytida).
          if (_mode == _AddMode.pipe && _cursorScreen != null && _drawingPoints.isNotEmpty)
            Positioned(
              left: _cursorScreen!.dx + 18,
              top: _cursorScreen!.dy + 8,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _formatDistance(_currentSegmentMeters() + _totalDrawnMeters()),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

          if (_mode == _AddMode.pipe)
            Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: AppSpacing.lg,
              child: _PipeDrawingBar(
                pointCount: _drawingPoints.length,
                totalMeters: _totalDrawnMeters(),
                onUndo: _drawingPoints.isEmpty ? null : _undoPoint,
                onFinish: _drawingPoints.length >= 2 ? _finishPipe : null,
              ),
            ),
        ],
      ),
      floatingActionButton: perms.canCreateWellOrPipe && _mode == _AddMode.none
          ? _MultiFab(
              onAddWell: () => setState(() => _mode = _AddMode.well),
              onAddPipe: () => setState(() {
                _mode = _AddMode.pipe;
                _drawingPoints.clear();
              }),
            )
          : null,
    );
  }

  // --- Helpers ---

  String _appBarTitle() {
    switch (_mode) {
      case _AddMode.well:
        return 'Yangi kolodets — joyni tanlang';
      case _AddMode.pipe:
        return 'Yangi turba — nuqtalarni belgilang';
      case _AddMode.none:
        return 'Xarita';
    }
  }

  void _cancelAdd() {
    setState(() {
      _mode = _AddMode.none;
      _drawingPoints.clear();
    });
  }

  void _onMapTap(LatLng latLng) {
    if (_mode == _AddMode.well) {
      setState(() => _mode = _AddMode.none);
      context.push('/wells/new', extra: {
        'lat': latLng.latitude,
        'lng': latLng.longitude,
      });
    } else if (_mode == _AddMode.pipe) {
      setState(() => _drawingPoints.add(latLng));
    }
  }

  void _handlePipeTap() {
    final hit = _pipeHit.value;
    if (hit == null || hit.hitValues.isEmpty) return;
    context.push('/pipes/${hit.hitValues.first}');
  }

  void _undoPoint() {
    setState(() => _drawingPoints.removeLast());
  }

  void _finishPipe() {
    final pts = _drawingPoints
        .map((p) => '${p.latitude},${p.longitude}')
        .toList(growable: false);
    setState(() {
      _mode = _AddMode.none;
      _drawingPoints.clear();
    });
    context.push('/pipes/new', extra: {'points': pts});
  }

  double _currentSegmentMeters() {
    if (_drawingPoints.isEmpty || _cursorLatLng == null) return 0;
    return _haversine(_drawingPoints.last, _cursorLatLng!);
  }

  double _totalDrawnMeters() {
    double sum = 0;
    for (var i = 1; i < _drawingPoints.length; i++) {
      sum += _haversine(_drawingPoints[i - 1], _drawingPoints[i]);
    }
    return sum;
  }

  String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.toStringAsFixed(0)} m';
    return '${(meters / 1000).toStringAsFixed(2)} km';
  }

  Marker _pipeLabelMarker(Pipe p) {
    final pts = p.points.map<LatLng>((g) => LatLng(g.latitude, g.longitude)).toList();
    final mid = _midpoint(pts);
    final angle = _midAngle(pts);
    return Marker(
      point: mid,
      width: 140,
      height: 22,
      child: IgnorePointer(
        child: Transform.rotate(
          angle: angle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: p.status.color, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              '${p.code}  ${p.diameterMm}mm · ${p.lengthM.toStringAsFixed(1)}m',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  /// Polyline yo'nalishi bo'yicha burchak (radian). Yozish to'g'ri yo'naladi (-90..90).
  double _midAngle(List<LatLng> pts) {
    // Polyline o'rta segmentini topamiz.
    final idx = pts.length ~/ 2;
    final a = pts[(idx - 1).clamp(0, pts.length - 1)];
    final b = pts[idx];
    final dy = b.latitude - a.latitude;
    final dx = b.longitude - a.longitude;
    var angle = math.atan2(-dy, dx); // screen y o'qi past
    // Yozish bir tomondan o'qish uchun: -90..90 oraliqqa keltiramiz.
    if (angle > math.pi / 2) angle -= math.pi;
    if (angle < -math.pi / 2) angle += math.pi;
    return angle;
  }

  LatLng _midpoint(List<LatLng> pts) {
    // Ko'p nuqta polyline'da o'rta uzunlikdagi nuqtani topamiz.
    if (pts.length == 2) {
      return LatLng(
        (pts[0].latitude + pts[1].latitude) / 2,
        (pts[0].longitude + pts[1].longitude) / 2,
      );
    }
    double total = 0;
    for (var i = 1; i < pts.length; i++) {
      total += _haversine(pts[i - 1], pts[i]);
    }
    final half = total / 2;
    double acc = 0;
    for (var i = 1; i < pts.length; i++) {
      final seg = _haversine(pts[i - 1], pts[i]);
      if (acc + seg >= half) {
        final t = (half - acc) / seg;
        return LatLng(
          pts[i - 1].latitude + (pts[i].latitude - pts[i - 1].latitude) * t,
          pts[i - 1].longitude + (pts[i].longitude - pts[i - 1].longitude) * t,
        );
      }
      acc += seg;
    }
    return pts[pts.length ~/ 2];
  }

  double _haversine(LatLng a, LatLng b) {
    const r = 6371000.0;
    final dLat = _rad(b.latitude - a.latitude);
    final dLng = _rad(b.longitude - a.longitude);
    final sa = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(a.latitude)) * math.cos(_rad(b.latitude)) *
            math.sin(dLng / 2) * math.sin(dLng / 2);
    return 2 * r * math.atan2(math.sqrt(sa), math.sqrt(1 - sa));
  }

  double _rad(double deg) => deg * math.pi / 180;
}

// ---------- Widgets ----------

class _MultiFab extends StatelessWidget {
  const _MultiFab({required this.onAddWell, required this.onAddPipe});

  final VoidCallback onAddWell;
  final VoidCallback onAddPipe;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton.extended(
          heroTag: 'fab_pipe',
          onPressed: onAddPipe,
          icon: const Icon(Icons.timeline),
          label: const Text('Turba'),
        ),
        const SizedBox(height: AppSpacing.sm),
        FloatingActionButton.extended(
          heroTag: 'fab_well',
          onPressed: onAddWell,
          icon: const Icon(Icons.add_location_alt_outlined),
          label: const Text('Kolodets'),
        ),
      ],
    );
  }
}

class _PipeDrawingBar extends StatelessWidget {
  const _PipeDrawingBar({
    required this.pointCount,
    required this.totalMeters,
    required this.onUndo,
    required this.onFinish,
  });

  final int pointCount;
  final double totalMeters;
  final VoidCallback? onUndo;
  final VoidCallback? onFinish;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(Icons.timeline, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    pointCount == 0
                        ? 'Xaritaga bosib nuqtalar qo\'shing'
                        : '$pointCount nuqta tanlandi',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (totalMeters > 0)
                    Text(
                      'Uzunlik: ${totalMeters < 1000 ? '${totalMeters.toStringAsFixed(0)} m' : '${(totalMeters / 1000).toStringAsFixed(2)} km'}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed: onUndo,
              tooltip: 'Oxirgisini olib tashlash',
            ),
            FilledButton.icon(
              onPressed: onFinish,
              icon: const Icon(Icons.check),
              label: const Text('Tugatish'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WellMarker extends StatelessWidget {
  const _WellMarker({required this.well, required this.onTap});

  final Well well;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: onTap == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Tooltip(
          message: well.code,
          child: Container(
            decoration: BoxDecoration(
              color: well.status.color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              well.code,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

class _YandexTileLayer extends StatelessWidget {
  const _YandexTileLayer();

  @override
  Widget build(BuildContext context) {
    return TileLayer(
      urlTemplate:
          'https://core-renderer-tiles.maps.yandex.net/tiles?l=map&x={x}&y={y}&z={z}&scale=1&lang=ru_RU',
      userAgentPackageName: 'uz.turonsuv.turon_suv',
      maxNativeZoom: 19,
      tileProvider: NetworkTileProvider(),
    );
  }
}

class _AppDrawer extends ConsumerWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final perms = ref.watch(permissionsProvider);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.name ?? '—'),
              accountEmail: Text(_roleLabel(user?.role.wire ?? 'user')),
              currentAccountPicture: CircleAvatar(
                child: Text(
                  (user?.name.isNotEmpty ?? false)
                      ? user!.name.substring(0, 1).toUpperCase()
                      : '?',
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.map_outlined),
              title: const Text('Xarita'),
              selected: true,
              onTap: () => Navigator.of(context).pop(),
            ),
            if (perms.canManageMasters)
              ListTile(
                leading: const Icon(Icons.engineering_outlined),
                title: const Text('Ustalar'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/masters');
                },
              ),
            if (perms.canManageUsers)
              ListTile(
                leading: const Icon(Icons.people_outline),
                title: const Text('Foydalanuvchilar'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/users');
                },
              ),
            if (perms.canViewAuditLog)
              ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: const Text('Audit log'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tez kunda qo\'shiladi')),
                  );
                },
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profil'),
              onTap: () {
                Navigator.of(context).pop();
                context.push('/profile');
              },
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  String _roleLabel(String wire) {
    switch (wire) {
      case 'super_admin':
        return 'Bosh administrator';
      case 'admin':
        return 'Administrator';
      default:
        return 'Foydalanuvchi';
    }
  }
}
