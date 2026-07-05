import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../models/zakat_provider.dart';
import '../utils/theme.dart';

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});
  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_Message> _messages = [];
  bool _isLoading = false;
  bool _welcomeAdded = false;

  static const String _apiKey = '';
  static const String _model = 'gemini-2.0-flash';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';
  // ───────────────────────────────────────────────────────────────

  // تاريخ المحادثة بصيغة Gemini
  final List<Map<String, dynamic>> _history = [];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage(bool ar) {
    if (_welcomeAdded) return;
    _welcomeAdded = true;
    _messages.add(_Message(
      text: ar
          ? 'السلام عليكم! أنا مساعدك الذكي.\n\nيمكنني مساعدتك في:\n• حساب زكاة أموالك وتجارتك\n• أحكام الزكاة من المذاهب الأربعة\n• مصارف الزكاة الشرعية\n• فتاوى الزكاة المعاصرة\n• أو أي سؤال عام آخر يخطر لك\n\nاسألني أي شيء.'
          : 'Hello! I\'m your AI assistant.\n\nI can help with:\n• Calculating Zakat on your wealth and trade\n• Zakat rulings across the 4 schools of thought\n• Legitimate Zakat recipients\n• Contemporary Zakat fatwas\n• Or any other general question\n\nAsk me anything.',
      isUser: false,
    ));
  }

  String _buildSystemPrompt(ZakatProvider p, bool ar) {
    if (ar) {
      return '''أنت مساعد ذكي عام يستطيع الإجابة على أي سؤال، مع تخصص إضافي في أحكام الزكاة الإسلامية. تجيب بالعربية الفصحى الواضحة.

بيانات المستخدم الحالية (استخدمها فقط عند السؤال عن الزكاة):
- إجمالي الثروة: ${p.totalWealth.toStringAsFixed(2)} ${p.selectedCurrency}
- الزكاة الواجبة: ${p.zakatDue.toStringAsFixed(2)} ${p.selectedCurrency}
- سعر الذهب: ${p.goldPricePerGram.toStringAsFixed(2)} ${p.selectedCurrency}/جرام
- نصاب الذهب (85 جرام): ${(p.goldPricePerGram * 85).toStringAsFixed(2)} ${p.selectedCurrency}
- هل بلغ النصاب: ${p.hasReachedNisab ? "نعم" : "لا"}

قواعد:
1. إذا كان السؤال عن الزكاة: استند للقرآن والسنة، واذكر آراء المذاهب الأربعة عند الاختلاف، وأشر للمصادر
2. إذا كان السؤال عاماً (غير متعلق بالزكاة): أجب بشكل طبيعي ومفيد كمساعد عام
3. الإجابات مختصرة ومفيدة، لا تزيد عن 300 كلمة
4. للأسئلة الحسابية، اعرض الخطوات بوضوح''';
    }
    return '''You are a general-purpose AI assistant that can answer any question, with additional expertise in Islamic Zakat rulings. Respond in clear English.

Current user data (use only when asked about Zakat):
- Total wealth: ${p.totalWealth.toStringAsFixed(2)} ${p.selectedCurrency}
- Zakat due: ${p.zakatDue.toStringAsFixed(2)} ${p.selectedCurrency}
- Gold price: ${p.goldPricePerGram.toStringAsFixed(2)} ${p.selectedCurrency}/gram
- Gold Nisab (85g): ${(p.goldPricePerGram * 85).toStringAsFixed(2)} ${p.selectedCurrency}
- Reached Nisab: ${p.hasReachedNisab ? "Yes" : "No"}

Rules:
1. If the question is about Zakat: cite Quran/Sunnah, mention the 4 schools of thought when they differ, cite sources
2. If it's a general question (not Zakat-related): respond naturally and helpfully as a general assistant
3. Keep answers concise and useful, under 300 words
4. For calculation questions, show the steps clearly''';
  }

  Future<void> _sendMessage(bool ar) async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    if (_apiKey == 'YOUR_GEMINI_API_KEY') {
      _showApiKeyDialog(ar);
      return;
    }

    setState(() {
      _messages.add(_Message(text: text, isUser: true));
      _isLoading = true;
      _controller.clear();
    });
    _scrollToBottom();

    _history.add({
      'role': 'user',
      'parts': [
        {'text': text}
      ]
    });

    try {
      final p = context.read<ZakatProvider>();
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': _history,
          'systemInstruction': {
            'parts': [
              {'text': _buildSystemPrompt(p, ar)}
            ]
          },
          'generationConfig': {'maxOutputTokens': 800, 'temperature': 0.7},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List?;
        if (candidates == null || candidates.isEmpty) {
          _handleError(ar
              ? 'لم يتم استلام رد. حاول مجدداً.'
              : 'No response received. Try again.');
          return;
        }
        final parts = candidates[0]['content']?['parts'] as List?;
        final reply = (parts != null && parts.isNotEmpty)
            ? (parts[0]['text'] as String?) ?? ''
            : '';

        if (reply.isEmpty) {
          _handleError(ar
              ? 'لم يتم استلام رد. حاول مجدداً.'
              : 'No response received. Try again.');
          return;
        }

        _history.add({
          'role': 'model',
          'parts': [
            {'text': reply}
          ]
        });
        if (_history.length > 20) _history.removeRange(0, 2);

        setState(() {
          _messages.add(_Message(text: reply, isUser: false));
          _isLoading = false;
        });
      } else if (response.statusCode == 400) {
        _handleError(ar
            ? 'مفتاح API غير صحيح أو الطلب غير صالح.'
            : 'Invalid API key or request.');
      } else if (response.statusCode == 429) {
        _handleError(ar
            ? 'تجاوزت الحد المسموح من الطلبات. انتظر قليلاً.'
            : 'Rate limit exceeded. Please wait a moment.');
      } else {
        _handleError(
            '${ar ? "حدث خطأ في الاتصال" : "Connection error"} (${response.statusCode})');
      }
    } catch (e) {
      _handleError(ar
          ? 'تعذّر الاتصال بالإنترنت. تحقق من اتصالك.'
          : 'Could not connect. Check your internet connection.');
    }
    _scrollToBottom();
  }

  void _handleError(String msg) {
    setState(() {
      _messages.add(_Message(text: '⚠️ $msg', isUser: false, isError: true));
      _isLoading = false;
    });
  }

  void _showApiKeyDialog(bool ar) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          title: Text(ar ? 'مفتاح API مطلوب' : 'API Key Required',
              style: const TextStyle(fontFamily: 'Scheherazade')),
          content: Text(
            ar
                ? 'لاستخدام المساعد الذكي، يجب إضافة مفتاح Gemini API في ملف ai_screen.dart\n\nاحصل على مفتاحك المجاني من:\nhttps://aistudio.google.com/app/apikey'
                : 'To use the AI assistant, add a Gemini API key in ai_screen.dart\n\nGet your free key from:\nhttps://aistudio.google.com/app/apikey',
            style: const TextStyle(fontFamily: 'Scheherazade'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(ar ? 'حسناً' : 'OK',
                  style: const TextStyle(fontFamily: 'Scheherazade')),
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildSuggestions(bool ar, Color accent) {
    final suggestions = ar
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
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () {
            _controller.text = suggestions[i];
            _sendMessage(ar);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accent.withOpacity(0.3)),
            ),
            child: Text(suggestions[i],
                style: TextStyle(
                    fontSize: 12, color: accent, fontFamily: 'Scheherazade')),
          ),
        ),
      ),
    );
  }

  Widget _buildMessage(_Message msg, bool isDark, Color accent, Color cardColor,
      Color textColor) {
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
                radius: 18,
                backgroundColor: accent,
                child: const Text('🕌', style: TextStyle(fontSize: 16))),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? accent
                    : msg.isError
                        ? (isDark
                            ? ZakatTheme.error.withOpacity(0.15)
                            : Colors.red.shade50)
                        : cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: ZakatTheme.cardShadowAdaptive(isDark),
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: isUser
                      ? Colors.white
                      : msg.isError
                          ? ZakatTheme.error
                          : textColor,
                  fontFamily: 'Scheherazade',
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 18,
              backgroundColor: ZakatTheme.gold.withOpacity(0.2),
              child: const Icon(Icons.person, size: 20, color: ZakatTheme.gold),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ZakatProvider>();
    final isDark = p.isDarkMode;
    final ar = p.isArabic;
    _addWelcomeMessage(ar);

    final cardColor = ZakatTheme.cardBgAdaptive(isDark);
    final textColor = isDark ? ZakatTheme.darkTextPrimary : ZakatTheme.darkText;
    final accent = isDark ? ZakatTheme.lightGreen : ZakatTheme.deepGreen;
    final appBarBg = isDark ? const Color(0xFF0A2A1A) : ZakatTheme.deepGreen;

    return Directionality(
      textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
      child: Theme(
        data: isDark ? ZakatTheme.darkTheme : ZakatTheme.theme,
        child: Scaffold(
          backgroundColor: ZakatTheme.scaffoldBgAdaptive(isDark),
          appBar: AppBar(
            backgroundColor: appBarBg,
            title: Text(
              ar ? 'المساعد الذكي' : 'AI Assistant',
              style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Scheherazade',
                  fontSize: 20),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white70),
                tooltip: ar ? 'مسح المحادثة' : 'Clear chat',
                onPressed: () {
                  setState(() {
                    _messages.clear();
                    _history.clear();
                    _welcomeAdded = false;
                    _addWelcomeMessage(ar);
                  });
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // شريط الاقتراحات
              Container(
                color: cardColor,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: _buildSuggestions(ar, accent),
              ),

              // المحادثة
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == _messages.length) {
                      return _TypingIndicator(
                          accent: accent, cardColor: cardColor, isDark: isDark);
                    }
                    return _buildMessage(
                        _messages[i], isDark, accent, cardColor, textColor);
                  },
                ),
              ),

              // حقل الإدخال
              Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                decoration: BoxDecoration(
                  color: cardColor,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, -2)),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textDirection: TextDirection.rtl,
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(ar),
                        style: TextStyle(
                            fontFamily: 'Scheherazade',
                            fontSize: 15,
                            color: textColor),
                        decoration: InputDecoration(
                          hintText: ar ? 'اسأل أي شيء...' : 'Ask anything...',
                          hintTextDirection: TextDirection.rtl,
                          hintStyle: TextStyle(
                            color: isDark
                                ? ZakatTheme.darkTextSecondary
                                : Colors.grey.shade400,
                            fontFamily: 'Scheherazade',
                          ),
                          filled: true,
                          fillColor: ZakatTheme.scaffoldBgAdaptive(isDark),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _sendMessage(ar),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _isLoading ? Colors.grey.shade400 : accent,
                          shape: BoxShape.circle,
                        ),
                        child: _isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.send_rounded,
                                color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;
  final bool isError;
  _Message({required this.text, required this.isUser, this.isError = false});
}

class _TypingIndicator extends StatefulWidget {
  final Color accent;
  final Color cardColor;
  final bool isDark;
  const _TypingIndicator(
      {required this.accent, required this.cardColor, required this.isDark});

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
              radius: 18,
              backgroundColor: widget.accent,
              child: const Text('🕌', style: TextStyle(fontSize: 16))),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: widget.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: ZakatTheme.cardShadowAdaptive(widget.isDark),
            ),
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  3,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.accent.withOpacity(
                          0.3 + 0.7 * ((_ctrl.value + i * 0.3) % 1.0)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
