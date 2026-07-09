// ================================================================
// zakat_provider.dart — V11 النهائي
// يضيف: NisabMethod + officialSources + setNisabMethod/setOfficialNisab/setCustomNisab
// باقي الكود مطابق لـ V10 بدون تغيير
// ================================================================
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/gold_price_service.dart';
import '../services/firebase_service.dart';

// ── أنواع طريقة النصاب ───────────────────────────────────────
enum NisabMethod { global, official, custom }

// ── المصادر الرسمية ──────────────────────────────────────────
class OfficialSource {
  final String currency, nameAr, nameEn, url;
  const OfficialSource({
    required this.currency,
    required this.nameAr,
    required this.nameEn,
    required this.url,
  });
}

const List<OfficialSource> officialSources = [
  OfficialSource(
      currency: 'LYD',
      nameAr: 'صندوق الزكاة الليبي',
      nameEn: 'Libyan Zakat Fund',
      url: 'https://www.facebook.com/ZakatFundLibya'),
  OfficialSource(
      currency: 'EGP',
      nameAr: 'دار الإفتاء المصرية',
      nameEn: 'Egyptian Dar Al-Ifta',
      url: 'https://www.dar-alifta.org'),
  OfficialSource(
      currency: 'SAR',
      nameAr: 'هيئة الزكاة والضريبة والجمارك',
      nameEn: 'ZATCA Saudi Arabia',
      url: 'https://zatca.gov.sa'),
  OfficialSource(
      currency: 'AED',
      nameAr: 'الهيئة العامة للشؤون الإسلامية',
      nameEn: 'GAIAE UAE',
      url: 'https://www.gaiae.gov.ae'),
  OfficialSource(
      currency: 'KWD',
      nameAr: 'بيت الزكاة الكويتي',
      nameEn: 'Kuwait Zakat House',
      url: 'https://www.zakathouse.org.kw'),
  OfficialSource(
      currency: 'QAR',
      nameAr: 'وزارة الأوقاف القطرية',
      nameEn: 'Qatar Ministry of Awqaf',
      url: 'https://www.awqaf.gov.qa'),
  OfficialSource(
      currency: 'JOD',
      nameAr: 'دائرة الإفتاء الأردنية',
      nameEn: 'Jordan Iftaa Department',
      url: 'https://www.aliftaa.jo'),
  OfficialSource(
      currency: 'MAD',
      nameAr: 'وزارة الأوقاف المغربية',
      nameEn: 'Morocco Ministry of Awqaf',
      url: 'https://www.habous.gov.ma'),
  OfficialSource(
      currency: 'TND',
      nameAr: 'ديوان الإفتاء التونسي',
      nameEn: 'Tunisia Dar Al-Ifta',
      url: 'https://www.mam.gov.tn'),
  OfficialSource(
      currency: 'DZD',
      nameAr: 'وزارة الشؤون الدينية الجزائرية',
      nameEn: 'Algeria Ministry of Religious Affairs',
      url: 'https://www.marw.dz'),
];

// ════════════════════════════════════════════════════════════════
class ZakatProvider extends ChangeNotifier {
  // ── الأسعار ─────────────────────────────────────────────────
  double goldPricePerGram = 285.0;
  double silverPricePerGram = 3.2;
  bool goldPriceIsLive = false;
  String? goldPriceLastUpdated;
  bool isLoadingGoldPrice = false;

  // ── العملة ──────────────────────────────────────────────────
  String selectedCurrency = 'LYD';
  String currencySymbol = 'د.ل';

  // ── الثروة ──────────────────────────────────────────────────
  double savedMoney = 0;
  double goldGrams = 0;
  double silverGrams = 0;
  double tradeGoods = 0;
  double debtsOwed = 0;
  double debtsToReceive = 0;
  DateTime? nisabDate;

  List<ZakatRecord> zakatHistory = [];

  // ── الإعدادات ────────────────────────────────────────────────
  bool isRamadanMode = false;
  bool fitrPaid = false;
  bool isDarkMode = false;

  // ── اللغة ────────────────────────────────────────────────────
  Locale _locale = const Locale('ar', 'SA');
  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';

  // ── Firebase ────────────────────────────────────────────────
  bool isSyncing = false;
  bool cloudSyncEnabled = false;
  DateTime? lastSyncTime;

  // ── طريقة النصاب (V11) ──────────────────────────────────────
  NisabMethod nisabMethod = NisabMethod.global;
  double officialNisabValue = 0.0;
  double customNisabValue = 0.0;

  bool _loaded = false;

  // ════════════════════════════════════════════════════════════
  // تهيئة
  // ════════════════════════════════════════════════════════════
  Future<void> init() async {
    if (_loaded) return;
    _loaded = true;

    await GoldPriceService.initHive();

    await StorageService.loadWealth(this);
    nisabDate = await StorageService.loadNisabDate();
    zakatHistory = await StorageService.loadHistory();
    final curr = await StorageService.loadCurrency();
    selectedCurrency = curr['code']!;
    currencySymbol = curr['symbol']!;
    isRamadanMode = await StorageService.loadRamadanMode();
    fitrPaid = await StorageService.loadFitrPaid();
    isDarkMode = await StorageService.loadDarkMode();
    cloudSyncEnabled = await StorageService.loadCloudSync();

    final langCode = await StorageService.loadLanguage();
    _locale =
        langCode == 'en' ? const Locale('en', 'US') : const Locale('ar', 'SA');

    // تحميل إعدادات النصاب
    final nisabData = await StorageService.loadNisabMethod();
    nisabMethod = nisabData['method'] as NisabMethod;
    officialNisabValue = nisabData['official'] as double;
    customNisabValue = nisabData['custom'] as double;

    final savedPrice = await StorageService.loadGoldPrice();
    if (savedPrice != null) goldPricePerGram = savedPrice;

    notifyListeners();
    fetchGoldPrice();
    if (cloudSyncEnabled) await _initCloudSync();
  }

  // ════════════════════════════════════════════════════════════
  // طرق النصاب
  // ════════════════════════════════════════════════════════════

  // النصاب الفعلي المستخدم في كل الحسابات
  double get goldNisabValue {
    switch (nisabMethod) {
      case NisabMethod.official:
        return officialNisabValue > 0 ? officialNisabValue : _globalNisab;
      case NisabMethod.custom:
        return customNisabValue > 0 ? customNisabValue : _globalNisab;
      case NisabMethod.global:
        return _globalNisab;
    }
  }

  double get _globalNisab => goldNisabGrams * goldPricePerGram;

  Future<void> setNisabMethod(NisabMethod method) async {
    nisabMethod = method;
    notifyListeners();
    await StorageService.saveNisabMethod(
        method, officialNisabValue, customNisabValue);
  }

  Future<void> setOfficialNisab(double value) async {
    officialNisabValue = value;
    notifyListeners();
    await StorageService.saveNisabMethod(
        nisabMethod, officialNisabValue, customNisabValue);
  }

  Future<void> setCustomNisab(double value) async {
    customNisabValue = value;
    notifyListeners();
    await StorageService.saveNisabMethod(
        nisabMethod, officialNisabValue, customNisabValue);
  }

  double calcNisabFromGramPrice(double gramPrice) => gramPrice * 85;
  double calcNisabFromOz(double ozPrice, double exchangeRate) =>
      (ozPrice / 31.1035) * 85 * exchangeRate;

  // ════════════════════════════════════════════════════════════
  // سعر الذهب
  // ════════════════════════════════════════════════════════════
  Future<void> fetchGoldPrice() async {
    isLoadingGoldPrice = true;
    notifyListeners();

    final result =
        await GoldPriceService.fetchGoldPricePerGram(selectedCurrency);
    goldPricePerGram = result.pricePerGram;
    silverPricePerGram = result.silverPricePerGram;
    goldPriceIsLive = result.isLive;
    goldPriceLastUpdated = result.formattedTime;

    if (result.pricePerGram > 0) {
      await StorageService.saveGoldPrice(result.pricePerGram);
    }

    isLoadingGoldPrice = false;
    notifyListeners();
  }

  // ════════════════════════════════════════════════════════════
  // حسابات الزكاة
  // ════════════════════════════════════════════════════════════
  double get goldNisabGrams => 85.0;
  double get silverNisabGrams => 595.0;
  double get zakatRate => 0.025;
  double get silverNisabValue => silverNisabGrams * silverPricePerGram;
  double get totalWealth => totalZakatableWealth;

  double get totalZakatableWealth {
    double t = savedMoney;
    t += goldGrams * goldPricePerGram;
    t += silverGrams * silverPricePerGram;
    t += tradeGoods;
    t += debtsToReceive;
    t -= debtsOwed;
    return t < 0 ? 0 : t;
  }

  bool get hasReachedNisab => totalZakatableWealth >= goldNisabValue;
  double get zakatDue => hasReachedNisab ? totalZakatableWealth * zakatRate : 0;

  int get daysUntilZakat {
    if (nisabDate == null) return -1;
    return nisabDate!
        .add(const Duration(days: 354))
        .difference(DateTime.now())
        .inDays;
  }

  DateTime? get zakatDueDate => nisabDate?.add(const Duration(days: 354));
  double get fitrAmount => goldPricePerGram * 2;

  // ════════════════════════════════════════════════════════════
  // اللغة
  // ════════════════════════════════════════════════════════════
  Future<void> setLanguage(String langCode) async {
    _locale =
        langCode == 'en' ? const Locale('en', 'US') : const Locale('ar', 'SA');
    notifyListeners();
    await StorageService.saveLanguage(langCode);
  }

  // ════════════════════════════════════════════════════════════
  // Firebase
  // ════════════════════════════════════════════════════════════
  Future<void> _initCloudSync() async {
    try {
      await FirebaseService.signInAnonymously();
      await FirebaseService.loadAll(this);
      zakatHistory = await FirebaseService.loadHistory();
      lastSyncTime = DateTime.now();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> toggleCloudSync(bool on) async {
    cloudSyncEnabled = on;
    notifyListeners();
    await StorageService.saveCloudSync(on);
    if (on) {
      await _initCloudSync();
      await _pushToCloud();
    }
  }

  Future<void> _pushToCloud() async {
    if (!cloudSyncEnabled || !FirebaseService.isSignedIn) return;
    try {
      isSyncing = true;
      notifyListeners();
      await FirebaseService.saveAll(this);
      await FirebaseService.saveHistory(zakatHistory);
      lastSyncTime = DateTime.now();
    } catch (_) {
    } finally {
      isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> syncNow() async {
    if (!cloudSyncEnabled) return;
    await FirebaseService.signInAnonymously();
    await _pushToCloud();
    await FirebaseService.loadAll(this);
    zakatHistory = await FirebaseService.loadHistory();
    lastSyncTime = DateTime.now();
    notifyListeners();
  }

  // ════════════════════════════════════════════════════════════
  // تحديث مع حفظ
  // ════════════════════════════════════════════════════════════
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
    StorageService.saveWealth(this);
    _pushToCloud();
  }

  void setNisabDate(DateTime date) {
    nisabDate = date;
    notifyListeners();
    StorageService.saveNisabDate(date);
    _pushToCloud();
  }

  void addZakatRecord(ZakatRecord record) {
    zakatHistory.add(record);
    notifyListeners();
    StorageService.saveHistory(zakatHistory);
    _pushToCloud();
  }

  void setCurrency(String code, String symbol) {
    selectedCurrency = code;
    currencySymbol = symbol;
    notifyListeners();
    StorageService.saveCurrency(code, symbol);
    fetchGoldPrice();
    _pushToCloud();
  }

  void toggleRamadanMode(bool on) {
    isRamadanMode = on;
    notifyListeners();
    StorageService.saveRamadanMode(on);
    _pushToCloud();
  }

  void markFitrPaid(bool paid) {
    fitrPaid = paid;
    notifyListeners();
    StorageService.saveFitrPaid(paid);
    _pushToCloud();
  }

  void toggleDarkMode(bool on) {
    isDarkMode = on;
    notifyListeners();
    StorageService.saveDarkMode(on);
  }

  // ════════════════════════════════════════════════════════════
  // إحصائيات
  // ════════════════════════════════════════════════════════════
  double get totalZakatPaid => zakatHistory.fold(0, (s, r) => s + r.amount);
  double get averageYearlyZakat {
    if (zakatHistory.isEmpty) return 0;
    return totalZakatPaid / zakatHistory.map((r) => r.year).toSet().length;
  }

  int get yearsCount => zakatHistory.map((r) => r.year).toSet().length;
  Map<int, double> get yearlyZakat {
    final map = <int, double>{};
    for (final r in zakatHistory) {
      map[r.year] = (map[r.year] ?? 0) + r.amount;
    }
    return map;
  }
}

// ── النماذج ──────────────────────────────────────────────────
class ZakatRecord {
  final int year;
  final double amount, wealth;
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

class CurrencyModel {
  final String code, symbol, name;
  const CurrencyModel(
      {required this.code, required this.symbol, required this.name});
}

const List<CurrencyModel> currencies = [
  CurrencyModel(code: 'LYD', symbol: 'د.ل', name: 'دينار ليبي'),
  CurrencyModel(code: 'SAR', symbol: 'ر.س', name: 'ريال سعودي'),
  CurrencyModel(code: 'AED', symbol: 'د.إ', name: 'درهم إماراتي'),
  CurrencyModel(code: 'EGP', symbol: 'ج.م', name: 'جنيه مصري'),
  CurrencyModel(code: 'USD', symbol: '\$', name: 'دولار أمريكي'),
  CurrencyModel(code: 'EUR', symbol: '€', name: 'يورو'),
  CurrencyModel(code: 'GBP', symbol: '£', name: 'جنيه إسترليني'),
  CurrencyModel(code: 'KWD', symbol: 'د.ك', name: 'دينار كويتي'),
  CurrencyModel(code: 'QAR', symbol: 'ر.ق', name: 'ريال قطري'),
  CurrencyModel(code: 'JOD', symbol: 'د.أ', name: 'دينار أردني'),
  CurrencyModel(code: 'MAD', symbol: 'د.م', name: 'درهم مغربي'),
  CurrencyModel(code: 'TND', symbol: 'د.ت', name: 'دينار تونسي'),
];
