// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zakat_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZakatRecord _$ZakatRecordFromJson(Map<String, dynamic> json) => ZakatRecord(
      year: (json['year'] as num?)?.toInt() ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      wealth: (json['wealth'] as num?)?.toDouble() ?? 0,
      date: json['date'] == null
          ? DateTime.now()
          : DateTime.parse(json['date'] as String),
      note: json['note'] as String? ?? '',
    );

Map<String, dynamic> _$ZakatRecordToJson(ZakatRecord instance) =>
    <String, dynamic>{
      'year': instance.year,
      'amount': instance.amount,
      'wealth': instance.wealth,
      'date': instance.date.toIso8601String(),
      'note': instance.note,
    };
