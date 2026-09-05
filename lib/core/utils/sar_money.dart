import 'package:intl/intl.dart';

/// Saudi Riyal display helpers for quotes / agreements / totals.
abstract final class SarMoney {
  static const symbol = 'ر.س';
  static const code = 'SAR';

  static final _amountFmt = NumberFormat('#,##0.00', 'en');

  /// e.g. `1,350.00 ر.س`
  static String format(num value) => '${_amountFmt.format(value)} $symbol';

  /// Amount only with two decimals (no currency suffix).
  static String amount(num value) => _amountFmt.format(value);

  /// Field-friendly amount (no thousand separators) for editing.
  static String amountInput(num value) {
    if (value <= 0) return '';
    final rounded = double.parse(value.toStringAsFixed(2));
    if ((rounded - rounded.roundToDouble()).abs() < 0.0001) {
      return rounded.round().toString();
    }
    return rounded.toStringAsFixed(2);
  }
}
