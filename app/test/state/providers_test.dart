import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:digibyte_timechain/data/chain_repository.dart';
import 'package:digibyte_timechain/state/providers.dart';
import '../fixtures/fixtures.dart';

class MockRepo extends Mock implements ChainRepository {}

void main() {
  test('nowProvider ticks while resumed and stops while the app is backgrounded', () async {
    final paused = ProviderContainer(overrides: [appResumedProvider.overrideWith((_) => false)]);
    final off = <DateTime>[];
    final s1 = paused.listen(nowProvider, (_, n) { if (n.value != null) off.add(n.value!); });
    final running = ProviderContainer();
    final on = <DateTime>[];
    final s2 = running.listen(nowProvider, (_, n) { if (n.value != null) on.add(n.value!); });
    await Future<void>.delayed(const Duration(milliseconds: 2200));
    expect(off.length, 1, reason: 'a backgrounded app must not rebuild the dial once a second');
    expect(on.length, greaterThan(1));
    s1.close(); paused.dispose(); s2.close(); running.dispose();
  });

  test('selectedSnapshot follows the tip when live and fetches a block when scrubbed', () async {
    final repo = MockRepo();
    final tips = StreamController<TipUpdate>.broadcast();
    when(() => repo.watchTip()).thenAnswer((_) => tips.stream);
    when(() => repo.fetchBlock(24151710)).thenAnswer((_) async => blockFixture());
    final c = ProviderContainer(overrides: [chainRepositoryProvider.overrideWithValue(repo)]);
    final sub = c.listen(selectedSnapshotProvider, (_, __) {});
    tips.add(TipUpdate(tipFixture(), FeedStatus.live));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(c.read(isLiveProvider), isTrue);
    expect(c.read(selectedSnapshotProvider).value?.height, 24151775);
    c.read(selectedHeightProvider.notifier).state = 24151710;
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(c.read(isLiveProvider), isFalse);
    expect(c.read(selectedSnapshotProvider).value?.height, 24151710);
    sub.close();
  });
}
