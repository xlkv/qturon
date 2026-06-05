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
import '../data/well_repository.dart';
import '../domain/well.dart';

class WellCreateEditPage extends ConsumerStatefulWidget {
  const WellCreateEditPage({
    super.key,
    this.wellId,
    this.initialLat,
    this.initialLng,
  });

  final String? wellId;
  final double? initialLat;
  final double? initialLng;

  bool get isEdit => wellId != null;

  @override
  ConsumerState<WellCreateEditPage> createState() => _WellCreateEditPageState();
}

class _WellCreateEditPageState extends ConsumerState<WellCreateEditPage> {
  final _form = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  ObjectStatus _status = ObjectStatus.planned;
  bool _paid = true;
  DateTime? _installedAt;
  String? _masterId;
  List<String> _photoUrls = const [];
  bool _saving = false;
  bool _loaded = false;
  Well? _existing;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _loadExisting();
    } else {
      _latCtrl.text = widget.initialLat?.toStringAsFixed(5) ?? '';
      _lngCtrl.text = widget.initialLng?.toStringAsFixed(5) ?? '';
      _loaded = true;
    }
  }

  Future<void> _loadExisting() async {
    final w = await ref.read(wellRepositoryProvider).get(widget.wellId!);
    if (w == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kolodets topilmadi')),
        );
        context.pop();
      }
      return;
    }
    setState(() {
      _existing = w;
      _codeCtrl.text = w.code;
      _latCtrl.text = w.location.latitude.toStringAsFixed(5);
      _lngCtrl.text = w.location.longitude.toStringAsFixed(5);
      _notesCtrl.text = w.notes ?? '';
      _status = w.status;
      _paid = w.paid;
      _installedAt = w.installedAt;
      _masterId = w.masterId;
      _photoUrls = List<String>.from(w.photoUrls);
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final repo = ref.read(wellRepositoryProvider);
    final logger = ref.read(loggerProvider);
    final location = GeoPoint(
      double.parse(_latCtrl.text),
      double.parse(_lngCtrl.text),
    );
    final notes = _notesCtrl.text.trim();
    final code = _codeCtrl.text.trim();
    try {
      if (widget.isEdit && _existing != null) {
        await repo.update(_existing!.copyWith(
          code: code,
          location: location,
          status: _status,
          paid: _paid,
          installedAt: _installedAt,
          masterId: _masterId,
          notes: notes.isEmpty ? null : notes,
          photoUrls: _photoUrls,
        ));
        logger.info('well.update', {'id': widget.wellId});
      } else {
        final created = await repo.create(
          code: code,
          location: location,
          status: _status,
          paid: _paid,
          installedAt: _installedAt,
          masterId: _masterId,
          notes: notes.isEmpty ? null : notes,
          photoUrls: _photoUrls,
        );
        logger.info('well.create', {'id': created.id, 'code': created.code});
      }
      if (mounted) context.pop();
    } catch (e, st) {
      logger.error('well.save_failed', e, st);
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

  @override
  Widget build(BuildContext context) {
    final perms = ref.watch(permissionsProvider);
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Kolodets tahrirlash' : 'Yangi kolodets'),
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
                hintText: 'Masalan: B1, B12',
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
                    controller: _latCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Lat',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    validator: _coord(-90, 90),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextFormField(
                    controller: _lngCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Lng',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    validator: _coord(-180, 180),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
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
              folder: widget.isEdit ? 'wells/${widget.wellId}' : 'wells/_new',
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
                      width: 16,
                      height: 16,
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

  String? Function(String?) _coord(double min, double max) {
    return (v) {
      final n = double.tryParse(v ?? '');
      if (n == null) return 'Raqam kiriting';
      if (n < min || n > max) return '$min..$max';
      return null;
    };
  }
}
