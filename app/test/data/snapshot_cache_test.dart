import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:digibyte_timechain/data/snapshot_cache.dart';
import '../fixtures/fixtures.dart';

void main() {
  test('round-trips the tip and returns null when empty or corrupt', () async {
    final dir = await Directory.systemTemp.createTemp('tc-cache');
    final cache = SnapshotCache(dir);
    expect(await cache.load(), isNull);
    await cache.save(tipFixture());
    expect((await cache.load())!.height, 24151775);
    File('${dir.path}/tip.json').writeAsStringSync('{not json');
    expect(await cache.load(), isNull);
    await dir.delete(recursive: true);
  });
}
