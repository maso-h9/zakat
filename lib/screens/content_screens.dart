import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zakat_app/l10n/app_localizations.dart';
import '../data/zakat_data.dart';
import '../utils/theme.dart';
import '../widgets/hadith_card.dart';
import '../models/zakat_provider.dart';

// شاشة الأحاديث

class AhadithScreen extends StatelessWidget {
  const AhadithScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ZakatProvider>();
    final isDark = p.isDarkMode;
    final appBarBg = isDark ? const Color(0xFF0A2A1A) : ZakatTheme.deepGreen;

    return Directionality(
      textDirection: p.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Theme(
        data: isDark ? ZakatTheme.darkTheme : ZakatTheme.theme,
        child: Scaffold(
          backgroundColor: ZakatTheme.scaffoldBgAdaptive(isDark),
          appBar: AppBar(
            title: Text(AppLocalizations.of(context).zakatHadiths,
                style: const TextStyle(fontFamily: 'Scheherazade')),
            backgroundColor: appBarBg,
          ),
          body: Column(children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: isDark
                    ? ZakatTheme.darkModeGradient
                    : ZakatTheme.mainGradient,
              ),
              child: Row(children: [
                const Icon(Icons.verified, color: ZakatTheme.gold, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).hadithsSourceNote,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontFamily: 'Scheherazade',
                        height: 1.6),
                  ),
                ),
              ]),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: ahadith.length,
                itemBuilder: (ctx, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: HadithCard(hadith: ahadith[i]),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ==============================
// شاشة المصارف الثمانية
// ==============================
class MasarifScreen extends StatelessWidget {
  const MasarifScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ZakatProvider>();
    final isDark = p.isDarkMode;
    final appBarBg = isDark ? const Color(0xFF0A2A1A) : ZakatTheme.deepGreen;

    return Directionality(
      textDirection: p.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Theme(
        data: isDark ? ZakatTheme.darkTheme : ZakatTheme.theme,
        child: Scaffold(
          backgroundColor: ZakatTheme.scaffoldBgAdaptive(isDark),
          appBar: AppBar(
            title: Text(AppLocalizations.of(context).zakatRecipients,
                style: const TextStyle(fontFamily: 'Scheherazade')),
            backgroundColor: appBarBg,
          ),
          body: Column(children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: appBarBg,
              child: const Text(
                '﴿إِنَّمَا الصَّدَقَاتُ لِلْفُقَرَاءِ وَالْمَسَاكِينِ وَالْعَامِلِينَ عَلَيْهَا وَالْمُؤَلَّفَةِ قُلُوبُهُمْ وَفِي الرِّقَابِ وَالْغَارِمِينَ وَفِي سَبِيلِ اللَّهِ وَابْنِ السَّبِيلِ فَرِيضَةً مِّنَ اللَّهِ﴾',
                style: TextStyle(
                    color: ZakatTheme.gold,
                    fontSize: 17,
                    height: 2.0,
                    fontFamily: 'Scheherazade'),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: masarifZakat.length,
                itemBuilder: (ctx, i) => _MasrafCard(
                    masraf: masarifZakat[i], number: i + 1, isDark: isDark),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _MasrafCard extends StatefulWidget {
  final MasrafModel masraf;
  final int number;
  final bool isDark;
  const _MasrafCard(
      {required this.masraf, required this.number, required this.isDark});

  @override
  State<_MasrafCard> createState() => _MasrafCardState();
}

class _MasrafCardState extends State<_MasrafCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final cardColor = ZakatTheme.cardBgAdaptive(isDark);
    final textColor = isDark ? ZakatTheme.darkTextPrimary : ZakatTheme.darkText;
    final subColor = isDark ? ZakatTheme.darkTextSecondary : ZakatTheme.medText;
    final color = Color(int.parse('0xFF${widget.masraf.color.substring(1)}'));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ZakatTheme.cardShadowAdaptive(isDark),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.35 : 0.2)),
      ),
      child: Column(children: [
        ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.18 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
                child: Text(widget.masraf.icon,
                    style: const TextStyle(fontSize: 20))),
          ),
          title: Text('${widget.number}. ${widget.masraf.name}',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: color,
                  fontFamily: 'Scheherazade')),
          subtitle: Text(widget.masraf.description,
              style: TextStyle(
                  fontSize: 13,
                  color: subColor,
                  fontFamily: 'Scheherazade',
                  height: 1.5),
              maxLines: _expanded ? null : 2),
          trailing: IconButton(
            icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                color: color),
            onPressed: () => setState(() => _expanded = !_expanded),
          ),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Divider(color: isDark ? ZakatTheme.darkBorder : null),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? ZakatTheme.gold.withValues(alpha: 0.1)
                      : ZakatTheme.paleGold.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(widget.masraf.evidence,
                    style: TextStyle(
                        fontSize: 15,
                        height: 1.8,
                        color: textColor,
                        fontFamily: 'Scheherazade')),
              ),
              const SizedBox(height: 12),
              Text(AppLocalizations.of(context).realExamples,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Scheherazade',
                      fontSize: 15,
                      color: textColor)),
              const SizedBox(height: 8),
              ...widget.masraf.examples.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.arrow_left, color: color, size: 18),
                          const SizedBox(width: 4),
                          Expanded(
                              child: Text(e,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: subColor,
                                      fontFamily: 'Scheherazade'))),
                        ]),
                  )),
            ]),
          ),
      ]),
    );
  }
}

// ==============================
// شاشة الفتاوى
// ==============================
class FatawaScreen extends StatefulWidget {
  const FatawaScreen({super.key});
  @override
  State<FatawaScreen> createState() => _FatawaScreenState();
}

class _FatawaScreenState extends State<FatawaScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ZakatProvider>();
    final isDark = p.isDarkMode;
    final appBarBg = isDark ? const Color(0xFF0A2A1A) : ZakatTheme.deepGreen;
    final textColor = isDark ? ZakatTheme.darkTextPrimary : ZakatTheme.darkText;

    final filtered = fatawa
        .where((f) =>
            f.question.contains(_searchQuery) ||
            f.answer.contains(_searchQuery))
        .toList();

    return Directionality(
      textDirection: p.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Theme(
        data: isDark ? ZakatTheme.darkTheme : ZakatTheme.theme,
        child: Scaffold(
          backgroundColor: ZakatTheme.scaffoldBgAdaptive(isDark),
          appBar: AppBar(
            title: Text(AppLocalizations.of(context).zakatRulings,
                style: const TextStyle(fontFamily: 'Scheherazade')),
            backgroundColor: appBarBg,
          ),
          body: Column(children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                textDirection: TextDirection.rtl,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: TextStyle(fontFamily: 'Scheherazade', color: textColor),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).searchRulings,
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: ZakatTheme.cardBgAdaptive(isDark),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) =>
                    _FatawaCard(ruling: filtered[i], isDark: isDark),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _FatawaCard extends StatefulWidget {
  final ZakatRulingModel ruling;
  final bool isDark;
  const _FatawaCard({required this.ruling, required this.isDark});
  @override
  State<_FatawaCard> createState() => _FatawaCardState();
}

class _FatawaCardState extends State<_FatawaCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final cardColor = ZakatTheme.cardBgAdaptive(isDark);
    final textColor = isDark ? ZakatTheme.darkTextPrimary : ZakatTheme.darkText;
    final subColor =
        isDark ? ZakatTheme.darkTextSecondary : ZakatTheme.lightText;
    final accent = isDark ? ZakatTheme.lightGreen : ZakatTheme.deepGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: ZakatTheme.cardShadowAdaptive(isDark),
      ),
      child: Column(children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: isDark ? 0.2 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.question_mark, color: accent, size: 18),
          ),
          title: Text(widget.ruling.question,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  fontFamily: 'Scheherazade',
                  color: textColor)),
          trailing: Icon(_open ? Icons.expand_less : Icons.expand_more,
              color: accent),
          onTap: () => setState(() => _open = !_open),
        ),
        if (_open)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Divider(color: isDark ? ZakatTheme.darkBorder : null),
              const SizedBox(height: 8),
              Text(widget.ruling.answer,
                  style: TextStyle(
                      fontSize: 15,
                      height: 1.9,
                      color: textColor,
                      fontFamily: 'Scheherazade')),
              const SizedBox(height: 8),
              Text('${AppLocalizations.of(context).sourceLabel}: ${widget.ruling.source}',
                  style: TextStyle(
                      fontSize: 12,
                      color: subColor,
                      fontFamily: 'Scheherazade')),
            ]),
          ),
      ]),
    );
  }
}

// ==============================
// شاشة اختبار الوجوب (Wizard)
// ==============================
class WizardScreen extends StatefulWidget {
  const WizardScreen({super.key});
  @override
  State<WizardScreen> createState() => _WizardScreenState();
}

class _WizardScreenState extends State<WizardScreen> {
  int _step = 0;
  String? _finalResult;
  String? _finalReason;

  void _answer(bool yes) {
    final q = zakatWizardQuestions[_step];
    if (!yes) {
      setState(() {
        _finalResult = q['noResult'] as String;
        _finalReason = q['noReason'] as String;
      });
      return;
    }
    if (_step < zakatWizardQuestions.length - 1) {
      setState(() => _step++);
    } else {
      setState(() {
        _finalResult = AppLocalizations.of(context).zakatObligatoryYes;
        _finalReason =
            '${AppLocalizations.of(context).zakatObligatoryYesDesc}. ${AppLocalizations.of(context).calculateZakatAmount}';
      });
    }
  }

  void _reset() => setState(() {
        _step = 0;
        _finalResult = null;
        _finalReason = null;
      });

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ZakatProvider>();
    final isDark = p.isDarkMode;
    final appBarBg = isDark ? const Color(0xFF0A2A1A) : ZakatTheme.deepGreen;

    return Directionality(
      textDirection: p.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Theme(
        data: isDark ? ZakatTheme.darkTheme : ZakatTheme.theme,
        child: Scaffold(
          backgroundColor: ZakatTheme.scaffoldBgAdaptive(isDark),
          appBar: AppBar(
            title: Text(
                AppLocalizations.of(context).isZakatObligatory,
                style: const TextStyle(fontFamily: 'Scheherazade')),
            backgroundColor: appBarBg,
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: _finalResult != null
                ? _buildResult(isDark)
                : _buildQuestion(isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestion(bool isDark) {
    final q = zakatWizardQuestions[_step];
    final textColor = isDark ? ZakatTheme.darkTextPrimary : ZakatTheme.darkText;
    final subColor = isDark ? ZakatTheme.darkTextSecondary : ZakatTheme.medText;

    return Column(children: [
      Row(
        children: List.generate(zakatWizardQuestions.length, (i) {
          return Expanded(
            child: Container(
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: i <= _step
                    ? ZakatTheme.deepGreen
                    : ZakatTheme.deepGreen.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
      ),
      const SizedBox(height: 8),
      Text(AppLocalizations.of(context).questionOf(_step + 1, zakatWizardQuestions.length),
          style: TextStyle(
              color: subColor, fontSize: 13, fontFamily: 'Scheherazade')),
      const Spacer(),
      Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [ZakatTheme.darkCard, ZakatTheme.darkSurface])
              : ZakatTheme.cardGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: ZakatTheme.cardShadowAdaptive(isDark),
          border: Border.all(color: ZakatTheme.gold.withValues(alpha: 0.3)),
        ),
        child: Column(children: [
          const Icon(Icons.quiz_outlined, color: ZakatTheme.gold, size: 48),
          const SizedBox(height: 20),
          Text(q['question'] as String,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  height: 1.7,
                  fontFamily: 'Scheherazade'),
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(q['subtitle'] as String,
              style: TextStyle(
                  fontSize: 14,
                  color: subColor,
                  height: 1.7,
                  fontFamily: 'Scheherazade'),
              textAlign: TextAlign.center),
        ]),
      ),
      const Spacer(),
      Row(children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _answer(true),
            style: ElevatedButton.styleFrom(
                backgroundColor: ZakatTheme.deepGreen,
                padding: const EdgeInsets.symmetric(vertical: 16)),
            child: Text(q['yes'] as String,
                style:
                    const TextStyle(fontSize: 18, fontFamily: 'Scheherazade')),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _answer(false),
            style: OutlinedButton.styleFrom(
                side: const BorderSide(color: ZakatTheme.error),
                padding: const EdgeInsets.symmetric(vertical: 16)),
            child: Text(q['no'] as String,
                style: const TextStyle(
                    fontSize: 18,
                    color: ZakatTheme.error,
                    fontFamily: 'Scheherazade')),
          ),
        ),
      ]),
      const SizedBox(height: 16),
    ]);
  }

  Widget _buildResult(bool isDark) {
    final isObligation = _finalResult!.startsWith('✅');
    final textColor =
        isDark ? ZakatTheme.darkTextSecondary : ZakatTheme.medText;

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: isObligation
              ? ZakatTheme.mainGradient
              : (isDark
                  ? const LinearGradient(
                      colors: [ZakatTheme.darkCard, ZakatTheme.darkSurface])
                  : ZakatTheme.cardGradient),
          borderRadius: BorderRadius.circular(24),
          boxShadow: ZakatTheme.cardShadowAdaptive(isDark),
        ),
        child: Column(children: [
          Text(isObligation ? '🟢' : '🔴',
              style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(_finalResult!,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isObligation ? Colors.white : ZakatTheme.error,
                  fontFamily: 'Scheherazade'),
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(_finalReason!,
              style: TextStyle(
                  fontSize: 16,
                  color: isObligation ? Colors.white70 : textColor,
                  height: 1.7,
                  fontFamily: 'Scheherazade'),
              textAlign: TextAlign.center),
        ]),
      ),
      const SizedBox(height: 32),
      ElevatedButton.icon(
        onPressed: _reset,
        icon: const Icon(Icons.refresh),
        label: Text(AppLocalizations.of(context).retakeTest,
            style: const TextStyle(fontFamily: 'Scheherazade')),
      ),
      if (isObligation) ...[
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.calculate_outlined),
          label: Text(AppLocalizations.of(context).calculateZakatAmount,
              style: const TextStyle(fontFamily: 'Scheherazade')),
          style: OutlinedButton.styleFrom(
              side: const BorderSide(color: ZakatTheme.deepGreen)),
        ),
      ],
    ]);
  }
}
