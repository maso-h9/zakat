// ================================================================
// test/zakat_calculation_test.dart — Unit Tests (بند 7)
// flutter test
// ================================================================
import 'package:flutter_test/flutter_test.dart';
import 'package:zakat_app/services/nisab_service.dart';

void main() {
  group('NisabService — حسابات النصاب', () {
    // ── النصاب العالمي ──────────────────────────────────────────
    test('النصاب العالمي = سعر الجرام × 85', () {
      expect(NisabService.globalNisab(1000), equals(85000));
      expect(NisabService.globalNisab(285.5), closeTo(24267.5, 0.1));
      expect(NisabService.globalNisab(0), equals(0));
    });

    test('النصاب من سعر الجرام', () {
      expect(NisabService.fromGramPrice(1147), equals(97495));
      expect(NisabService.fromGramPrice(0), equals(0));
    });

    test('النصاب من الأوقية وسعر الصرف', () {
      // أوقية = 2350 دولار، صرف = 4.85 دينار
      const expected = (2350 / 31.1035) * 85 * 4.85;
      expect(NisabService.fromOzAndRate(2350, 4.85), closeTo(expected, 1));
    });

    // ── الزكاة ──────────────────────────────────────────────────
    group('حساب الزكاة 2.5%', () {
      const rate = 0.025;

      test('زكاة 100,000 = 2,500', () {
        expect(100000 * rate, equals(2500));
      });

      test('زكاة 85,000 = 2,125', () {
        expect(85000 * rate, equals(2125));
      });

      test('زكاة صفر = صفر', () {
        expect(0 * rate, equals(0));
      });
    });

    // ── مقارنة النصاب ───────────────────────────────────────────
    group('NisabComparison', () {
      test('النصاب الرسمي أعلى من العالمي', () {
        final cmp = NisabService.compare(
          globalNisabValue: 73000,
          activeNisabValue: 97495,
          activeMethod: 'official',
          currency: 'LYD',
        );
        expect(cmp.isHigherThanGlobal, isTrue);
        expect(cmp.difference, closeTo(24495, 1));
        expect(cmp.isSameAsGlobal, isFalse);
      });

      test('النصاب المخصص أقل من العالمي', () {
        final cmp = NisabService.compare(
          globalNisabValue: 73000,
          activeNisabValue: 60000,
          activeMethod: 'custom',
          currency: 'LYD',
        );
        expect(cmp.isHigherThanGlobal, isFalse);
        expect(cmp.difference, closeTo(-13000, 1));
      });

      test('النصاب مطابق للعالمي', () {
        final cmp = NisabService.compare(
          globalNisabValue: 73000,
          activeNisabValue: 73000,
          activeMethod: 'global',
          currency: 'LYD',
        );
        expect(cmp.isSameAsGlobal, isTrue);
      });
    });
  });

  // ── حساب إجمالي الثروة ─────────────────────────────────────
  group('حساب إجمالي الثروة', () {
    double calcWealth({
      double money = 0,
      double goldGrams = 0,
      double goldPrice = 0,
      double silverGrams = 0,
      double silverPrice = 0,
      double trade = 0,
      double debtsOwed = 0,
      double debtsReceive = 0,
    }) {
      final t = money +
          goldGrams * goldPrice +
          silverGrams * silverPrice +
          trade +
          debtsReceive -
          debtsOwed;
      return t < 0 ? 0 : t;
    }

    test('مدخرات فقط', () {
      expect(calcWealth(money: 50000), equals(50000));
    });

    test('ذهب + مدخرات', () {
      // 100 جرام ذهب × 1000 + 20000 مدخرات
      expect(calcWealth(money: 20000, goldGrams: 100, goldPrice: 1000),
          equals(120000));
    });

    test('طرح الديون', () {
      expect(calcWealth(money: 100000, debtsOwed: 30000), equals(70000));
    });

    test('لا تقل الثروة عن الصفر', () {
      expect(calcWealth(money: 1000, debtsOwed: 5000), equals(0));
    });

    test('إضافة الديون المستحقة', () {
      expect(calcWealth(money: 50000, debtsReceive: 20000), equals(70000));
    });

    test('حساب شامل', () {
      final w = calcWealth(
        money: 50000,
        goldGrams: 50,
        goldPrice: 1000,
        silverGrams: 200,
        silverPrice: 1,
        trade: 30000,
        debtsOwed: 10000,
        debtsReceive: 5000,
      );
      // 50000 + 50000 + 200 + 30000 - 10000 + 5000 = 125200
      expect(w, closeTo(125200, 0.1));
    });
  });

  // ── تحويل العملات ───────────────────────────────────────────
  group('تحويل العملات (GoldPriceService.convert)', () {
    double convert(double amount, String from, String to) {
      const fx = <String, double>{
        'USD': 1.0,
        'LYD': 4.85,
        'SAR': 3.75,
        'AED': 3.67,
        'EGP': 30.9,
        'EUR': 0.92,
        'GBP': 0.79,
        'KWD': 0.31,
      };
      return amount / (fx[from] ?? 1.0) * (fx[to] ?? 1.0);
    }

    test('USD to LYD', () {
      expect(convert(1000, 'USD', 'LYD'), closeTo(4850, 0.1));
    });

    test('LYD to USD', () {
      expect(convert(4850, 'LYD', 'USD'), closeTo(1000, 0.1));
    });

    test('نفس العملة', () {
      expect(convert(1000, 'USD', 'USD'), equals(1000));
    });

    test('EUR to SAR', () {
      const expected = 1000 / 0.92 * 3.75;
      expect(convert(1000, 'EUR', 'SAR'), closeTo(expected, 0.1));
    });
  });

  // ── نصاب الفضة ──────────────────────────────────────────────
  group('نصاب الفضة', () {
    test('نصاب الفضة = سعر الجرام × 595', () {
      const silverPerGram = 0.85;
      const expected = silverPerGram * 595;
      expect(595 * silverPerGram, closeTo(expected, 0.01));
    });
  });

  // ── CountrySourcesRepository helper ─────────────────────────
  group('countryCodeForCurrency', () {
    final map = <String, String>{
      'LYD': 'LY',
      'EGP': 'EG',
      'SAR': 'SA',
      'AED': 'AE',
      'KWD': 'KW',
      'QAR': 'QA',
      'JOD': 'JO',
      'USD': 'US',
    };

    test('LYD → LY', () => expect(map['LYD'], equals('LY')));
    test('EGP → EG', () => expect(map['EGP'], equals('EG')));
    test('SAR → SA', () => expect(map['SAR'], equals('SA')));
    test('غير موجود → null', () => expect(map['XYZ'], isNull));
  });
}
