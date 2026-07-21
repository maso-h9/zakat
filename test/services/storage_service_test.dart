import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zakat_app/services/storage_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    await StorageService.clearAll();
  });

  group('StorageService - Dark mode', () {
    test('default is false', () async {
      expect(await StorageService.loadDarkMode(), isFalse);
    });

    test('save and load dark mode', () async {
      await StorageService.saveDarkMode(true);
      expect(await StorageService.loadDarkMode(), isTrue);
    });

    test('toggle off', () async {
      await StorageService.saveDarkMode(true);
      await StorageService.saveDarkMode(false);
      expect(await StorageService.loadDarkMode(), isFalse);
    });
  });

  group('StorageService - Ramadan mode', () {
    test('default is false', () async {
      expect(await StorageService.loadRamadanMode(), isFalse);
    });

    test('save and load ramadan mode', () async {
      await StorageService.saveRamadanMode(true);
      expect(await StorageService.loadRamadanMode(), isTrue);
    });
  });

  group('StorageService - Language', () {
    test('default is ar', () async {
      expect(await StorageService.loadLanguage(), equals('ar'));
    });

    test('save and load language', () async {
      await StorageService.saveLanguage('en');
      expect(await StorageService.loadLanguage(), equals('en'));
    });
  });

  group('StorageService - Currency', () {
    test('default is LYD', () async {
      final c = await StorageService.loadCurrency();
      expect(c['code'], equals('LYD'));
    });

    test('save and load currency', () async {
      await StorageService.saveCurrency('USD', '\$');
      final c = await StorageService.loadCurrency();
      expect(c['code'], equals('USD'));
      expect(c['symbol'], equals('\$'));
    });
  });

  group('StorageService - Cloud sync', () {
    test('default is false', () async {
      expect(await StorageService.loadCloudSync(), isFalse);
    });

    test('save and load', () async {
      await StorageService.saveCloudSync(true);
      expect(await StorageService.loadCloudSync(), isTrue);
    });
  });

  group('StorageService - Fitr paid', () {
    test('default is false', () async {
      expect(await StorageService.loadFitrPaid(), isFalse);
    });

    test('save and load', () async {
      await StorageService.saveFitrPaid(true);
      expect(await StorageService.loadFitrPaid(), isTrue);
    });
  });

  group('StorageService - Gold price', () {
    test('default is null', () async {
      expect(await StorageService.loadGoldPrice(), isNull);
    });

    test('save and load', () async {
      await StorageService.saveGoldPrice(1500.5);
      expect(await StorageService.loadGoldPrice(), closeTo(1500.5, 0.01));
    });
  });

  group('StorageService - Nisab date', () {
    test('default is null', () async {
      expect(await StorageService.loadNisabDate(), isNull);
    });

    test('save and load', () async {
      final date = DateTime(2025, 6, 15);
      await StorageService.saveNisabDate(date);
      final loaded = await StorageService.loadNisabDate();
      expect(loaded, equals(date));
    });
  });

  group('StorageService - clearAll', () {
    test('resets everything', () async {
      await StorageService.saveDarkMode(true);
      await StorageService.saveRamadanMode(true);
      await StorageService.saveLanguage('en');
      await StorageService.saveCurrency('USD', '\$');

      await StorageService.clearAll();

      expect(await StorageService.loadDarkMode(), isFalse);
      expect(await StorageService.loadRamadanMode(), isFalse);
      expect(await StorageService.loadLanguage(), equals('ar'));
      final c = await StorageService.loadCurrency();
      expect(c['code'], equals('LYD'));
    });
  });
}
