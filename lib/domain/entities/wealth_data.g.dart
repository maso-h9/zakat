// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wealth_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WealthData _$WealthDataFromJson(Map<String, dynamic> json) => WealthData(
      savedMoney: (json['money'] as num?)?.toDouble() ?? 0,
      goldGrams: (json['gold'] as num?)?.toDouble() ?? 0,
      silverGrams: (json['silver'] as num?)?.toDouble() ?? 0,
      tradeGoods: (json['trade'] as num?)?.toDouble() ?? 0,
      debtsOwed: (json['debtsOwed'] as num?)?.toDouble() ?? 0,
      debtsToReceive: (json['debtsReceive'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$WealthDataToJson(WealthData instance) =>
    <String, dynamic>{
      'money': instance.savedMoney,
      'gold': instance.goldGrams,
      'silver': instance.silverGrams,
      'trade': instance.tradeGoods,
      'debtsOwed': instance.debtsOwed,
      'debtsReceive': instance.debtsToReceive,
    };
