import 'package:freezed_annotation/freezed_annotation.dart';

part 'chain_snapshot.freezed.dart';
part 'chain_snapshot.g.dart';

@freezed
class FeeRate with _$FeeRate {
  const factory FeeRate({required String unit, required double median, required double min, required double max}) = _FeeRate;
  factory FeeRate.fromJson(Map<String, dynamic> json) => _$FeeRateFromJson(json);
}

@freezed
class Reward with _$Reward {
  const factory Reward({required double subsidy, required double fees, required double total}) = _Reward;
  factory Reward.fromJson(Map<String, dynamic> json) => _$RewardFromJson(json);
}

@freezed
class PoolInfo with _$PoolInfo {
  const factory PoolInfo({String? tag, String? raw}) = _PoolInfo;
  factory PoolInfo.fromJson(Map<String, dynamic> json) => _$PoolInfoFromJson(json);
}

@freezed
class ReductionInfo with _$ReductionInfo {
  const factory ReductionInfo({required int step, required int cycle, required int blocksUntilNext, required int nextHeight, required double fraction}) = _ReductionInfo;
  factory ReductionInfo.fromJson(Map<String, dynamic> json) => _$ReductionInfoFromJson(json);
}

@freezed
class SupplyInfo with _$SupplyInfo {
  const factory SupplyInfo({double? total, required double cap}) = _SupplyInfo;
  factory SupplyInfo.fromJson(Map<String, dynamic> json) => _$SupplyInfoFromJson(json);
}

@freezed
class AlgoShare with _$AlgoShare {
  const AlgoShare._();
  const factory AlgoShare({
    @Default(0) double sha256d, @Default(0) double scrypt, @Default(0) double skein,
    @Default(0) double qubit, @Default(0) double odocrypt, @Default(0) int blocksCounted,
  }) = _AlgoShare;
  factory AlgoShare.fromJson(Map<String, dynamic> json) => _$AlgoShareFromJson(json);

  Map<String, double> get asMap => {'sha256d': sha256d, 'scrypt': scrypt, 'skein': skein, 'qubit': qubit, 'odocrypt': odocrypt};
  double share(String key) => asMap[key] ?? 0;
}

@freezed
class BlockRef with _$BlockRef {
  const factory BlockRef({required int height, required String algo, required int sizeBytes, required int txCount, required int time}) = _BlockRef;
  factory BlockRef.fromJson(Map<String, dynamic> json) => _$BlockRefFromJson(json);
}

@freezed
class FeeEstimates with _$FeeEstimates {
  const factory FeeEstimates({required String unit, double? priority, double? anytime}) = _FeeEstimates;
  factory FeeEstimates.fromJson(Map<String, dynamic> json) => _$FeeEstimatesFromJson(json);
}

@freezed
class MempoolInfo with _$MempoolInfo {
  const factory MempoolInfo({required int txCount, required int vbytes, required double inflowVbPerSec, required double depthBlocks, required FeeEstimates fees, required int asOf}) = _MempoolInfo;
  factory MempoolInfo.fromJson(Map<String, dynamic> json) => _$MempoolInfoFromJson(json);
}

@freezed
class PriceInfo with _$PriceInfo {
  const factory PriceInfo({required double usd, double? marketCapUsd, required int asOf, @Default(false) bool isStale}) = _PriceInfo;
  factory PriceInfo.fromJson(Map<String, dynamic> json) => _$PriceInfoFromJson(json);
}

@freezed
class MempoolPatch with _$MempoolPatch {
  const factory MempoolPatch({int? height, MempoolInfo? mempool, PriceInfo? price}) = _MempoolPatch;
  factory MempoolPatch.fromJson(Map<String, dynamic> json) => _$MempoolPatchFromJson(json);
}

@freezed
class ChainSnapshot with _$ChainSnapshot {
  const ChainSnapshot._();
  const factory ChainSnapshot({
    required int height, required String hash, String? prevHash, required int time,
    required String algo, required int sizeBytes, required int txCount,
    FeeRate? feeRate, required Reward reward, required PoolInfo pool,
    required ReductionInfo reduction, required SupplyInfo supply, required AlgoShare algoShare24h,
    required List<BlockRef> recentBlocks, MempoolInfo? mempool, PriceInfo? price,
    @Default(false) bool isTip,
  }) = _ChainSnapshot;
  factory ChainSnapshot.fromJson(Map<String, dynamic> json) => _$ChainSnapshotFromJson(json);

  ChainSnapshot withPatch(MempoolPatch p) => copyWith(mempool: p.mempool, price: p.price);
}
