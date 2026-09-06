import 'package:intl/intl.dart';

final _int = NumberFormat('#,##0', 'en_US');
const _dash = '—';

String fmtHeight(int h) => _int.format(h);
String fmtDgb(double v, {int decimals = 2}) => NumberFormat('#,##0.${'0' * decimals}', 'en_US').format(v);

/// DGB/kB to 4 significant digits (0.1000, 0.01100, 0.001100).
String fmtFeeDgbPerKb(double? v) {
  if (v == null || v <= 0) return _dash;
  final s = v.toStringAsPrecision(4);
  return s.contains('e') ? v.toStringAsFixed(6) : s;
}

String fmtBillions(double? v) => v == null ? _dash : '${(v / 1e9).toStringAsFixed(2)}B';
String fmtPercent(double f, {int decimals = 1}) => '${(f * 100).toStringAsFixed(decimals)}%';
String fmtUsdPrice(double? usd) => usd == null || usd <= 0 ? _dash : usd.toStringAsPrecision(3);
String fmtDgbPerUsd(double? usd) => usd == null || usd <= 0 ? _dash : _int.format((1 / usd).round());

String fmtUsdCompact(double? v) {
  if (v == null || v <= 0) return _dash;
  if (v >= 1e9) return '\$${(v / 1e9).toStringAsFixed(2)}B';
  if (v >= 1e6) return '\$${(v / 1e6).toStringAsFixed(1)}M';
  if (v >= 1e3) return '\$${(v / 1e3).toStringAsFixed(1)}K';
  return '\$${v.toStringAsFixed(0)}';
}

String fmtDaysFromBlocks(int blocks) => '~${(blocks * 15 / 86400).toStringAsFixed(1)} days';

String fmtElapsed(Duration d) {
  final s = d.inSeconds;
  if (s < 60) return '${s}s';
  if (s < 3600) return '${s ~/ 60}m ${(s % 60).toString().padLeft(2, '0')}s';
  return '${s ~/ 3600}h ${((s % 3600) ~/ 60).toString().padLeft(2, '0')}m';
}

DateTime _utc(int unix) => DateTime.fromMillisecondsSinceEpoch(unix * 1000, isUtc: true);
String fmtUtcTime(int unix) => DateFormat('HH:mm', 'en_US').format(_utc(unix));
String fmtUtcTimeSec(int unix) => DateFormat('HH:mm:ss', 'en_US').format(_utc(unix));
String fmtUtcDate(int unix) => DateFormat('MMM d, y', 'en_US').format(_utc(unix));
String fmtWeekday(int unix) => DateFormat('EEEE', 'en_US').format(_utc(unix)).toUpperCase();
