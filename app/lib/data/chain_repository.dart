import 'dart:async';
import 'dart:convert';
import 'chain_api.dart';
import 'models/chain_snapshot.dart';
import 'snapshot_cache.dart';
import 'sse_client.dart';

enum FeedStatus { live, reconnecting, stale }

class TipUpdate {
  const TipUpdate(this.snapshot, this.status);
  final ChainSnapshot snapshot;
  final FeedStatus status;
}

/// Single source of truth for "what is the tip right now".
/// SSE when it works, REST polling while it does not, disk cache when neither does.
class ChainRepository {
  ChainRepository({required ChainApi api, required SseSource sse, required SnapshotCache cache, this.pollInterval = const Duration(seconds: 10)})
      : _api = api, _sse = sse, _cache = cache;

  final ChainApi _api;
  final SseSource _sse;
  final SnapshotCache _cache;
  final Duration pollInterval;

  StreamController<TipUpdate>? _ctrl;
  StreamSubscription<SseEvent>? _sseSub;
  Timer? _poll;
  ChainSnapshot? _last;
  bool _polling = false;
  final _blocks = <int, ChainSnapshot>{};
  static const _maxBlocks = 512;

  Stream<TipUpdate> watchTip() {
    _ctrl ??= StreamController<TipUpdate>.broadcast(onListen: _start, onCancel: _stop);
    return _ctrl!.stream;
  }

  void _start() {
    // Subscribe synchronously first so events fired right after listen() (as
    // in tests, and in real reconnect races) are never lost by the broadcast
    // SSE controller — it does not buffer for listener-less moments.
    _sse.state.addListener(_onSseState);
    _sseSub = _sse.events.listen(_onEvent);
    _onSseState();
    _loadCached();
  }

  Future<void> _loadCached() async {
    final cached = await _cache.load();
    if (cached != null && _last == null) { _last = cached; _emit(FeedStatus.stale); }
  }

  void _stop() { _sseSub?.cancel(); _sseSub = null; _sse.state.removeListener(_onSseState); _poll?.cancel(); _poll = null; }

  void _onSseState() {
    if (_sse.state.value == SseState.disconnected) {
      _poll ??= Timer.periodic(pollInterval, (_) => _pollOnce());
    } else {
      _poll?.cancel(); _poll = null;
    }
  }

  Future<void> _pollOnce() async {
    if (_polling) return;                  // never overlap: a slow poll must not race a newer one
    _polling = true;
    try {
      _last = await _api.fetchTip();
      await _cache.save(_last!);
      _emit(FeedStatus.live);
    } catch (_) {
      if (_last != null) _emit(FeedStatus.reconnecting);
    } finally {
      _polling = false;
    }
  }

  void _onEvent(SseEvent e) {
    try {
      final json = jsonDecode(e.data) as Map<String, dynamic>;
      if (e.event == 'tip') {
        _last = ChainSnapshot.fromJson(json);
        unawaited(_cache.save(_last!).catchError((_) {}));
        _emit(FeedStatus.live);
      } else if (e.event == 'mempool' && _last != null) {
        final p = MempoolPatch.fromJson(json);
        if (p.height == null || p.height == _last!.height) { _last = _last!.withPatch(p); _emit(FeedStatus.live); }
      }
    } catch (_) {/* malformed frame: ignore, next tip fixes it */}
  }

  void _emit(FeedStatus s) { final l = _last; if (l != null && !(_ctrl?.isClosed ?? true)) _ctrl!.add(TipUpdate(l, s)); }

  Future<ChainSnapshot> fetchBlock(int height) async {
    final hit = _blocks.remove(height);
    if (hit != null) { _blocks[height] = hit; return hit; }
    final s = await _api.fetchBlock(height);
    _blocks[height] = s;
    if (_blocks.length > _maxBlocks) _blocks.remove(_blocks.keys.first);
    return s;
  }

  void dispose() { _stop(); _sse.close(); _ctrl?.close(); _ctrl = null; }
}
