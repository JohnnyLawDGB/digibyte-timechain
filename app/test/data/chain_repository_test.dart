import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:digibyte_timechain/data/chain_api.dart';
import 'package:digibyte_timechain/data/chain_repository.dart';
import 'package:digibyte_timechain/data/snapshot_cache.dart';
import 'package:digibyte_timechain/data/sse_client.dart';
import '../fixtures/fixtures.dart';

class MockApi extends Mock implements ChainApi {}

class FakeSse implements SseSource {
  final ctrl = StreamController<SseEvent>.broadcast();
  final _state = ValueNotifier(SseState.connecting);
  @override Stream<SseEvent> get events => ctrl.stream;
  @override ValueListenable<SseState> get state => _state;
  void set(SseState s) => _state.value = s;
  @override void close() { ctrl.close(); }
}

void main() {
  late MockApi api; late FakeSse sse; late Directory dir; late SnapshotCache cache;
  setUp(() async { api = MockApi(); sse = FakeSse(); dir = await Directory.systemTemp.createTemp('tc-repo'); cache = SnapshotCache(dir); });
  tearDown(() => dir.delete(recursive: true));

  test('emits the cached tip as stale, then live tips from SSE, and caches them', () async {
    await cache.save(blockFixture().copyWith(isTip: true));
    final repo = ChainRepository(api: api, sse: sse, cache: cache, pollInterval: const Duration(hours: 1));
    final got = <TipUpdate>[];
    final sub = repo.watchTip().listen(got.add);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    sse.set(SseState.connected);
    sse.ctrl.add(SseEvent('tip', fixtureText('tip.json')));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(got.map((u) => u.status), [FeedStatus.stale, FeedStatus.live]);
    expect(got.last.snapshot.height, 24151775);
    expect((await cache.load())!.height, 24151775);
    await sub.cancel(); repo.dispose();
  });

  test('mempool patches update the last tip in place', () async {
    final repo = ChainRepository(api: api, sse: sse, cache: cache, pollInterval: const Duration(hours: 1));
    final got = <TipUpdate>[]; final sub = repo.watchTip().listen(got.add);
    sse.set(SseState.connected);
    sse.ctrl.add(SseEvent('tip', fixtureText('tip.json')));
    sse.ctrl.add(SseEvent('mempool', jsonEncode({'height': 24151775, 'mempool': {'txCount': 9, 'vbytes': 1, 'inflowVbPerSec': 0, 'depthBlocks': 0, 'fees': {'unit': 'DGB/kB'}, 'asOf': 5}, 'price': null})));
    sse.ctrl.add(SseEvent('ping', '{}'));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(got.length, 2);
    expect(got.last.snapshot.mempool!.txCount, 9); expect(got.last.snapshot.price, isNull); expect(got.last.snapshot.height, 24151775);
    await sub.cancel(); repo.dispose();
  });

  test('polls while the socket is down and marks failures as reconnecting', () async {
    var calls = 0;
    when(() => api.fetchTip()).thenAnswer((_) async { calls++; if (calls == 2) throw ChainApiException(500, 'x'); return tipFixture(); });
    final repo = ChainRepository(api: api, sse: sse, cache: cache, pollInterval: const Duration(milliseconds: 30));
    final got = <TipUpdate>[]; final sub = repo.watchTip().listen(got.add);
    sse.set(SseState.disconnected);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(got.map((u) => u.status).take(2), [FeedStatus.live, FeedStatus.reconnecting]);
    sse.set(SseState.connected);
    final before = calls;
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(calls, before);
    await sub.cancel(); repo.dispose();
  });

  test('fetchBlock memoizes', () async {
    when(() => api.fetchBlock(24151710)).thenAnswer((_) async => blockFixture());
    final repo = ChainRepository(api: api, sse: sse, cache: cache);
    await repo.fetchBlock(24151710); await repo.fetchBlock(24151710);
    verify(() => api.fetchBlock(24151710)).called(1);
    repo.dispose();
  });
}
