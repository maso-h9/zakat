import '../entities/wealth_data.dart';
import '../entities/zakat_result.dart';
import '../../core/constants/app_constants.dart';

class CalculateZakatUseCase {
  static const double _zakatRate = AppConstants.zakatRate;
  static const double _goldNisabGrams = AppConstants.goldNisabGrams;
  static const double _silverNisabGrams = AppConstants.silverNisabGrams;

  double calculateGoldNisab(double goldPricePerGram) =>
      _goldNisabGrams * goldPricePerGram;

  double calculateSilverNisab(double silverPricePerGram) =>
      _silverNisabGrams * silverPricePerGram;

  double calculateTotalWealth({
    required WealthData wealth,
    required double goldPricePerGram,
    required double silverPricePerGram,
  }) {
    double total = wealth.savedMoney;
    total += wealth.goldGrams * goldPricePerGram;
    total += wealth.silverGrams * silverPricePerGram;
    total += wealth.tradeGoods + wealth.debtsToReceive - wealth.debtsOwed;
    return total < 0 ? 0 : total;
  }

  double calculateZakatDue(double totalWealth, double goldNisabValue) {
    return totalWealth >= goldNisabValue ? totalWealth * _zakatRate : 0;
  }

  bool hasReachedNisab(double totalWealth, double goldNisabValue) {
    return totalWealth >= goldNisabValue;
  }

  int daysUntilZakat(DateTime? nisabDate) {
    if (nisabDate == null) return -1;
    return nisabDate
        .add(const Duration(days: AppConstants.hijriYearDays))
        .difference(DateTime.now())
        .inDays;
  }

  ZakatResult calculate({
    required WealthData wealth,
    required double goldPricePerGram,
    required double silverPricePerGram,
    required String currency,
    DateTime? nisabDate,
  }) {
    final goldNisab = calculateGoldNisab(goldPricePerGram);
    final silverNisab = calculateSilverNisab(silverPricePerGram);
    final total = calculateTotalWealth(
      wealth: wealth,
      goldPricePerGram: goldPricePerGram,
      silverPricePerGram: silverPricePerGram,
    );
    final reached = hasReachedNisab(total, goldNisab);
    final zakat = reached ? total * _zakatRate : 0.0;

    return ZakatResult(
      totalWealth: total,
      zakatDue: zakat,
      goldNisabValue: goldNisab,
      silverNisabValue: silverNisab,
      hasReachedNisab: reached,
      daysUntilZakat: daysUntilZakat(nisabDate),
      currency: currency,
    );
  }
}
