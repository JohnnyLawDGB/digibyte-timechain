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
  SseClient({required this.uri, http.Client Function()? clientFactory, Duration? Function(int attempt)? backoff})
      : _clientFactory = clientFactory ?? http.Client.new,
        _backoff = backoff ?? defaultBackoff;

  final Uri uri;
  final http.Client Function() _clientFactory;
  final Duration? Function(int attempt) _backoff;
  final _state = ValueNotifier<SseState>(SseState.disconnected);
  StreamController<SseEvent>? _ctrl;
  http.Client? _client;
  var _closed = false;

  /// 1 s → 30 s exponential, forever.
  static Duration? defaultBackoff(int attempt) => Duration(seconds: min(30, pow(2, attempt - 1).toInt()));

  @override
  ValueListenable<SseState> get state => _state;

  @override
  Stream<SseEvent> get events {
    _ctrl ??= StreamController<SseEvent>.broadcast(onListen: _run, onCancel: close);
    return _ctrl!.stream;
  }

  Future<void> _run() async {
    // The client is created once and reused across reconnect attempts: a
    // fresh http.Client per attempt is unnecessary churn, and (per
    // package:http's contract) a single Client is meant to be reused for
    // many requests over its lifetime.
    var attempt = 0;
    _client = _clientFactory();
    while (!_closed) {
      _state.value = SseState.connecting;
      try {
        final res = await _client!.send(http.Request('GET', uri)..headers['Accept'] = 'text/event-stream');
        if (res.statusCode != 200) throw http.ClientException('HTTP ${res.statusCode}', uri);
        _state.value = SseState.connected;
        attempt = 0;
        await for (final e in parseSse(res.stream.transform(utf8.decoder).transform(const LineSplitter()))) {
          if (_closed) break;
          _ctrl?.add(e);
        }
      } catch (_) {
        // fall through to reconnect
      }
      if (_closed) break;
      _state.value = SseState.disconnected;
      final delay = _backoff(++attempt);
      if (delay == null) break;
      await Future<void>.delayed(delay);
    }
    _client?.close(); _client = null;
    _state.value = SseState.disconnected;
  }

  @override
  void close() {
    _closed = true;
    _client?.close();
    _state.value = SseState.disconnected;
    final c = _ctrl; _ctrl = null;
    if (c != null && !c.isClosed) c.close();
  }
}
