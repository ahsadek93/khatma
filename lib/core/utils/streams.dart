import 'dart:async';

/// combineLatest for two streams: emits a combined value whenever either source
/// emits, once both have produced at least one value. Cancels both upstream
/// subscriptions when the result stream is cancelled.
///
/// A tiny dependency-free substitute for rxdart's `combineLatest2`, used to fuse
/// the separate khatma + juz-progress streams the database exposes.
Stream<R> combine2<A, B, R>(
  Stream<A> a,
  Stream<B> b,
  R Function(A a, B b) combine,
) {
  late StreamController<R> controller;
  late StreamSubscription<A> subA;
  late StreamSubscription<B> subB;

  A? latestA;
  B? latestB;
  var hasA = false;
  var hasB = false;

  void emit() {
    if (hasA && hasB) controller.add(combine(latestA as A, latestB as B));
  }

  controller = StreamController<R>(
    onListen: () {
      subA = a.listen(
        (value) {
          latestA = value;
          hasA = true;
          emit();
        },
        onError: controller.addError,
      );
      subB = b.listen(
        (value) {
          latestB = value;
          hasB = true;
          emit();
        },
        onError: controller.addError,
      );
    },
    onCancel: () async {
      await subA.cancel();
      await subB.cancel();
    },
  );

  return controller.stream;
}
