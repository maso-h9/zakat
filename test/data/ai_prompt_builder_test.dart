import 'package:flutter_test/flutter_test.dart';
import 'package:zakat_app/data/datasources/ai_prompt_builder.dart';

void main() {
  group('AiPromptBuilder', () {
    group('buildSystemPrompt', () {
      test('Arabic prompt contains user wealth data', () {
        final prompt = AiPromptBuilder.buildSystemPrompt(
          isArabic: true,
          totalWealth: 100000,
          zakatDue: 2500,
          goldPricePerGram: 285,
          goldNisab: 24225,
          hasReachedNisab: true,
          currency: 'LYD',
        );
        expect(prompt, contains('100000'));
        expect(prompt, contains('2500'));
        expect(prompt, contains('285'));
        expect(prompt, contains('LYD'));
        expect(prompt, contains('نعم'));
      });

      test('English prompt contains user wealth data', () {
        final prompt = AiPromptBuilder.buildSystemPrompt(
          isArabic: false,
          totalWealth: 50000,
          zakatDue: 1250,
          goldPricePerGram: 300,
          goldNisab: 25500,
          hasReachedNisab: false,
          currency: 'USD',
        );
        expect(prompt, contains('50000'));
        expect(prompt, contains('1250'));
        expect(prompt, contains('300'));
        expect(prompt, contains('USD'));
        expect(prompt, contains('No'));
      });

      test('Arabic prompt is in Arabic', () {
        final prompt = AiPromptBuilder.buildSystemPrompt(
          isArabic: true,
          totalWealth: 0,
          zakatDue: 0,
          goldPricePerGram: 0,
          goldNisab: 0,
          hasReachedNisab: false,
          currency: 'LYD',
        );
        expect(prompt, contains('مساعد ذكي'));
        expect(prompt, contains('الزكاة'));
      });

      test('English prompt is in English', () {
        final prompt = AiPromptBuilder.buildSystemPrompt(
          isArabic: false,
          totalWealth: 0,
          zakatDue: 0,
          goldPricePerGram: 0,
          goldNisab: 0,
          hasReachedNisab: false,
          currency: 'USD',
        );
        expect(prompt, contains('AI assistant'));
        expect(prompt, contains('Zakat'));
      });

      test('Arabic prompt has reached nisab = yes', () {
        final prompt = AiPromptBuilder.buildSystemPrompt(
          isArabic: true,
          totalWealth: 100000,
          zakatDue: 2500,
          goldPricePerGram: 285,
          goldNisab: 24225,
          hasReachedNisab: true,
          currency: 'LYD',
        );
        expect(prompt, contains('نعم'));
      });

      test('Arabic prompt not reached nisab = no', () {
        final prompt = AiPromptBuilder.buildSystemPrompt(
          isArabic: true,
          totalWealth: 1000,
          zakatDue: 0,
          goldPricePerGram: 285,
          goldNisab: 24225,
          hasReachedNisab: false,
          currency: 'LYD',
        );
        expect(prompt, contains('لا'));
      });

      test('English prompt has reached nisab = Yes', () {
        final prompt = AiPromptBuilder.buildSystemPrompt(
          isArabic: false,
          totalWealth: 100000,
          zakatDue: 2500,
          goldPricePerGram: 285,
          goldNisab: 24225,
          hasReachedNisab: true,
          currency: 'LYD',
        );
        expect(prompt, contains('Yes'));
      });

      test('prompt mentions four schools of thought', () {
        final promptEn = AiPromptBuilder.buildSystemPrompt(
          isArabic: false,
          totalWealth: 0,
          zakatDue: 0,
          goldPricePerGram: 0,
          goldNisab: 0,
          hasReachedNisab: false,
          currency: 'USD',
        );
        expect(promptEn, contains('4 schools'));
      });
    });

    group('suggestions', () {
      test('Arabic suggestions are non-empty', () {
        final suggestions = AiPromptBuilder.suggestions(true);
        expect(suggestions, isNotEmpty);
        expect(suggestions.length, 4);
        for (final s in suggestions) {
          expect(s, isNotEmpty);
        }
      });

      test('English suggestions are non-empty', () {
        final suggestions = AiPromptBuilder.suggestions(false);
        expect(suggestions, isNotEmpty);
        expect(suggestions.length, 4);
        for (final s in suggestions) {
          expect(s, isNotEmpty);
        }
      });

      test('Arabic and English suggestions are different', () {
        final ar = AiPromptBuilder.suggestions(true);
        final en = AiPromptBuilder.suggestions(false);
        expect(ar, isNot(equals(en)));
      });
    });

    group('welcomeMessage', () {
      test('Arabic welcome message is non-empty and in Arabic', () {
        final msg = AiPromptBuilder.welcomeMessage(true);
        expect(msg, isNotEmpty);
        expect(msg, contains('السلام عليكم'));
      });

      test('English welcome message is non-empty and in English', () {
        final msg = AiPromptBuilder.welcomeMessage(false);
        expect(msg, isNotEmpty);
        expect(msg, contains('Hello'));
      });

      test('Arabic and English welcome messages are different', () {
        expect(
          AiPromptBuilder.welcomeMessage(true),
          isNot(equals(AiPromptBuilder.welcomeMessage(false))),
        );
      });
    });
  });
}
