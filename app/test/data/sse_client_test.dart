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
    final c = scripted([['event: tip\ndata: {"height":1}\n\n', 'event: ping\ndata: {}\n\n']]);
    final client = SseClient(uri: Uri.parse('http://x/stream'), clientFactory: () => c, backoff: (_) => null);
    client.state.addListener(() => states.add(client.state.value));
    final events = await client.events.take(2).toList();
    expect(events.first.event, 'tip'); expect(events.first.data, '{"height":1}');
    expect(states.first, SseState.connecting); expect(states, contains(SseState.connected));
    client.close();
  });
  test('reconnects after EOF and after a connection error with backoff', () async {
    final attempts = <int>[]; final delays = <int>[];
    final c = scripted([[], ['event: tip\ndata: {"height":2}\n\n']], fail: [true, false], onConnect: attempts.add);
    final client = SseClient(
      uri: Uri.parse('http://x/stream'),
      clientFactory: () => c,
      backoff: (attempt) { delays.add(attempt); return attempt < 3 ? const Duration(milliseconds: 1) : null; },
    );
    final e = await client.events.first;
    expect(e.data, '{"height":2}');
    expect(attempts, [0, 1]);
    expect(delays, [1]);
    client.close();
  });
  test('an idle socket that never EOFs is dropped and reconnected by the watchdog', () async {
    // One frame, then the connection stays open forever with nothing on it —
    // the failure mode a dead NAT/proxy leaves behind. Without a watchdog the
    // client sits in `connected` and the repository never falls back to polling.
    var connects = 0;
    final c = MockClient.streaming((req, body) async {
      connects++;
      final ctrl = StreamController<List<int>>();
      ctrl.add(utf8.encode('event: tip\ndata: {"height":1}\n\n'));
      return http.StreamedResponse(ctrl.stream, 200, headers: {'content-type': 'text/event-stream'});
    });
    final states = <SseState>[];
    final client = SseClient(
      uri: Uri.parse('http://x/stream'),
      clientFactory: () => c,
      backoff: (_) => const Duration(milliseconds: 1),
      idleTimeout: const Duration(milliseconds: 100),
      idleCheckInterval: const Duration(milliseconds: 20),
    );
    client.state.addListener(() => states.add(client.state.value));
    final sub = client.events.listen((_) {});
    await Future<void>.delayed(const Duration(milliseconds: 400));
    expect(connects, greaterThanOrEqualTo(2), reason: 'states: $states');
    expect(states, contains(SseState.disconnected));
    await sub.cancel();
    client.close();
  });

  test('close() ends the stream and stops reconnecting', () async {
    var connects = 0;
    final c = scripted([[]], onConnect: (_) => connects++);
    final client = SseClient(uri: Uri.parse('http://x/stream'), clientFactory: () => c, backoff: (_) => const Duration(milliseconds: 1));
    final sub = client.events.listen((_) {});
    await Future<void>.delayed(const Duration(milliseconds: 20));
    client.close();
    final before = connects;
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(connects, before);
    expect(client.state.value, SseState.disconnected);
    await sub.cancel();
  });
  test('re-subscribing after the last listener cancels reconnects', () async {
    var connects = 0;
    final c = scripted([[], []], onConnect: (_) => connects++);
    final client = SseClient(uri: Uri.parse('http://x/stream'), clientFactory: () => c, backoff: (_) => null);
    final sub1 = client.events.listen((_) {});
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await sub1.cancel();
    expect(client.state.value, SseState.disconnected);
    final before = connects;
    final sub2 = client.events.listen((_) {});
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(connects, greaterThan(before));
    await sub2.cancel();
    client.close();
  });
  test('a stop during an in-flight request cannot leak state into a restarted loop', () async {
    var requests = 0;
    final slow = MockClient.streaming((req, body) async {
      requests++;
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return http.StreamedResponse(const Stream<List<int>>.empty(), 200, headers: {'content-type': 'text/event-stream'});
    });
    final client = SseClient(uri: Uri.parse('http://x/stream'), clientFactory: () => slow, backoff: (_) => null);
    final states = <SseState>[];
    final sub1 = client.events.listen((_) {});
    await Future<void>.delayed(const Duration(milliseconds: 10));
    await sub1.cancel();                                   // first request still in flight
    client.state.addListener(() => states.add(client.state.value));
    final sub2 = client.events.listen((_) {});
    await Future<void>.delayed(const Duration(milliseconds: 150));
    expect(requests, 2);
    expect(states.where((s) => s == SseState.connected).length, 1, reason: 'states: $states');
    await sub2.cancel();
    client.close();
  });
}
