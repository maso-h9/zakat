// ================================================================
// services/ai_repository.dart — AiRepository مستقل (بند 23)
// فصل منطق Gemini عن الـ UI
// AiPromptBuilder · AiResponseParser · AiRepository
// ================================================================
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/errors/app_exception.dart';
import '../core/utils/app_logger.dart';

// ══════════════════════════════════════════════════════════════
// نموذج الرسالة
// ══════════════════════════════════════════════════════════════
class AiMessage {
  final String text;
  final bool isUser;
  final bool isError;
  final DateTime createdAt;

  AiMessage({
    required this.text,
    required this.isUser,
    this.isError = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

// ══════════════════════════════════════════════════════════════
// AiPromptBuilder — بناء الـ System Prompt (بند 23)
// ══════════════════════════════════════════════════════════════
class AiPromptBuilder {
  static String buildSystemPrompt({
    required bool isArabic,
    required double totalWealth,
    required double zakatDue,
    required double goldPricePerGram,
    required double goldNisab,
    required bool hasReachedNisab,
    required String currency,
  }) {
    if (isArabic) {
      return '''أنت مساعد ذكي عام يستطيع الإجابة على أي سؤال، مع تخصص إضافي في أحكام الزكاة الإسلامية. تجيب بالعربية الفصحى الواضحة.

بيانات المستخدم الحالية (استخدمها فقط عند السؤال عن الزكاة):
- إجمالي الثروة: ${totalWealth.toStringAsFixed(2)} $currency
- الزكاة الواجبة: ${zakatDue.toStringAsFixed(2)} $currency
- سعر الذهب: ${goldPricePerGram.toStringAsFixed(2)} $currency/جرام
- نصاب الذهب (85 جرام): ${goldNisab.toStringAsFixed(2)} $currency
- هل بلغ النصاب: ${hasReachedNisab ? "نعم" : "لا"}

قواعد:
1. إذا كان السؤال عن الزكاة: استند للقرآن والسنة، واذكر آراء المذاهب الأربعة عند الاختلاف
2. إذا كان السؤال عاماً: أجب بشكل طبيعي ومفيد
3. الإجابات مختصرة، لا تزيد عن 300 كلمة
4. للأسئلة الحسابية، اعرض الخطوات بوضوح''';
    }

    return '''You are a general-purpose AI assistant with expertise in Islamic Zakat rulings. Respond in clear English.

Current user data (use only when asked about Zakat):
- Total wealth: ${totalWealth.toStringAsFixed(2)} $currency
- Zakat due: ${zakatDue.toStringAsFixed(2)} $currency
- Gold price: ${goldPricePerGram.toStringAsFixed(2)} $currency/gram
- Gold Nisab (85g): ${goldNisab.toStringAsFixed(2)} $currency
- Reached Nisab: ${hasReachedNisab ? "Yes" : "No"}

Rules:
1. Zakat questions: cite Quran/Sunnah, mention 4 schools of thought
2. General questions: respond naturally and helpfully
3. Keep answers under 300 words
4. For calculations, show steps clearly''';
  }

  static List<String> suggestions(bool isArabic) => isArabic
      ? [
          'كيف أحسب زكاة مدخراتي؟',
          'ما حكم زكاة الراتب؟',
          'من هم مستحقو الزكاة؟',
          'ما الفرق بين الزكاة والصدقة؟',
        ]
      : [
          'How do I calculate Zakat on savings?',
          'Is Zakat due on salary?',
          'Who is eligible for Zakat?',
          'What\'s the difference between Zakat and charity?',
        ];

  static String welcomeMessage(bool isArabic) => isArabic
      ? 'السلام عليكم! أنا مساعدك الذكي.\n\nيمكنني مساعدتك في:\n• حساب زكاة أموالك وتجارتك\n• أحكام الزكاة من المذاهب الأربعة\n• مصارف الزكاة الشرعية\n• فتاوى الزكاة المعاصرة\n• أو أي سؤال عام آخر\n\nاسألني أي شيء.'
      : 'Hello! I\'m your AI assistant.\n\nI can help with:\n• Calculating Zakat on your wealth\n• Zakat rulings across the 4 schools\n• Legitimate Zakat recipients\n• Contemporary Zakat fatwas\n• Or any general question\n\nAsk me anything.';
}

// ══════════════════════════════════════════════════════════════
// AiResponseParser — تحليل استجابة Gemini (بند 23)
// ══════════════════════════════════════════════════════════════
class AiResponseParser {
  /// استخرج النص من استجابة Gemini
  static String? parseText(Map<String, dynamic> json) {
    try {
      final candidates = json['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) return null;
      final parts = candidates[0]['content']?['parts'] as List?;
      if (parts == null || parts.isEmpty) return null;
      final text = parts[0]['text'] as String?;
      return text?.trim().isEmpty == true ? null : text;
    } catch (e) {
      AppLogger.error('AiResponseParser: فشل التحليل', exception: e);
      return null;
    }
  }

  /// هل الاستجابة خطأ rate limit؟
  static bool isRateLimit(int statusCode, Map<String, dynamic>? body) =>
      statusCode == 429 || (body?['error']?['status'] == 'RESOURCE_EXHAUSTED');
}

// ══════════════════════════════════════════════════════════════
// AiRepository — طبقة الوصول لـ Gemini API (بند 23)
// ══════════════════════════════════════════════════════════════
class AiRepository {
  static const String _model = 'gemini-2.0-flash';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';
  static const int _maxHistory = 20;

  final String apiKey;
  final List<Map<String, dynamic>> _history = [];

  AiRepository({required this.apiKey});

  bool get hasApiKey => apiKey.isNotEmpty && apiKey != 'YOUR_GEMINI_API_KEY';

  /// أرسل رسالة واحصل على الرد
  Future<String> sendMessage({
    required String userText,
    required String systemPrompt,
  }) async {
    if (!hasApiKey) throw AiException('api_key_missing');

    _history.add({
      'role': 'user',
      'parts': [
        {'text': userText}
      ],
    });

    AppLogger.request('$_baseUrl (Gemini)');

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl?key=$apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': _history,
              'systemInstruction': {
                'parts': [
                  {'text': systemPrompt}
                ],
              },
              'generationConfig': {
                'maxOutputTokens': 800,
                'temperature': 0.7,
              },
            }),
          )
          .timeout(const Duration(seconds: 30));

      AppLogger.response('Gemini', response.statusCode);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final reply = AiResponseParser.parseText(data);
        if (reply == null) throw AiException('empty_response');

        _history.add({
          'role': 'model',
          'parts': [
            {'text': reply}
          ],
        });

        // حافظ على آخر 20 رسالة فقط لتوفير الـ tokens
        if (_history.length > _maxHistory) {
          _history.removeRange(0, 2);
        }

        return reply;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>?;
      if (AiResponseParser.isRateLimit(response.statusCode, body)) {
        throw AiException('rate_limit');
      }
      if (response.statusCode == 400) throw AiException('invalid_key');

      throw AiException('http_${response.statusCode}');
    } on AiException {
      _history.removeLast(); // أزل الرسالة الأخيرة عند الخطأ
      rethrow;
    } catch (e) {
      _history.removeLast();
      AppLogger.error('AiRepository: خطأ', exception: e);
      throw AiException('network_error', cause: e.toString());
    }
  }

  /// مسح تاريخ المحادثة
  void clearHistory() => _history.clear();
}

// ── AiException ───────────────────────────────────────────────
class AiException extends AppException {
  AiException(String code, {String? cause})
      : super(
          'AI Error: $code',
          arabicMessage: _arabicMsg(code),
          cause: cause,
        );

  static String _arabicMsg(String code) {
    switch (code) {
      case 'api_key_missing':
        return 'يجب إضافة مفتاح Gemini API للمساعد الذكي.';
      case 'rate_limit':
        return 'تجاوزت الحد المسموح. حاول بعد دقيقة.';
      case 'invalid_key':
        return 'مفتاح API غير صحيح أو منتهي الصلاحية.';
      case 'empty_response':
        return 'لم يصلني رد من المساعد. حاول مجدداً.';
      case 'network_error':
        return 'تعذّر الاتصال بالمساعد. تحقق من الإنترنت.';
      default:
        return 'حدث خطأ في المساعد الذكي. حاول مجدداً.';
    }
  }
}
