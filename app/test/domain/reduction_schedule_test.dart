import 'package:flutter_test/flutter_test.dart';
import 'package:digibyte_timechain/domain/reduction_schedule.dart';

void main() {
  group('subsidySats — Core Period VI replica', () {
    test('matches the live node at 24,151,775', () {
      expect(ReductionSchedule.subsidySats(24151775), BigInt.from(25355810338));
    });
    test('steps down on the cycle boundary', () {
      expect(ReductionSchedule.subsidySats(24205999), BigInt.from(25355810338));
      expect(ReductionSchedule.subsidySats(24206000), BigInt.from(25072839494));
    });
    test('refuses pre-Period-VI heights', () {
      expect(() => ReductionSchedule.subsidySats(1429999), throwsRangeError);
    });
    test('subsidyDgb', () {
      expect(ReductionSchedule.subsidyDgb(24151775), closeTo(253.55810338, 1e-8));
    });
  });
  group('at', () {
    test('step 130, 54,225 blocks to go at 24,151,775', () {
      final r = ReductionSchedule.at(24151775);
      expect(r.step, 130); expect(r.cycle, 175200); expect(r.blocksUntilNext, 54225);
      expect(r.nextHeight, 24206000); expect(r.fraction, closeTo(0.6905, 1e-4));
    });
    test('origin is step 1 with fraction 0', () {
      expect(ReductionSchedule.at(1430000).step, 1);
      expect(ReductionSchedule.at(1430000).fraction, 0);
    });
  });
}
