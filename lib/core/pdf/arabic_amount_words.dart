/// Converts a whole SAR amount to Arabic words for quote/agreement PDFs.
class ArabicAmountWords {
  ArabicAmountWords._();

  static const _ones = [
    '',
    'واحد',
    'اثنان',
    'ثلاثة',
    'أربعة',
    'خمسة',
    'ستة',
    'سبعة',
    'ثمانية',
    'تسعة',
    'عشرة',
    'أحد عشر',
    'اثنا عشر',
    'ثلاثة عشر',
    'أربعة عشر',
    'خمسة عشر',
    'ستة عشر',
    'سبعة عشر',
    'ثمانية عشر',
    'تسعة عشر',
  ];

  static const _tens = [
    '',
    '',
    'عشرون',
    'ثلاثون',
    'أربعون',
    'خمسون',
    'ستون',
    'سبعون',
    'ثمانون',
    'تسعون',
  ];

  static const _hundreds = [
    '',
    'مائة',
    'مائتان',
    'ثلاثمائة',
    'أربعمائة',
    'خمسمائة',
    'ستمائة',
    'سبعمائة',
    'ثمانمائة',
    'تسعمائة',
  ];

  static String sar(num amount) {
    final whole = amount.round().abs();
    if (whole == 0) return 'صفر ريال سعودي فقط لا غير';
    return '${_convert(whole)} ريال سعودي فقط لا غير';
  }

  static String _convert(int n) {
    if (n < 20) return _ones[n];
    if (n < 100) {
      final t = n ~/ 10;
      final o = n % 10;
      if (o == 0) return _tens[t];
      return '${_ones[o]} و${_tens[t]}';
    }
    if (n < 1000) {
      final h = n ~/ 100;
      final rest = n % 100;
      if (rest == 0) return _hundreds[h];
      return '${_hundreds[h]} و${_convert(rest)}';
    }
    if (n < 1000000) {
      final thousands = n ~/ 1000;
      final rest = n % 1000;
      final prefix = switch (thousands) {
        1 => 'ألف',
        2 => 'ألفان',
        _ when thousands >= 3 && thousands <= 10 =>
          '${_convert(thousands)} آلاف',
        _ => '${_convert(thousands)} ألف',
      };
      if (rest == 0) return prefix;
      return '$prefix و${_convert(rest)}';
    }
    final millions = n ~/ 1000000;
    final rest = n % 1000000;
    final prefix = switch (millions) {
      1 => 'مليون',
      2 => 'مليونان',
      _ => '${_convert(millions)} مليون',
    };
    if (rest == 0) return prefix;
    return '$prefix و${_convert(rest)}';
  }
}
