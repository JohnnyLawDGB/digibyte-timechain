// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chain_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FeeRate _$FeeRateFromJson(Map<String, dynamic> json) {
  return _FeeRate.fromJson(json);
}

/// @nodoc
mixin _$FeeRate {
  String get unit => throw _privateConstructorUsedError;
  double get median => throw _privateConstructorUsedError;
  double get min => throw _privateConstructorUsedError;
  double get max => throw _privateConstructorUsedError;

  /// Serializes this FeeRate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FeeRate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeeRateCopyWith<FeeRate> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeeRateCopyWith<$Res> {
  factory $FeeRateCopyWith(FeeRate value, $Res Function(FeeRate) then) =
      _$FeeRateCopyWithImpl<$Res, FeeRate>;
  @useResult
  $Res call({String unit, double median, double min, double max});
}

/// @nodoc
class _$FeeRateCopyWithImpl<$Res, $Val extends FeeRate>
    implements $FeeRateCopyWith<$Res> {
  _$FeeRateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeeRate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? unit = null,
    Object? median = null,
    Object? min = null,
    Object? max = null,
  }) {
    return _then(
      _value.copyWith(
            unit:
                null == unit
                    ? _value.unit
                    : unit // ignore: cast_nullable_to_non_nullable
                        as String,
            median:
                null == median
                    ? _value.median
                    : median // ignore: cast_nullable_to_non_nullable
                        as double,
            min:
                null == min
                    ? _value.min
                    : min // ignore: cast_nullable_to_non_nullable
                        as double,
            max:
                null == max
                    ? _value.max
                    : max // ignore: cast_nullable_to_non_nullable
                        as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FeeRateImplCopyWith<$Res> implements $FeeRateCopyWith<$Res> {
  factory _$$FeeRateImplCopyWith(
    _$FeeRateImpl value,
    $Res Function(_$FeeRateImpl) then,
  ) = __$$FeeRateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String unit, double median, double min, double max});
}

/// @nodoc
class __$$FeeRateImplCopyWithImpl<$Res>
    extends _$FeeRateCopyWithImpl<$Res, _$FeeRateImpl>
    implements _$$FeeRateImplCopyWith<$Res> {
  __$$FeeRateImplCopyWithImpl(
    _$FeeRateImpl _value,
    $Res Function(_$FeeRateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FeeRate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? unit = null,
    Object? median = null,
    Object? min = null,
    Object? max = null,
  }) {
    return _then(
      _$FeeRateImpl(
        unit:
            null == unit
                ? _value.unit
                : unit // ignore: cast_nullable_to_non_nullable
                    as String,
        median:
            null == median
                ? _value.median
                : median // ignore: cast_nullable_to_non_nullable
                    as double,
        min:
            null == min
                ? _value.min
                : min // ignore: cast_nullable_to_non_nullable
                    as double,
        max:
            null == max
                ? _value.max
                : max // ignore: cast_nullable_to_non_nullable
                    as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FeeRateImpl implements _FeeRate {
  const _$FeeRateImpl({
    required this.unit,
    required this.median,
    required this.min,
    required this.max,
  });

  factory _$FeeRateImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeeRateImplFromJson(json);

  @override
  final String unit;
  @override
  final double median;
  @override
  final double min;
  @override
  final double max;

  @override
  String toString() {
    return 'FeeRate(unit: $unit, median: $median, min: $min, max: $max)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeeRateImpl &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.median, median) || other.median == median) &&
            (identical(other.min, min) || other.min == min) &&
            (identical(other.max, max) || other.max == max));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, unit, median, min, max);

  /// Create a copy of FeeRate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeeRateImplCopyWith<_$FeeRateImpl> get copyWith =>
      __$$FeeRateImplCopyWithImpl<_$FeeRateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeeRateImplToJson(this);
  }
}

abstract class _FeeRate implements FeeRate {
  const factory _FeeRate({
    required final String unit,
    required final double median,
    required final double min,
    required final double max,
  }) = _$FeeRateImpl;

  factory _FeeRate.fromJson(Map<String, dynamic> json) = _$FeeRateImpl.fromJson;

  @override
  String get unit;
  @override
  double get median;
  @override
  double get min;
  @override
  double get max;

  /// Create a copy of FeeRate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeeRateImplCopyWith<_$FeeRateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Reward _$RewardFromJson(Map<String, dynamic> json) {
  return _Reward.fromJson(json);
}

/// @nodoc
mixin _$Reward {
  double get subsidy => throw _privateConstructorUsedError;
  double get fees => throw _privateConstructorUsedError;
  double get total => throw _privateConstructorUsedError;

  /// Serializes this Reward to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Reward
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RewardCopyWith<Reward> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RewardCopyWith<$Res> {
  factory $RewardCopyWith(Reward value, $Res Function(Reward) then) =
      _$RewardCopyWithImpl<$Res, Reward>;
  @useResult
  $Res call({double subsidy, double fees, double total});
}

/// @nodoc
class _$RewardCopyWithImpl<$Res, $Val extends Reward>
    implements $RewardCopyWith<$Res> {
  _$RewardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Reward
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subsidy = null,
    Object? fees = null,
    Object? total = null,
  }) {
    return _then(
      _value.copyWith(
            subsidy:
                null == subsidy
                    ? _value.subsidy
                    : subsidy // ignore: cast_nullable_to_non_nullable
                        as double,
            fees:
                null == fees
                    ? _value.fees
                    : fees // ignore: cast_nullable_to_non_nullable
                        as double,
            total:
                null == total
                    ? _value.total
                    : total // ignore: cast_nullable_to_non_nullable
                        as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RewardImplCopyWith<$Res> implements $RewardCopyWith<$Res> {
  factory _$$RewardImplCopyWith(
    _$RewardImpl value,
    $Res Function(_$RewardImpl) then,
  ) = __$$RewardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double subsidy, double fees, double total});
}

/// @nodoc
class __$$RewardImplCopyWithImpl<$Res>
    extends _$RewardCopyWithImpl<$Res, _$RewardImpl>
    implements _$$RewardImplCopyWith<$Res> {
  __$$RewardImplCopyWithImpl(
    _$RewardImpl _value,
    $Res Function(_$RewardImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Reward
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subsidy = null,
    Object? fees = null,
    Object? total = null,
  }) {
    return _then(
      _$RewardImpl(
        subsidy:
            null == subsidy
                ? _value.subsidy
                : subsidy // ignore: cast_nullable_to_non_nullable
                    as double,
        fees:
            null == fees
                ? _value.fees
                : fees // ignore: cast_nullable_to_non_nullable
                    as double,
        total:
            null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                    as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RewardImpl implements _Reward {
  const _$RewardImpl({
    required this.subsidy,
    required this.fees,
    required this.total,
  });

  factory _$RewardImpl.fromJson(Map<String, dynamic> json) =>
      _$$RewardImplFromJson(json);

  @override
  final double subsidy;
  @override
  final double fees;
  @override
  final double total;

  @override
  String toString() {
    return 'Reward(subsidy: $subsidy, fees: $fees, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RewardImpl &&
            (identical(other.subsidy, subsidy) || other.subsidy == subsidy) &&
            (identical(other.fees, fees) || other.fees == fees) &&
            (identical(other.total, total) || other.total == total));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, subsidy, fees, total);

  /// Create a copy of Reward
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RewardImplCopyWith<_$RewardImpl> get copyWith =>
      __$$RewardImplCopyWithImpl<_$RewardImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RewardImplToJson(this);
  }
}

abstract class _Reward implements Reward {
  const factory _Reward({
    required final double subsidy,
    required final double fees,
    required final double total,
  }) = _$RewardImpl;

  factory _Reward.fromJson(Map<String, dynamic> json) = _$RewardImpl.fromJson;

  @override
  double get subsidy;
  @override
  double get fees;
  @override
  double get total;

  /// Create a copy of Reward
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RewardImplCopyWith<_$RewardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PoolInfo _$PoolInfoFromJson(Map<String, dynamic> json) {
  return _PoolInfo.fromJson(json);
}

/// @nodoc
mixin _$PoolInfo {
  String? get tag => throw _privateConstructorUsedError;
  String? get raw => throw _privateConstructorUsedError;

  /// Serializes this PoolInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PoolInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PoolInfoCopyWith<PoolInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PoolInfoCopyWith<$Res> {
  factory $PoolInfoCopyWith(PoolInfo value, $Res Function(PoolInfo) then) =
      _$PoolInfoCopyWithImpl<$Res, PoolInfo>;
  @useResult
  $Res call({String? tag, String? raw});
}

/// @nodoc
class _$PoolInfoCopyWithImpl<$Res, $Val extends PoolInfo>
    implements $PoolInfoCopyWith<$Res> {
  _$PoolInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PoolInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? tag = freezed, Object? raw = freezed}) {
    return _then(
      _value.copyWith(
            tag:
                freezed == tag
                    ? _value.tag
                    : tag // ignore: cast_nullable_to_non_nullable
                        as String?,
            raw:
                freezed == raw
                    ? _value.raw
                    : raw // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PoolInfoImplCopyWith<$Res>
    implements $PoolInfoCopyWith<$Res> {
  factory _$$PoolInfoImplCopyWith(
    _$PoolInfoImpl value,
    $Res Function(_$PoolInfoImpl) then,
  ) = __$$PoolInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? tag, String? raw});
}

/// @nodoc
class __$$PoolInfoImplCopyWithImpl<$Res>
    extends _$PoolInfoCopyWithImpl<$Res, _$PoolInfoImpl>
    implements _$$PoolInfoImplCopyWith<$Res> {
  __$$PoolInfoImplCopyWithImpl(
    _$PoolInfoImpl _value,
    $Res Function(_$PoolInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PoolInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? tag = freezed, Object? raw = freezed}) {
    return _then(
      _$PoolInfoImpl(
        tag:
            freezed == tag
                ? _value.tag
                : tag // ignore: cast_nullable_to_non_nullable
                    as String?,
        raw:
            freezed == raw
                ? _value.raw
                : raw // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PoolInfoImpl implements _PoolInfo {
  const _$PoolInfoImpl({this.tag, this.raw});

  factory _$PoolInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PoolInfoImplFromJson(json);

  @override
  final String? tag;
  @override
  final String? raw;

  @override
  String toString() {
    return 'PoolInfo(tag: $tag, raw: $raw)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PoolInfoImpl &&
            (identical(other.tag, tag) || other.tag == tag) &&
            (identical(other.raw, raw) || other.raw == raw));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, tag, raw);

  /// Create a copy of PoolInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PoolInfoImplCopyWith<_$PoolInfoImpl> get copyWith =>
      __$$PoolInfoImplCopyWithImpl<_$PoolInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PoolInfoImplToJson(this);
  }
}

abstract class _PoolInfo implements PoolInfo {
  const factory _PoolInfo({final String? tag, final String? raw}) =
      _$PoolInfoImpl;

  factory _PoolInfo.fromJson(Map<String, dynamic> json) =
      _$PoolInfoImpl.fromJson;

  @override
  String? get tag;
  @override
  String? get raw;

  /// Create a copy of PoolInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PoolInfoImplCopyWith<_$PoolInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReductionInfo _$ReductionInfoFromJson(Map<String, dynamic> json) {
  return _ReductionInfo.fromJson(json);
}

/// @nodoc
mixin _$ReductionInfo {
  int get step => throw _privateConstructorUsedError;
  int get cycle => throw _privateConstructorUsedError;
  int get blocksUntilNext => throw _privateConstructorUsedError;
  int get nextHeight => throw _privateConstructorUsedError;
  double get fraction => throw _privateConstructorUsedError;

  /// Serializes this ReductionInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReductionInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReductionInfoCopyWith<ReductionInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReductionInfoCopyWith<$Res> {
  factory $ReductionInfoCopyWith(
    ReductionInfo value,
    $Res Function(ReductionInfo) then,
  ) = _$ReductionInfoCopyWithImpl<$Res, ReductionInfo>;
  @useResult
  $Res call({
    int step,
    int cycle,
    int blocksUntilNext,
    int nextHeight,
    double fraction,
  });
}

/// @nodoc
class _$ReductionInfoCopyWithImpl<$Res, $Val extends ReductionInfo>
    implements $ReductionInfoCopyWith<$Res> {
  _$ReductionInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReductionInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? step = null,
    Object? cycle = null,
    Object? blocksUntilNext = null,
    Object? nextHeight = null,
    Object? fraction = null,
  }) {
    return _then(
      _value.copyWith(
            step:
                null == step
                    ? _value.step
                    : step // ignore: cast_nullable_to_non_nullable
                        as int,
            cycle:
                null == cycle
                    ? _value.cycle
                    : cycle // ignore: cast_nullable_to_non_nullable
                        as int,
            blocksUntilNext:
                null == blocksUntilNext
                    ? _value.blocksUntilNext
                    : blocksUntilNext // ignore: cast_nullable_to_non_nullable
                        as int,
            nextHeight:
                null == nextHeight
                    ? _value.nextHeight
                    : nextHeight // ignore: cast_nullable_to_non_nullable
                        as int,
            fraction:
                null == fraction
                    ? _value.fraction
                    : fraction // ignore: cast_nullable_to_non_nullable
                        as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReductionInfoImplCopyWith<$Res>
    implements $ReductionInfoCopyWith<$Res> {
  factory _$$ReductionInfoImplCopyWith(
    _$ReductionInfoImpl value,
    $Res Function(_$ReductionInfoImpl) then,
  ) = __$$ReductionInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int step,
    int cycle,
    int blocksUntilNext,
    int nextHeight,
    double fraction,
  });
}

/// @nodoc
class __$$ReductionInfoImplCopyWithImpl<$Res>
    extends _$ReductionInfoCopyWithImpl<$Res, _$ReductionInfoImpl>
    implements _$$ReductionInfoImplCopyWith<$Res> {
  __$$ReductionInfoImplCopyWithImpl(
    _$ReductionInfoImpl _value,
    $Res Function(_$ReductionInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReductionInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? step = null,
    Object? cycle = null,
    Object? blocksUntilNext = null,
    Object? nextHeight = null,
    Object? fraction = null,
  }) {
    return _then(
      _$ReductionInfoImpl(
        step:
            null == step
                ? _value.step
                : step // ignore: cast_nullable_to_non_nullable
                    as int,
        cycle:
            null == cycle
                ? _value.cycle
                : cycle // ignore: cast_nullable_to_non_nullable
                    as int,
        blocksUntilNext:
            null == blocksUntilNext
                ? _value.blocksUntilNext
                : blocksUntilNext // ignore: cast_nullable_to_non_nullable
                    as int,
        nextHeight:
            null == nextHeight
                ? _value.nextHeight
                : nextHeight // ignore: cast_nullable_to_non_nullable
                    as int,
        fraction:
            null == fraction
                ? _value.fraction
                : fraction // ignore: cast_nullable_to_non_nullable
                    as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReductionInfoImpl implements _ReductionInfo {
  const _$ReductionInfoImpl({
    required this.step,
    required this.cycle,
    required this.blocksUntilNext,
    required this.nextHeight,
    required this.fraction,
  });

  factory _$ReductionInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReductionInfoImplFromJson(json);

  @override
  final int step;
  @override
  final int cycle;
  @override
  final int blocksUntilNext;
  @override
  final int nextHeight;
  @override
  final double fraction;

  @override
  String toString() {
    return 'ReductionInfo(step: $step, cycle: $cycle, blocksUntilNext: $blocksUntilNext, nextHeight: $nextHeight, fraction: $fraction)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReductionInfoImpl &&
            (identical(other.step, step) || other.step == step) &&
            (identical(other.cycle, cycle) || other.cycle == cycle) &&
            (identical(other.blocksUntilNext, blocksUntilNext) ||
                other.blocksUntilNext == blocksUntilNext) &&
            (identical(other.nextHeight, nextHeight) ||
                other.nextHeight == nextHeight) &&
            (identical(other.fraction, fraction) ||
                other.fraction == fraction));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    step,
    cycle,
    blocksUntilNext,
    nextHeight,
    fraction,
  );

  /// Create a copy of ReductionInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReductionInfoImplCopyWith<_$ReductionInfoImpl> get copyWith =>
      __$$ReductionInfoImplCopyWithImpl<_$ReductionInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReductionInfoImplToJson(this);
  }
}

abstract class _ReductionInfo implements ReductionInfo {
  const factory _ReductionInfo({
    required final int step,
    required final int cycle,
    required final int blocksUntilNext,
    required final int nextHeight,
    required final double fraction,
  }) = _$ReductionInfoImpl;

  factory _ReductionInfo.fromJson(Map<String, dynamic> json) =
      _$ReductionInfoImpl.fromJson;

  @override
  int get step;
  @override
  int get cycle;
  @override
  int get blocksUntilNext;
  @override
  int get nextHeight;
  @override
  double get fraction;

  /// Create a copy of ReductionInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReductionInfoImplCopyWith<_$ReductionInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SupplyInfo _$SupplyInfoFromJson(Map<String, dynamic> json) {
  return _SupplyInfo.fromJson(json);
}

/// @nodoc
mixin _$SupplyInfo {
  double? get total => throw _privateConstructorUsedError;
  double get cap => throw _privateConstructorUsedError;

  /// Serializes this SupplyInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SupplyInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SupplyInfoCopyWith<SupplyInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SupplyInfoCopyWith<$Res> {
  factory $SupplyInfoCopyWith(
    SupplyInfo value,
    $Res Function(SupplyInfo) then,
  ) = _$SupplyInfoCopyWithImpl<$Res, SupplyInfo>;
  @useResult
  $Res call({double? total, double cap});
}

/// @nodoc
class _$SupplyInfoCopyWithImpl<$Res, $Val extends SupplyInfo>
    implements $SupplyInfoCopyWith<$Res> {
  _$SupplyInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SupplyInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? total = freezed, Object? cap = null}) {
    return _then(
      _value.copyWith(
            total:
                freezed == total
                    ? _value.total
                    : total // ignore: cast_nullable_to_non_nullable
                        as double?,
            cap:
                null == cap
                    ? _value.cap
                    : cap // ignore: cast_nullable_to_non_nullable
                        as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SupplyInfoImplCopyWith<$Res>
    implements $SupplyInfoCopyWith<$Res> {
  factory _$$SupplyInfoImplCopyWith(
    _$SupplyInfoImpl value,
    $Res Function(_$SupplyInfoImpl) then,
  ) = __$$SupplyInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double? total, double cap});
}

/// @nodoc
class __$$SupplyInfoImplCopyWithImpl<$Res>
    extends _$SupplyInfoCopyWithImpl<$Res, _$SupplyInfoImpl>
    implements _$$SupplyInfoImplCopyWith<$Res> {
  __$$SupplyInfoImplCopyWithImpl(
    _$SupplyInfoImpl _value,
    $Res Function(_$SupplyInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SupplyInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? total = freezed, Object? cap = null}) {
    return _then(
      _$SupplyInfoImpl(
        total:
            freezed == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                    as double?,
        cap:
            null == cap
                ? _value.cap
                : cap // ignore: cast_nullable_to_non_nullable
                    as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SupplyInfoImpl implements _SupplyInfo {
  const _$SupplyInfoImpl({this.total, required this.cap});

  factory _$SupplyInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SupplyInfoImplFromJson(json);

  @override
  final double? total;
  @override
  final double cap;

  @override
  String toString() {
    return 'SupplyInfo(total: $total, cap: $cap)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SupplyInfoImpl &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.cap, cap) || other.cap == cap));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, total, cap);

  /// Create a copy of SupplyInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SupplyInfoImplCopyWith<_$SupplyInfoImpl> get copyWith =>
      __$$SupplyInfoImplCopyWithImpl<_$SupplyInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SupplyInfoImplToJson(this);
  }
}

abstract class _SupplyInfo implements SupplyInfo {
  const factory _SupplyInfo({final double? total, required final double cap}) =
      _$SupplyInfoImpl;

  factory _SupplyInfo.fromJson(Map<String, dynamic> json) =
      _$SupplyInfoImpl.fromJson;

  @override
  double? get total;
  @override
  double get cap;

  /// Create a copy of SupplyInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SupplyInfoImplCopyWith<_$SupplyInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AlgoShare _$AlgoShareFromJson(Map<String, dynamic> json) {
  return _AlgoShare.fromJson(json);
}

/// @nodoc
mixin _$AlgoShare {
  double get sha256d => throw _privateConstructorUsedError;
  double get scrypt => throw _privateConstructorUsedError;
  double get skein => throw _privateConstructorUsedError;
  double get qubit => throw _privateConstructorUsedError;
  double get odocrypt => throw _privateConstructorUsedError;
  int get blocksCounted => throw _privateConstructorUsedError;

  /// Serializes this AlgoShare to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AlgoShare
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AlgoShareCopyWith<AlgoShare> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AlgoShareCopyWith<$Res> {
  factory $AlgoShareCopyWith(AlgoShare value, $Res Function(AlgoShare) then) =
      _$AlgoShareCopyWithImpl<$Res, AlgoShare>;
  @useResult
  $Res call({
    double sha256d,
    double scrypt,
    double skein,
    double qubit,
    double odocrypt,
    int blocksCounted,
  });
}

/// @nodoc
class _$AlgoShareCopyWithImpl<$Res, $Val extends AlgoShare>
    implements $AlgoShareCopyWith<$Res> {
  _$AlgoShareCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AlgoShare
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sha256d = null,
    Object? scrypt = null,
    Object? skein = null,
    Object? qubit = null,
    Object? odocrypt = null,
    Object? blocksCounted = null,
  }) {
    return _then(
      _value.copyWith(
            sha256d:
                null == sha256d
                    ? _value.sha256d
                    : sha256d // ignore: cast_nullable_to_non_nullable
                        as double,
            scrypt:
                null == scrypt
                    ? _value.scrypt
                    : scrypt // ignore: cast_nullable_to_non_nullable
                        as double,
            skein:
                null == skein
                    ? _value.skein
                    : skein // ignore: cast_nullable_to_non_nullable
                        as double,
            qubit:
                null == qubit
                    ? _value.qubit
                    : qubit // ignore: cast_nullable_to_non_nullable
                        as double,
            odocrypt:
                null == odocrypt
                    ? _value.odocrypt
                    : odocrypt // ignore: cast_nullable_to_non_nullable
                        as double,
            blocksCounted:
                null == blocksCounted
                    ? _value.blocksCounted
                    : blocksCounted // ignore: cast_nullable_to_non_nullable
                        as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AlgoShareImplCopyWith<$Res>
    implements $AlgoShareCopyWith<$Res> {
  factory _$$AlgoShareImplCopyWith(
    _$AlgoShareImpl value,
    $Res Function(_$AlgoShareImpl) then,
  ) = __$$AlgoShareImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double sha256d,
    double scrypt,
    double skein,
    double qubit,
    double odocrypt,
    int blocksCounted,
  });
}

/// @nodoc
class __$$AlgoShareImplCopyWithImpl<$Res>
    extends _$AlgoShareCopyWithImpl<$Res, _$AlgoShareImpl>
    implements _$$AlgoShareImplCopyWith<$Res> {
  __$$AlgoShareImplCopyWithImpl(
    _$AlgoShareImpl _value,
    $Res Function(_$AlgoShareImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AlgoShare
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sha256d = null,
    Object? scrypt = null,
    Object? skein = null,
    Object? qubit = null,
    Object? odocrypt = null,
    Object? blocksCounted = null,
  }) {
    return _then(
      _$AlgoShareImpl(
        sha256d:
            null == sha256d
                ? _value.sha256d
                : sha256d // ignore: cast_nullable_to_non_nullable
                    as double,
        scrypt:
            null == scrypt
                ? _value.scrypt
                : scrypt // ignore: cast_nullable_to_non_nullable
                    as double,
        skein:
            null == skein
                ? _value.skein
                : skein // ignore: cast_nullable_to_non_nullable
                    as double,
        qubit:
            null == qubit
                ? _value.qubit
                : qubit // ignore: cast_nullable_to_non_nullable
                    as double,
        odocrypt:
            null == odocrypt
                ? _value.odocrypt
                : odocrypt // ignore: cast_nullable_to_non_nullable
                    as double,
        blocksCounted:
            null == blocksCounted
                ? _value.blocksCounted
                : blocksCounted // ignore: cast_nullable_to_non_nullable
                    as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AlgoShareImpl extends _AlgoShare {
  const _$AlgoShareImpl({
    this.sha256d = 0,
    this.scrypt = 0,
    this.skein = 0,
    this.qubit = 0,
    this.odocrypt = 0,
    this.blocksCounted = 0,
  }) : super._();

  factory _$AlgoShareImpl.fromJson(Map<String, dynamic> json) =>
      _$$AlgoShareImplFromJson(json);

  @override
  @JsonKey()
  final double sha256d;
  @override
  @JsonKey()
  final double scrypt;
  @override
  @JsonKey()
  final double skein;
  @override
  @JsonKey()
  final double qubit;
  @override
  @JsonKey()
  final double odocrypt;
  @override
  @JsonKey()
  final int blocksCounted;

  @override
  String toString() {
    return 'AlgoShare(sha256d: $sha256d, scrypt: $scrypt, skein: $skein, qubit: $qubit, odocrypt: $odocrypt, blocksCounted: $blocksCounted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AlgoShareImpl &&
            (identical(other.sha256d, sha256d) || other.sha256d == sha256d) &&
            (identical(other.scrypt, scrypt) || other.scrypt == scrypt) &&
            (identical(other.skein, skein) || other.skein == skein) &&
            (identical(other.qubit, qubit) || other.qubit == qubit) &&
            (identical(other.odocrypt, odocrypt) ||
                other.odocrypt == odocrypt) &&
            (identical(other.blocksCounted, blocksCounted) ||
                other.blocksCounted == blocksCounted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    sha256d,
    scrypt,
    skein,
    qubit,
    odocrypt,
    blocksCounted,
  );

  /// Create a copy of AlgoShare
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AlgoShareImplCopyWith<_$AlgoShareImpl> get copyWith =>
      __$$AlgoShareImplCopyWithImpl<_$AlgoShareImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AlgoShareImplToJson(this);
  }
}

abstract class _AlgoShare extends AlgoShare {
  const factory _AlgoShare({
    final double sha256d,
    final double scrypt,
    final double skein,
    final double qubit,
    final double odocrypt,
    final int blocksCounted,
  }) = _$AlgoShareImpl;
  const _AlgoShare._() : super._();

  factory _AlgoShare.fromJson(Map<String, dynamic> json) =
      _$AlgoShareImpl.fromJson;

  @override
  double get sha256d;
  @override
  double get scrypt;
  @override
  double get skein;
  @override
  double get qubit;
  @override
  double get odocrypt;
  @override
  int get blocksCounted;

  /// Create a copy of AlgoShare
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AlgoShareImplCopyWith<_$AlgoShareImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BlockRef _$BlockRefFromJson(Map<String, dynamic> json) {
  return _BlockRef.fromJson(json);
}

/// @nodoc
mixin _$BlockRef {
  int get height => throw _privateConstructorUsedError;
  String get algo => throw _privateConstructorUsedError;
  int get sizeBytes => throw _privateConstructorUsedError;
  int get txCount => throw _privateConstructorUsedError;
  int get time => throw _privateConstructorUsedError;

  /// Serializes this BlockRef to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BlockRef
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BlockRefCopyWith<BlockRef> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BlockRefCopyWith<$Res> {
  factory $BlockRefCopyWith(BlockRef value, $Res Function(BlockRef) then) =
      _$BlockRefCopyWithImpl<$Res, BlockRef>;
  @useResult
  $Res call({int height, String algo, int sizeBytes, int txCount, int time});
}

/// @nodoc
class _$BlockRefCopyWithImpl<$Res, $Val extends BlockRef>
    implements $BlockRefCopyWith<$Res> {
  _$BlockRefCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BlockRef
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? height = null,
    Object? algo = null,
    Object? sizeBytes = null,
    Object? txCount = null,
    Object? time = null,
  }) {
    return _then(
      _value.copyWith(
            height:
                null == height
                    ? _value.height
                    : height // ignore: cast_nullable_to_non_nullable
                        as int,
            algo:
                null == algo
                    ? _value.algo
                    : algo // ignore: cast_nullable_to_non_nullable
                        as String,
            sizeBytes:
                null == sizeBytes
                    ? _value.sizeBytes
                    : sizeBytes // ignore: cast_nullable_to_non_nullable
                        as int,
            txCount:
                null == txCount
                    ? _value.txCount
                    : txCount // ignore: cast_nullable_to_non_nullable
                        as int,
            time:
                null == time
                    ? _value.time
                    : time // ignore: cast_nullable_to_non_nullable
                        as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BlockRefImplCopyWith<$Res>
    implements $BlockRefCopyWith<$Res> {
  factory _$$BlockRefImplCopyWith(
    _$BlockRefImpl value,
    $Res Function(_$BlockRefImpl) then,
  ) = __$$BlockRefImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int height, String algo, int sizeBytes, int txCount, int time});
}

/// @nodoc
class __$$BlockRefImplCopyWithImpl<$Res>
    extends _$BlockRefCopyWithImpl<$Res, _$BlockRefImpl>
    implements _$$BlockRefImplCopyWith<$Res> {
  __$$BlockRefImplCopyWithImpl(
    _$BlockRefImpl _value,
    $Res Function(_$BlockRefImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BlockRef
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? height = null,
    Object? algo = null,
    Object? sizeBytes = null,
    Object? txCount = null,
    Object? time = null,
  }) {
    return _then(
      _$BlockRefImpl(
        height:
            null == height
                ? _value.height
                : height // ignore: cast_nullable_to_non_nullable
                    as int,
        algo:
            null == algo
                ? _value.algo
                : algo // ignore: cast_nullable_to_non_nullable
                    as String,
        sizeBytes:
            null == sizeBytes
                ? _value.sizeBytes
                : sizeBytes // ignore: cast_nullable_to_non_nullable
                    as int,
        txCount:
            null == txCount
                ? _value.txCount
                : txCount // ignore: cast_nullable_to_non_nullable
                    as int,
        time:
            null == time
                ? _value.time
                : time // ignore: cast_nullable_to_non_nullable
                    as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BlockRefImpl implements _BlockRef {
  const _$BlockRefImpl({
    required this.height,
    required this.algo,
    required this.sizeBytes,
    required this.txCount,
    required this.time,
  });

  factory _$BlockRefImpl.fromJson(Map<String, dynamic> json) =>
      _$$BlockRefImplFromJson(json);

  @override
  final int height;
  @override
  final String algo;
  @override
  final int sizeBytes;
  @override
  final int txCount;
  @override
  final int time;

  @override
  String toString() {
    return 'BlockRef(height: $height, algo: $algo, sizeBytes: $sizeBytes, txCount: $txCount, time: $time)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BlockRefImpl &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.algo, algo) || other.algo == algo) &&
            (identical(other.sizeBytes, sizeBytes) ||
                other.sizeBytes == sizeBytes) &&
            (identical(other.txCount, txCount) || other.txCount == txCount) &&
            (identical(other.time, time) || other.time == time));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, height, algo, sizeBytes, txCount, time);

  /// Create a copy of BlockRef
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BlockRefImplCopyWith<_$BlockRefImpl> get copyWith =>
      __$$BlockRefImplCopyWithImpl<_$BlockRefImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BlockRefImplToJson(this);
  }
}

abstract class _BlockRef implements BlockRef {
  const factory _BlockRef({
    required final int height,
    required final String algo,
    required final int sizeBytes,
    required final int txCount,
    required final int time,
  }) = _$BlockRefImpl;

  factory _BlockRef.fromJson(Map<String, dynamic> json) =
      _$BlockRefImpl.fromJson;

  @override
  int get height;
  @override
  String get algo;
  @override
  int get sizeBytes;
  @override
  int get txCount;
  @override
  int get time;

  /// Create a copy of BlockRef
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BlockRefImplCopyWith<_$BlockRefImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FeeEstimates _$FeeEstimatesFromJson(Map<String, dynamic> json) {
  return _FeeEstimates.fromJson(json);
}

/// @nodoc
mixin _$FeeEstimates {
  String get unit => throw _privateConstructorUsedError;
  double? get priority => throw _privateConstructorUsedError;
  double? get anytime => throw _privateConstructorUsedError;

  /// Serializes this FeeEstimates to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FeeEstimates
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeeEstimatesCopyWith<FeeEstimates> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeeEstimatesCopyWith<$Res> {
  factory $FeeEstimatesCopyWith(
    FeeEstimates value,
    $Res Function(FeeEstimates) then,
  ) = _$FeeEstimatesCopyWithImpl<$Res, FeeEstimates>;
  @useResult
  $Res call({String unit, double? priority, double? anytime});
}

/// @nodoc
class _$FeeEstimatesCopyWithImpl<$Res, $Val extends FeeEstimates>
    implements $FeeEstimatesCopyWith<$Res> {
  _$FeeEstimatesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeeEstimates
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? unit = null,
    Object? priority = freezed,
    Object? anytime = freezed,
  }) {
    return _then(
      _value.copyWith(
            unit:
                null == unit
                    ? _value.unit
                    : unit // ignore: cast_nullable_to_non_nullable
                        as String,
            priority:
                freezed == priority
                    ? _value.priority
                    : priority // ignore: cast_nullable_to_non_nullable
                        as double?,
            anytime:
                freezed == anytime
                    ? _value.anytime
                    : anytime // ignore: cast_nullable_to_non_nullable
                        as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FeeEstimatesImplCopyWith<$Res>
    implements $FeeEstimatesCopyWith<$Res> {
  factory _$$FeeEstimatesImplCopyWith(
    _$FeeEstimatesImpl value,
    $Res Function(_$FeeEstimatesImpl) then,
  ) = __$$FeeEstimatesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String unit, double? priority, double? anytime});
}

/// @nodoc
class __$$FeeEstimatesImplCopyWithImpl<$Res>
    extends _$FeeEstimatesCopyWithImpl<$Res, _$FeeEstimatesImpl>
    implements _$$FeeEstimatesImplCopyWith<$Res> {
  __$$FeeEstimatesImplCopyWithImpl(
    _$FeeEstimatesImpl _value,
    $Res Function(_$FeeEstimatesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FeeEstimates
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? unit = null,
    Object? priority = freezed,
    Object? anytime = freezed,
  }) {
    return _then(
      _$FeeEstimatesImpl(
        unit:
            null == unit
                ? _value.unit
                : unit // ignore: cast_nullable_to_non_nullable
                    as String,
        priority:
            freezed == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                    as double?,
        anytime:
            freezed == anytime
                ? _value.anytime
                : anytime // ignore: cast_nullable_to_non_nullable
                    as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FeeEstimatesImpl implements _FeeEstimates {
  const _$FeeEstimatesImpl({required this.unit, this.priority, this.anytime});

  factory _$FeeEstimatesImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeeEstimatesImplFromJson(json);

  @override
  final String unit;
  @override
  final double? priority;
  @override
  final double? anytime;

  @override
  String toString() {
    return 'FeeEstimates(unit: $unit, priority: $priority, anytime: $anytime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeeEstimatesImpl &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.anytime, anytime) || other.anytime == anytime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, unit, priority, anytime);

  /// Create a copy of FeeEstimates
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeeEstimatesImplCopyWith<_$FeeEstimatesImpl> get copyWith =>
      __$$FeeEstimatesImplCopyWithImpl<_$FeeEstimatesImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeeEstimatesImplToJson(this);
  }
}

abstract class _FeeEstimates implements FeeEstimates {
  const factory _FeeEstimates({
    required final String unit,
    final double? priority,
    final double? anytime,
  }) = _$FeeEstimatesImpl;

  factory _FeeEstimates.fromJson(Map<String, dynamic> json) =
      _$FeeEstimatesImpl.fromJson;

  @override
  String get unit;
  @override
  double? get priority;
  @override
  double? get anytime;

  /// Create a copy of FeeEstimates
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeeEstimatesImplCopyWith<_$FeeEstimatesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MempoolInfo _$MempoolInfoFromJson(Map<String, dynamic> json) {
  return _MempoolInfo.fromJson(json);
}

/// @nodoc
mixin _$MempoolInfo {
  int get txCount => throw _privateConstructorUsedError;
  int get vbytes => throw _privateConstructorUsedError;
  double get inflowVbPerSec => throw _privateConstructorUsedError;
  double get depthBlocks => throw _privateConstructorUsedError;
  FeeEstimates get fees => throw _privateConstructorUsedError;
  int get asOf => throw _privateConstructorUsedError;

  /// Serializes this MempoolInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MempoolInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MempoolInfoCopyWith<MempoolInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MempoolInfoCopyWith<$Res> {
  factory $MempoolInfoCopyWith(
    MempoolInfo value,
    $Res Function(MempoolInfo) then,
  ) = _$MempoolInfoCopyWithImpl<$Res, MempoolInfo>;
  @useResult
  $Res call({
    int txCount,
    int vbytes,
    double inflowVbPerSec,
    double depthBlocks,
    FeeEstimates fees,
    int asOf,
  });

  $FeeEstimatesCopyWith<$Res> get fees;
}

/// @nodoc
class _$MempoolInfoCopyWithImpl<$Res, $Val extends MempoolInfo>
    implements $MempoolInfoCopyWith<$Res> {
  _$MempoolInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MempoolInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? txCount = null,
    Object? vbytes = null,
    Object? inflowVbPerSec = null,
    Object? depthBlocks = null,
    Object? fees = null,
    Object? asOf = null,
  }) {
    return _then(
      _value.copyWith(
            txCount:
                null == txCount
                    ? _value.txCount
                    : txCount // ignore: cast_nullable_to_non_nullable
                        as int,
            vbytes:
                null == vbytes
                    ? _value.vbytes
                    : vbytes // ignore: cast_nullable_to_non_nullable
                        as int,
            inflowVbPerSec:
                null == inflowVbPerSec
                    ? _value.inflowVbPerSec
                    : inflowVbPerSec // ignore: cast_nullable_to_non_nullable
                        as double,
            depthBlocks:
                null == depthBlocks
                    ? _value.depthBlocks
                    : depthBlocks // ignore: cast_nullable_to_non_nullable
                        as double,
            fees:
                null == fees
                    ? _value.fees
                    : fees // ignore: cast_nullable_to_non_nullable
                        as FeeEstimates,
            asOf:
                null == asOf
                    ? _value.asOf
                    : asOf // ignore: cast_nullable_to_non_nullable
                        as int,
          )
          as $Val,
    );
  }

  /// Create a copy of MempoolInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FeeEstimatesCopyWith<$Res> get fees {
    return $FeeEstimatesCopyWith<$Res>(_value.fees, (value) {
      return _then(_value.copyWith(fees: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MempoolInfoImplCopyWith<$Res>
    implements $MempoolInfoCopyWith<$Res> {
  factory _$$MempoolInfoImplCopyWith(
    _$MempoolInfoImpl value,
    $Res Function(_$MempoolInfoImpl) then,
  ) = __$$MempoolInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int txCount,
    int vbytes,
    double inflowVbPerSec,
    double depthBlocks,
    FeeEstimates fees,
    int asOf,
  });

  @override
  $FeeEstimatesCopyWith<$Res> get fees;
}

/// @nodoc
class __$$MempoolInfoImplCopyWithImpl<$Res>
    extends _$MempoolInfoCopyWithImpl<$Res, _$MempoolInfoImpl>
    implements _$$MempoolInfoImplCopyWith<$Res> {
  __$$MempoolInfoImplCopyWithImpl(
    _$MempoolInfoImpl _value,
    $Res Function(_$MempoolInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MempoolInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? txCount = null,
    Object? vbytes = null,
    Object? inflowVbPerSec = null,
    Object? depthBlocks = null,
    Object? fees = null,
    Object? asOf = null,
  }) {
    return _then(
      _$MempoolInfoImpl(
        txCount:
            null == txCount
                ? _value.txCount
                : txCount // ignore: cast_nullable_to_non_nullable
                    as int,
        vbytes:
            null == vbytes
                ? _value.vbytes
                : vbytes // ignore: cast_nullable_to_non_nullable
                    as int,
        inflowVbPerSec:
            null == inflowVbPerSec
                ? _value.inflowVbPerSec
                : inflowVbPerSec // ignore: cast_nullable_to_non_nullable
                    as double,
        depthBlocks:
            null == depthBlocks
                ? _value.depthBlocks
                : depthBlocks // ignore: cast_nullable_to_non_nullable
                    as double,
        fees:
            null == fees
                ? _value.fees
                : fees // ignore: cast_nullable_to_non_nullable
                    as FeeEstimates,
        asOf:
            null == asOf
                ? _value.asOf
                : asOf // ignore: cast_nullable_to_non_nullable
                    as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MempoolInfoImpl implements _MempoolInfo {
  const _$MempoolInfoImpl({
    required this.txCount,
    required this.vbytes,
    required this.inflowVbPerSec,
    required this.depthBlocks,
    required this.fees,
    required this.asOf,
  });

  factory _$MempoolInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$MempoolInfoImplFromJson(json);

  @override
  final int txCount;
  @override
  final int vbytes;
  @override
  final double inflowVbPerSec;
  @override
  final double depthBlocks;
  @override
  final FeeEstimates fees;
  @override
  final int asOf;

  @override
  String toString() {
    return 'MempoolInfo(txCount: $txCount, vbytes: $vbytes, inflowVbPerSec: $inflowVbPerSec, depthBlocks: $depthBlocks, fees: $fees, asOf: $asOf)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MempoolInfoImpl &&
            (identical(other.txCount, txCount) || other.txCount == txCount) &&
            (identical(other.vbytes, vbytes) || other.vbytes == vbytes) &&
            (identical(other.inflowVbPerSec, inflowVbPerSec) ||
                other.inflowVbPerSec == inflowVbPerSec) &&
            (identical(other.depthBlocks, depthBlocks) ||
                other.depthBlocks == depthBlocks) &&
            (identical(other.fees, fees) || other.fees == fees) &&
            (identical(other.asOf, asOf) || other.asOf == asOf));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    txCount,
    vbytes,
    inflowVbPerSec,
    depthBlocks,
    fees,
    asOf,
  );

  /// Create a copy of MempoolInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MempoolInfoImplCopyWith<_$MempoolInfoImpl> get copyWith =>
      __$$MempoolInfoImplCopyWithImpl<_$MempoolInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MempoolInfoImplToJson(this);
  }
}

abstract class _MempoolInfo implements MempoolInfo {
  const factory _MempoolInfo({
    required final int txCount,
    required final int vbytes,
    required final double inflowVbPerSec,
    required final double depthBlocks,
    required final FeeEstimates fees,
    required final int asOf,
  }) = _$MempoolInfoImpl;

  factory _MempoolInfo.fromJson(Map<String, dynamic> json) =
      _$MempoolInfoImpl.fromJson;

  @override
  int get txCount;
  @override
  int get vbytes;
  @override
  double get inflowVbPerSec;
  @override
  double get depthBlocks;
  @override
  FeeEstimates get fees;
  @override
  int get asOf;

  /// Create a copy of MempoolInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MempoolInfoImplCopyWith<_$MempoolInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PriceInfo _$PriceInfoFromJson(Map<String, dynamic> json) {
  return _PriceInfo.fromJson(json);
}

/// @nodoc
mixin _$PriceInfo {
  double get usd => throw _privateConstructorUsedError;
  double? get marketCapUsd => throw _privateConstructorUsedError;
  int get asOf => throw _privateConstructorUsedError;
  bool get isStale => throw _privateConstructorUsedError;

  /// Serializes this PriceInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PriceInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PriceInfoCopyWith<PriceInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PriceInfoCopyWith<$Res> {
  factory $PriceInfoCopyWith(PriceInfo value, $Res Function(PriceInfo) then) =
      _$PriceInfoCopyWithImpl<$Res, PriceInfo>;
  @useResult
  $Res call({double usd, double? marketCapUsd, int asOf, bool isStale});
}

/// @nodoc
class _$PriceInfoCopyWithImpl<$Res, $Val extends PriceInfo>
    implements $PriceInfoCopyWith<$Res> {
  _$PriceInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PriceInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? usd = null,
    Object? marketCapUsd = freezed,
    Object? asOf = null,
    Object? isStale = null,
  }) {
    return _then(
      _value.copyWith(
            usd:
                null == usd
                    ? _value.usd
                    : usd // ignore: cast_nullable_to_non_nullable
                        as double,
            marketCapUsd:
                freezed == marketCapUsd
                    ? _value.marketCapUsd
                    : marketCapUsd // ignore: cast_nullable_to_non_nullable
                        as double?,
            asOf:
                null == asOf
                    ? _value.asOf
                    : asOf // ignore: cast_nullable_to_non_nullable
                        as int,
            isStale:
                null == isStale
                    ? _value.isStale
                    : isStale // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PriceInfoImplCopyWith<$Res>
    implements $PriceInfoCopyWith<$Res> {
  factory _$$PriceInfoImplCopyWith(
    _$PriceInfoImpl value,
    $Res Function(_$PriceInfoImpl) then,
  ) = __$$PriceInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double usd, double? marketCapUsd, int asOf, bool isStale});
}

/// @nodoc
class __$$PriceInfoImplCopyWithImpl<$Res>
    extends _$PriceInfoCopyWithImpl<$Res, _$PriceInfoImpl>
    implements _$$PriceInfoImplCopyWith<$Res> {
  __$$PriceInfoImplCopyWithImpl(
    _$PriceInfoImpl _value,
    $Res Function(_$PriceInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PriceInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? usd = null,
    Object? marketCapUsd = freezed,
    Object? asOf = null,
    Object? isStale = null,
  }) {
    return _then(
      _$PriceInfoImpl(
        usd:
            null == usd
                ? _value.usd
                : usd // ignore: cast_nullable_to_non_nullable
                    as double,
        marketCapUsd:
            freezed == marketCapUsd
                ? _value.marketCapUsd
                : marketCapUsd // ignore: cast_nullable_to_non_nullable
                    as double?,
        asOf:
            null == asOf
                ? _value.asOf
                : asOf // ignore: cast_nullable_to_non_nullable
                    as int,
        isStale:
            null == isStale
                ? _value.isStale
                : isStale // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PriceInfoImpl implements _PriceInfo {
  const _$PriceInfoImpl({
    required this.usd,
    this.marketCapUsd,
    required this.asOf,
    this.isStale = false,
  });

  factory _$PriceInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PriceInfoImplFromJson(json);

  @override
  final double usd;
  @override
  final double? marketCapUsd;
  @override
  final int asOf;
  @override
  @JsonKey()
  final bool isStale;

  @override
  String toString() {
    return 'PriceInfo(usd: $usd, marketCapUsd: $marketCapUsd, asOf: $asOf, isStale: $isStale)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PriceInfoImpl &&
            (identical(other.usd, usd) || other.usd == usd) &&
            (identical(other.marketCapUsd, marketCapUsd) ||
                other.marketCapUsd == marketCapUsd) &&
            (identical(other.asOf, asOf) || other.asOf == asOf) &&
            (identical(other.isStale, isStale) || other.isStale == isStale));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, usd, marketCapUsd, asOf, isStale);

  /// Create a copy of PriceInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PriceInfoImplCopyWith<_$PriceInfoImpl> get copyWith =>
      __$$PriceInfoImplCopyWithImpl<_$PriceInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PriceInfoImplToJson(this);
  }
}

abstract class _PriceInfo implements PriceInfo {
  const factory _PriceInfo({
    required final double usd,
    final double? marketCapUsd,
    required final int asOf,
    final bool isStale,
  }) = _$PriceInfoImpl;

  factory _PriceInfo.fromJson(Map<String, dynamic> json) =
      _$PriceInfoImpl.fromJson;

  @override
  double get usd;
  @override
  double? get marketCapUsd;
  @override
  int get asOf;
  @override
  bool get isStale;

  /// Create a copy of PriceInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PriceInfoImplCopyWith<_$PriceInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MempoolPatch _$MempoolPatchFromJson(Map<String, dynamic> json) {
  return _MempoolPatch.fromJson(json);
}

/// @nodoc
mixin _$MempoolPatch {
  int? get height => throw _privateConstructorUsedError;
  MempoolInfo? get mempool => throw _privateConstructorUsedError;
  PriceInfo? get price => throw _privateConstructorUsedError;

  /// Serializes this MempoolPatch to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MempoolPatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MempoolPatchCopyWith<MempoolPatch> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MempoolPatchCopyWith<$Res> {
  factory $MempoolPatchCopyWith(
    MempoolPatch value,
    $Res Function(MempoolPatch) then,
  ) = _$MempoolPatchCopyWithImpl<$Res, MempoolPatch>;
  @useResult
  $Res call({int? height, MempoolInfo? mempool, PriceInfo? price});

  $MempoolInfoCopyWith<$Res>? get mempool;
  $PriceInfoCopyWith<$Res>? get price;
}

/// @nodoc
class _$MempoolPatchCopyWithImpl<$Res, $Val extends MempoolPatch>
    implements $MempoolPatchCopyWith<$Res> {
  _$MempoolPatchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MempoolPatch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? height = freezed,
    Object? mempool = freezed,
    Object? price = freezed,
  }) {
    return _then(
      _value.copyWith(
            height:
                freezed == height
                    ? _value.height
                    : height // ignore: cast_nullable_to_non_nullable
                        as int?,
            mempool:
                freezed == mempool
                    ? _value.mempool
                    : mempool // ignore: cast_nullable_to_non_nullable
                        as MempoolInfo?,
            price:
                freezed == price
                    ? _value.price
                    : price // ignore: cast_nullable_to_non_nullable
                        as PriceInfo?,
          )
          as $Val,
    );
  }

  /// Create a copy of MempoolPatch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MempoolInfoCopyWith<$Res>? get mempool {
    if (_value.mempool == null) {
      return null;
    }

    return $MempoolInfoCopyWith<$Res>(_value.mempool!, (value) {
      return _then(_value.copyWith(mempool: value) as $Val);
    });
  }

  /// Create a copy of MempoolPatch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PriceInfoCopyWith<$Res>? get price {
    if (_value.price == null) {
      return null;
    }

    return $PriceInfoCopyWith<$Res>(_value.price!, (value) {
      return _then(_value.copyWith(price: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MempoolPatchImplCopyWith<$Res>
    implements $MempoolPatchCopyWith<$Res> {
  factory _$$MempoolPatchImplCopyWith(
    _$MempoolPatchImpl value,
    $Res Function(_$MempoolPatchImpl) then,
  ) = __$$MempoolPatchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? height, MempoolInfo? mempool, PriceInfo? price});

  @override
  $MempoolInfoCopyWith<$Res>? get mempool;
  @override
  $PriceInfoCopyWith<$Res>? get price;
}

/// @nodoc
class __$$MempoolPatchImplCopyWithImpl<$Res>
    extends _$MempoolPatchCopyWithImpl<$Res, _$MempoolPatchImpl>
    implements _$$MempoolPatchImplCopyWith<$Res> {
  __$$MempoolPatchImplCopyWithImpl(
    _$MempoolPatchImpl _value,
    $Res Function(_$MempoolPatchImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MempoolPatch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? height = freezed,
    Object? mempool = freezed,
    Object? price = freezed,
  }) {
    return _then(
      _$MempoolPatchImpl(
        height:
            freezed == height
                ? _value.height
                : height // ignore: cast_nullable_to_non_nullable
                    as int?,
        mempool:
            freezed == mempool
                ? _value.mempool
                : mempool // ignore: cast_nullable_to_non_nullable
                    as MempoolInfo?,
        price:
            freezed == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                    as PriceInfo?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MempoolPatchImpl implements _MempoolPatch {
  const _$MempoolPatchImpl({this.height, this.mempool, this.price});

  factory _$MempoolPatchImpl.fromJson(Map<String, dynamic> json) =>
      _$$MempoolPatchImplFromJson(json);

  @override
  final int? height;
  @override
  final MempoolInfo? mempool;
  @override
  final PriceInfo? price;

  @override
  String toString() {
    return 'MempoolPatch(height: $height, mempool: $mempool, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MempoolPatchImpl &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.mempool, mempool) || other.mempool == mempool) &&
            (identical(other.price, price) || other.price == price));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, height, mempool, price);

  /// Create a copy of MempoolPatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MempoolPatchImplCopyWith<_$MempoolPatchImpl> get copyWith =>
      __$$MempoolPatchImplCopyWithImpl<_$MempoolPatchImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MempoolPatchImplToJson(this);
  }
}

abstract class _MempoolPatch implements MempoolPatch {
  const factory _MempoolPatch({
    final int? height,
    final MempoolInfo? mempool,
    final PriceInfo? price,
  }) = _$MempoolPatchImpl;

  factory _MempoolPatch.fromJson(Map<String, dynamic> json) =
      _$MempoolPatchImpl.fromJson;

  @override
  int? get height;
  @override
  MempoolInfo? get mempool;
  @override
  PriceInfo? get price;

  /// Create a copy of MempoolPatch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MempoolPatchImplCopyWith<_$MempoolPatchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChainSnapshot _$ChainSnapshotFromJson(Map<String, dynamic> json) {
  return _ChainSnapshot.fromJson(json);
}

/// @nodoc
mixin _$ChainSnapshot {
  int get height => throw _privateConstructorUsedError;
  String get hash => throw _privateConstructorUsedError;
  String? get prevHash => throw _privateConstructorUsedError;
  int get time => throw _privateConstructorUsedError;
  String get algo => throw _privateConstructorUsedError;
  int get sizeBytes => throw _privateConstructorUsedError;
  int get txCount => throw _privateConstructorUsedError;
  FeeRate? get feeRate => throw _privateConstructorUsedError;
  Reward get reward => throw _privateConstructorUsedError;
  PoolInfo get pool => throw _privateConstructorUsedError;
  ReductionInfo get reduction => throw _privateConstructorUsedError;
  SupplyInfo get supply => throw _privateConstructorUsedError;
  AlgoShare get algoShare24h => throw _privateConstructorUsedError;
  List<BlockRef> get recentBlocks => throw _privateConstructorUsedError;
  MempoolInfo? get mempool => throw _privateConstructorUsedError;
  PriceInfo? get price => throw _privateConstructorUsedError;
  bool get isTip => throw _privateConstructorUsedError;

  /// Serializes this ChainSnapshot to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChainSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChainSnapshotCopyWith<ChainSnapshot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChainSnapshotCopyWith<$Res> {
  factory $ChainSnapshotCopyWith(
    ChainSnapshot value,
    $Res Function(ChainSnapshot) then,
  ) = _$ChainSnapshotCopyWithImpl<$Res, ChainSnapshot>;
  @useResult
  $Res call({
    int height,
    String hash,
    String? prevHash,
    int time,
    String algo,
    int sizeBytes,
    int txCount,
    FeeRate? feeRate,
    Reward reward,
    PoolInfo pool,
    ReductionInfo reduction,
    SupplyInfo supply,
    AlgoShare algoShare24h,
    List<BlockRef> recentBlocks,
    MempoolInfo? mempool,
    PriceInfo? price,
    bool isTip,
  });

  $FeeRateCopyWith<$Res>? get feeRate;
  $RewardCopyWith<$Res> get reward;
  $PoolInfoCopyWith<$Res> get pool;
  $ReductionInfoCopyWith<$Res> get reduction;
  $SupplyInfoCopyWith<$Res> get supply;
  $AlgoShareCopyWith<$Res> get algoShare24h;
  $MempoolInfoCopyWith<$Res>? get mempool;
  $PriceInfoCopyWith<$Res>? get price;
}

/// @nodoc
class _$ChainSnapshotCopyWithImpl<$Res, $Val extends ChainSnapshot>
    implements $ChainSnapshotCopyWith<$Res> {
  _$ChainSnapshotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChainSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? height = null,
    Object? hash = null,
    Object? prevHash = freezed,
    Object? time = null,
    Object? algo = null,
    Object? sizeBytes = null,
    Object? txCount = null,
    Object? feeRate = freezed,
    Object? reward = null,
    Object? pool = null,
    Object? reduction = null,
    Object? supply = null,
    Object? algoShare24h = null,
    Object? recentBlocks = null,
    Object? mempool = freezed,
    Object? price = freezed,
    Object? isTip = null,
  }) {
    return _then(
      _value.copyWith(
            height:
                null == height
                    ? _value.height
                    : height // ignore: cast_nullable_to_non_nullable
                        as int,
            hash:
                null == hash
                    ? _value.hash
                    : hash // ignore: cast_nullable_to_non_nullable
                        as String,
            prevHash:
                freezed == prevHash
                    ? _value.prevHash
                    : prevHash // ignore: cast_nullable_to_non_nullable
                        as String?,
            time:
                null == time
                    ? _value.time
                    : time // ignore: cast_nullable_to_non_nullable
                        as int,
            algo:
                null == algo
                    ? _value.algo
                    : algo // ignore: cast_nullable_to_non_nullable
                        as String,
            sizeBytes:
                null == sizeBytes
                    ? _value.sizeBytes
                    : sizeBytes // ignore: cast_nullable_to_non_nullable
                        as int,
            txCount:
                null == txCount
                    ? _value.txCount
                    : txCount // ignore: cast_nullable_to_non_nullable
                        as int,
            feeRate:
                freezed == feeRate
                    ? _value.feeRate
                    : feeRate // ignore: cast_nullable_to_non_nullable
                        as FeeRate?,
            reward:
                null == reward
                    ? _value.reward
                    : reward // ignore: cast_nullable_to_non_nullable
                        as Reward,
            pool:
                null == pool
                    ? _value.pool
                    : pool // ignore: cast_nullable_to_non_nullable
                        as PoolInfo,
            reduction:
                null == reduction
                    ? _value.reduction
                    : reduction // ignore: cast_nullable_to_non_nullable
                        as ReductionInfo,
            supply:
                null == supply
                    ? _value.supply
                    : supply // ignore: cast_nullable_to_non_nullable
                        as SupplyInfo,
            algoShare24h:
                null == algoShare24h
                    ? _value.algoShare24h
                    : algoShare24h // ignore: cast_nullable_to_non_nullable
                        as AlgoShare,
            recentBlocks:
                null == recentBlocks
                    ? _value.recentBlocks
                    : recentBlocks // ignore: cast_nullable_to_non_nullable
                        as List<BlockRef>,
            mempool:
                freezed == mempool
                    ? _value.mempool
                    : mempool // ignore: cast_nullable_to_non_nullable
                        as MempoolInfo?,
            price:
                freezed == price
                    ? _value.price
                    : price // ignore: cast_nullable_to_non_nullable
                        as PriceInfo?,
            isTip:
                null == isTip
                    ? _value.isTip
                    : isTip // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of ChainSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FeeRateCopyWith<$Res>? get feeRate {
    if (_value.feeRate == null) {
      return null;
    }

    return $FeeRateCopyWith<$Res>(_value.feeRate!, (value) {
      return _then(_value.copyWith(feeRate: value) as $Val);
    });
  }

  /// Create a copy of ChainSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RewardCopyWith<$Res> get reward {
    return $RewardCopyWith<$Res>(_value.reward, (value) {
      return _then(_value.copyWith(reward: value) as $Val);
    });
  }

  /// Create a copy of ChainSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PoolInfoCopyWith<$Res> get pool {
    return $PoolInfoCopyWith<$Res>(_value.pool, (value) {
      return _then(_value.copyWith(pool: value) as $Val);
    });
  }

  /// Create a copy of ChainSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReductionInfoCopyWith<$Res> get reduction {
    return $ReductionInfoCopyWith<$Res>(_value.reduction, (value) {
      return _then(_value.copyWith(reduction: value) as $Val);
    });
  }

  /// Create a copy of ChainSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SupplyInfoCopyWith<$Res> get supply {
    return $SupplyInfoCopyWith<$Res>(_value.supply, (value) {
      return _then(_value.copyWith(supply: value) as $Val);
    });
  }

  /// Create a copy of ChainSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AlgoShareCopyWith<$Res> get algoShare24h {
    return $AlgoShareCopyWith<$Res>(_value.algoShare24h, (value) {
      return _then(_value.copyWith(algoShare24h: value) as $Val);
    });
  }

  /// Create a copy of ChainSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MempoolInfoCopyWith<$Res>? get mempool {
    if (_value.mempool == null) {
      return null;
    }

    return $MempoolInfoCopyWith<$Res>(_value.mempool!, (value) {
      return _then(_value.copyWith(mempool: value) as $Val);
    });
  }

  /// Create a copy of ChainSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PriceInfoCopyWith<$Res>? get price {
    if (_value.price == null) {
      return null;
    }

    return $PriceInfoCopyWith<$Res>(_value.price!, (value) {
      return _then(_value.copyWith(price: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ChainSnapshotImplCopyWith<$Res>
    implements $ChainSnapshotCopyWith<$Res> {
  factory _$$ChainSnapshotImplCopyWith(
    _$ChainSnapshotImpl value,
    $Res Function(_$ChainSnapshotImpl) then,
  ) = __$$ChainSnapshotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int height,
    String hash,
    String? prevHash,
    int time,
    String algo,
    int sizeBytes,
    int txCount,
    FeeRate? feeRate,
    Reward reward,
    PoolInfo pool,
    ReductionInfo reduction,
    SupplyInfo supply,
    AlgoShare algoShare24h,
    List<BlockRef> recentBlocks,
    MempoolInfo? mempool,
    PriceInfo? price,
    bool isTip,
  });

  @override
  $FeeRateCopyWith<$Res>? get feeRate;
  @override
  $RewardCopyWith<$Res> get reward;
  @override
  $PoolInfoCopyWith<$Res> get pool;
  @override
  $ReductionInfoCopyWith<$Res> get reduction;
  @override
  $SupplyInfoCopyWith<$Res> get supply;
  @override
  $AlgoShareCopyWith<$Res> get algoShare24h;
  @override
  $MempoolInfoCopyWith<$Res>? get mempool;
  @override
  $PriceInfoCopyWith<$Res>? get price;
}

/// @nodoc
class __$$ChainSnapshotImplCopyWithImpl<$Res>
    extends _$ChainSnapshotCopyWithImpl<$Res, _$ChainSnapshotImpl>
    implements _$$ChainSnapshotImplCopyWith<$Res> {
  __$$ChainSnapshotImplCopyWithImpl(
    _$ChainSnapshotImpl _value,
    $Res Function(_$ChainSnapshotImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChainSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? height = null,
    Object? hash = null,
    Object? prevHash = freezed,
    Object? time = null,
    Object? algo = null,
    Object? sizeBytes = null,
    Object? txCount = null,
    Object? feeRate = freezed,
    Object? reward = null,
    Object? pool = null,
    Object? reduction = null,
    Object? supply = null,
    Object? algoShare24h = null,
    Object? recentBlocks = null,
    Object? mempool = freezed,
    Object? price = freezed,
    Object? isTip = null,
  }) {
    return _then(
      _$ChainSnapshotImpl(
        height:
            null == height
                ? _value.height
                : height // ignore: cast_nullable_to_non_nullable
                    as int,
        hash:
            null == hash
                ? _value.hash
                : hash // ignore: cast_nullable_to_non_nullable
                    as String,
        prevHash:
            freezed == prevHash
                ? _value.prevHash
                : prevHash // ignore: cast_nullable_to_non_nullable
                    as String?,
        time:
            null == time
                ? _value.time
                : time // ignore: cast_nullable_to_non_nullable
                    as int,
        algo:
            null == algo
                ? _value.algo
                : algo // ignore: cast_nullable_to_non_nullable
                    as String,
        sizeBytes:
            null == sizeBytes
                ? _value.sizeBytes
                : sizeBytes // ignore: cast_nullable_to_non_nullable
                    as int,
        txCount:
            null == txCount
                ? _value.txCount
                : txCount // ignore: cast_nullable_to_non_nullable
                    as int,
        feeRate:
            freezed == feeRate
                ? _value.feeRate
                : feeRate // ignore: cast_nullable_to_non_nullable
                    as FeeRate?,
        reward:
            null == reward
                ? _value.reward
                : reward // ignore: cast_nullable_to_non_nullable
                    as Reward,
        pool:
            null == pool
                ? _value.pool
                : pool // ignore: cast_nullable_to_non_nullable
                    as PoolInfo,
        reduction:
            null == reduction
                ? _value.reduction
                : reduction // ignore: cast_nullable_to_non_nullable
                    as ReductionInfo,
        supply:
            null == supply
                ? _value.supply
                : supply // ignore: cast_nullable_to_non_nullable
                    as SupplyInfo,
        algoShare24h:
            null == algoShare24h
                ? _value.algoShare24h
                : algoShare24h // ignore: cast_nullable_to_non_nullable
                    as AlgoShare,
        recentBlocks:
            null == recentBlocks
                ? _value._recentBlocks
                : recentBlocks // ignore: cast_nullable_to_non_nullable
                    as List<BlockRef>,
        mempool:
            freezed == mempool
                ? _value.mempool
                : mempool // ignore: cast_nullable_to_non_nullable
                    as MempoolInfo?,
        price:
            freezed == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                    as PriceInfo?,
        isTip:
            null == isTip
                ? _value.isTip
                : isTip // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChainSnapshotImpl extends _ChainSnapshot {
  const _$ChainSnapshotImpl({
    required this.height,
    required this.hash,
    this.prevHash,
    required this.time,
    required this.algo,
    required this.sizeBytes,
    required this.txCount,
    this.feeRate,
    required this.reward,
    required this.pool,
    required this.reduction,
    required this.supply,
    required this.algoShare24h,
    required final List<BlockRef> recentBlocks,
    this.mempool,
    this.price,
    this.isTip = false,
  }) : _recentBlocks = recentBlocks,
       super._();

  factory _$ChainSnapshotImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChainSnapshotImplFromJson(json);

  @override
  final int height;
  @override
  final String hash;
  @override
  final String? prevHash;
  @override
  final int time;
  @override
  final String algo;
  @override
  final int sizeBytes;
  @override
  final int txCount;
  @override
  final FeeRate? feeRate;
  @override
  final Reward reward;
  @override
  final PoolInfo pool;
  @override
  final ReductionInfo reduction;
  @override
  final SupplyInfo supply;
  @override
  final AlgoShare algoShare24h;
  final List<BlockRef> _recentBlocks;
  @override
  List<BlockRef> get recentBlocks {
    if (_recentBlocks is EqualUnmodifiableListView) return _recentBlocks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentBlocks);
  }

  @override
  final MempoolInfo? mempool;
  @override
  final PriceInfo? price;
  @override
  @JsonKey()
  final bool isTip;

  @override
  String toString() {
    return 'ChainSnapshot(height: $height, hash: $hash, prevHash: $prevHash, time: $time, algo: $algo, sizeBytes: $sizeBytes, txCount: $txCount, feeRate: $feeRate, reward: $reward, pool: $pool, reduction: $reduction, supply: $supply, algoShare24h: $algoShare24h, recentBlocks: $recentBlocks, mempool: $mempool, price: $price, isTip: $isTip)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChainSnapshotImpl &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.hash, hash) || other.hash == hash) &&
            (identical(other.prevHash, prevHash) ||
                other.prevHash == prevHash) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.algo, algo) || other.algo == algo) &&
            (identical(other.sizeBytes, sizeBytes) ||
                other.sizeBytes == sizeBytes) &&
            (identical(other.txCount, txCount) || other.txCount == txCount) &&
            (identical(other.feeRate, feeRate) || other.feeRate == feeRate) &&
            (identical(other.reward, reward) || other.reward == reward) &&
            (identical(other.pool, pool) || other.pool == pool) &&
            (identical(other.reduction, reduction) ||
                other.reduction == reduction) &&
            (identical(other.supply, supply) || other.supply == supply) &&
            (identical(other.algoShare24h, algoShare24h) ||
                other.algoShare24h == algoShare24h) &&
            const DeepCollectionEquality().equals(
              other._recentBlocks,
              _recentBlocks,
            ) &&
            (identical(other.mempool, mempool) || other.mempool == mempool) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.isTip, isTip) || other.isTip == isTip));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    height,
    hash,
    prevHash,
    time,
    algo,
    sizeBytes,
    txCount,
    feeRate,
    reward,
    pool,
    reduction,
    supply,
    algoShare24h,
    const DeepCollectionEquality().hash(_recentBlocks),
    mempool,
    price,
    isTip,
  );

  /// Create a copy of ChainSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChainSnapshotImplCopyWith<_$ChainSnapshotImpl> get copyWith =>
      __$$ChainSnapshotImplCopyWithImpl<_$ChainSnapshotImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChainSnapshotImplToJson(this);
  }
}

abstract class _ChainSnapshot extends ChainSnapshot {
  const factory _ChainSnapshot({
    required final int height,
    required final String hash,
    final String? prevHash,
    required final int time,
    required final String algo,
    required final int sizeBytes,
    required final int txCount,
    final FeeRate? feeRate,
    required final Reward reward,
    required final PoolInfo pool,
    required final ReductionInfo reduction,
    required final SupplyInfo supply,
    required final AlgoShare algoShare24h,
    required final List<BlockRef> recentBlocks,
    final MempoolInfo? mempool,
    final PriceInfo? price,
    final bool isTip,
  }) = _$ChainSnapshotImpl;
  const _ChainSnapshot._() : super._();

  factory _ChainSnapshot.fromJson(Map<String, dynamic> json) =
      _$ChainSnapshotImpl.fromJson;

  @override
  int get height;
  @override
  String get hash;
  @override
  String? get prevHash;
  @override
  int get time;
  @override
  String get algo;
  @override
  int get sizeBytes;
  @override
  int get txCount;
  @override
  FeeRate? get feeRate;
  @override
  Reward get reward;
  @override
  PoolInfo get pool;
  @override
  ReductionInfo get reduction;
  @override
  SupplyInfo get supply;
  @override
  AlgoShare get algoShare24h;
  @override
  List<BlockRef> get recentBlocks;
  @override
  MempoolInfo? get mempool;
  @override
  PriceInfo? get price;
  @override
  bool get isTip;

  /// Create a copy of ChainSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChainSnapshotImplCopyWith<_$ChainSnapshotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
