import 'dart:io';

import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../debug/debug_flow_logs.dart';

/// Opens WhatsApp / shares a PDF toward a client phone.
class WhatsAppLauncher {
  const WhatsAppLauncher();

  /// Digits only with country code (no `+`). Egyptian `0…` → `20…`.
  static String? normalizePhone(String? raw) {
    if (raw == null) return null;
    var digits = raw.replaceAll(RegExp(r'[^\d+]'), '');
    digits = digits.replaceFirst(RegExp(r'^\+'), '');
    if (digits.startsWith('00')) {
      digits = digits.substring(2);
    }
    if (digits.startsWith('0')) {
      digits = '20${digits.substring(1)}';
    }
    if (digits.length < 10) return null;
    return digits;
  }

  /// Shares [file] via the system sheet (user picks WhatsApp), then opens the
  /// client chat when [phone] is valid. WhatsApp URL schemes cannot attach files.
  Future<void> sharePdfToClient({
    required File file,
    required String? phone,
    required String message,
  }) async {
    final digits = normalizePhone(phone);
    if (digits == null) {
      throw StateError('لا يوجد رقم هاتف صالح للعميل');
    }

    dbgWorkOrders('whatsapp share pdf phone=$digits');
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf', name: file.uri.pathSegments.last)],
        subject: message,
      ),
    );

    final chatUri = Uri.parse(
      'https://wa.me/$digits?text=${Uri.encodeComponent(message)}',
    );
    if (await canLaunchUrl(chatUri)) {
      await launchUrl(chatUri, mode: LaunchMode.externalApplication);
      dbgWorkOrders('whatsapp chat opened phone=$digits');
    }
  }

  Future<void> openClientChat({
    required String? phone,
    required String message,
  }) async {
    final digits = normalizePhone(phone);
    if (digits == null) {
      throw StateError('لا يوجد رقم هاتف صالح للعميل');
    }
    final chatUri = Uri.parse(
      'https://wa.me/$digits?text=${Uri.encodeComponent(message)}',
    );
    if (!await canLaunchUrl(chatUri)) {
      throw StateError('تعذر فتح واتساب');
    }
    await launchUrl(chatUri, mode: LaunchMode.externalApplication);
  }
}
