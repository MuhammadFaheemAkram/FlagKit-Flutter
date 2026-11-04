import 'dart:async';

/// The [current] value, then every one of [changes]: "what is it now, and
/// tell me when it changes", in one stream.
///
/// A `StreamController` that subscribes in `onListen`, not an `async*`
/// (`yield current; yield* changes;`): the generator subscribes to the
/// changes only after the first value is delivered, so a change made in
/// between is lost (conventions §11.99).
Stream<T> startWith<T>(T Function() current, Stream<T> changes) {
  StreamSubscription<T>? subscription;
  late final StreamController<T> out;
  out = StreamController<T>(
    onListen: () {
      out.add(current());
      subscription = changes.listen(out.add, onError: out.addError);
    },
    onCancel: () async {
      await subscription?.cancel();
      await out.close();
    },
  );
  return out.stream;
}
