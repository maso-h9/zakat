import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/zakat_provider.dart';
import '../../../../utils/theme.dart';
import 'ai_chat_view_model.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _controller = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ZakatProvider>();
      final vm = context.read<AiChatViewModel>();
      vm.addWelcome(p.isArabic);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
          title: Text(
            ar ? 'مفتاح API مطلوب' : 'API Key Required',
            style: const TextStyle(fontFamily: 'Scheherazade'),
          ),
          content: Text(
            ar
                ? 'يجب تكوين مفتاح Gemini API في Firebase Console → Remote Config\n\nالمفتاح: gemini_api_key\n\nاحصل عليه مجاناً:\nhttps://aistudio.google.com/app/apikey'
                : 'Configure the Gemini API key in Firebase Console → Remote Config\n\nKey: gemini_api_key\n\nGet it free:\nhttps://aistudio.google.com/app/apikey',
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

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ZakatProvider>();
    final vm = context.watch<AiChatViewModel>();
    final isDark = p.isDarkMode;
    final ar = p.isArabic;
    final cardColor = ZakatTheme.cardBgAdaptive(isDark);
    final textColor =
        isDark ? ZakatTheme.darkTextPrimary : ZakatTheme.darkText;
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
                  vm.clearChat();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    vm.addWelcome(p.isArabic);
                  });
                },
              ),
            ],
          ),
          body: Column(children: [
            // ── Suggestions ──
            Container(
              color: cardColor,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: AiChatViewModel.suggestions(ar).length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final s = AiChatViewModel.suggestions(ar)[i];
                    return GestureDetector(
                      onTap: () {
                        _controller.text = s;
                        _send(vm, ar, p);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: accent.withValues(alpha: 0.3)),
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

            // ── Messages ──
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: vm.messages.length + (vm.isLoading ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == vm.messages.length) {
                    return _TypingIndicator(
                        accent: accent, cardColor: cardColor, isDark: isDark);
                  }
                  final msg = vm.messages[i];
                  final isUser = msg.isUser;
                  final isError = msg.isError;
                  return _MessageBubble(
                    text: msg.text,
                    isUser: isUser,
                    isError: isError,
                    isDark: isDark,
                    accent: accent,
                    cardColor: cardColor,
                    textColor: textColor,
                  );
                },
              ),
            ),

            // ── Input ──
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              decoration: BoxDecoration(
                color: cardColor,
                boxShadow: [
                  BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
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
                    onSubmitted: (_) => _send(vm, ar, p),
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
                  onTap: () => _send(vm, ar, p),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: vm.isLoading ? Colors.grey.shade400 : accent,
                      shape: BoxShape.circle,
                    ),
                    child: vm.isLoading
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

  void _send(AiChatViewModel vm, bool ar, ZakatProvider p) {
    final text = _controller.text.trim();
    if (text.isEmpty || vm.isLoading) return;

    if (!vm.hasApiKey) {
      _showApiKeyDialog(ar);
      return;
    }

    vm.sendMessage(
      text: text,
      isArabic: ar,
      totalWealth: p.totalWealth,
      zakatDue: p.zakatDue,
      goldPricePerGram: p.goldPricePerGram,
      goldNisab: p.goldNisabValue,
      hasReachedNisab: p.hasReachedNisab,
      currency: p.selectedCurrency,
    );
    _controller.clear();
    _scrollToBottom();
  }
}

// ── Message Bubble ──
class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool isError;
  final bool isDark;
  final Color accent, cardColor, textColor;

  const _MessageBubble({
    required this.text,
    required this.isUser,
    required this.isError,
    required this.isDark,
    required this.accent,
    required this.cardColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? accent
                    : isError
                        ? (isDark
                            ? ZakatTheme.error.withValues(alpha: 0.15)
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
              child: Text(text,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    fontFamily: 'Scheherazade',
                    color: isUser
                        ? Colors.white
                        : isError
                            ? ZakatTheme.error
                            : textColor,
                  )),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
                radius: 18,
                backgroundColor: ZakatTheme.gold.withValues(alpha: 0.2),
                child: const Icon(Icons.person,
                    size: 20, color: ZakatTheme.gold)),
          ],
        ],
      ),
    );
  }
}

// ── Typing Indicator ──
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
