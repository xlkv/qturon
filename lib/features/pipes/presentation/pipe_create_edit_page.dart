import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/permissions_provider.dart';
import '../../../core/constants/object_status.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/models/geo_point.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/photo_grid_editor.dart';
import '../../masters/presentation/widgets/master_picker.dart';
import '../data/pipe_repository.dart';
import '../domain/pipe.dart';

class PipeCreateEditPage extends ConsumerStatefulWidget {
  const PipeCreateEditPage({
    super.key,
    this.pipeId,
    this.initialPoints,
  });

  final String? pipeId;
  final List<GeoPoint>? initialPoints;

  bool get isEdit => pipeId != null;

  @override
  ConsumerState<PipeCreateEditPage> createState() => _PipeCreateEditPageState();
}

class _PipeCreateEditPageState extends ConsumerState<PipeCreateEditPage> {
  final _form = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _diameterCtrl = TextEditingController();
  final _lengthCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  ObjectStatus _status = ObjectStatus.planned;
  bool _paid = true;
  DateTime? _installedAt;
  String? _masterId;
  List<GeoPoint> _points = [];
  List<String> _photoUrls = const [];
  bool _saving = false;
  bool _loaded = false;
  Pipe? _existing;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _loadExisting();
    } else {
      _points = List<GeoPoint>.from(widget.initialPoints ?? const []);
      // Auto-suggest length from haversine
      if (_points.length >= 2) {
        final geoLen = _geoLength(_points);
        _lengthCtrl.text = geoLen.toStringAsFixed(1);
      }
      _loaded = true;
    }
  }

  Future<void> _loadExisting() async {
    final p = await ref.read(pipeRepositoryProvider).get(widget.pipeId!);
    if (p == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Turba topilmadi')),
        );
        context.pop();
      }
      return;
    }
    setState(() {
      _existing = p;
      _codeCtrl.text = p.code;
      _diameterCtrl.text = p.diameterMm.toString();
      _lengthCtrl.text = p.lengthM.toString();
      _notesCtrl.text = p.notes ?? '';
      _status = p.status;
      _paid = p.paid;
      _installedAt = p.installedAt;
      _masterId = p.masterId;
      _points = List<GeoPoint>.from(p.points);
      _photoUrls = List<String>.from(p.photoUrls);
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _diameterCtrl.dispose();
    _lengthCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (_points.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kamida 2 nuqta kerak')),
      );
      return;
    }
    setState(() => _saving = true);
    final repo = ref.read(pipeRepositoryProvider);
    final logger = ref.read(loggerProvider);
    final notes = _notesCtrl.text.trim();
    final code = _codeCtrl.text.trim();
    final diameter = int.parse(_diameterCtrl.text);
    final length = double.parse(_lengthCtrl.text);
    try {
      if (widget.isEdit && _existing != null) {
        await repo.update(_existing!.copyWith(
          code: code,
          points: _points,
          diameterMm: diameter,
          lengthM: length,
          status: _status,
          paid: _paid,
          installedAt: _installedAt,
          masterId: _masterId,
          notes: notes.isEmpty ? null : notes,
          photoUrls: _photoUrls,
        ));
        logger.info('pipe.update', {'id': widget.pipeId});
      } else {
        final created = await repo.create(
          code: code,
          points: _points,
          diameterMm: diameter,
          lengthM: length,
          status: _status,
          paid: _paid,
          installedAt: _installedAt,
          masterId: _masterId,
          notes: notes.isEmpty ? null : notes,
          photoUrls: _photoUrls,
        );
        logger.info('pipe.create', {'id': created.id, 'code': created.code});
      }
      if (mounted) context.pop();
    } catch (e, st) {
      logger.error('pipe.save_failed', e, st);
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xato: $e')));
      }
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _installedAt ?? now,
      firstDate: DateTime(2000),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _installedAt = picked);
  }

  double _geoLength(List<GeoPoint> pts) {
    double sum = 0;
    for (var i = 1; i < pts.length; i++) {
      sum += _haversine(pts[i - 1], pts[i]);
    }
    return sum;
  }

  double _haversine(GeoPoint a, GeoPoint b) {
    const r = 6371000.0; // metr
    final dLat = _rad(b.latitude - a.latitude);
    final dLng = _rad(b.longitude - a.longitude);
    final sa = (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        math.cos(_rad(a.latitude)) * math.cos(_rad(b.latitude)) *
            math.sin(dLng / 2) * math.sin(dLng / 2);
    return 2 * r * math.atan2(math.sqrt(sa), math.sqrt(1 - sa));
  }

  double _rad(double deg) => deg * math.pi / 180;

  @override
  Widget build(BuildContext context) {
    final perms = ref.watch(permissionsProvider);
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final geoLen = _points.length >= 2 ? _geoLength(_points) : 0.0;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Turba tahrirlash' : 'Yangi turba'),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            TextFormField(
              controller: _codeCtrl,
              decoration: const InputDecoration(
                labelText: 'Kod',
                hintText: 'Masalan: P1, P12',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (v) {
                final s = (v ?? '').trim();
                if (s.isEmpty) return 'Kodni kiriting';
                if (s.length > 16) return 'Juda uzun';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _diameterCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Diametr (mm)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n <= 0) return 'Musbat son';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextFormField(
                    controller: _lengthCtrl,
                    decoration: InputDecoration(
                      labelText: 'Uzunlik (m)',
                      border: const OutlineInputBorder(),
                      helperText: geoLen > 0
                          ? 'Geo: ${geoLen.toStringAsFixed(1)} m'
                          : null,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      final n = double.tryParse(v ?? '');
                      if (n == null || n <= 0) return 'Musbat son';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.scatter_plot),
              title: const Text('Nuqtalar'),
              subtitle: Text('${_points.length} ta nuqta'),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('Status', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<ObjectStatus>(
              segments: [
                for (final s in ObjectStatus.values)
                  ButtonSegment(value: s, label: Text(s.label)),
              ],
              selected: {_status},
              onSelectionChanged: (s) => setState(() => _status = s.first),
            ),
            const SizedBox(height: AppSpacing.lg),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('O\'rnatilgan sana'),
              subtitle: Text(_installedAt == null
                  ? 'Tanlanmagan'
                  : DateFormat('dd.MM.yyyy').format(_installedAt!)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_installedAt != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _installedAt = null),
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit_calendar_outlined),
                    onPressed: _pickDate,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            MasterPicker(
              masterId: _masterId,
              onChanged: (id) => setState(() => _masterId = id),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Izoh',
                border: OutlineInputBorder(),
              ),
              minLines: 2,
              maxLines: 5,
              maxLength: 1000,
            ),
            const SizedBox(height: AppSpacing.lg),
            PhotoGridEditor(
              folder: widget.isEdit ? 'pipes/${widget.pipeId}' : 'pipes/_new',
              urls: _photoUrls,
              onChanged: (urls) => setState(() => _photoUrls = urls),
            ),
            if (perms.canSeePaidField) ...[
              const SizedBox(height: AppSpacing.sm),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _paid,
                onChanged: (v) => setState(() => _paid = v),
                title: const Text('To\'langan'),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: _saving ? null : _submit,
              icon: _saving
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save),
              label: const Text('Saqlash'),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            ),
          ],
        ),
      ),
    );
  }
}

