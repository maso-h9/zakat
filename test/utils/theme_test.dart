import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zakat_app/utils/theme.dart';

void main() {
  group('ZakatTheme', () {
    test('theme is a valid ThemeData', () {
      expect(ZakatTheme.theme, isA<ThemeData>());
    });

    test('darkTheme is a valid ThemeData', () {
      expect(ZakatTheme.darkTheme, isA<ThemeData>());
    });

    test('ramadanTheme is a valid ThemeData', () {
      expect(ZakatTheme.ramadanTheme, isA<ThemeData>());
    });

    test('darkRamadanTheme is a valid ThemeData', () {
      expect(ZakatTheme.darkRamadanTheme, isA<ThemeData>());
    });

    test('darkTheme is dark', () {
      expect(ZakatTheme.darkTheme.brightness, Brightness.dark);
    });

    test('darkRamadanTheme is dark', () {
      expect(ZakatTheme.darkRamadanTheme.brightness, Brightness.dark);
    });

    test('all color constants are non-null', () {
      expect(ZakatTheme.gold, isNotNull);
      expect(ZakatTheme.deepGreen, isNotNull);
      expect(ZakatTheme.ramadanGold, isNotNull);
      expect(ZakatTheme.ramadanNavy, isNotNull);
    });

    test('gold and ramadanGold are distinct', () {
      expect(ZakatTheme.gold, isNot(equals(ZakatTheme.ramadanGold)));
    });

    test('deepGreen and ramadanNavy are distinct', () {
      expect(ZakatTheme.deepGreen, isNot(equals(ZakatTheme.ramadanNavy)));
    });
  });
}
