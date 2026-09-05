/// Logical-px layout caps for expanded (desktop / laptop) layouts.
/// Never use ScreenUtil (`.w` / `.h` / `.sp`) with these — they are already px.
abstract final class DesktopUiTokens {
  static const double body = 13;
  static const double label = 11;
  static const double pageTitle = 17;
  static const double title = 16;

  static const double buttonHeight = 36;
  static const double inputHeight = 36;
  static const double iconSize = 18;
  static const double iconBadge = 40;
  static const double toolbarHeight = 48;
  static const double denseRowHeight = 40;

  static const double masterSidebarWidth = 300;
  static const double filterSidebarWidth = 280;
  static const double masterListMinWidth = 320;
  static const double masterListMaxWidth = 420;

  static const double formMaxWidth = 560;
  static const double formNarrowMaxWidth = 520;
  static const double authFormMaxWidth = 420;
  static const double detailMaxWidth = 720;
  static const double hubMaxWidth = 1280;
  static const double reportCardExtent = 280;

  static const double pagePadding = 16;
  static const double gapXs = 4;
  static const double gapSm = 8;
  static const double gapMd = 12;
  static const double gapLg = 16;
  static const double gapXl = 24;

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
}
