import 'dart:convert';
import 'dart:io';
import 'models/chain_snapshot.dart';

/// Last tip snapshot on disk so the app opens with data while offline.
class SnapshotCache {
  SnapshotCache(this.dir);
  final Directory dir;
  File get _file => File('${dir.path}/tip.json');

  Future<ChainSnapshot?> load() async {
    try {
      if (!await _file.exists()) return null;
      return ChainSnapshot.fromJson(jsonDecode(await _file.readAsString()) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(ChainSnapshot s) async {
    try {
      await dir.create(recursive: true);
      await _file.writeAsString(jsonEncode(s.toJson()), flush: true);
    } catch (_) {/* cache is best-effort */}
  }
}
