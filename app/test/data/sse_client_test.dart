import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:digibyte_timechain/data/sse_client.dart';

/// One scripted connection: a list of frames, then EOF (or an error if [fail]).
http.Client scripted(List<List<String>> connections, {List<bool>? fail, void Function(int)? onConnect}) {
  var n = 0;
  return MockClient.streaming((req, body) async {
    final i = n++;
    onConnect?.call(i);
    if (fail != null && i < fail.length && fail[i]) throw http.ClientException('refused');
    final frames = i < connections.length ? connections[i] : const <String>[];
    final ctrl = StreamController<List<int>>();
    Future(() async { for (final f in frames) { ctrl.add(utf8.encode(f)); await Future<void>.delayed(const Duration(milliseconds: 5)); } await ctrl.close(); });
    return http.StreamedResponse(ctrl.stream, 200, headers: {'content-type': 'text/event-stream'});
  });
}

void main() {
  test('emits parsed events and reports connected/disconnected', () async {
    final states = <SseState>[];
    final client = SseClient(uri: Uri.parse('http://x/stream'), clientFactory: () => scripted([['event: tip\ndata: {"height":1}\n\n', 'event: ping\ndata: {}\n\n']]), backoff: (_) => null);
    client.state.addListener(() => states.add(client.state.value));
    final events = await client.events.take(2).toList();
    expect(events.first.event, 'tip'); expect(events.first.data, '{"height":1}');
    expect(states.first, SseState.connecting); expect(states, contains(SseState.connected));
    client.close();
  });
  test('reconnects after EOF and after a connection error with backoff', () async {
    final attempts = <int>[]; final delays = <int>[];
    final client = SseClient(
      uri: Uri.parse('http://x/stream'),
      clientFactory: () => scripted([[], ['event: tip\ndata: {"height":2}\n\n']], fail: [true, false], onConnect: attempts.add),
      backoff: (attempt) { delays.add(attempt); return attempt < 3 ? const Duration(milliseconds: 1) : null; },
    );
    final e = await client.events.first;
    expect(e.data, '{"height":2}');
    expect(attempts, [0, 1]);
    expect(delays, [1]);
    client.close();
  });
  test('close() ends the stream and stops reconnecting', () async {
    var connects = 0;
    final client = SseClient(uri: Uri.parse('http://x/stream'), clientFactory: () => scripted([[]], onConnect: (_) => connects++), backoff: (_) => const Duration(milliseconds: 1));
    final sub = client.events.listen((_) {});
    await Future<void>.delayed(const Duration(milliseconds: 20));
    client.close();
    final before = connects;
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(connects, before);
    expect(client.state.value, SseState.disconnected);
    await sub.cancel();
  });
}
