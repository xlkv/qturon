import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/firebase/rest/firebase_storage_rest.dart';
import '../logging/app_logger.dart';
import '../theme/app_spacing.dart';

/// Photo grid + add/remove. Yangi rasm tanlanganda darhol Storage'ga yuklab,
/// URL'ni callback orqali parent'ga uzatadi.
class PhotoGridEditor extends ConsumerStatefulWidget {
  const PhotoGridEditor({
    super.key,
    required this.folder,
    required this.urls,
    required this.onChanged,
    this.maxCount = 5,
  });

  /// Storage path prefix, masalan: `wells/abc123`.
  final String folder;
  final List<String> urls;
  final ValueChanged<List<String>> onChanged;
  final int maxCount;

  @override
  ConsumerState<PhotoGridEditor> createState() => _PhotoGridEditorState();
}

class _PhotoGridEditorState extends ConsumerState<PhotoGridEditor> {
  final _picker = ImagePicker();
  bool _uploading = false;

  Future<void> _add(ImageSource source) async {
    if (widget.urls.length >= widget.maxCount) return;
    final XFile? file;
    try {
      file = await _picker.pickImage(source: source, maxWidth: 1600);
    } catch (e) {
      _snack('Rasm tanlashda xato: $e');
      return;
    }
    if (file == null) return;
    setState(() => _uploading = true);
    try {
      final compressed = await _compress(File(file.path));
      final storage = ref.read(firebaseStorageRestProvider);
      final url = await storage.uploadImage(
        folder: widget.folder,
        bytes: compressed,
      );
      widget.onChanged([...widget.urls, url]);
      ref.read(loggerProvider).info('photo.upload', {'folder': widget.folder});
    } catch (e, st) {
      ref.read(loggerProvider).error('photo.upload_failed', e, st);
      _snack('Yuklash xatosi: $e');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<Uint8List> _compress(File file) async {
    final out = await FlutterImageCompress.compressWithFile(
      file.path,
      minWidth: 1600,
      minHeight: 1600,
      quality: 80,
      format: CompressFormat.jpeg,
    );
    return out ?? await file.readAsBytes();
  }

  Future<void> _remove(int index) async {
    final url = widget.urls[index];
    final next = [...widget.urls]..removeAt(index);
    widget.onChanged(next);
    // Storage'dan o'chirish — fire and forget.
    unawaited(
      ref.read(firebaseStorageRestProvider).deleteByUrl(url).catchError((_) {}),
    );
  }

  void _snack(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Rasmlar', style: Theme.of(context).textTheme.labelLarge),
            const Spacer(),
            Text(
              '${widget.urls.length} / ${widget.maxCount}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (var i = 0; i < widget.urls.length; i++)
              _PhotoTile(
                url: widget.urls[i],
                onRemove: _uploading ? null : () => _remove(i),
              ),
            if (widget.urls.length < widget.maxCount)
              _AddTile(
                uploading: _uploading,
                onCamera: () => _add(ImageSource.camera),
                onGallery: () => _add(ImageSource.gallery),
              ),
          ],
        ),
      ],
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.url, required this.onRemove});

  final String url;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: url,
            width: 96,
            height: 96,
            fit: BoxFit.cover,
            placeholder: (_, _) => Container(
              width: 96,
              height: 96,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            errorWidget: (_, _, _) => Container(
              width: 96,
              height: 96,
              color: Theme.of(context).colorScheme.errorContainer,
              child: const Icon(Icons.broken_image_outlined),
            ),
          ),
        ),
        if (onRemove != null)
          Positioned(
            top: 2,
            right: 2,
            child: Material(
              color: Colors.black54,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onRemove,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({
    required this.uploading,
    required this.onCamera,
    required this.onGallery,
  });

  final bool uploading;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: uploading
              ? null
              : () => _showOptions(context),
          child: uploading
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : const Center(child: Icon(Icons.add_photo_alternate_outlined, size: 32)),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galereyadan'),
              onTap: () {
                Navigator.pop(context);
                onGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Kameradan'),
              onTap: () {
                Navigator.pop(context);
                onCamera();
              },
            ),
          ],
        ),
      ),
    );
  }
}

