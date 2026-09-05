import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// Local image picked before upload (product or color gallery).
class LocalMediaPick extends Equatable {
  const LocalMediaPick({
    required this.localId,
    required this.fileName,
    required this.bytes,
    required this.mimeType,
    required this.sizeBytes,
  });

  final String localId;
  final String fileName;
  final Uint8List bytes;
  final String mimeType;
  final int sizeBytes;

  String get extension {
    final dot = fileName.lastIndexOf('.');
    if (dot == -1) return 'jpg';
    return fileName.substring(dot + 1).toLowerCase();
  }

  @override
  List<Object?> get props => [localId, fileName, mimeType, sizeBytes];
}
