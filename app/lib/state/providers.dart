import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config.dart';
import '../data/chain_api.dart';
import '../data/chain_repository.dart';
import '../data/models/chain_snapshot.dart';
import '../data/snapshot_cache.dart';
import '../data/sse_client.dart';

final cacheDirProvider = Provider<Directory>((_) => throw UnimplementedError('override in main'));
final chainApiProvider = Provider<ChainApi>((_) => ChainApi(base: Uri.parse(kApiBase)));
final sseSourceProvider = Provider<SseSource>((ref) => SseClient(uri: ref.watch(chainApiProvider).streamUri));
final snapshotCacheProvider = Provider<SnapshotCache>((ref) => SnapshotCache(ref.watch(cacheDirProvider)));

final chainRepositoryProvider = Provider<ChainRepository>((ref) {
  final repo = ChainRepository(api: ref.watch(chainApiProvider), sse: ref.watch(sseSourceProvider), cache: ref.watch(snapshotCacheProvider));
  ref.onDispose(repo.dispose);
  return repo;
});

final tipUpdateProvider = StreamProvider<TipUpdate>((ref) => ref.watch(chainRepositoryProvider).watchTip());

/// null = live (follow the tip); otherwise the scrubbed height.
final selectedHeightProvider = StateProvider<int?>((_) => null);
final isLiveProvider = Provider<bool>((ref) => ref.watch(selectedHeightProvider) == null);

final selectedSnapshotProvider = FutureProvider<ChainSnapshot>((ref) async {
  final h = ref.watch(selectedHeightProvider);
  if (h == null) {
    final tip = ref.watch(tipUpdateProvider);
    return tip.when(data: (u) => u.snapshot, loading: () => Completer<ChainSnapshot>().future, error: (e, _) => throw e);
  }
  return ref.watch(chainRepositoryProvider).fetchBlock(h);
});

/// False whenever the app is not in the foreground. Driven by the lifecycle
/// listener in [TimechainApp].
final appResumedProvider = StateProvider<bool>((_) => true);

/// One tick per second for the block timer — but only while the app is resumed.
/// A backgrounded app would otherwise rebuild the whole dial once a second for
/// nobody; it still emits once so a paused frame shows a sane time.
final nowProvider = StreamProvider<DateTime>((ref) => ref.watch(appResumedProvider) ? _tickingNow() : Stream.value(DateTime.now()));

Stream<DateTime> _tickingNow() async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
}
