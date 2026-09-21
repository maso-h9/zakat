import 'package:flutter_test/flutter_test.dart';
import 'package:zakat_app/domain/entities/wealth_data.dart';
import 'package:zakat_app/domain/entities/zakat_record.dart';
import 'package:zakat_app/domain/entities/gold_price_result.dart';
import 'package:zakat_app/domain/usecases/calculate_zakat.dart';

void main() {
  group('Zakat Calculation Integration', () {
    late CalculateZakatUseCase useCase;

    setUp(() {
      useCase = CalculateZakatUseCase();
    });

    test('complete zakat calculation with nisab reached', () {
      const wealth = WealthData(
        savedMoney: 50000,
        goldGrams: 100,
        silverGrams: 200,
        tradeGoods: 10000,
        debtsOwed: 5000,
        debtsToReceive: 3000,
      );

      final result = useCase.calculate(
        wealth: wealth,
        goldPricePerGram: 285.0,
        silverPricePerGram: 3.2,
        currency: 'LYD',
      );

      expect(result.totalWealth, greaterThan(0));
      expect(result.hasReachedNisab, isTrue);
      expect(result.zakatDue, greaterThan(0));
      expect(result.zakatDue, result.totalWealth * 0.025);
    });

    test('zakat calculation with zero wealth', () {
      final result = useCase.calculate(
        wealth: WealthData.empty,
        goldPricePerGram: 285.0,
        silverPricePerGram: 3.2,
        currency: 'LYD',
      );

      expect(result.totalWealth, 0);
      expect(result.hasReachedNisab, isFalse);
      expect(result.zakatDue, 0);
    });

    test('zakat calculation below nisab', () {
      final result = useCase.calculate(
        wealth: const WealthData(savedMoney: 100),
        goldPricePerGram: 285.0,
        silverPricePerGram: 3.2,
        currency: 'LYD',
      );

      expect(result.hasReachedNisab, isFalse);
      expect(result.zakatDue, 0);
    });
  });

  group('Wealth Data Serialization', () {
    test('roundtrip preserves data', () {
      const original = WealthData(
        savedMoney: 1000,
        goldGrams: 50,
        silverGrams: 100,
        tradeGoods: 2000,
        debtsOwed: 500,
        debtsToReceive: 300,
      );

      final map = original.toMap();
      final restored = WealthData.fromMap(map);

      expect(restored.savedMoney, original.savedMoney);
      expect(restored.goldGrams, original.goldGrams);
      expect(restored.silverGrams, original.silverGrams);
      expect(restored.tradeGoods, original.tradeGoods);
      expect(restored.debtsOwed, original.debtsOwed);
      expect(restored.debtsToReceive, original.debtsToReceive);
    });

    test('copyWith overrides only specified fields', () {
      const original = WealthData(savedMoney: 100, goldGrams: 50);
      final modified = original.copyWith(savedMoney: 200);

      expect(modified.savedMoney, 200);
      expect(modified.goldGrams, 50);
    });
  });

  group('Zakat Record Serialization', () {
    test('roundtrip preserves data', () {
      final original = ZakatRecord(
        year: 1445,
        amount: 2500,
        wealth: 100000,
        date: DateTime(2024, 3, 15),
        note: 'Test note',
      );

      final map = original.toMap();
      final restored = ZakatRecord.fromMap(map);

      expect(restored.year, original.year);
      expect(restored.amount, original.amount);
      expect(restored.wealth, original.wealth);
      expect(restored.note, original.note);
    });
  });

  group('Gold Price Result', () {
    test('empty has zero values', () {
      expect(GoldPriceResult.empty.pricePerGram, 0);
      expect(GoldPriceResult.empty.silverPricePerGram, 0);
      expect(GoldPriceResult.empty.isLive, false);
    });

    test('copyWith preserves data', () {
      const original = GoldPriceResult(
        pricePerGram: 285.0,
        silverPricePerGram: 3.2,
        isLive: true,
        formattedTime: '2024-01-01',
        source: 'firestore',
      );

      final modified = original.copyWith(pricePerGram: 300.0);

      expect(modified.pricePerGram, 300.0);
      expect(modified.silverPricePerGram, 3.2);
      expect(modified.isLive, true);
    });
  });
}
