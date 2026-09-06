import 'package:flutter_test/flutter_test.dart';
import 'package:digibyte_timechain/domain/formatters.dart';

void main() {
  test('heights and DGB', () {
    expect(fmtHeight(24151775), '24,151,775');
    expect(fmtDgb(253.55810338), '253.56');
    expect(fmtDgb(0.64499045, decimals: 3), '0.645');
  });
  test('fees in DGB/kB to 4 significant digits, dash when unknown', () {
    expect(fmtFeeDgbPerKb(0.10003), '0.1000');
    expect(fmtFeeDgbPerKb(0.0011), '0.001100');
    expect(fmtFeeDgbPerKb(0.011), '0.01100');
    expect(fmtFeeDgbPerKb(null), '—');
  });
  test('supply, percent, price, market cap', () {
    expect(fmtBillions(18457077640.5), '18.46B');
    expect(fmtBillions(null), '—');
    expect(fmtPercent(0.6905), '69.0%');
    expect(fmtPercent(0.8789, decimals: 2), '87.89%');
    expect(fmtUsdPrice(0.004692), '0.00469');
    expect(fmtUsdPrice(null), '—');
    expect(fmtUsdCompact(86638859), '\$86.6M');
    expect(fmtUsdCompact(1234567890), '\$1.23B');
    expect(fmtDgbPerUsd(0.004692), '213');
  });
  test('durations', () {
    expect(fmtDaysFromBlocks(54225), '~9.4 days');
    expect(fmtElapsed(const Duration(seconds: 9)), '9s');
    expect(fmtElapsed(const Duration(seconds: 68)), '1m 08s');
    expect(fmtElapsed(const Duration(hours: 2, minutes: 5)), '2h 05m');
  });
  test('UTC time and date', () {
    expect(fmtUtcTime(1788518429), '10:40');
    expect(fmtUtcTimeSec(1788518429), '10:40:29');
    expect(fmtUtcDate(1788518429), 'Sep 4, 2026');
    expect(fmtWeekday(1788518429), 'FRIDAY');
  });
}
