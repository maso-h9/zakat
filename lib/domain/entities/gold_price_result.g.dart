// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gold_price_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoldPriceResult _$GoldPriceResultFromJson(Map<String, dynamic> json) =>
    GoldPriceResult(
      pricePerGram: (json['pricePerGram'] as num?)?.toDouble() ?? 0,
      silverPricePerGram:
          (json['silverPricePerGram'] as num?)?.toDouble() ?? 0,
      isLive: json['isLive'] as bool? ?? false,
      formattedTime: json['formattedTime'] as String?,
      source: json['source'] as String? ?? 'unknown',
    );

Map<String, dynamic> _$GoldPriceResultToJson(GoldPriceResult instance) =>
    <String, dynamic>{
      'pricePerGram': instance.pricePerGram,
      'silverPricePerGram': instance.silverPricePerGram,
      'isLive': instance.isLive,
      'formattedTime': instance.formattedTime,
      'source': instance.source,
    };
