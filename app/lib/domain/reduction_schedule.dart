/// DigiByte Core `GetBlockSubsidy` Period VI (height >= 1,430,000), replicated
/// exactly with BigInt so integer truncation matches the C++.
/// Verified 2026-09-04: 24,151,775 → 25,355,810,338 sats; 24,206,000 → 25,072,839,494.
class Reduction {
  const Reduction({required this.step, required this.cycle, required this.blocksUntilNext, required this.nextHeight, required this.fraction});
  final int step, cycle, blocksUntilNext, nextHeight;
  final double fraction;
}

class ReductionSchedule {
  ReductionSchedule._();
  static const int periodViStart = 1430000;
  static const int blockTimeSeconds = 15;
  static const int secondsPerMonth = 2628000; // 60*60*24*365 ~/ 12
  static const int blocksPerMonth = secondsPerMonth ~/ blockTimeSeconds; // 175200
  static const int supplyCap = 21000000000;
  static final BigInt _coin = BigInt.from(100000000);

  static BigInt subsidySats(int height) {
    if (height < periodViStart) throw RangeError.value(height, 'height', 'Period VI only (>= $periodViStart)');
    var n = (BigInt.from(2157) * _coin) ~/ BigInt.two;
    final months = ((height - periodViStart) * blockTimeSeconds) ~/ secondsPerMonth;
    for (var i = 0; i < months; i++) {
      n = (n * BigInt.from(98884)) ~/ BigInt.from(100000);
    }
    return n < _coin ? BigInt.zero : n;
  }

  static double subsidyDgb(int height) => subsidySats(height).toDouble() / 1e8;

  static Reduction at(int height) {
    if (height < periodViStart) throw RangeError.value(height, 'height', 'Period VI only (>= $periodViStart)');
    final n = height - periodViStart;
    final months = n ~/ blocksPerMonth;
    final next = periodViStart + (months + 1) * blocksPerMonth;
    return Reduction(step: months + 1, cycle: blocksPerMonth, blocksUntilNext: next - height, nextHeight: next, fraction: (n % blocksPerMonth) / blocksPerMonth);
  }
}
