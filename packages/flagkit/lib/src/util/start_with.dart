import 'dart:async';

import 'package:meta/meta.dart';

/// [changes], led by [current]'s value at the moment of listening.
///
/// Subscribed to [changes] *as* it is listened to: an `async*` generator
/// (`yield current; yield* changes;`) would subscribe only after its first
/// value was delivered, and a change in between would be lost.
@internal
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
