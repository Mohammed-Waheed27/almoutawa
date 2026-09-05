/// When to show [Skeletonizer] during list/hub reloads.
abstract final class SkeletonRefresh {
  /// App-bar reload — skeleton even if stale rows exist.
  static const showSkeleton = true;

  /// Pull-to-refresh / background sync — keep visible content.
  static const keepContent = false;

  static bool shouldShow({
    required bool isLoading,
    required bool isEmpty,
    required bool skeletonReload,
  }) {
    return skeletonReload || (isLoading && isEmpty);
  }
}
