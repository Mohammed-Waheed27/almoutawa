import 'package:equatable/equatable.dart';

class StorageQuota extends Equatable {
  const StorageQuota({
    required this.quotaBytes,
    required this.usedBytes,
    required this.maxFileBytes,
    required this.maxProductImages,
    required this.maxColorImages,
    required this.maxColorsPerProduct,
  });

  final int quotaBytes;
  final int usedBytes;
  final int maxFileBytes;
  final int maxProductImages;
  final int maxColorImages;
  final int maxColorsPerProduct;

  int get remainingBytes => (quotaBytes - usedBytes).clamp(0, quotaBytes);

  double get usedRatio =>
      quotaBytes == 0 ? 0 : (usedBytes / quotaBytes).clamp(0, 1);

  bool canUploadBytes(int additionalBytes) =>
      usedBytes + additionalBytes <= quotaBytes;

  String? validateFileSize(int fileBytes) {
    if (fileBytes <= 0) return 'الملف فارغ';
    if (fileBytes > maxFileBytes) {
      return 'حجم الملف يتجاوز ${_formatMb(maxFileBytes)}';
    }
    if (!canUploadBytes(fileBytes)) {
      return 'مساحة التخزين غير كافية';
    }
    return null;
  }

  static String _formatMb(int bytes) {
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} م.ب';
  }

  static String formatBytes(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} م.ب';
    }
    if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(0)} ك.ب';
    }
    return '$bytes بايت';
  }

  @override
  List<Object?> get props => [
    quotaBytes,
    usedBytes,
    maxFileBytes,
    maxProductImages,
    maxColorImages,
    maxColorsPerProduct,
  ];
}
