import 'dart:convert';
import 'dart:io';
import 'package:digibyte_timechain/data/models/chain_snapshot.dart';

String fixtureText(String name) => File('test/fixtures/$name').readAsStringSync();
Map<String, dynamic> fixtureJson(String name) => jsonDecode(fixtureText(name)) as Map<String, dynamic>;
ChainSnapshot tipFixture() => ChainSnapshot.fromJson(fixtureJson('tip.json'));
ChainSnapshot blockFixture() => ChainSnapshot.fromJson(fixtureJson('block.json'));

/// [blockFixture] with a full 240-entry `recentBlocks` ring (varied algo/size/tx/time),
/// for goldens that need to exercise the Dial's tick ring instead of a single tick.
ChainSnapshot ringFixture() => blockFixture().copyWith(recentBlocks: [
  for (var i = 0; i < 240; i++)
    BlockRef(
      height: 24151710 - i,
      algo: const ['sha256d', 'scrypt', 'skein', 'qubit', 'odocrypt'][i % 5],
      sizeBytes: 300 + (i * 37) % 7800,
      txCount: 1 + i % 4,
      time: 1788518429 - i * 15,
    ),
]);
