import 'package:flutter_test/flutter_test.dart';
import 'package:zakat_app/presentation/features/settings/settings_view_model.dart';
import 'package:zakat_app/domain/repositories/settings_repository.dart';

class FakeSettingsRepository implements SettingsRepository {
  bool _isDark = false;
  bool _ramadan = false;
  String _lang = 'ar';
  String _currencyCode = 'LYD';
  String _currencySymbol = 'د.ل';
  bool _fitrPaid = false;
  bool _cloudSync = false;
  double? _goldPrice;

  @override
  Future<void> saveDarkMode(bool isDark) async => _isDark = isDark;
  @override
  Future<bool> loadDarkMode() async => _isDark;
  @override
  Future<void> saveRamadanMode(bool on) async => _ramadan = on;
  @override
  Future<bool> loadRamadanMode() async => _ramadan;
  @override
  Future<void> saveLanguage(String langCode) async => _lang = langCode;
  @override
  Future<String> loadLanguage() async => _lang;
  @override
  Future<void> saveCurrency(String code, String symbol) async {
    _currencyCode = code;
    _currencySymbol = symbol;
  }
  @override
  Future<Map<String, String>> loadCurrency() async => {
    'code': _currencyCode,
    'symbol': _currencySymbol,
  };
  @override
  Future<void> saveFitrPaid(bool paid) async => _fitrPaid = paid;
  @override
  Future<bool> loadFitrPaid() async => _fitrPaid;
  @override
  Future<void> saveCloudSync(bool enabled) async => _cloudSync = enabled;
  @override
  Future<bool> loadCloudSync() async => _cloudSync;
  @override
  Future<void> saveGoldPrice(double price) async => _goldPrice = price;
  @override
  Future<double?> loadGoldPrice() async => _goldPrice;
}

void main() {
  late FakeSettingsRepository repo;
  late SettingsViewModel viewModel;

  setUp(() {
    repo = FakeSettingsRepository();
    viewModel = SettingsViewModel(repo);
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('SettingsViewModel', () {
    test('defaults before loadSettings are false/ar/false', () {
      expect(viewModel.isDarkMode, isFalse);
      expect(viewModel.language, equals('ar'));
      expect(viewModel.cloudSyncEnabled, isFalse);
    });

    test('loadSettings loads from repository', () async {
      await repo.saveDarkMode(true);
      await repo.saveLanguage('en');
      await viewModel.loadSettings();

      expect(viewModel.isDarkMode, isTrue);
      expect(viewModel.language, equals('en'));
    });

    test('toggleDarkMode persists to repository', () async {
      await viewModel.toggleDarkMode(true);
      expect(viewModel.isDarkMode, isTrue);
      expect(await repo.loadDarkMode(), isTrue);

      await viewModel.toggleDarkMode(false);
      expect(viewModel.isDarkMode, isFalse);
      expect(await repo.loadDarkMode(), isFalse);
    });

    test('setLanguage persists to repository', () async {
      await viewModel.setLanguage('en');
      expect(viewModel.language, equals('en'));
      expect(await repo.loadLanguage(), equals('en'));
    });

    test('toggleCloudSync persists to repository', () async {
      await viewModel.toggleCloudSync(true);
      expect(viewModel.cloudSyncEnabled, isTrue);
      expect(await repo.loadCloudSync(), isTrue);
    });

    test('notifyListeners fires on changes', () async {
      var notified = false;
      viewModel.addListener(() => notified = true);
      await viewModel.toggleDarkMode(true);
      expect(notified, isTrue);
    });
  });
}
