import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import 'local_media_pick.dart';
import 'product.dart';

/// Product form media — existing remote asset or a newly picked local file.
class FormMediaItem extends Equatable {
  const FormMediaItem._({this.remoteAsset, this.localPick})
    : assert(
        (remoteAsset != null) ^ (localPick != null),
        'FormMediaItem must be remote or local',
      );

  factory FormMediaItem.remote(ProductMediaAsset asset) =>
      FormMediaItem._(remoteAsset: asset);

  factory FormMediaItem.local(LocalMediaPick pick) =>
      FormMediaItem._(localPick: pick);

  final ProductMediaAsset? remoteAsset;
  final LocalMediaPick? localPick;

  bool get isRemote => remoteAsset != null;
  bool get isLocal => localPick != null;

  String get key => remoteAsset?.id ?? localPick!.localId;

  int get sizeBytes => remoteAsset?.fileSizeBytes ?? localPick!.sizeBytes;

  String? get previewUrl => remoteAsset?.publicUrl;

  Uint8List? get previewBytes => localPick?.bytes;

  LocalMediaPick? get localPickOrNull => localPick;

  @override
  List<Object?> get props => [remoteAsset, localPick];
}
