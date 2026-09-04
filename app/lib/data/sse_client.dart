import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'sse_parser.dart';

export 'sse_parser.dart' show SseEvent;

enum SseState { connecting, connected, disconnected }

abstract class SseSource {
  Stream<SseEvent> get events;
  ValueListenable<SseState> get state;
  void close();
}

/// Reconnecting SSE client. [backoff] returns the delay before attempt N
/// (N starts at 1 after the first failure) or null to stop retrying.
class SseClient implements SseSource {
  SseClient({
    required this.uri,
    http.Client Function()? clientFactory,
    Duration? Function(int attempt)? backoff,
    this.idleTimeout = const Duration(seconds: 60),
    this.idleCheckInterval = const Duration(seconds: 15),
  })  : _clientFactory = clientFactory ?? http.Client.new,
        _backoff = backoff ?? defaultBackoff;

  final Uri uri;

  /// A socket that has delivered nothing (not even a `ping`) for this long is
  /// treated as dead and dropped, so the loop reconnects and the repository's
  /// poll fallback gets a `disconnected` edge to work with. A half-open socket
  /// left behind by a NAT or proxy never EOFs on its own.
  final Duration idleTimeout;
  final Duration idleCheckInterval;
  final http.Client Function() _clientFactory;
  final Duration? Function(int attempt) _backoff;
  final _state = ValueNotifier<SseState>(SseState.disconnected);
  StreamController<SseEvent>? _ctrl;
  http.Client? _client;
  StreamSubscription<SseEvent>? _frames;
  Completer<void>? _connDone;
  Timer? _idleTimer;
  var _lastFrameAt = DateTime.now();
  var _closed = false;

  /// 1 s → 30 s exponential, forever.
  static Duration? defaultBackoff(int attempt) => Duration(seconds: min(30, pow(2, attempt - 1).toInt()));

  @override
  ValueListenable<SseState> get state => _state;

  @override
  Stream<SseEvent> get events {
    _ctrl ??= StreamController<SseEvent>.broadcast(onListen: _start, onCancel: _stop);
    return _ctrl!.stream;
  }

  int _gen = 0;

  void _start() {
    _closed = false;
    _lastFrameAt = DateTime.now();
    _idleTimer?.cancel();
    _idleTimer = Timer.periodic(idleCheckInterval, _checkIdle);
    _run(++_gen);
  }

  void _checkIdle(Timer _) {
    if (_closed || _state.value != SseState.connected) return;
    if (DateTime.now().difference(_lastFrameAt) <= idleTimeout) return;
    _abortConnection();
  }

  /// Tear the current connection down without stopping the loop: the run loop
  /// falls out of its frame subscription, reports `disconnected` and retries.
  void _abortConnection() {
    _frames?.cancel();
    _frames = null;
    _client?.close();
    _client = null;
    final d = _connDone;
    _connDone = null;
    if (d != null && !d.isCompleted) d.complete();
  }

  bool _cancelled(int gen) => _closed || gen != _gen;

  Future<void> _run(int gen) async {
    var attempt = 0;
    while (!_cancelled(gen)) {
      _state.value = SseState.connecting;
      final client = _clientFactory();
      _client = client;
      try {
        final res = await client.send(http.Request('GET', uri)..headers['Accept'] = 'text/event-stream');
        if (_cancelled(gen)) break;
        if (res.statusCode != 200) throw http.ClientException('HTTP ${res.statusCode}', uri);
        _state.value = SseState.connected;
        attempt = 0;
        _lastFrameAt = DateTime.now();
        // Subscribe rather than `await for` so the idle watchdog can cut a
        // half-open socket loose; awaiting a stream that never ends cannot.
        final done = Completer<void>();
        _connDone = done;
        _frames = parseSse(res.stream.transform(utf8.decoder).transform(const LineSplitter())).listen(
          (e) {
            _lastFrameAt = DateTime.now();          // `ping` counts: it proves the socket is alive
            if (!_cancelled(gen)) _ctrl?.add(e);
          },
          onError: (Object _) { if (!done.isCompleted) done.complete(); },
          onDone: () { if (!done.isCompleted) done.complete(); },
          cancelOnError: true,
        );
        await done.future;
        await _frames?.cancel();
        _frames = null;
        _connDone = null;
      } catch (_) {
        // fall through to reconnect
      } finally {
        client.close();
        if (identical(_client, client)) _client = null;
      }
      if (_cancelled(gen)) break;
      _state.value = SseState.disconnected;
      final delay = _backoff(++attempt);
      if (delay == null) break;
      await Future<void>.delayed(delay);
    }
    if (gen == _gen) _state.value = SseState.disconnected;
  }

  /// Last listener left: stop connecting, keep the controller so a later listen restarts.
  void _stop() {
    _closed = true;
    _idleTimer?.cancel(); _idleTimer = null;
    _abortConnection();
    _state.value = SseState.disconnected;
  }

  @override
  void close() {
    _stop();
    final c = _ctrl; _ctrl = null;
    if (c != null && !c.isClosed) c.close();
  }
}
