// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chain_snapshot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FeeRateImpl _$$FeeRateImplFromJson(Map<String, dynamic> json) =>
    _$FeeRateImpl(
      unit: json['unit'] as String,
      median: (json['median'] as num).toDouble(),
      min: (json['min'] as num).toDouble(),
      max: (json['max'] as num).toDouble(),
    );

Map<String, dynamic> _$$FeeRateImplToJson(_$FeeRateImpl instance) =>
    <String, dynamic>{
      'unit': instance.unit,
      'median': instance.median,
      'min': instance.min,
      'max': instance.max,
    };

_$RewardImpl _$$RewardImplFromJson(Map<String, dynamic> json) => _$RewardImpl(
  subsidy: (json['subsidy'] as num).toDouble(),
  fees: (json['fees'] as num).toDouble(),
  total: (json['total'] as num).toDouble(),
);

Map<String, dynamic> _$$RewardImplToJson(_$RewardImpl instance) =>
    <String, dynamic>{
      'subsidy': instance.subsidy,
      'fees': instance.fees,
      'total': instance.total,
    };

_$PoolInfoImpl _$$PoolInfoImplFromJson(Map<String, dynamic> json) =>
    _$PoolInfoImpl(tag: json['tag'] as String?, raw: json['raw'] as String?);

Map<String, dynamic> _$$PoolInfoImplToJson(_$PoolInfoImpl instance) =>
    <String, dynamic>{'tag': instance.tag, 'raw': instance.raw};

_$ReductionInfoImpl _$$ReductionInfoImplFromJson(Map<String, dynamic> json) =>
    _$ReductionInfoImpl(
      step: (json['step'] as num).toInt(),
      cycle: (json['cycle'] as num).toInt(),
      blocksUntilNext: (json['blocksUntilNext'] as num).toInt(),
      nextHeight: (json['nextHeight'] as num).toInt(),
      fraction: (json['fraction'] as num).toDouble(),
    );

Map<String, dynamic> _$$ReductionInfoImplToJson(_$ReductionInfoImpl instance) =>
    <String, dynamic>{
      'step': instance.step,
      'cycle': instance.cycle,
      'blocksUntilNext': instance.blocksUntilNext,
      'nextHeight': instance.nextHeight,
      'fraction': instance.fraction,
    };

_$SupplyInfoImpl _$$SupplyInfoImplFromJson(Map<String, dynamic> json) =>
    _$SupplyInfoImpl(
      total: (json['total'] as num?)?.toDouble(),
      cap: (json['cap'] as num).toDouble(),
    );

Map<String, dynamic> _$$SupplyInfoImplToJson(_$SupplyInfoImpl instance) =>
    <String, dynamic>{'total': instance.total, 'cap': instance.cap};

_$AlgoShareImpl _$$AlgoShareImplFromJson(Map<String, dynamic> json) =>
    _$AlgoShareImpl(
      sha256d: (json['sha256d'] as num?)?.toDouble() ?? 0,
      scrypt: (json['scrypt'] as num?)?.toDouble() ?? 0,
      skein: (json['skein'] as num?)?.toDouble() ?? 0,
      qubit: (json['qubit'] as num?)?.toDouble() ?? 0,
      odocrypt: (json['odocrypt'] as num?)?.toDouble() ?? 0,
      blocksCounted: (json['blocksCounted'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$AlgoShareImplToJson(_$AlgoShareImpl instance) =>
    <String, dynamic>{
      'sha256d': instance.sha256d,
      'scrypt': instance.scrypt,
      'skein': instance.skein,
      'qubit': instance.qubit,
      'odocrypt': instance.odocrypt,
      'blocksCounted': instance.blocksCounted,
    };

_$BlockRefImpl _$$BlockRefImplFromJson(Map<String, dynamic> json) =>
    _$BlockRefImpl(
      height: (json['height'] as num).toInt(),
      algo: json['algo'] as String,
      sizeBytes: (json['sizeBytes'] as num).toInt(),
      txCount: (json['txCount'] as num).toInt(),
      time: (json['time'] as num).toInt(),
    );

Map<String, dynamic> _$$BlockRefImplToJson(_$BlockRefImpl instance) =>
    <String, dynamic>{
      'height': instance.height,
      'algo': instance.algo,
      'sizeBytes': instance.sizeBytes,
      'txCount': instance.txCount,
      'time': instance.time,
    };

_$FeeEstimatesImpl _$$FeeEstimatesImplFromJson(Map<String, dynamic> json) =>
    _$FeeEstimatesImpl(
      unit: json['unit'] as String,
      priority: (json['priority'] as num?)?.toDouble(),
      anytime: (json['anytime'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$FeeEstimatesImplToJson(_$FeeEstimatesImpl instance) =>
    <String, dynamic>{
      'unit': instance.unit,
      'priority': instance.priority,
      'anytime': instance.anytime,
    };

_$MempoolInfoImpl _$$MempoolInfoImplFromJson(Map<String, dynamic> json) =>
    _$MempoolInfoImpl(
      txCount: (json['txCount'] as num).toInt(),
      vbytes: (json['vbytes'] as num).toInt(),
      inflowVbPerSec: (json['inflowVbPerSec'] as num).toDouble(),
      depthBlocks: (json['depthBlocks'] as num).toDouble(),
      fees: FeeEstimates.fromJson(json['fees'] as Map<String, dynamic>),
      asOf: (json['asOf'] as num).toInt(),
    );

Map<String, dynamic> _$$MempoolInfoImplToJson(_$MempoolInfoImpl instance) =>
    <String, dynamic>{
      'txCount': instance.txCount,
      'vbytes': instance.vbytes,
      'inflowVbPerSec': instance.inflowVbPerSec,
      'depthBlocks': instance.depthBlocks,
      'fees': instance.fees.toJson(),
      'asOf': instance.asOf,
    };

_$PriceInfoImpl _$$PriceInfoImplFromJson(Map<String, dynamic> json) =>
    _$PriceInfoImpl(
      usd: (json['usd'] as num).toDouble(),
      marketCapUsd: (json['marketCapUsd'] as num?)?.toDouble(),
      asOf: (json['asOf'] as num).toInt(),
      isStale: json['isStale'] as bool? ?? false,
    );

Map<String, dynamic> _$$PriceInfoImplToJson(_$PriceInfoImpl instance) =>
    <String, dynamic>{
      'usd': instance.usd,
      'marketCapUsd': instance.marketCapUsd,
      'asOf': instance.asOf,
      'isStale': instance.isStale,
    };

_$MempoolPatchImpl _$$MempoolPatchImplFromJson(Map<String, dynamic> json) =>
    _$MempoolPatchImpl(
      height: (json['height'] as num?)?.toInt(),
      mempool:
          json['mempool'] == null
              ? null
              : MempoolInfo.fromJson(json['mempool'] as Map<String, dynamic>),
      price:
          json['price'] == null
              ? null
              : PriceInfo.fromJson(json['price'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$MempoolPatchImplToJson(_$MempoolPatchImpl instance) =>
    <String, dynamic>{
      'height': instance.height,
      'mempool': instance.mempool?.toJson(),
      'price': instance.price?.toJson(),
    };

_$ChainSnapshotImpl _$$ChainSnapshotImplFromJson(Map<String, dynamic> json) =>
    _$ChainSnapshotImpl(
      height: (json['height'] as num).toInt(),
      hash: json['hash'] as String,
      prevHash: json['prevHash'] as String?,
      time: (json['time'] as num).toInt(),
      algo: json['algo'] as String,
      sizeBytes: (json['sizeBytes'] as num).toInt(),
      txCount: (json['txCount'] as num).toInt(),
      feeRate:
          json['feeRate'] == null
              ? null
              : FeeRate.fromJson(json['feeRate'] as Map<String, dynamic>),
      reward: Reward.fromJson(json['reward'] as Map<String, dynamic>),
      pool: PoolInfo.fromJson(json['pool'] as Map<String, dynamic>),
      reduction: ReductionInfo.fromJson(
        json['reduction'] as Map<String, dynamic>,
      ),
      supply: SupplyInfo.fromJson(json['supply'] as Map<String, dynamic>),
      algoShare24h: AlgoShare.fromJson(
        json['algoShare24h'] as Map<String, dynamic>,
      ),
      recentBlocks:
          (json['recentBlocks'] as List<dynamic>)
              .map((e) => BlockRef.fromJson(e as Map<String, dynamic>))
              .toList(),
      mempool:
          json['mempool'] == null
              ? null
              : MempoolInfo.fromJson(json['mempool'] as Map<String, dynamic>),
      price:
          json['price'] == null
              ? null
              : PriceInfo.fromJson(json['price'] as Map<String, dynamic>),
      isTip: json['isTip'] as bool? ?? false,
    );

Map<String, dynamic> _$$ChainSnapshotImplToJson(_$ChainSnapshotImpl instance) =>
    <String, dynamic>{
      'height': instance.height,
      'hash': instance.hash,
      'prevHash': instance.prevHash,
      'time': instance.time,
      'algo': instance.algo,
      'sizeBytes': instance.sizeBytes,
      'txCount': instance.txCount,
      'feeRate': instance.feeRate?.toJson(),
      'reward': instance.reward.toJson(),
      'pool': instance.pool.toJson(),
      'reduction': instance.reduction.toJson(),
      'supply': instance.supply.toJson(),
      'algoShare24h': instance.algoShare24h.toJson(),
      'recentBlocks': instance.recentBlocks.map((e) => e.toJson()).toList(),
      'mempool': instance.mempool?.toJson(),
      'price': instance.price?.toJson(),
      'isTip': instance.isTip,
    };
