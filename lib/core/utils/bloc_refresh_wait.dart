import 'dart:async';

/// Waits until [readTick] increases past [tickBefore], with a safety timeout
/// so [RefreshIndicator] never spins forever.
Future<void> waitForBlocRefreshTick<S>({
  required Stream<S> stream,
  required int tickBefore,
  required int Function(S state) readTick,
  Duration timeout = const Duration(seconds: 30),
}) async {
  try {
    await stream
        .firstWhere((state) => readTick(state) > tickBefore)
        .timeout(timeout);
  } on TimeoutException {
    // End the refresh indicator even if the fetch hung or was superseded.
  }
}
