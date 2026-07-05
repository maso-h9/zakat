import 'package:flutter/foundation.dart';

class ZakatProvider extends ChangeNotifier {
  // أسعار المعادن (تُحدَّث من API)
  double goldPricePerGram = 285.0; // دينار ليبي تقريبي
  double silverPricePerGram = 3.2;
  String selectedCurrency = 'LYD';
  String currencySymbol = 'د.ل';

  // بيانات المستخدم
  double savedMoney = 0;
  double goldGrams = 0;
  double silverGrams = 0;
  double tradeGoods = 0;
  double debtsOwed = 0; // ديون على المستخدم
  double debtsToReceive = 0; // ديون يستحقها المستخدم
  DateTime? nisabDate;

  // سجل الزكاة
  List<ZakatRecord> zakatHistory = [];

  // نصاب الذهب بالغرام
  double get goldNisabGrams => 85.0;
  double get silverNisabGrams => 595.0;
  double get zakatRate => 0.025;

  // قيمة نصاب الذهب بالعملة
  double get goldNisabValue => goldNisabGrams * goldPricePerGram;
  double get silverNisabValue => silverNisabGrams * silverPricePerGram;

  // إجمالي المال الخاضع للزكاة
  double get totalZakatableWealth {
    double total = savedMoney;
    total += goldGrams * goldPricePerGram;
    total += silverGrams * silverPricePerGram;
    total += tradeGoods;
    total += debtsToReceive;
    total -= debtsOwed;
    return total < 0 ? 0 : total;
  }

  // هل بلغ النصاب؟
  bool get hasReachedNisab => totalZakatableWealth >= goldNisabValue;

  // مقدار الزكاة الواجبة
  double get zakatDue => hasReachedNisab ? totalZakatableWealth * zakatRate : 0;

  // أيام حتى موعد الزكاة
  int get daysUntilZakat {
    if (nisabDate == null) return -1;
    final dueDate = nisabDate!.add(const Duration(days: 354)); // حول هجري
    final now = DateTime.now();
    return dueDate.difference(now).inDays;
  }

  // تحديث البيانات
  void updateWealth({
    double? money,
    double? gold,
    double? silver,
    double? trade,
    double? debtsOwedVal,
    double? debtsReceive,
  }) {
    if (money != null) savedMoney = money;
    if (gold != null) goldGrams = gold;
    if (silver != null) silverGrams = silver;
    if (trade != null) tradeGoods = trade;
    if (debtsOwedVal != null) debtsOwed = debtsOwedVal;
    if (debtsReceive != null) debtsToReceive = debtsReceive;
    notifyListeners();
  }

  void setNisabDate(DateTime date) {
    nisabDate = date;
    notifyListeners();
  }

  void addZakatRecord(ZakatRecord record) {
    zakatHistory.add(record);
    notifyListeners();
  }

  void updateGoldPrice(double price) {
    goldPricePerGram = price;
    notifyListeners();
  }

  void setCurrency(String currency, String symbol) {
    selectedCurrency = currency;
    currencySymbol = symbol;
    notifyListeners();
  }

  // إجمالي الزكاة المدفوعة
  double get totalZakatPaid => zakatHistory.fold(0, (sum, r) => sum + r.amount);

  // متوسط الزكاة السنوي
  double get averageYearlyZakat {
    if (zakatHistory.isEmpty) return 0;
    final years = zakatHistory.map((r) => r.year).toSet().length;
    return totalZakatPaid / years;
  }
}

class ZakatRecord {
  final int year;
  final double amount;
  final double wealth;
  final DateTime date;
  final String note;

  ZakatRecord({
    required this.year,
    required this.amount,
    required this.wealth,
    required this.date,
    this.note = '',
  });
}

// نموذج العملات
class CurrencyModel {
  final String code;
  final String symbol;
  final String name;
  final double rateToUSD;

  const CurrencyModel({
    required this.code,
    required this.symbol,
    required this.name,
    required this.rateToUSD,
  });
}

const List<CurrencyModel> currencies = [
  CurrencyModel(
      code: 'LYD', symbol: 'د.ل', name: 'دينار ليبي', rateToUSD: 4.85),
  CurrencyModel(
      code: 'SAR', symbol: 'ر.س', name: 'ريال سعودي', rateToUSD: 3.75),
  CurrencyModel(
      code: 'AED', symbol: 'د.إ', name: 'درهم إماراتي', rateToUSD: 3.67),
  CurrencyModel(code: 'EGP', symbol: 'ج.م', name: 'جنيه مصري', rateToUSD: 30.9),
  CurrencyModel(
      code: 'USD', symbol: '\$', name: 'دولار أمريكي', rateToUSD: 1.0),
  CurrencyModel(code: 'EUR', symbol: '€', name: 'يورو', rateToUSD: 0.92),
  CurrencyModel(
      code: 'GBP', symbol: '£', name: 'جنيه إسترليني', rateToUSD: 0.79),
  CurrencyModel(
      code: 'KWD', symbol: 'د.ك', name: 'دينار كويتي', rateToUSD: 0.31),
  CurrencyModel(code: 'QAR', symbol: 'ر.ق', name: 'ريال قطري', rateToUSD: 3.64),
  CurrencyModel(
      code: 'JOD', symbol: 'د.أ', name: 'دينار أردني', rateToUSD: 0.71),
  CurrencyModel(
      code: 'MAD', symbol: 'د.م', name: 'درهم مغربي', rateToUSD: 10.1),
  CurrencyModel(
      code: 'TND', symbol: 'د.ت', name: 'دينار تونسي', rateToUSD: 3.12),
];
