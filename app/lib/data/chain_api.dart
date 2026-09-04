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
  /// A base with a trailing slash ('.../api/') would otherwise build '.../api//chain/tip'.
  ChainApi({required Uri base, http.Client? client})
      : _base = base.replace(path: base.path.endsWith('/') ? base.path.substring(0, base.path.length - 1) : base.path),
        _client = client ?? http.Client();
  final Uri _base;
  final http.Client _client;

  Uri _u(String path) => _base.replace(path: '${_base.path}/$path');
  Uri get streamUri => _u('chain/stream');

  Future<ChainSnapshot> fetchTip() => _get('chain/tip');
  Future<ChainSnapshot> fetchBlock(int height) => _get('chain/block/$height');

  Future<ChainSnapshot> _get(String path) async {
    final res = await _client.get(_u(path)).timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) {
      // A captive portal or a proxy error page can answer 200 with HTML.
      final Object? body;
      try { body = jsonDecode(res.body); } catch (_) { throw ChainApiException(200, 'malformed response'); }
      if (body is! Map<String, dynamic>) throw ChainApiException(200, 'malformed response');
      return ChainSnapshot.fromJson(body);
    }
    String msg = res.body;
    try { msg = (jsonDecode(res.body) as Map<String, dynamic>)['error']?.toString() ?? msg; } catch (_) {}
    if (res.statusCode == 404 && path.startsWith('chain/block/')) throw BlockNotFound();
    if (res.statusCode == 503) throw ChainWarmingUp();
    throw ChainApiException(res.statusCode, msg);
  }
}
