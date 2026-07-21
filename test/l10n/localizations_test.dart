import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zakat_app/l10n/app_localizations.dart';

void main() {
  group('AppLocalizations', () {
    late AppLocalizations en;
    late AppLocalizations ar;

    setUp(() {
      en = AppLocalizations(const Locale('en'));
      ar = AppLocalizations(const Locale('ar'));
    });

    test('basic strings are not empty', () {
      expect(en.appName, isNotEmpty);
      expect(en.appSubtitle, isNotEmpty);
      expect(en.loading, isNotEmpty);
      expect(en.noData, isNotEmpty);
      expect(en.ok, isNotEmpty);
      expect(en.cancel, isNotEmpty);
      expect(en.confirm, isNotEmpty);
      expect(en.delete, isNotEmpty);
      expect(en.save, isNotEmpty);
    });

    test('navigation strings are localized', () {
      expect(en.home, isNotEmpty);
      expect(en.settings, isNotEmpty);
      expect(en.aboutApp, isNotEmpty);
      expect(en.language, isNotEmpty);
    });

    test('calculator strings are localized', () {
      expect(en.calculator, isNotEmpty);
      expect(en.calculatorTitle, isNotEmpty);
      expect(en.goldSection, isNotEmpty);
      expect(en.silverSection, isNotEmpty);
      expect(en.cashAndSavings, isNotEmpty);
      expect(en.receivables, isNotEmpty);
      expect(en.tradeGoodsZakat, isNotEmpty);
    });

    test('zakat strings are localized', () {
      expect(en.zakatDue, isNotEmpty);
      expect(en.zakatDueLabel, isNotEmpty);
      expect(en.totalWealth, isNotEmpty);
      expect(en.nisabInfo, isNotEmpty);
      expect(en.calculateAndSave, isNotEmpty);
      expect(en.calculateMyZakat, isNotEmpty);
    });

    test('madhab strings are localized', () {
      expect(en.madhabsComparison, isNotEmpty);
      expect(en.shafii, isNotEmpty);
      expect(en.hanafi, isNotEmpty);
      expect(en.maliki, isNotEmpty);
      expect(en.hanbali, isNotEmpty);
      expect(en.preferred, isNotEmpty);
    });

    test('hadith strings are localized', () {
      expect(en.ahadith, isNotEmpty);
      expect(en.narrator, isNotEmpty);
      expect(en.dailyHadith, isNotEmpty);
      expect(en.islamicHadith, isNotEmpty);
    });

    test('settings strings are localized', () {
      expect(en.darkMode, isNotEmpty);
      expect(en.ramadanMode, isNotEmpty);
      expect(en.cloudSync, isNotEmpty);
      expect(en.appearance, isNotEmpty);
    });

    test('Arabic is distinct from English', () {
      expect(en.appName, isNot(equals(ar.appName)));
      expect(en.home, isNot(equals(ar.home)));
      expect(en.settings, isNot(equals(ar.settings)));
      expect(en.darkMode, isNot(equals(ar.darkMode)));
    });

    test('invalid locale falls back to English', () {
      final fallback = AppLocalizations(const Locale('xx'));
      expect(fallback.appName, equals(en.appName));
      expect(fallback.home, equals(en.home));
    });

    test('profile and auth strings exist', () {
      expect(en.profileTitle, isNotEmpty);
      expect(en.myAccount, isNotEmpty);
      expect(en.email, isNotEmpty);
      expect(en.password, isNotEmpty);
      expect(en.forgotPassword, isNotEmpty);
      expect(en.continueWithGoogle, isNotEmpty);
      expect(en.loginTitle, isNotEmpty);
    });

    test('AI screen strings exist', () {
      expect(en.aiAssistantTitle, isNotEmpty);
      expect(en.aiZakatAssistant, isNotEmpty);
      expect(en.askQuestion, isNotEmpty);
      expect(en.aiPlaceholder, isNotEmpty);
      expect(en.zakatDisclaimer, isNotEmpty);
    });

    test('what-if screen strings exist', () {
      expect(en.whatIfTitle, isNotEmpty);
      expect(en.whatIfPlanning, isNotEmpty);
      expect(en.scenarioComparison, isNotEmpty);
      expect(en.scenarioOne, isNotEmpty);
      expect(en.scenarioTwo, isNotEmpty);
    });

    test('nisab strings exist', () {
      expect(en.nisabSources, isNotEmpty);
      expect(en.nisabSourcesDesc, isNotEmpty);
      expect(en.globalNisab, isNotEmpty);
      expect(en.officialNisab, isNotEmpty);
      expect(en.nisabCalculated, isNotEmpty);
      expect(en.belowNisab, isNotEmpty);
      expect(en.reachedNisab, isNotEmpty);
    });

    test('livestock strings exist', () {
      expect(en.livestockTitle, isNotEmpty);
      expect(en.cattle, isNotEmpty);
      expect(en.sheep, isNotEmpty);
      expect(en.camelCount, isNotEmpty);
      expect(en.cattleCount, isNotEmpty);
    });

    test('calendar strings exist', () {
      expect(en.calendar, isNotEmpty);
      expect(en.annualCalendar, isNotEmpty);
      expect(en.annualZakatCalendar, isNotEmpty);
      expect(en.nextZakatDate, isNotEmpty);
    });

    test('statistics strings exist', () {
      expect(en.myStats, isNotEmpty);
      expect(en.myStatsTitle, isNotEmpty);
      expect(en.personalStats, isNotEmpty);
      expect(en.accountSummary, isNotEmpty);
      expect(en.annualAverage, isNotEmpty);
    });
  });
}
