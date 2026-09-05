import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/inputs/form_info_banner.dart';
import '../../../../domain/entities/storage_quota.dart';

class ProductFormStorageBanner extends StatelessWidget {
  const ProductFormStorageBanner({
    super.key,
    required this.quota,
    required this.pendingBytes,
  });

  final StorageQuota? quota;
  final int pendingBytes;

  @override
  Widget build(BuildContext context) {
    if (quota == null) return const SizedBox.shrink();

    final projected = quota!.usedBytes + pendingBytes;
    final remaining = (quota!.quotaBytes - projected).clamp(
      0,
      quota!.quotaBytes,
    );

    return FormInfoBanner(
      icon: Icons.cloud_outlined,
      message:
          'المساحة المتبقية: ${StorageQuota.formatBytes(remaining)} '
          'من ${StorageQuota.formatBytes(quota!.quotaBytes)} '
          '(بعد الرفع: ${StorageQuota.formatBytes(pendingBytes)})',
    );
  }
}
