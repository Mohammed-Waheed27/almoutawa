import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/local_media_pick.dart';

abstract final class MediaPickerHelper {
  static const _uuid = Uuid();
  static final _picker = ImagePicker();
  static const _imageTypes = XTypeGroup(
    label: 'images',
    extensions: <String>['jpg', 'jpeg', 'png', 'webp'],
  );

  static bool get _useFileSelector {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  static Future<List<LocalMediaPick>> pickImages({
    required ImageSource source,
    bool multiple = true,
  }) async {
    if (_useFileSelector) {
      return _pickWithFileSelector(multiple: multiple);
    }
    if (multiple) {
      final files = await _picker.pickMultiImage(imageQuality: 85);
      return _mapFiles(files);
    }

    final file = await _picker.pickImage(source: source, imageQuality: 85);
    if (file == null) return const [];
    return _mapFiles([file]);
  }

  static Future<List<LocalMediaPick>> _pickWithFileSelector({
    required bool multiple,
  }) async {
    if (multiple) {
      final files = await openFiles(acceptedTypeGroups: const [_imageTypes]);
      return _mapXFiles(files);
    }
    final file = await openFile(acceptedTypeGroups: const [_imageTypes]);
    if (file == null) return const [];
    return _mapXFiles([file]);
  }

  static Future<List<LocalMediaPick>> _mapXFiles(List<XFile> files) {
    return _mapFiles(files);
  }

  static Future<List<LocalMediaPick>> _mapFiles(List<XFile> files) async {
    final picks = <LocalMediaPick>[];
    for (final file in files) {
      final bytes = await file.readAsBytes();
      picks.add(
        LocalMediaPick(
          localId: _uuid.v4(),
          fileName: file.name,
          bytes: Uint8List.fromList(bytes),
          mimeType: _mimeFromName(file.name),
          sizeBytes: bytes.length,
        ),
      );
    }
    return picks;
  }

  static String _mimeFromName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic')) return 'image/heic';
    return 'image/jpeg';
  }
}
