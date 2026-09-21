// ================================================================
// secondary_screens.dart — Dark Mode كامل + ترجمة AR/EN
// CalendarScreen · AIAssistantScreen · CompanyZakatScreen · NisabComparisonScreen
//
// ملاحظة: StatsScreen و WhatIfScreen أُزيلا من هذا الملف لأنهما
// مكرّران (موجودان بنسخة محدّثة في stats_chart_screen.dart و whatif_screen.dart)
// ================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zakat_app/l10n/app_localizations.dart';
import '../utils/theme.dart';
import '../models/zakat_provider.dart';

// ==============================
// تقويم الزكاة
// ==============================
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<ZakatProvider>();
    final isDark = p.isDarkMode;
    final daysLeft = p.daysUntilZakat;
    final cardColor = ZakatTheme.cardBgAdaptive(isDark);
    final textColor = isDark ? ZakatTheme.darkTextPrimary : ZakatTheme.darkText;
    final subColor = isDark ? ZakatTheme.darkTextSecondary : ZakatTheme.medText;
    final appBarBg = isDark ? const Color(0xFF0A2A1A) : ZakatTheme.deepGreen;

    return Directionality(
      textDirection: p.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Theme(
        data: isDark ? ZakatTheme.darkTheme : ZakatTheme.theme,
        child: Scaffold(
          backgroundColor: ZakatTheme.scaffoldBgAdaptive(isDark),
          appBar: AppBar(
            title: Text(
                AppLocalizations.of(context).annualZakatCalendar,
                style: const TextStyle(fontFamily: 'Scheherazade')),
            backgroundColor: appBarBg,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              // عداد تنازلي
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? ZakatTheme.darkModeGradient
                      : ZakatTheme.mainGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: ZakatTheme.goldShadow,
                ),
                child: Column(children: [
                  Text(AppLocalizations.of(context).nextZakatDate,
                      style: const TextStyle(
                          color: Colors.white70,
                          fontFamily: 'Scheherazade',
                          fontSize: 15)),
                  const SizedBox(height: 16),
                  if (daysLeft > 0) ...[
                    Text('$daysLeft',
                        style: const TextStyle(
                            color: ZakatTheme.gold,
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Scheherazade')),
                    Text(AppLocalizations.of(context).daysRemaining,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontFamily: 'Scheherazade')),
                  ] else if (p.nisabDate != null) ...[
                    const Text('⚠️', style: TextStyle(fontSize: 48)),
                    Text(AppLocalizations.of(context).zakatObligatoryNow,
                        style: const TextStyle(
                            color: ZakatTheme.gold,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Scheherazade')),
                    Text(
                        AppLocalizations.of(context).payNow,
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontFamily: 'Scheherazade')),
                  ] else ...[
                    const Icon(Icons.add_circle_outline,
                        color: Colors.white70, size: 48),
                    const SizedBox(height: 12),
                    Text(
                        AppLocalizations.of(context).setNisabDatePrompt,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Scheherazade')),
                  ],
                ]),
              ),
              const SizedBox(height: 20),

              // تحديد التاريخ
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: ZakatTheme.cardShadowAdaptive(isDark)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          AppLocalizations.of(context).nisabDateTitle,
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Scheherazade',
                              color: textColor)),
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.of(context).nisabDateDescription,
                        style: TextStyle(
                            fontSize: 14,
                            color: subColor,
                            height: 1.7,
                            fontFamily: 'Scheherazade'),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: p.nisabDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) p.setNisabDate(date);
                        },
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Text(
                          p.nisabDate != null
                              ? '${p.isArabic ? "التاريخ" : "Date"}: ${p.nisabDate!.day}/${p.nisabDate!.month}/${p.nisabDate!.year}'
                              : AppLocalizations.of(context).chooseDate,
                          style: const TextStyle(fontFamily: 'Scheherazade'),
                        ),
                      ),
                      if (p.nisabDate != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (isDark
                                    ? ZakatTheme.lightGreen
                                    : ZakatTheme.deepGreen)
                                .withValues(alpha: isDark ? 0.12 : 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _calRow(
                                    AppLocalizations.of(context).dateOfNisab,
                                    '${p.nisabDate!.day}/${p.nisabDate!.month}/${p.nisabDate!.year}',
                                    isDark,
                                    false),
                                const SizedBox(height: 4),
                                _calRow(
                                    AppLocalizations.of(context).nextObligationDate, () {
                                  final d = p.nisabDate!
                                      .add(const Duration(days: 354));
                                  return '${d.day}/${d.month}/${d.year}';
                                }(), isDark, false),
                                const SizedBox(height: 4),
                                _calRow(
                                    AppLocalizations.of(context).daysUntilObligation,
                                    daysLeft > 0
                                ? '$daysLeft ${AppLocalizations.of(context).daysLeft}'
                                : AppLocalizations.of(context).zakatObligatoryNow,
                                    isDark,
                                    daysLeft <= 0),
                              ]),
                        ),
                      ],
                    ]),
              ),
              const SizedBox(height: 20),

              // تذكير
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? ZakatTheme.gold.withValues(alpha: 0.08)
                      : const Color(0xFFFFF8E7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: ZakatTheme.gold.withValues(alpha: isDark ? 0.3 : 0.5)),
                ),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_outline,
                          color: ZakatTheme.gold),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          p.isArabic
                              ? 'الحول الهجري = 354 يوماً. ابدأ العدّ من اليوم الذي بلغ فيه مالك النصاب. إذا نقص المال عن النصاب أثناء الحول انقطع الحول.'
                              : 'A Hijri year = 354 days. Start counting from the day your wealth reached Nisab. If it drops below Nisab during the year, the count resets.',
                          style: TextStyle(
                              fontSize: 14,
                              height: 1.7,
                              color: subColor,
                              fontFamily: 'Scheherazade'),
                        ),
                      ),
                    ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _calRow(String label, String value, bool isDark, bool highlight) {
    final subColor = isDark ? ZakatTheme.darkTextSecondary : ZakatTheme.medText;
    final accent = isDark ? ZakatTheme.lightGreen : ZakatTheme.deepGreen;
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label,
          style: TextStyle(
              color: subColor, fontSize: 13, fontFamily: 'Scheherazade')),
      Text(value,
          style: TextStyle(
              color: highlight ? ZakatTheme.error : accent,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              fontFamily: 'Scheherazade')),
    ]);
  }
}

// ==============================
// مساعد الزكاة الذكي (محلي — بدون API)
// ==============================
class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});
  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final _ctrl = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _loading = false;

  List<String> _examples(bool ar) => ar
      ? [
          'عندي 10,000 دينار مدخر من سنة',
          'لدي ذهب وزنه 100 غرام وعليّ دين 3000',
          'عندي بضاعة للبيع بـ 20,000 دينار',
          'أملك 50 رأس من الغنم',
          'لدي راتب أدخر منه شهرياً 500 دينار',
        ]
      : [
          'I saved 10,000 for a year',
          'I have 100g of gold and owe 3000 in debt',
          'I have goods worth 20,000 for trade',
          'I own 50 sheep',
          'I save 500 monthly from my salary',
        ];

  void _sendMessage(String text, bool ar) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _loading = true;
    });
    _ctrl.clear();
    Future.delayed(const Duration(milliseconds: 1200), () {
      setState(() {
        _loading = false;
        _messages.add({'role': 'ai', 'text': _generateResponse(text, ar)});
      });
    });
  }

  String _generateResponse(String input, bool ar) {
    final lower = input.toLowerCase();
    if (lower.contains('ذهب') || lower.contains('gold')) {
      return ar
          ? '🥇 بالنسبة للذهب:\n\n• النصاب: 85 غرام من الذهب الخالص\n• إذا كان وزنه يبلغ النصاب وحال عليه الحول → تجب الزكاة\n• المقدار: 2.5% من قيمته السوقية\n\nهل تعرف وزن الذهب بالضبط؟ سأحسب لك الزكاة المستحقة.'
          : '🥇 Regarding gold:\n\n• Nisab: 85 grams of pure gold\n• If it reaches Nisab and a full lunar year passes → Zakat is due\n• Rate: 2.5% of market value\n\nDo you know the exact weight? I can calculate the Zakat for you.';
    }
    if (lower.contains('غنم') ||
        lower.contains('ماعز') ||
        lower.contains('أغنام') ||
        lower.contains('sheep') ||
        lower.contains('goat')) {
      return ar
          ? '🐑 زكاة الغنم:\n\n• النصاب: 40 رأساً\n• من 40 إلى 120: شاة واحدة\n• من 121 إلى 200: شاتان\n• من 201 إلى 399: ثلاث شياه\n\nأخبرني بالعدد لأحدد الواجب بدقة.'
          : '🐑 Sheep/Goat Zakat:\n\n• Nisab: 40 head\n• 40–120: 1 sheep\n• 121–200: 2 sheep\n• 201–399: 3 sheep\n\nTell me the exact count for a precise calculation.';
    }
    if (lower.contains('راتب') ||
        lower.contains('دخل') ||
        lower.contains('salary') ||
        lower.contains('income')) {
      return ar
          ? '💰 زكاة الراتب والدخل:\n\n• ما تُنفقه في حوائجك لا زكاة فيه\n• ما تُدّخره حتى يبلغ النصاب ويحول عليه الحول → تجب فيه الزكاة\n• النصاب ≈ 85 غرام ذهب بالقيمة الحالية\n\nكم تدّخر شهرياً وكم مدة الادخار؟'
          : '💰 Salary & Income Zakat:\n\n• What you spend on needs has no Zakat\n• What you save until it reaches Nisab and a year passes → Zakat is due\n• Nisab ≈ 85g of gold at current value\n\nHow much do you save monthly, and for how long?';
    }
    if (lower.contains('دين') ||
        lower.contains('مديون') ||
        lower.contains('debt')) {
      return ar
          ? '📊 الديون وأثرها على الزكاة:\n\n• الديون عليك: تُخصم من وعاء الزكاة عند بعض العلماء\n• الديون لك (مضمونة): تُضاف إلى وعاء الزكاة\n• الديون المشكوك في استردادها: اختلف العلماء فيها\n\nأخبرني بمبلغ الدين لأوضح الحكم بشكل أدق.'
          : '📊 Debts and Zakat:\n\n• Your debts: deducted from the Zakat base per some scholars\n• Debts owed to you (guaranteed): added to the base\n• Doubtful receivables: scholars differ\n\nTell me the amount for a more precise explanation.';
    }
    if (lower.contains('بضاعة') ||
        lower.contains('تجارة') ||
        lower.contains('محل') ||
        lower.contains('trade') ||
        lower.contains('goods')) {
      return ar
          ? '🏪 زكاة عروض التجارة:\n\n• تُزكَّى البضاعة بقيمتها السوقية عند تمام الحول\n• النسبة: 2.5%\n• تُضاف إليها النقود والديون المستحقة\n• وتُطرح منها الديون على التاجر\n\nأخبرني بقيمة البضاعة والديون لأحسب الزكاة.'
          : '🏪 Trade Goods Zakat:\n\n• Valued at market price when the year completes\n• Rate: 2.5%\n• Add cash and receivables\n• Subtract business debts\n\nTell me the goods value and debts to calculate.';
    }
    return ar
        ? '🌟 جزاك الله خيراً على اهتمامك بأداء الزكاة.\n\nلحساب زكاتك بدقة، أحتاج أن أعرف:\n1️⃣ نوع المال (نقود، ذهب، بضاعة، أنعام)\n2️⃣ مقداره\n3️⃣ مدة امتلاكه\n4️⃣ هل عليك ديون؟\n\nأخبرني بتفاصيل أكثر وسأساعدك.'
        : '🌟 May Allah reward you for your interest in Zakat.\n\nTo calculate precisely, I need to know:\n1️⃣ Type of wealth (cash, gold, goods, livestock)\n2️⃣ Its amount\n3️⃣ How long you\'ve owned it\n4️⃣ Do you have debts?\n\nGive me more details and I\'ll help.';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ZakatProvider>();
    final isDark = p.isDarkMode;
    final ar = p.isArabic;
    final cardColor = ZakatTheme.cardBgAdaptive(isDark);
    final textColor = isDark ? ZakatTheme.darkTextPrimary : ZakatTheme.darkText;
    final subColor = isDark ? ZakatTheme.darkTextSecondary : ZakatTheme.medText;
    final accent = isDark ? ZakatTheme.lightGreen : ZakatTheme.deepGreen;
    final appBarBg = isDark ? const Color(0xFF0A2A1A) : ZakatTheme.deepGreen;

    return Directionality(
      textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
      child: Theme(
        data: isDark ? ZakatTheme.darkTheme : ZakatTheme.theme,
        child: Scaffold(
          backgroundColor: ZakatTheme.scaffoldBgAdaptive(isDark),
          appBar: AppBar(
            title: Text(AppLocalizations.of(context).zakatAssistantTitle,
                style: const TextStyle(fontFamily: 'Scheherazade')),
            backgroundColor: appBarBg,
          ),
          body: Column(children: [
            Container(
              padding: const EdgeInsets.all(12),
              color: accent.withValues(alpha: isDark ? 0.12 : 0.05),
              child: Row(children: [
                const CircleAvatar(
                    backgroundColor: ZakatTheme.gold,
                    child: Icon(Icons.auto_awesome,
                        color: Colors.white, size: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).assistantPlaceholder,
                    style: TextStyle(
                        fontFamily: 'Scheherazade',
                        fontSize: 13,
                        color: subColor),
                  ),
                ),
              ]),
            ),
            Expanded(
              child: _messages.isEmpty
                  ? _buildExamples(ar, textColor, cardColor, accent, isDark)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length + (_loading ? 1 : 0),
                      itemBuilder: (ctx, i) {
                        if (i == _messages.length) {
                          return _buildTypingIndicator(accent);
                        }
                        final m = _messages[i];
                        return _buildMessage(m['role']!, m['text']!, isDark,
                            accent, cardColor, textColor);
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ZakatTheme.scaffoldBgAdaptive(isDark),
                border: Border(
                    top: BorderSide(
                        color: isDark
                            ? ZakatTheme.darkBorder
                            : const Color(0xFFEEE8D5))),
              ),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    textDirection: TextDirection.rtl,
                    style:
                        TextStyle(fontFamily: 'Scheherazade', color: textColor),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).askQuestion,
                      filled: true,
                      fillColor: cardColor,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                    onSubmitted: (v) => _sendMessage(v, ar),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: accent,
                  child: IconButton(
                      icon:
                          const Icon(Icons.send, color: Colors.white, size: 18),
                      onPressed: () => _sendMessage(_ctrl.text, ar)),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildExamples(
      bool ar, Color textColor, Color cardColor, Color accent, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(AppLocalizations.of(context).examplesToStart,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Scheherazade',
                fontSize: 16,
                color: textColor)),
        const SizedBox(height: 12),
        ..._examples(ar).map((e) => GestureDetector(
              onTap: () => _sendMessage(e, ar),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: accent.withValues(alpha: isDark ? 0.35 : 0.3)),
                  boxShadow: ZakatTheme.cardShadowAdaptive(isDark),
                ),
                child: Row(children: [
                  Icon(ar ? Icons.arrow_left : Icons.arrow_right,
                      color: accent),
                  Expanded(
                      child: Text(e,
                          style: TextStyle(
                              fontFamily: 'Scheherazade',
                              fontSize: 14,
                              color: textColor))),
                ]),
              ),
            )),
      ]),
    );
  }

  Widget _buildMessage(String role, String text, bool isDark, Color accent,
      Color cardColor, Color textColor) {
    final isUser = role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isUser ? accent : cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
          boxShadow: ZakatTheme.cardShadowAdaptive(isDark),
        ),
        child: Text(text,
            style: TextStyle(
                color: isUser ? Colors.white : textColor,
                fontFamily: 'Scheherazade',
                fontSize: 15,
                height: 1.7)),
      ),
    );
  }

  Widget _buildTypingIndicator(Color accent) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: CircularProgressIndicator(strokeWidth: 2, color: accent),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}

// ==============================
// حاسبة زكاة الشركات
// ==============================
class CompanyZakatScreen extends StatefulWidget {
  const CompanyZakatScreen({super.key});
  @override
  State<CompanyZakatScreen> createState() => _CompanyZakatScreenState();
}

class _CompanyZakatScreenState extends State<CompanyZakatScreen> {
  final _capitalCtrl = TextEditingController();
  final _goodsCtrl = TextEditingController();
  final _profitCtrl = TextEditingController();
  final _debtCtrl = TextEditingController();
  final _receivableCtrl = TextEditingController();

  double get _totalBase {
    final capital = double.tryParse(_capitalCtrl.text) ?? 0;
    final goods = double.tryParse(_goodsCtrl.text) ?? 0;
    final profit = double.tryParse(_profitCtrl.text) ?? 0;
    final receivable = double.tryParse(_receivableCtrl.text) ?? 0;
    final debt = double.tryParse(_debtCtrl.text) ?? 0;
    return (capital + goods + profit + receivable - debt)
        .clamp(0, double.infinity);
  }

  @override
  void dispose() {
    for (final c in [
      _capitalCtrl,
      _goodsCtrl,
      _profitCtrl,
      _debtCtrl,
      _receivableCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ZakatProvider>();
    final isDark = p.isDarkMode;
    final ar = p.isArabic;
    final cardColor = ZakatTheme.cardBgAdaptive(isDark);
    final textColor = isDark ? ZakatTheme.darkTextPrimary : ZakatTheme.darkText;
    final subColor =
        isDark ? ZakatTheme.darkTextSecondary : ZakatTheme.lightText;
    final appBarBg = isDark ? const Color(0xFF0A2A1A) : ZakatTheme.deepGreen;

    return Directionality(
      textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
      child: Theme(
        data: isDark ? ZakatTheme.darkTheme : ZakatTheme.theme,
        child: Scaffold(
          backgroundColor: ZakatTheme.scaffoldBgAdaptive(isDark),
          appBar: AppBar(
            title: Text(AppLocalizations.of(context).companyZakatTitle,
                style: const TextStyle(fontFamily: 'Scheherazade')),
            backgroundColor: appBarBg,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: ZakatTheme.cardShadowAdaptive(isDark)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          AppLocalizations.of(context).companyZakatElements,
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Scheherazade',
                              color: textColor)),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context).companyFormula,
                        style: TextStyle(
                            fontSize: 12,
                            color: subColor,
                            fontFamily: 'Scheherazade',
                            height: 1.6),
                      ),
                      Divider(
                          height: 20,
                          color: isDark ? ZakatTheme.darkBorder : null),
                      _companyField(
                          _capitalCtrl,
                          AppLocalizations.of(context).cashCapital,
                          Colors.blue,
                          isDark,
                          textColor),
                      const SizedBox(height: 10),
                      _companyField(
                          _goodsCtrl,
                          AppLocalizations.of(context).currentGoodsValue,
                          Colors.green,
                          isDark,
                          textColor),
                      const SizedBox(height: 10),
                      _companyField(
                          _profitCtrl,
                          AppLocalizations.of(context).netProfits,
                          Colors.teal,
                          isDark,
                          textColor),
                      const SizedBox(height: 10),
                      _companyField(
                          _receivableCtrl,
                          AppLocalizations.of(context).companyDebtsDue,
                          ZakatTheme.gold,
                          isDark,
                          textColor),
                      const SizedBox(height: 10),
                      _companyField(
                          _debtCtrl,
                          AppLocalizations.of(context).companyDebtsOwed,
                          ZakatTheme.error,
                          isDark,
                          textColor),
                    ]),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? ZakatTheme.darkModeGradient
                      : ZakatTheme.mainGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(children: [
                  Text(AppLocalizations.of(context).zakatPool,
                      style: const TextStyle(
                          color: Colors.white70, fontFamily: 'Scheherazade')),
                  Text('${_totalBase.toStringAsFixed(0)} ${p.currencySymbol}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Scheherazade')),
                  const SizedBox(height: 12),
                  if (_totalBase >= p.goldNisabValue) ...[
                    Text(AppLocalizations.of(context).zakatDueLabel,
                        style: const TextStyle(
                            color: Colors.white70, fontFamily: 'Scheherazade')),
                    Text(
                        '${(_totalBase * 0.025).toStringAsFixed(2)} ${p.currencySymbol}',
                        style: const TextStyle(
                            color: ZakatTheme.gold,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Scheherazade')),
                  ] else
                    Text(AppLocalizations.of(context).poolBelowNisab,
                        style: const TextStyle(
                            color: Colors.white60,
                            fontFamily: 'Scheherazade',
                            fontSize: 16)),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _companyField(TextEditingController ctrl, String label, Color color,
      bool isDark, Color textColor) {
    return Row(children: [
      Container(
          width: 4,
          height: 40,
          margin: const EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2))),
      Expanded(
        child: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textDirection: TextDirection.rtl,
          onChanged: (_) => setState(() {}),
          style: TextStyle(fontFamily: 'Scheherazade', color: textColor),
          decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: color, fontFamily: 'Scheherazade'),
              isDense: true),
        ),
      ),
    ]);
  }
}

// ==============================
// مقارنة النصاب
// ==============================
class NisabComparisonScreen extends StatelessWidget {
  const NisabComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ZakatProvider>();
    final isDark = p.isDarkMode;
    final ar = p.isArabic;
    final cardColor = ZakatTheme.cardBgAdaptive(isDark);
    final textColor = isDark ? ZakatTheme.darkTextPrimary : ZakatTheme.darkText;
    final subColor = isDark ? ZakatTheme.darkTextSecondary : ZakatTheme.medText;
    final appBarBg = isDark ? const Color(0xFF0A2A1A) : ZakatTheme.deepGreen;

    return Directionality(
      textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
      child: Theme(
        data: isDark ? ZakatTheme.darkTheme : ZakatTheme.theme,
        child: Scaffold(
          backgroundColor: ZakatTheme.scaffoldBgAdaptive(isDark),
          appBar: AppBar(
            title: Text(
                AppLocalizations.of(context).goldSilverNisabComparison,
                style: const TextStyle(fontFamily: 'Scheherazade')),
            backgroundColor: appBarBg,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Row(children: [
                Expanded(
                    child: _nisabCard(context,
                        AppLocalizations.of(context).goldNisab85,
                        AppLocalizations.of(context).goldNisabGrams,
                        '${p.goldNisabValue.toStringAsFixed(0)} ${p.currencySymbol}',
                        ZakatTheme.gold,
                        p.totalZakatableWealth >= p.goldNisabValue,
                        isDark,
                        ar,
                        subColor)),
                const SizedBox(width: 16),
                Expanded(
                    child: _nisabCard(context,
                        AppLocalizations.of(context).silverNisab595,
                        AppLocalizations.of(context).silverNisabGrams,
                        '${p.silverNisabValue.toStringAsFixed(0)} ${p.currencySymbol}',
                        Colors.blueGrey,
                        p.totalZakatableWealth >= p.silverNisabValue,
                        isDark,
                        ar,
                        subColor)),
              ]),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: ZakatTheme.cardShadowAdaptive(isDark)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context).whichIsAdopted,
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Scheherazade',
                              color: textColor)),
                      const SizedBox(height: 12),
                      Text(
                        ar
                            ? 'اختلف العلماء المعاصرون في هذه المسألة:\n\n'
                                '• بعض العلماء يرى اعتماد نصاب الذهب لأنه أصل للنقد وأثبت قيمةً.\n\n'
                                '• بعضهم يرى اعتماد نصاب الفضة لأنه أنفع للفقراء وأوسع للمستحقين، إذ قيمة الفضة أقل.\n\n'
                                '• والأحوط للخروج من الخلاف: اعتماد نصاب الفضة إذا كان أقل قيمةً لأنه أكثر إيجاباً للزكاة وأنفع للمحتاجين.'
                            : 'Contemporary scholars differ on this:\n\n'
                                '• Some prefer Gold Nisab as it\'s a stable store of value.\n\n'
                                '• Others prefer Silver Nisab as it\'s lower in value, making Zakat obligatory more often — more beneficial for the poor.\n\n'
                                '• The safer approach: use whichever Nisab is lower in value, as it widens the scope of Zakat for the needy.',
                        style: TextStyle(
                            fontSize: 15,
                            color: subColor,
                            height: 1.9,
                            fontFamily: 'Scheherazade'),
                      ),
                    ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _nisabCard(BuildContext context, String title, String grams, String value, Color color,
      bool reached, bool isDark, bool ar, Color subColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: color.withValues(alpha: isDark ? 0.5 : 0.4), width: 2),
      ),
      child: Column(children: [
        Text(title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Scheherazade',
                color: color,
                fontSize: 16),
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(grams,
            style: TextStyle(color: subColor, fontFamily: 'Scheherazade')),
        const SizedBox(height: 8),
        Text(value,
            style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Scheherazade')),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: reached
                ? Colors.green.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            reached
                ? AppLocalizations.of(context).reachedNisab
                : AppLocalizations.of(context).notReached,
            style: TextStyle(
                color: reached ? Colors.green : subColor,
                fontSize: 12,
                fontFamily: 'Scheherazade'),
          ),
        ),
      ]),
    );
  }
}
