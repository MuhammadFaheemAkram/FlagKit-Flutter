import 'package:flagkit_sample/core/design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Future<void> pump(WidgetTester tester, {double textScale = 1}) async {
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    tester.usePhoneSurface();
    await tester.pumpThemed(
      const StatRow(icon: Icons.download, label: 'Fetched', value: '00:59:22'),
    );
  }

  testWidgets('the value beside the label', (tester) async {
    await pump(tester);

    final label = tester.getRect(find.text('Fetched'));
    final value = tester.getRect(find.text('00:59:22'));
    expect(value.left, greaterThan(label.right));
    expect(value.center.dy, closeTo(label.center.dy, 2));
  });

  testWidgets('at large text, under it: the label keeps its width', (
    tester,
  ) async {
    await pump(tester, textScale: 2.35);

    final label = tester.getRect(find.text('Fetched'));
    final value = tester.getRect(find.text('00:59:22'));
    expect(value.top, greaterThanOrEqualTo(label.bottom));
    expect(value.left, closeTo(label.left, 1));
    expect(find.bySemanticsLabel('Fetched: 00:59:22'), findsOneWidget);
  });
}
