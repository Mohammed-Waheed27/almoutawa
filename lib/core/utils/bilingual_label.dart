/// Resolves bilingual display labels. Arabic is required; English falls back to Arabic.
String bilingualLabel({
  required String arabic,
  String? english,
  bool preferEnglish = false,
}) {
  final ar = arabic.trim();
  final en = english?.trim();
  if (preferEnglish) {
    if (en != null && en.isNotEmpty) return en;
    return ar;
  }
  return ar;
}

/// PDF / dual-line label: "Arabic / English" when English differs; Arabic only otherwise.
String bilingualPair({required String arabic, String? english}) {
  final ar = arabic.trim();
  final en = english?.trim();
  if (en == null || en.isEmpty || en == ar) return ar;
  return '$ar / $en';
}
