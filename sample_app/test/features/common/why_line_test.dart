import 'package:flagkit_sample/domain/flags/flag_reading.dart';
import 'package:flagkit_sample/features/common/flag_words.dart';
import 'package:flagkit_sample/features/common/why_line.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  FlagReading reading(
    ReadingReason reason, {
    ReadingSource source = ReadingSource.server,
    int? bucket,
    double? rolloutPercent,
  }) => FlagReading(
    key: 'k',
    value: 'true',
    source: source,
    reason: reason,
    bucket: bucket,
    rolloutPercent: rolloutPercent,
  );

  group('whyWords', () {
    test('every reason has its own sentence', () {
      final sentences = {
        for (final reason in ReadingReason.values)
          whyWords(
            'the new home',
            reading(reason, source: ReadingSource.override),
          ),
      };
      // The three "FlagKit has no value" reasons share one sentence.
      expect(sentences, hasLength(ReadingReason.values.length - 2));
      for (final sentence in sentences) {
        expect(sentence, startsWith('You see the new home because '));
      }
    });

    test('a rollout: the percentage, the bucket and the threshold', () {
      expect(
        whyWords(
          'the one-page checkout',
          reading(ReadingReason.inRollout, bucket: 404, rolloutPercent: 25),
        ),
        'You see the one-page checkout because you\'re in its 25 % rollout '
        '(bucket 404 of 10,000, below 2500). From the server.',
      );
      expect(
        whyWords(
          'the step-by-step checkout',
          reading(
            ReadingReason.outsideRollout,
            source: ReadingSource.cache,
            bucket: 4486,
            rolloutPercent: 12.5,
          ),
        ),
        'You see the step-by-step checkout because you\'re outside its '
        '12.5 % rollout (bucket 4486 of 10,000, not below 1250). '
        'From the flags saved on this device.',
      );
    });

    test('a bucket at the threshold is not below it (as in the SDK)', () {
      expect(
        whyWords(
          'x',
          reading(
            ReadingReason.outsideRollout,
            bucket: 2500,
            rolloutPercent: 25,
          ),
        ),
        contains('(bucket 2500 of 10,000, not below 2500)'),
      );
    });

    test('rules, then a rollout among the eligible', () {
      expect(
        whyWords(
          'x',
          reading(ReadingReason.rulesMatched, bucket: 10, rolloutPercent: 50),
        ),
        contains(
          'the flag\'s rules match you, and you\'re in its 50 % rollout',
        ),
      );
      expect(
        whyWords('x', reading(ReadingReason.rulesMatched)),
        contains('the flag\'s targeting rules match you.'),
      );
    });

    test('a default says where it came from: nowhere', () {
      expect(
        whyWords(
          'x',
          reading(ReadingReason.unknownFlag, source: ReadingSource.appDefault),
        ),
        'You see x because FlagKit has no value for the flag, so the app '
        'uses its own default.',
      );
    });
  });

  group('WhyLine', () {
    final whys = <Why>[
      (subject: 'the new home', reading: reading(ReadingReason.onForEveryone)),
      (
        subject: 'the modern look',
        reading: reading(ReadingReason.rulesMatched),
      ),
    ];

    testWidgets('closed, then a sentence per flag; closes again', (
      tester,
    ) async {
      await tester.pumpThemed(Scaffold(body: WhyLine(whys)));
      expect(find.textContaining('You see'), findsNothing);

      await tester.tap(find.text('Why am I seeing this?'));
      await tester.pump();
      expect(find.textContaining('You see the new home'), findsOneWidget);
      expect(find.textContaining('You see the modern look'), findsOneWidget);

      await tester.tap(find.text('Why am I seeing this?'));
      await tester.pump();
      expect(find.textContaining('You see'), findsNothing);
    });

    testWidgets('says whether it is open', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpThemed(Scaffold(body: WhyLine(whys)));
      final button = find.bySemanticsLabel('Why am I seeing this?');

      expect(
        tester.getSemantics(button),
        isSemantics(isButton: true, isExpanded: false),
      );
      await tester.tap(find.text('Why am I seeing this?'));
      await tester.pump();
      expect(
        tester.getSemantics(button),
        isSemantics(isButton: true, isExpanded: true),
      );
      semantics.dispose();
    });
  });
}
