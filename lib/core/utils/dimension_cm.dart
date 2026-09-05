/// Width / height helpers — values are always centimeters.
abstract final class DimensionCm {
  /// Parse user input as cm; rounds to 2 decimal places (avoids float noise).
  static double parse(String raw) {
    final normalized = raw.replaceAll(',', '.').trim();
    if (normalized.isEmpty) return 0;
    final value = double.tryParse(normalized) ?? 0;
    return round(value);
  }

  static double round(double cm) {
    if (cm <= 0) return 0;
    return double.parse(cm.toStringAsFixed(2));
  }

  /// Display in fields: whole cm without `.0`, else up to 2 decimals.
  static String format(double cm) {
    if (cm <= 0) return '';
    final rounded = round(cm);
    if ((rounded - rounded.roundToDouble()).abs() < 0.0001) {
      return rounded.round().toString();
    }
    return rounded.toStringAsFixed(2);
  }

  /// Compact table cell with unit.
  static String formatWithUnit(double cm) {
    if (cm <= 0) return '—';
    return '${format(cm)} سم';
  }

  /// Quote / agreement size as two labeled Arabic lines.
  static String labeledWidthHeight({
    required double widthCm,
    required double heightCm,
  }) {
    return 'العرض: ${formatWithUnit(widthCm)}\nالارتفاع: ${formatWithUnit(heightCm)}';
  }
}
