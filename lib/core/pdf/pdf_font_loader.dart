import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfFontLoader {
  PdfFontLoader._();

  static pw.Font? _regular;
  static pw.Font? _bold;

  static Future<({pw.Font regular, pw.Font bold})> load() async {
    _regular ??= pw.Font.ttf(
      await rootBundle.load('assets/fonts/Tajawal-Regular.ttf'),
    );
    _bold ??= pw.Font.ttf(
      await rootBundle.load('assets/fonts/Tajawal-Bold.ttf'),
    );
    return (regular: _regular!, bold: _bold!);
  }
}
