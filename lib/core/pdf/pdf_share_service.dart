import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../debug/debug_flow_logs.dart';
import '../utils/whatsapp_launcher.dart';
import 'pdf_document_action.dart';

class PdfShareService {
  PdfShareService({WhatsAppLauncher? whatsAppLauncher})
    : _whatsApp = whatsAppLauncher ?? const WhatsAppLauncher();

  final WhatsAppLauncher _whatsApp;

  static bool get isWindowsDesktop {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.windows;
  }

  static String sanitizeFileName(String fileName) {
    var cleaned = fileName.trim();
    if (cleaned.isEmpty) cleaned = 'document.pdf';
    cleaned = cleaned.replaceAll(RegExp(r'[<>:"/\\|?*]+'), '_');
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), '_');
    if (!cleaned.toLowerCase().endsWith('.pdf')) {
      cleaned = '$cleaned.pdf';
    }
    return cleaned;
  }

  Future<File> saveBytes({
    required Uint8List bytes,
    required String fileName,
  }) async {
    if (bytes.isEmpty) {
      throw StateError('ملف PDF فارغ');
    }
    final safeName = sanitizeFileName(fileName);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$safeName');
    await file.writeAsBytes(bytes, flush: true);
    dbgWorkOrders('pdf temp saved path=${file.path} bytes=${bytes.length}');
    return file;
  }

  Future<File> saveToDocuments({
    required Uint8List bytes,
    required String fileName,
  }) async {
    if (bytes.isEmpty) {
      throw StateError('ملف PDF فارغ');
    }
    final safeName = sanitizeFileName(fileName);
    final dir = await getApplicationDocumentsDirectory();
    final pdfDir = Directory('${dir.path}/pdfs');
    if (!await pdfDir.exists()) {
      await pdfDir.create(recursive: true);
    }
    final file = File('${pdfDir.path}/$safeName');
    await file.writeAsBytes(bytes, flush: true);
    dbgWorkOrders('pdf documents saved path=${file.path}');
    return file;
  }

  Future<File?> saveWithOptionalLocationPicker({
    required Uint8List bytes,
    required String fileName,
  }) async {
    if (bytes.isEmpty) {
      throw StateError('ملف PDF فارغ');
    }
    final safeName = sanitizeFileName(fileName);
    if (isWindowsDesktop) {
      try {
        final location = await getSaveLocation(
          suggestedName: safeName,
          acceptedTypeGroups: const [
            XTypeGroup(label: 'PDF', extensions: <String>['pdf']),
          ],
        );
        if (location == null) {
          dbgWorkOrders('pdf save cancelled by user');
          return null;
        }
        final path = location.path.toLowerCase().endsWith('.pdf')
            ? location.path
            : '${location.path}.pdf';
        final file = File(path);
        await file.writeAsBytes(bytes, flush: true);
        dbgWorkOrders('pdf windows saved path=${file.path}');
        return file;
      } catch (error, stackTrace) {
        dbgWorkOrdersError(
          'pdf windows save picker failed, falling back to documents',
          error: error,
          stackTrace: stackTrace,
        );
        return saveToDocuments(bytes: bytes, fileName: safeName);
      }
    }
    return saveToDocuments(bytes: bytes, fileName: safeName);
  }

  Future<void> shareFile({required File file, required String subject}) async {
    if (!await file.exists()) {
      throw StateError('تعذر العثور على ملف PDF للمشاركة');
    }
    final length = await file.length();
    if (length <= 0) {
      throw StateError('ملف PDF غير صالح للمشاركة');
    }
    final shareName = sanitizeFileName(
      file.uri.pathSegments.isEmpty ? subject : file.uri.pathSegments.last,
    );
    dbgWorkOrders('pdf share start name=$shareName bytes=$length');
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile(
              file.path,
              mimeType: 'application/pdf',
              name: shareName,
            ),
          ],
          subject: subject,
          sharePositionOrigin: const Rect.fromLTWH(0, 0, 120, 120),
        ),
      );
    } catch (error, stackTrace) {
      dbgWorkOrdersError(
        'pdf share failed, opening file location',
        error: error,
        stackTrace: stackTrace,
      );
      if (isWindowsDesktop) {
        await Process.run('explorer.exe', <String>['/select,', file.path]);
        return;
      }
      rethrow;
    }
  }

  Future<void> preview(Uint8List bytes) async {
    if (bytes.isEmpty) {
      throw StateError('ملف PDF فارغ');
    }
    if (isWindowsDesktop) {
      throw StateError('المعاينة غير متاحة على ويندوز — استخدم حفظ PDF');
    }
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  Future<void> sendWhatsApp({
    required File file,
    required String? phone,
    required String message,
  }) {
    return _whatsApp.sharePdfToClient(
      file: file,
      phone: phone,
      message: message,
    );
  }

  Future<String> deliver({
    required Uint8List bytes,
    required String fileName,
    required String subject,
    required PdfDocumentAction action,
    String? clientPhone,
    String? whatsAppMessage,
  }) async {
    switch (action) {
      case PdfDocumentAction.save:
        final file = await saveWithOptionalLocationPicker(
          bytes: bytes,
          fileName: fileName,
        );
        if (file == null) {
          return 'تم إلغاء حفظ PDF';
        }
        if (isWindowsDesktop) {
          return 'تم حفظ ملف PDF في: ${file.path}';
        }
        return 'تم حفظ ملف PDF في مستندات التطبيق';
      case PdfDocumentAction.share:
        final file = await saveBytes(bytes: bytes, fileName: fileName);
        await shareFile(file: file, subject: subject);
        return 'تم فتح مشاركة الملف';
      case PdfDocumentAction.preview:
        if (isWindowsDesktop) {
          return 'المعاينة غير متاحة على ويندوز — استخدم حفظ PDF';
        }
        await preview(bytes);
        return 'تم فتح معاينة PDF';
      case PdfDocumentAction.whatsapp:
        final file = await saveBytes(bytes: bytes, fileName: fileName);
        await sendWhatsApp(
          file: file,
          phone: clientPhone,
          message: whatsAppMessage ?? subject,
        );
        return 'اختر واتساب لإرسال الملف للعميل';
    }
  }

  @Deprecated('Use deliver() with PdfDocumentAction')
  Future<void> saveShareAndPreview({
    required Uint8List bytes,
    required String fileName,
    required String subject,
    bool preview = true,
  }) async {
    final file = await saveBytes(bytes: bytes, fileName: fileName);
    await shareFile(file: file, subject: subject);
    if (preview) {
      await this.preview(bytes);
    }
  }
}
