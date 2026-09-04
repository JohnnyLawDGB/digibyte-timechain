import 'package:flutter_test/flutter_test.dart';
import 'package:digibyte_timechain/data/models/chain_snapshot.dart';
import '../../fixtures/fixtures.dart';

void main() {
  test('parses the tip snapshot', () {
    final s = tipFixture();
    expect(s.height, 24151775); expect(s.algo, 'odocrypt'); expect(s.isTip, isTrue);
    expect(s.feeRate, isNull);
    expect(s.reward.total, closeTo(253.55810338, 1e-8));
    expect(s.pool.tag, 'm2pool.com');
    expect(s.reduction.blocksUntilNext, 54225);
    expect(s.supply.total, closeTo(18457077640.5, 1e-3)); expect(s.supply.cap, 21000000000);
    expect(s.algoShare24h.share('skein'), closeTo(0.2125, 1e-9));
    expect(s.algoShare24h.asMap.keys, ['sha256d', 'scrypt', 'skein', 'qubit', 'odocrypt']);
    expect(s.recentBlocks.first.height, 24151775);
    expect(s.mempool!.fees.priority, closeTo(0.011, 1e-9));
    expect(s.price!.usd, closeTo(0.004692, 1e-9));
  });
  test('parses a scrubbed block without mempool/price and with a fee band', () {
    final b = blockFixture();
    expect(b.isTip, isFalse); expect(b.mempool, isNull); expect(b.price, isNull);
    expect(b.feeRate!.median, closeTo(0.10003, 1e-9)); expect(b.feeRate!.unit, 'DGB/kB');
  });
  test('tolerates a null supply total and missing price', () {
    final j = fixtureJson('tip.json')..['supply'] = {'total': null, 'cap': 21000000000}..['price'] = null;
    final s = ChainSnapshot.fromJson(j);
    expect(s.supply.total, isNull); expect(s.price, isNull);
  });
  test('withPatch replaces mempool and price only', () {
    final s = tipFixture();
    expect(s.price, isNotNull, reason: 'fixture guard: the tip carries a price to preserve');
    const mempool = {'txCount': 7, 'vbytes': 900, 'inflowVbPerSec': 12.5, 'depthBlocks': 0.0, 'fees': {'unit': 'DGB/kB', 'priority': null, 'anytime': null}, 'asOf': 1};
    // A mempool frame carries no price of its own; it must not wipe the tip's.
    final p = MempoolPatch.fromJson({'height': 24151775, 'mempool': mempool, 'price': null});
    final s2 = s.withPatch(p);
    expect(s2.mempool!.txCount, 7); expect(s2.mempool!.fees.priority, isNull);
    expect(s2.price, s.price);
    expect(s2.height, s.height); expect(s2.recentBlocks, s.recentBlocks);
    // A patch that does carry a price replaces it.
    final p2 = MempoolPatch.fromJson({'height': 24151775, 'mempool': mempool, 'price': {'usd': 0.009, 'marketCapUsd': 1, 'asOf': 2, 'isStale': false}});
    expect(s.withPatch(p2).price!.usd, 0.009);
  });
  test('round-trips through toJson', () {
    final s = tipFixture();
    expect(ChainSnapshot.fromJson(s.toJson()), s);
  });
}
