import 'package:flutter_test/flutter_test.dart';
import 'package:zakat_app/domain/entities/ai_message.dart';

void main() {
  group('AiMessage', () {
    group('constructor', () {
      test('creates with required fields', () {
        final msg = AiMessage(text: 'Hello', isUser: true);
        expect(msg.text, 'Hello');
        expect(msg.isUser, isTrue);
        expect(msg.isError, isFalse);
        expect(msg.createdAt, isA<DateTime>());
      });

      test('defaults isError to false', () {
        final msg = AiMessage(text: 'test', isUser: false);
        expect(msg.isError, isFalse);
      });

      test('accepts custom isError', () {
        final msg = AiMessage(text: 'error', isUser: false, isError: true);
        expect(msg.isError, isTrue);
      });

      test('accepts custom createdAt', () {
        final fixed = DateTime(2025, 1, 1);
        final msg = AiMessage(text: 'test', isUser: true, createdAt: fixed);
        expect(msg.createdAt, fixed);
      });

      test('defaults createdAt to now', () {
        final before = DateTime.now();
        final msg = AiMessage(text: 'test', isUser: true);
        final after = DateTime.now();
        expect(msg.createdAt.isAfter(before) || msg.createdAt.isAtSameMomentAs(before), isTrue);
        expect(msg.createdAt.isBefore(after) || msg.createdAt.isAtSameMomentAs(after), isTrue);
      });
    });

    group('copyWith', () {
      test('copies with no changes preserves all fields', () {
        final original = AiMessage(text: 'hello', isUser: true, isError: false);
        final copy = original.copyWith();
        expect(copy.text, original.text);
        expect(copy.isUser, original.isUser);
        expect(copy.isError, original.isError);
        expect(copy.createdAt, original.createdAt);
      });

      test('copies with text change', () {
        final original = AiMessage(text: 'hello', isUser: true);
        final copy = original.copyWith(text: 'world');
        expect(copy.text, 'world');
        expect(copy.isUser, isTrue);
      });

      test('copies with isUser change', () {
        final original = AiMessage(text: 'hello', isUser: true);
        final copy = original.copyWith(isUser: false);
        expect(copy.isUser, isFalse);
        expect(copy.text, 'hello');
      });

      test('copies with isError change', () {
        final original = AiMessage(text: 'hello', isUser: false);
        final copy = original.copyWith(isError: true);
        expect(copy.isError, isTrue);
      });

      test('preserves createdAt across copyWith', () {
        final fixed = DateTime(2025, 6, 15);
        final original = AiMessage(text: 'a', isUser: true, createdAt: fixed);
        final copy = original.copyWith(text: 'b');
        expect(copy.createdAt, fixed);
      });
    });

    group('toMap / fromMap', () {
      test('toMap produces correct keys', () {
        final msg = AiMessage(text: 'Hello', isUser: true, isError: false);
        final map = msg.toMap();
        expect(map['text'], 'Hello');
        expect(map['isUser'], 'true');
        expect(map['isError'], 'false');
      });

      test('toMap with isError true', () {
        final msg = AiMessage(text: 'err', isUser: false, isError: true);
        final map = msg.toMap();
        expect(map['isError'], 'true');
      });

      test('fromMap restores fields correctly', () {
        final map = {'text': 'Hello', 'isUser': 'true', 'isError': 'false'};
        final msg = AiMessage.fromMap(map);
        expect(msg.text, 'Hello');
        expect(msg.isUser, isTrue);
        expect(msg.isError, isFalse);
      });

      test('fromMap with isError true', () {
        final map = {'text': 'Error occurred', 'isUser': 'false', 'isError': 'true'};
        final msg = AiMessage.fromMap(map);
        expect(msg.isError, isTrue);
        expect(msg.isUser, isFalse);
      });

      test('toMap/fromMap roundtrip preserves data', () {
        final original = AiMessage(text: 'test msg', isUser: true, isError: false);
        final restored = AiMessage.fromMap(original.toMap());
        expect(restored.text, original.text);
        expect(restored.isUser, original.isUser);
        expect(restored.isError, original.isError);
      });

      test('fromMap handles missing keys gracefully', () {
        final msg = AiMessage.fromMap({});
        expect(msg.text, '');
        expect(msg.isUser, isFalse);
        expect(msg.isError, isFalse);
      });

      test('fromMap handles extra keys gracefully', () {
        final msg = AiMessage.fromMap({
          'text': 'hi',
          'isUser': 'true',
          'isError': 'false',
          'extra': 'ignored',
        });
        expect(msg.text, 'hi');
        expect(msg.isUser, isTrue);
      });
    });
  });
}
