import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/chain_snapshot.dart';

class ChainApiException implements Exception {
  ChainApiException(this.statusCode, this.message);
  final int statusCode;
  final String message;
  @override
  String toString() => 'ChainApiException($statusCode: $message)';
}
class BlockNotFound extends ChainApiException { BlockNotFound() : super(404, 'block not found'); }
class ChainWarmingUp extends ChainApiException { ChainWarmingUp() : super(503, 'chain data warming up'); }

class ChainApi {
  ChainApi({required Uri base, http.Client? client}) : _base = base, _client = client ?? http.Client();
  final Uri _base;
  final http.Client _client;

  Uri _u(String path) => _base.replace(path: '${_base.path}/$path');
  Uri get streamUri => _u('chain/stream');

  Future<ChainSnapshot> fetchTip() => _get('chain/tip');
  Future<ChainSnapshot> fetchBlock(int height) => _get('chain/block/$height');

  Future<ChainSnapshot> _get(String path) async {
    final res = await _client.get(_u(path)).timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) return ChainSnapshot.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    String msg = res.body;
    try { msg = (jsonDecode(res.body) as Map<String, dynamic>)['error']?.toString() ?? msg; } catch (_) {}
    if (res.statusCode == 404 && path.startsWith('chain/block/')) throw BlockNotFound();
    if (res.statusCode == 503) throw ChainWarmingUp();
    throw ChainApiException(res.statusCode, msg);
  }
}
