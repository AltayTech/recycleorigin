/// Width breakpoints for responsive layouts (aligned with common Material
/// window classes; values match existing home hero and services grid).
abstract final class AppBreakpoints {
  AppBreakpoints._();

  /// Hero switches to side-by-side copy + visual; services grid uses 3 columns.
  static const double expanded = 720;

  /// Services grid uses 4 columns.
  static const double extraExpanded = 1100;

  /// Centered content does not grow beyond this on ultra-wide viewports.
  static const double contentMaxWidth = 1280;

  /// Below this width the service grid uses a single column for readability.
  static const double compactSingleColumn = 360;

  static bool isExpandedWidth(double width) => width >= expanded;

  static bool isExtraExpandedWidth(double width) => width >= extraExpanded;

  static int servicesGridCrossAxisCount(double width) {
    if (width >= extraExpanded) return 4;
    if (width >= expanded) return 3;
    if (width < compactSingleColumn) return 1;
    return 2;
  }

  static double servicesGridChildAspectRatio(double width) {
    if (width < compactSingleColumn) return 2.4;
    return width >= expanded ? 1.15 : 1.05;
  }
}
