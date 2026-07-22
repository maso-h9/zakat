import 'package:json_annotation/json_annotation.dart';

part 'gold_price_result.g.dart';

@JsonSerializable()
class GoldPriceResult {
  final double pricePerGram;
  final double silverPricePerGram;
  final bool isLive;
  final String? formattedTime;
  final String source;

  const GoldPriceResult({
    required this.pricePerGram,
    required this.silverPricePerGram,
    required this.isLive,
    this.formattedTime,
    this.source = 'unknown',
  });

  factory GoldPriceResult.fromJson(Map<String, dynamic> json) =>
      _$GoldPriceResultFromJson(json);

  Map<String, dynamic> toJson() => _$GoldPriceResultToJson(this);

  GoldPriceResult copyWith({
    double? pricePerGram,
    double? silverPricePerGram,
    bool? isLive,
    String? formattedTime,
    String? source,
  }) {
    return GoldPriceResult(
      pricePerGram: pricePerGram ?? this.pricePerGram,
      silverPricePerGram: silverPricePerGram ?? this.silverPricePerGram,
      isLive: isLive ?? this.isLive,
      formattedTime: formattedTime ?? this.formattedTime,
      source: source ?? this.source,
    );
  }

  static const empty = GoldPriceResult(
    pricePerGram: 0,
    silverPricePerGram: 0,
    isLive: false,
  );
}
