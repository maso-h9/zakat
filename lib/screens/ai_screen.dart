// ================================================================
// screens/ai_screen.dart — المساعد الذكي (بند 23 + 26)
// UI فقط — كل منطق Gemini في AiRepository
// من 547 سطر → ~280 سطر
// ================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zakat_app/l10n/app_localizations.dart';
import '../models/zakat_provider.dart';
import '../services/ai_repository.dart';
import '../services/remote_config_service.dart';
import '../utils/theme.dart';

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});
  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  final _controller = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _messages = <AiMessage>[];
  bool _isLoading = false;
  bool _welcomeAdded = false;

  // ─── مفتاح Gemini يُجلب بأمان من Firebase Remote Config ────────
  // لا تضع المفتاح هنا — ضعه في Firebase Console → Remote Config
  // المفتاح: gemini_api_key
  // ──────────────────────────────────────────────────────────────

  // يُنشأ عند أول استخدام بعد تحميل Remote Config
  AiRepository? _repoInstance;
  AiRepository get _repo {
    _repoInstance ??= AiRepository(
      apiKey: RemoteConfigService.geminiApiKey,
    );
    return _repoInstance!;
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _addWelcome(bool ar) {
    if (_welcomeAdded) return;
    _welcomeAdded = true;
    _messages.add(AiMessage(
      text: AiPromptBuilder.welcomeMessage(ar),
      isUser: false,
    ));
  }

  Future<void> _send(bool ar) async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    if (!_repo.hasApiKey) {
      _showApiKeyDialog(ar);
      return;
    }

    final p = context.read<ZakatProvider>();
    setState(() {
      _messages.add(AiMessage(text: text, isUser: true));
      _isLoading = true;
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final reply = await _repo.sendMessage(
        userText: text,
        systemPrompt: AiPromptBuilder.buildSystemPrompt(
          isArabic: ar,
          totalWealth: p.totalWealth,
          zakatDue: p.zakatDue,
          goldPricePerGram: p.goldPricePerGram,
          goldNisab: p.goldNisabValue,
          hasReachedNisab: p.hasReachedNisab,
          currency: p.selectedCurrency,
        ),
      );
      setState(() {
        _messages.add(AiMessage(text: reply, isUser: false));
        _isLoading = false;
      });
    } on AiException catch (e) {
      setState(() {
        _messages.add(AiMessage(
          text: '⚠️ ${e.userMessage}',
          isUser: false,
          isError: true,
        ));
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showApiKeyDialog(bool ar) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          title: Text(AppLocalizations.of(context).apiKeyRequired,
              style: const TextStyle(fontFamily: 'Scheherazade')),
          content: Text(
            AppLocalizations.of(context).apiKeyMessage,
            style: const TextStyle(fontFamily: 'Scheherazade'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).ok,
                  style: const TextStyle(fontFamily: 'Scheherazade')),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ZakatProvider>();
    final isDark = p.isDarkMode;
    final ar = p.isArabic;
    final cardColor = ZakatTheme.cardBgAdaptive(isDark);
    final textColor = isDark ? ZakatTheme.darkTextPrimary : ZakatTheme.darkText;
    final accent = isDark ? ZakatTheme.lightGreen : ZakatTheme.deepGreen;
    final appBarBg = isDark ? const Color(0xFF0A2A1A) : ZakatTheme.deepGreen;

    _addWelcome(ar);

    return Directionality(
      textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
      child: Theme(
        data: isDark ? ZakatTheme.darkTheme : ZakatTheme.theme,
        child: Scaffold(
          backgroundColor: ZakatTheme.scaffoldBgAdaptive(isDark),
          appBar: AppBar(
            backgroundColor: appBarBg,
            title: Text(AppLocalizations.of(context).aiAssistantTitle,
                style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Scheherazade',
                    fontSize: 20)),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white70),
                tooltip: AppLocalizations.of(context).clearChat,
                onPressed: () {
                  setState(() {
                    _messages.clear();
                    _repo.clearHistory();
                    _welcomeAdded = false;
                    _addWelcome(ar);
                  });
                },
              ),
            ],
          ),
          body: Column(children: [
            // ── اقتراحات ──────────────────────────────────────
            Container(
              color: cardColor,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: AiPromptBuilder.suggestions(ar).length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final s = AiPromptBuilder.suggestions(ar)[i];
                    return GestureDetector(
                      onTap: () {
                        _controller.text = s;
                        _send(ar);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: accent.withValues(alpha: 0.3)),
                        ),
                        child: Text(s,
                            style: TextStyle(
                                fontSize: 12,
                                color: accent,
                                fontFamily: 'Scheherazade')),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ── المحادثة ──────────────────────────────────────
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == _messages.length) {
                    return _TypingIndicator(
                        accent: accent, cardColor: cardColor, isDark: isDark);
                  }
                  return _MessageBubble(
                    msg: _messages[i],
                    isDark: isDark,
                    accent: accent,
                    cardColor: cardColor,
                    textColor: textColor,
                  );
                },
              ),
            ),

            // ── حقل الإدخال ───────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              decoration: BoxDecoration(
                color: cardColor,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, -2))
                ],
              ),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textDirection: TextDirection.rtl,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(ar),
                    style: TextStyle(
                        fontFamily: 'Scheherazade',
                        fontSize: 15,
                        color: textColor),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).aiPlaceholder,
                      hintTextDirection: TextDirection.rtl,
                      hintStyle: TextStyle(
                          color: isDark
                              ? ZakatTheme.darkTextSecondary
                              : Colors.grey.shade400,
                          fontFamily: 'Scheherazade'),
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
                  onTap: () => _send(ar),
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
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send_rounded,
                            color: Colors.white, size: 22),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── فقاعة الرسالة ─────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final AiMessage msg;
  final bool isDark;
  final Color accent, cardColor, textColor;
  const _MessageBubble(
      {required this.msg,
      required this.isDark,
      required this.accent,
      required this.cardColor,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment:
            msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!msg.isUser) ...[
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
                color: msg.isUser
                    ? accent
                    : msg.isError
                        ? (isDark
                            ? ZakatTheme.error.withValues(alpha: 0.15)
                            : Colors.red.shade50)
                        : cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
                  bottomRight: Radius.circular(msg.isUser ? 4 : 16),
                ),
                boxShadow: ZakatTheme.cardShadowAdaptive(isDark),
              ),
              child: Text(msg.text,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    fontFamily: 'Scheherazade',
                    color: msg.isUser
                        ? Colors.white
                        : msg.isError
                            ? ZakatTheme.error
                            : textColor,
                  )),
            ),
          ),
          if (msg.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
                radius: 18,
                backgroundColor: ZakatTheme.gold.withValues(alpha: 0.2),
                child:
                    const Icon(Icons.person, size: 20, color: ZakatTheme.gold)),
          ],
        ],
      ),
    );
  }
}

// ── مؤشر الكتابة ──────────────────────────────────────────────
class _TypingIndicator extends StatefulWidget {
  final Color accent, cardColor;
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
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 16, bottom: 8),
        child: Row(children: [
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
                boxShadow: ZakatTheme.cardShadowAdaptive(widget.isDark)),
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
                                color: widget.accent.withValues(alpha: 0.3 +
                                    0.7 * ((_ctrl.value + i * 0.3) % 1.0))),
                          ))),
            ),
          ),
        ]),
      );
}
