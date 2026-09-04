import 'dart:convert';
import 'dart:io';
import 'package:digibyte_timechain/data/models/chain_snapshot.dart';

String fixtureText(String name) => File('test/fixtures/$name').readAsStringSync();
Map<String, dynamic> fixtureJson(String name) => jsonDecode(fixtureText(name)) as Map<String, dynamic>;
ChainSnapshot tipFixture() => ChainSnapshot.fromJson(fixtureJson('tip.json'));
ChainSnapshot blockFixture() => ChainSnapshot.fromJson(fixtureJson('block.json'));
