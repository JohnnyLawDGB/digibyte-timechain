import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:digibyte_timechain/ui/dial/dial.dart';
import 'package:digibyte_timechain/ui/theme/timechain_theme.dart';
import '../../fixtures/fixtures.dart';

const goldenFrameKey = Key('golden-frame');

Widget host(Widget child, TimechainPalette p) => MaterialApp(
  theme: timechainTheme(p),
  home: Scaffold(
    body: Center(
      child: RepaintBoundary(
        child: ColoredBox(
          key: goldenFrameKey,
          color: p.bg,
          child: Padding(padding: const EdgeInsets.all(12), child: child),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('renders height, algo, fee band and pills for a scrubbed block', (t) async {
    await t.pumpWidget(host(Dial(snapshot: blockFixture()), TimechainPalette.dark));
    expect(find.text('24,151,710'), findsOneWidget);
    expect(find.text('QUBIT'), findsOneWidget);
    expect(find.textContaining('0.1000'), findsOneWidget);
    expect(find.textContaining('min 0.001100'), findsOneWidget);
    expect(find.text('7,579 B · 4 tx'), findsOneWidget);
    expect(find.text('87.9%'), findsOneWidget);
    expect(find.text('69.0%'), findsOneWidget);
  });
  testWidgets('shows dashes for a coinbase-only block and null supply', (t) async {
    final s = tipFixture().copyWith(supply: tipFixture().supply.copyWith(total: null));
    await t.pumpWidget(host(Dial(snapshot: s), TimechainPalette.dark));
    expect(find.textContaining('— DGB/kB'), findsOneWidget);
    expect(find.text('—'), findsWidgets);
  });
  testWidgets('golden: dark', (t) async {
    await t.pumpWidget(host(Dial(snapshot: ringFixture()), TimechainPalette.dark));
    await expectLater(find.byKey(goldenFrameKey), matchesGoldenFile('../../goldens/dial_dark.png'));
  });
  testWidgets('golden: light', (t) async {
    await t.pumpWidget(host(Dial(snapshot: ringFixture()), TimechainPalette.light));
    await expectLater(find.byKey(goldenFrameKey), matchesGoldenFile('../../goldens/dial_light.png'));
  });
  testWidgets('golden: dark at tablet size', (t) async {
    await t.binding.setSurfaceSize(const Size(900, 900));
    await t.pumpWidget(host(Dial(snapshot: ringFixture(), size: 800), TimechainPalette.dark));
    await expectLater(find.byKey(goldenFrameKey), matchesGoldenFile('../../goldens/dial_dark_800.png'));
  });
}
