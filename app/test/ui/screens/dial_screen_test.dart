import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:digibyte_timechain/app.dart';
import 'package:digibyte_timechain/data/chain_repository.dart';
import 'package:digibyte_timechain/state/providers.dart';
import 'package:digibyte_timechain/state/settings.dart';
import '../../fixtures/fixtures.dart';

class MockRepo extends Mock implements ChainRepository {}

void main() {
  late MockRepo repo; late StreamController<TipUpdate> tips;
  setUp(() async {
    repo = MockRepo(); tips = StreamController<TipUpdate>.broadcast();
    when(() => repo.watchTip()).thenAnswer((_) => tips.stream);
    when(() => repo.fetchBlock(24151774)).thenAnswer((_) async => blockFixture().copyWith(height: 24151774));
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpApp(WidgetTester t) async {
    final prefs = await SharedPreferences.getInstance();
    // nowProvider is periodic; a fixed value keeps pumpAndSettle from waiting on a live timer.
    await t.pumpWidget(ProviderScope(overrides: [
      chainRepositoryProvider.overrideWithValue(repo),
      sharedPrefsProvider.overrideWithValue(prefs),
      nowProvider.overrideWith((_) => Stream.value(DateTime.fromMillisecondsSinceEpoch((tipFixture().time + 9) * 1000, isUtc: true))),
    ], child: const TimechainApp()));
  }

  testWidgets('shows a loading state, then the live dial, then a scrubbed block', (t) async {
    await t.binding.setSurfaceSize(const Size(390, 1200));
    await pumpApp(t);
    expect(find.text('Connecting to the chain…'), findsOneWidget);
    tips.add(TipUpdate(tipFixture(), FeedStatus.live));
    await t.pump();
    expect(find.text('LIVE'), findsOneWidget);
    expect(find.text('24,151,775'), findsOneWidget);
    await t.tap(find.byKey(const Key('scrub-prev')));
    await t.pump(); await t.pump();
    expect(find.text('VIEWING BLOCK'), findsOneWidget);
    expect(find.text('24,151,774'), findsOneWidget);
    expect(find.text('1 behind tip'), findsOneWidget);
  });
  testWidgets('stale and reconnecting badges', (t) async {
    await t.binding.setSurfaceSize(const Size(390, 1200));
    await pumpApp(t);
    tips.add(TipUpdate(tipFixture(), FeedStatus.stale)); await t.pump();
    expect(find.textContaining('STALE'), findsOneWidget);
    tips.add(TipUpdate(tipFixture(), FeedStatus.reconnecting)); await t.pump();
    expect(find.text('RECONNECTING'), findsOneWidget);
  });
  testWidgets('settings toggles the theme', (t) async {
    await t.binding.setSurfaceSize(const Size(390, 1200));
    await pumpApp(t);
    tips.add(TipUpdate(tipFixture(), FeedStatus.live)); await t.pump();
    await t.tap(find.byIcon(Icons.settings)); await t.pumpAndSettle();
    await t.tap(find.text('Light')); await t.pumpAndSettle();
    final app = t.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme!.brightness, Brightness.light);
    expect(find.text('USD'), findsOneWidget);
  });
}
