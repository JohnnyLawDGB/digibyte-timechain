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
    _ctrl ??= StreamController<SseEvent>.broadcast(onListen: _start, onCancel: _stop);
    return _ctrl!.stream;
  }

  int _gen = 0;

  void _start() {
    _closed = false;
    _run(++_gen);
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
        await for (final e in parseSse(res.stream.transform(utf8.decoder).transform(const LineSplitter()))) {
          if (_cancelled(gen)) break;
          _ctrl?.add(e);
        }
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
    _client?.close(); _client = null;
    _state.value = SseState.disconnected;
  }

  @override
  void close() {
    _stop();
    final c = _ctrl; _ctrl = null;
    if (c != null && !c.isClosed) c.close();
  }
}
