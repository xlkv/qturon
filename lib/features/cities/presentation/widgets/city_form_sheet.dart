import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/city_repository.dart';
import '../../domain/city.dart';

class CityFormSheet extends ConsumerStatefulWidget {
  const CityFormSheet({super.key, this.city});

  final City? city;

  static Future<bool?> show(BuildContext context, {City? city}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: CityFormSheet(city: city),
      ),
    );
  }

  @override
  ConsumerState<CityFormSheet> createState() => _CityFormSheetState();
}

class _CityFormSheetState extends ConsumerState<CityFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _lat;
  late final TextEditingController _lng;
  late double _zoom;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.city;
    _name = TextEditingController(text: c?.name ?? '');
    _lat = TextEditingController(text: c?.center.latitude.toStringAsFixed(5) ?? '41.31151');
    _lng = TextEditingController(text: c?.center.longitude.toStringAsFixed(5) ?? '69.27974');
    _zoom = c?.defaultZoom ?? 12.0;
  }

  @override
  void dispose() {
    _name.dispose();
    _lat.dispose();
    _lng.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final name = _name.text.trim();
    final center = GeoPoint(double.parse(_lat.text), double.parse(_lng.text));
    final repo = ref.read(cityRepositoryProvider);
    final logger = ref.read(loggerProvider);

    try {
      if (widget.city == null) {
        await repo.create(name: name, center: center, defaultZoom: _zoom);
        logger.info('city.create', {'name': name});
      } else {
        await repo.update(widget.city!.copyWith(
          name: name,
          center: center,
          defaultZoom: _zoom,
        ));
        logger.info('city.update', {'id': widget.city!.id});
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e, st) {
      logger.error('city.save_failed', e, st);
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xato: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.city == null ? 'Yangi shahar' : 'Shahar ma\'lumotlari',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Nomi',
                hintText: 'Masalan: Toshkent',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || v.trim().length < 2)
                  ? 'Kamida 2 ta belgi'
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _lat,
                    decoration: const InputDecoration(
                      labelText: 'Markaz — Lat',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    validator: _coordValidator(-90, 90),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextFormField(
                    controller: _lng,
                    decoration: const InputDecoration(
                      labelText: 'Markaz — Lng',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    validator: _coordValidator(-180, 180),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Default zoom: ${_zoom.toStringAsFixed(0)}'),
            Slider(
              value: _zoom,
              min: 10,
              max: 16,
              divisions: 6,
              label: _zoom.toStringAsFixed(0),
              onChanged: (v) => setState(() => _zoom = v),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _saving ? null : () => Navigator.of(context).pop(false),
                    child: const Text('Bekor qil'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: _saving ? null : _submit,
                    child: _saving
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Saqlash'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? Function(String?) _coordValidator(double min, double max) {
    return (v) {
      final n = double.tryParse(v ?? '');
      if (n == null) return 'Raqam kiriting';
      if (n < min || n > max) return '$min..$max';
      return null;
    };
  }
}
