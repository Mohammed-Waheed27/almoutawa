/// Breakpoints for adaptive layout — mobile first; Windows desktop later.
abstract final class AppBreakpoints {
  static const double compact = 0;
  static const double medium = 600;
  static const double expanded = 1024;
  static const double wide = 1440;

  static bool isCompact(double width) => width < medium;
  static bool isMedium(double width) => width >= medium && width < expanded;
  static bool isExpanded(double width) => width >= expanded;
}
