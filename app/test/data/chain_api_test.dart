import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:digibyte_timechain/data/chain_api.dart';
import '../fixtures/fixtures.dart';

void main() {
  ChainApi api(Map<String, http.Response Function()> routes) => ChainApi(
    base: Uri.parse('https://api.example/api'),
    client: MockClient((req) async => (routes[req.url.path] ?? () => http.Response('nope', 404))()),
  );

  test('fetchTip and fetchBlock parse snapshots from the right paths', () async {
    final a = api({'/api/chain/tip': () => http.Response(fixtureText('tip.json'), 200), '/api/chain/block/24151710': () => http.Response(fixtureText('block.json'), 200)});
    expect((await a.fetchTip()).height, 24151775);
    expect((await a.fetchBlock(24151710)).feeRate!.median, closeTo(0.10003, 1e-9));
    expect(a.streamUri.toString(), 'https://api.example/api/chain/stream');
  });
  test('tolerates a trailing slash on the base path', () async {
    final a = ChainApi(
      base: Uri.parse('https://api.example/api/'),
      client: MockClient((req) async => req.url.path == '/api/chain/tip' ? http.Response(fixtureText('tip.json'), 200) : http.Response('nope', 404)),
    );
    expect((await a.fetchTip()).height, 24151775);
    expect(a.streamUri.toString(), 'https://api.example/api/chain/stream');
  });
  test('a 200 that is not JSON is an error, not a crash', () async {
    // A captive portal or a proxy error page answers 200 with HTML.
    final a = api({'/api/chain/tip': () => http.Response('<html>gateway timeout</html>', 200)});
    expect(() => a.fetchTip(), throwsA(isA<ChainApiException>().having((e) => e.message, 'message', 'malformed response')));
  });
  test('maps 404 to BlockNotFound, 503 to ChainWarmingUp, others to ChainApiException', () async {
    final a = api({'/api/chain/block/1': () => http.Response('{"error":"block not found"}', 404), '/api/chain/tip': () => http.Response('{"error":"chain data warming up"}', 503)});
    expect(() => a.fetchBlock(1), throwsA(isA<BlockNotFound>()));
    expect(() => a.fetchTip(), throwsA(isA<ChainWarmingUp>()));
    expect(() => a.fetchBlock(2), throwsA(isA<ChainApiException>().having((e) => e.statusCode, 'status', 404)));
  });
}
