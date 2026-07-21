import 'package:flutter_test/flutter_test.dart';
import 'package:zakat_app/domain/entities/wealth_data.dart';
import 'package:zakat_app/domain/entities/zakat_result.dart';
import 'package:zakat_app/domain/entities/gold_price_result.dart';
import 'package:zakat_app/domain/usecases/calculate_zakat.dart';

void main() {
  group('WealthData', () {
    test('empty has zero values', () {
      const w = WealthData.empty;
      expect(w.savedMoney, 0);
      expect(w.goldGrams, 0);
      expect(w.silverGrams, 0);
      expect(w.tradeGoods, 0);
      expect(w.debtsOwed, 0);
      expect(w.debtsToReceive, 0);
    });

    test('toMap/fromMap roundtrip', () {
      const w = WealthData(
        savedMoney: 50000,
        goldGrams: 100,
        silverGrams: 200,
        tradeGoods: 30000,
        debtsOwed: 10000,
        debtsToReceive: 5000,
      );
      final m = w.toMap();
      final restored = WealthData.fromMap(m);
      expect(restored.savedMoney, 50000);
      expect(restored.goldGrams, 100);
      expect(restored.silverGrams, 200);
      expect(restored.tradeGoods, 30000);
      expect(restored.debtsOwed, 10000);
      expect(restored.debtsToReceive, 5000);
    });

    test('copyWith overrides only specified fields', () {
      const w = WealthData(savedMoney: 1000, goldGrams: 50);
      final w2 = w.copyWith(savedMoney: 2000);
      expect(w2.savedMoney, 2000);
      expect(w2.goldGrams, 50);
    });

    test('fromMap handles missing keys gracefully', () {
      final w = WealthData.fromMap({});
      expect(w.savedMoney, 0);
      expect(w.goldGrams, 0);
    });

    test('fromMap handles num types', () {
      final w = WealthData.fromMap({
        'money': 100,
        'gold': 200,
        'silver': 300,
        'trade': 400,
        'debtsOwed': 500,
        'debtsReceive': 600,
      });
      expect(w.savedMoney, 100);
      expect(w.debtsToReceive, 600);
    });
  });

  group('ZakatResult', () {
    test('empty has zero values', () {
      const r = ZakatResult.empty;
      expect(r.totalWealth, 0);
      expect(r.zakatDue, 0);
      expect(r.hasReachedNisab, isFalse);
      expect(r.currency, 'LYD');
    });
  });

  group('GoldPriceResult', () {
    test('empty has correct defaults', () {
      const r = GoldPriceResult.empty;
      expect(r.pricePerGram, 0);
      expect(r.source, equals('unknown'));
    });
  });

  group('CalculateZakatUseCase', () {
    late CalculateZakatUseCase useCase;

    setUp(() {
      useCase = CalculateZakatUseCase();
    });

    test('calculateGoldNisab returns 85 * price', () {
      expect(useCase.calculateGoldNisab(1000), 85000);
      expect(useCase.calculateGoldNisab(0), 0);
    });

    test('calculateSilverNisab returns 595 * price', () {
      expect(useCase.calculateSilverNisab(1), 595);
    });

    test('calculateTotalWealth sums all components', () {
      const wealth = WealthData(
        savedMoney: 50000,
        goldGrams: 100,
        silverGrams: 200,
        tradeGoods: 30000,
        debtsOwed: 10000,
        debtsToReceive: 5000,
      );
      final total = useCase.calculateTotalWealth(
        wealth: wealth,
        goldPricePerGram: 1000,
        silverPricePerGram: 1,
      );
      // 50000 + 100*1000 + 200*1 + 30000 - 10000 + 5000 = 175200
      expect(total, closeTo(175200, 0.1));
    });

    test('calculateTotalWealth never returns negative', () {
      const wealth = WealthData(savedMoney: 100, debtsOwed: 500);
      final total = useCase.calculateTotalWealth(
        wealth: wealth,
        goldPricePerGram: 0,
        silverPricePerGram: 0,
      );
      expect(total, 0);
    });

    test('calculateZakatDue returns 2.5% when above nisab', () {
      final zakat = useCase.calculateZakatDue(100000, 85000);
      expect(zakat, 2500);
    });

    test('calculateZakatDue returns 0 when below nisab', () {
      final zakat = useCase.calculateZakatDue(50000, 85000);
      expect(zakat, 0);
    });

    test('hasReachedNisab compares correctly', () {
      expect(useCase.hasReachedNisab(85000, 85000), isTrue);
      expect(useCase.hasReachedNisab(84999, 85000), isFalse);
      expect(useCase.hasReachedNisab(100000, 85000), isTrue);
    });

    test('calculate returns complete ZakatResult', () {
      const wealth = WealthData(savedMoney: 200000);
      final result = useCase.calculate(
        wealth: wealth,
        goldPricePerGram: 1000,
        silverPricePerGram: 1,
        currency: 'LYD',
      );
      expect(result.totalWealth, 200000);
      expect(result.zakatDue, 5000);
      expect(result.goldNisabValue, 85000);
      expect(result.silverNisabValue, 595);
      expect(result.hasReachedNisab, isTrue);
      expect(result.currency, 'LYD');
    });

    test('calculate with zero wealth', () {
      const wealth = WealthData.empty;
      final result = useCase.calculate(
        wealth: wealth,
        goldPricePerGram: 1000,
        silverPricePerGram: 1,
        currency: 'USD',
      );
      expect(result.zakatDue, 0);
      expect(result.hasReachedNisab, isFalse);
    });

    test('daysUntilZakat returns -1 for null date', () {
      expect(useCase.daysUntilZakat(null), -1);
    });

    test('daysUntilZakat returns positive for future date', () {
      final future = DateTime.now().add(const Duration(days: 100));
      expect(useCase.daysUntilZakat(future), greaterThan(90));
    });
  });
}
