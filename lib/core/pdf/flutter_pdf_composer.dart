import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:screenshot/screenshot.dart';

/// A4 canvas used by Flutter document pages before they are placed in a PDF.
class FlutterPdfComposer {
  FlutterPdfComposer();

  final ScreenshotController _screenshot = ScreenshotController();

  static const Size a4 = Size(794, 1123);

  Future<Uint8List> compose({
    required BuildContext context,
    required List<Widget> pages,
    double pixelRatio = 2.2,
    TextDirection textDirection = TextDirection.rtl,
  }) async {
    if (!context.mounted) {
      throw StateError('تعذر إنشاء الملف — أعد فتح الصفحة ثم حاول مرة أخرى');
    }
    final ratio = defaultTargetPlatform == TargetPlatform.windows
        ? 1.5
        : pixelRatio;
    final images = <Uint8List>[];
    try {
      for (final page in pages) {
        if (!context.mounted) {
          throw StateError(
            'تعذر إنشاء الملف — أعد فتح الصفحة ثم حاول مرة أخرى',
          );
        }
        final png = await _screenshot.captureFromWidget(
          _wrap(context, page, textDirection),
          context: context,
          pixelRatio: ratio,
          targetSize: a4,
          delay: const Duration(milliseconds: 80),
        );
        if (png.isEmpty) {
          throw StateError('تعذر تصوير صفحة المستند');
        }
        images.add(png);
      }
      return _pdfFromPngs(images);
    } catch (error) {
      if (error is StateError) rethrow;
      throw StateError(
        'تعذر إنشاء ملف PDF. أعد فتح الصفحة ثم حاول الحفظ مرة أخرى',
      );
    }
  }

  Widget _wrap(BuildContext context, Widget page, TextDirection textDirection) {
    return MediaQuery(
      data: const MediaQueryData(
        size: a4,
        devicePixelRatio: 1,
        textScaler: TextScaler.noScaling,
      ),
      child: Directionality(
        textDirection: textDirection,
        child: Theme(
          data: Theme.of(
            context,
          ).copyWith(visualDensity: VisualDensity.compact),
          child: DefaultTextStyle(
            style: const TextStyle(
              fontFamily: 'Tajawal',
              color: Color(0xFF111111),
              fontSize: 10,
              height: 1.25,
            ),
            child: Material(
              color: Colors.white,
              child: SizedBox(width: a4.width, height: a4.height, child: page),
            ),
          ),
        ),
      ),
    );
  }

  Future<Uint8List> _pdfFromPngs(List<Uint8List> images) async {
    final doc = pw.Document();
    for (final png in images) {
      final image = pw.MemoryImage(png);
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (_) =>
              pw.SizedBox.expand(child: pw.Image(image, fit: pw.BoxFit.fill)),
        ),
      );
    }
    return doc.save();
  }
}

/// Off-screen raster fallback if screenshot package is unavailable.
Future<Uint8List> rasterizeRepaintBoundary(
  GlobalKey key, {
  double pixelRatio = 2.2,
}) async {
  final boundary =
      key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) {
    throw StateError('تعذر التقاط صفحة المستند');
  }
  final image = await boundary.toImage(pixelRatio: pixelRatio);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  if (bytes == null) {
    throw StateError('تعذر تحويل صفحة المستند');
  }
  return bytes.buffer.asUint8List();
}
