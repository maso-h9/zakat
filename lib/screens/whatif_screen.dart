import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/zakat_provider.dart';
import '../utils/theme.dart';
import '../l10n/app_localizations.dart';

class WhatIfScreen extends StatefulWidget {
  const WhatIfScreen({super.key});

  @override
  State<WhatIfScreen> createState() => _WhatIfScreenState();
}

class _WhatIfScreenState extends State<WhatIfScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // تبويب 1: حاسبة تقديرية
  double _amount = 10000;
  final _amountCtrl = TextEditingController(text: '10000');

  // تبويب 2: تخطيط سنوي
  double _monthlyIncome = 0;
  double _monthlySavingsRate = 0.2; // 20%
  int _yearsToProject = 5;
  final _incomeCtrl = TextEditingController();

  // تبويب 3: مقارنة
  final _scenario1Ctrl = TextEditingController();
  final _scenario2Ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountCtrl.dispose();
    _incomeCtrl.dispose();
    _scenario1Ctrl.dispose();
    _scenario2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ZakatProvider>();
    final isDark = p.isDarkMode;
    final appBarColor = isDark ? const Color(0xFF0A2A1A) : ZakatTheme.deepGreen;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ZakatTheme.scaffoldBgAdaptive(isDark),
        appBar: AppBar(
          backgroundColor: appBarColor,
          title: Text(AppLocalizations.of(context).whatIfTitle),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: ZakatTheme.gold,
            indicatorWeight: 3,
            labelColor: ZakatTheme.gold,
            unselectedLabelColor: Colors.white60,
            labelStyle: const TextStyle(
                fontFamily: 'Scheherazade',
                fontSize: 13,
                fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: AppLocalizations.of(context).instantCalculator),
              Tab(text: AppLocalizations.of(context).annualForecast),
              Tab(text: AppLocalizations.of(context).scenarioComparison),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildQuickCalc(p, isDark),
            _buildYearlyProjection(p, isDark),
            _buildScenarioComparison(p, isDark),
          ],
        ),
      ),
    );
  }

  // ==============================
  // تبويب 1: حاسبة فورية
  // ==============================
  Widget _buildQuickCalc(ZakatProvider p, bool isDark) {
    final l10n = AppLocalizations.of(context);
    final cardColor = ZakatTheme.cardBgAdaptive(isDark);
    final textColor = isDark ? ZakatTheme.darkTextPrimary : ZakatTheme.darkText;
    final subColor = isDark ? ZakatTheme.darkTextSecondary : ZakatTheme.medText;

    final zakat = _amount >= p.goldNisabValue ? _amount * 0.025 : 0.0;
    final remaining = _amount - zakat;
    final hasNisab = _amount >= p.goldNisabValue;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Input card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: ZakatTheme.cardShadowAdaptive(isDark),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.ifYouOwn,
                    style: TextStyle(
                        fontFamily: 'Scheherazade',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor)),
                const SizedBox(height: 16),
                TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.rtl,
                  onChanged: (v) =>
                      setState(() => _amount = double.tryParse(v) ?? 0),
                  style: TextStyle(
                      fontFamily: 'Scheherazade',
                      fontSize: 18,
                      color: textColor),
                  decoration: InputDecoration(
                    labelText: '${l10n.amount} (${p.currencySymbol})',
                    suffixText: p.currencySymbol,
                    suffixStyle: const TextStyle(
                        fontFamily: 'Scheherazade',
                        color: ZakatTheme.gold,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Slider(
                  value: _amount.clamp(0, 500000),
                  min: 0,
                  max: 500000,
                  divisions: 500,
                  activeColor: hasNisab ? ZakatTheme.deepGreen : Colors.grey,
                  inactiveColor: Colors.grey.withValues(alpha: 0.3),
                  onChanged: (v) {
                    setState(() {
                      _amount = v.roundToDouble();
                      _amountCtrl.text = _amount.toStringAsFixed(0);
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0',
                        style: TextStyle(
                            color: subColor,
                            fontSize: 12,
                            fontFamily: 'Scheherazade')),
                    Text('500,000 ${p.currencySymbol}',
                        style: TextStyle(
                            color: subColor,
                            fontSize: 12,
                            fontFamily: 'Scheherazade')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Result card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: hasNisab
                  ? ZakatTheme.mainGradient
                  : (isDark
                      ? const LinearGradient(
                          colors: [Color(0xFF333333), Color(0xFF444444)])
                      : const LinearGradient(
                          colors: [Color(0xFF616161), Color(0xFF9E9E9E)])),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  hasNisab ? l10n.zakatObligatoryShort : l10n.belowNisabShort,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Scheherazade'),
                ),
                const SizedBox(height: 16),
                if (hasNisab) ...[
                  Text(l10n.zakatDuePercent,
                      style: const TextStyle(
                          color: Colors.white70, fontFamily: 'Scheherazade')),
                  Text(
                    '${zakat.toStringAsFixed(2)} ${p.currencySymbol}',
                    style: const TextStyle(
                      color: ZakatTheme.gold,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Scheherazade',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                      '${l10n.remainingAfterZakat}: ${remaining.toStringAsFixed(0)} ${p.currencySymbol}',
                      style: const TextStyle(
                          color: Colors.white70,
                          fontFamily: 'Scheherazade',
                          fontSize: 13)),
                ] else
                  Text(
                    '${l10n.nisabInfo}: ${p.goldNisabValue.toStringAsFixed(0)} ${p.currencySymbol}\n${l10n.remainingToNisab}: ${(p.goldNisabValue - _amount).toStringAsFixed(0)} ${p.currencySymbol}',
                    style: const TextStyle(
                        color: Colors.white70,
                        fontFamily: 'Scheherazade',
                        height: 1.8),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Comparison table
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: ZakatTheme.cardShadowAdaptive(isDark),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.quickComparisonTable,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Scheherazade',
                        color: textColor)),
                const SizedBox(height: 12),
                ...[5000, 10000, 25000, 50000, 100000, 200000]
                    .map((amt) => _compactRow(amt.toDouble(), p, isDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _compactRow(double amount, ZakatProvider p, bool isDark) {
    final l10n = AppLocalizations.of(context);
    final zakat = amount >= p.goldNisabValue ? amount * 0.025 : 0.0;
    final isHighlighted = (_amount - amount).abs() < 2500;
    final subColor = isDark ? ZakatTheme.darkTextSecondary : ZakatTheme.medText;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isHighlighted ? ZakatTheme.deepGreen.withValues(alpha: 0.08) : null,
        borderRadius: BorderRadius.circular(8),
        border: isHighlighted
            ? Border.all(color: ZakatTheme.deepGreen.withValues(alpha: 0.2))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${_formatNum(amount)} ${p.currencySymbol}',
              style: TextStyle(
                  fontFamily: 'Scheherazade',
                  fontSize: 14,
                  fontWeight:
                      isHighlighted ? FontWeight.bold : FontWeight.normal,
                  color: isHighlighted ? ZakatTheme.deepGreen : subColor)),
          Text(
            zakat > 0
                ? '${_formatNum(zakat)} ${p.currencySymbol}'
                : l10n.below,
            style: TextStyle(
              color: zakat > 0
                  ? (isHighlighted ? ZakatTheme.gold : ZakatTheme.deepGreen)
                  : ZakatTheme.lightText,
              fontWeight: FontWeight.bold,
              fontFamily: 'Scheherazade',
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================
  // تبويب 2: توقع سنوي
  // ==============================
  Widget _buildYearlyProjection(ZakatProvider p, bool isDark) {
    final l10n = AppLocalizations.of(context);
    final cardColor = ZakatTheme.cardBgAdaptive(isDark);
    final textColor = isDark ? ZakatTheme.darkTextPrimary : ZakatTheme.darkText;
    final subColor = isDark ? ZakatTheme.darkTextSecondary : ZakatTheme.medText;

    // حساب التوقعات
    final List<Map<String, double>> projection = [];
    double accumulated = 0;
    final annualSavings = _monthlyIncome * _monthlySavingsRate * 12;

    for (int y = 1; y <= _yearsToProject; y++) {
      accumulated += annualSavings;
      final zakat = accumulated >= p.goldNisabValue ? accumulated * 0.025 : 0.0;
      projection.add({
        'year': y.toDouble(),
        'savings': accumulated,
        'zakat': zakat,
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: ZakatTheme.cardShadowAdaptive(isDark),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.forecastSettings,
                    style: TextStyle(
                        fontFamily: 'Scheherazade',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: textColor)),
                const SizedBox(height: 16),
                TextField(
                  controller: _incomeCtrl,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.rtl,
                  onChanged: (v) =>
                      setState(() => _monthlyIncome = double.tryParse(v) ?? 0),
                  style:
                      TextStyle(fontFamily: 'Scheherazade', color: textColor),
                  decoration: InputDecoration(
                    labelText: '${l10n.monthlyIncome} (${p.currencySymbol})',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${l10n.monthlySavingsRate}: ${(_monthlySavingsRate * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                      fontFamily: 'Scheherazade',
                      fontSize: 14,
                      color: subColor),
                ),
                Slider(
                  value: _monthlySavingsRate,
                  min: 0.05,
                  max: 0.8,
                  divisions: 15,
                  activeColor: ZakatTheme.deepGreen,
                  label: '${(_monthlySavingsRate * 100).toStringAsFixed(0)}%',
                  onChanged: (v) => setState(() => _monthlySavingsRate = v),
                ),
                const SizedBox(height: 8),
                Text(
                  '${l10n.yearsCount}: $_yearsToProject',
                  style: TextStyle(
                      fontFamily: 'Scheherazade',
                      fontSize: 14,
                      color: subColor),
                ),
                Slider(
                  value: _yearsToProject.toDouble(),
                  min: 1,
                  max: 20,
                  divisions: 19,
                  activeColor: ZakatTheme.gold,
                  label: '$_yearsToProject',
                  onChanged: (v) => setState(() => _yearsToProject = v.toInt()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_monthlyIncome > 0) ...[
            // Table
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: ZakatTheme.cardShadowAdaptive(isDark),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0A2A1A)
                          : ZakatTheme.deepGreen,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(l10n.yearLabel,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Scheherazade',
                                    fontWeight: FontWeight.bold))),
                        Expanded(
                            child: Text(l10n.savingsLabel,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Scheherazade',
                                    fontWeight: FontWeight.bold))),
                        Expanded(
                            child: Text(l10n.zakatLabel,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: ZakatTheme.gold,
                                    fontFamily: 'Scheherazade',
                                    fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                  ...projection.map((row) {
                    final hasZakat = row['zakat']! > 0;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              color: isDark
                                  ? ZakatTheme.darkBorder
                                  : const Color(0xFFEEE8D5),
                              width: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                              child: Text(l10n.yearLabel2(row['year']!.toInt()),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: 'Scheherazade',
                                      color: textColor))),
                          Expanded(
                              child: Text(
                                  '${_formatNum(row['savings']!)} ${p.currencySymbol}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: 'Scheherazade',
                                      color: textColor,
                                      fontSize: 13))),
                          Expanded(
                              child: Text(
                                  hasZakat
                                      ? '${_formatNum(row['zakat']!)} ${p.currencySymbol}'
                                      : '—',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: 'Scheherazade',
                                      color: hasZakat
                                          ? ZakatTheme.gold
                                          : ZakatTheme.lightText,
                                      fontWeight: hasZakat
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 13))),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ] else
            Container(
              padding: const EdgeInsets.all(32),
              child: Text(
                l10n.enterIncomeHint,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Scheherazade',
                    color: ZakatTheme.lightText,
                    fontSize: 15),
              ),
            ),
        ],
      ),
    );
  }

  // ==============================
  // تبويب 3: مقارنة سيناريوهات
  // ==============================
  Widget _buildScenarioComparison(ZakatProvider p, bool isDark) {
    final l10n = AppLocalizations.of(context);
    final cardColor = ZakatTheme.cardBgAdaptive(isDark);
    final textColor = isDark ? ZakatTheme.darkTextPrimary : ZakatTheme.darkText;

    final s1 = double.tryParse(_scenario1Ctrl.text) ?? 0;
    final s2 = double.tryParse(_scenario2Ctrl.text) ?? 0;
    final z1 = s1 >= p.goldNisabValue ? s1 * 0.025 : 0.0;
    final z2 = s2 >= p.goldNisabValue ? s2 * 0.025 : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Scenario inputs
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: ZakatTheme.deepGreen.withValues(alpha: 0.4)),
                    boxShadow: ZakatTheme.cardShadowAdaptive(isDark),
                  ),
                  child: Column(
                    children: [
                      Text(l10n.scenarioOne,
                          style: const TextStyle(
                              fontFamily: 'Scheherazade',
                              fontWeight: FontWeight.bold,
                              color: ZakatTheme.deepGreen)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _scenario1Ctrl,
                        keyboardType: TextInputType.number,
                        textDirection: TextDirection.rtl,
                        onChanged: (_) => setState(() {}),
                        style: TextStyle(
                            fontFamily: 'Scheherazade', color: textColor),
                        decoration: InputDecoration(
                          hintText: l10n.amount,
                          isDense: true,
                          suffixText: p.currencySymbol,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('VS',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ZakatTheme.gold,
                        fontSize: 16)),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: ZakatTheme.gold.withValues(alpha: 0.4)),
                    boxShadow: ZakatTheme.cardShadowAdaptive(isDark),
                  ),
                  child: Column(
                    children: [
                      Text(l10n.scenarioTwo,
                          style: const TextStyle(
                              fontFamily: 'Scheherazade',
                              fontWeight: FontWeight.bold,
                              color: ZakatTheme.gold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _scenario2Ctrl,
                        keyboardType: TextInputType.number,
                        textDirection: TextDirection.rtl,
                        onChanged: (_) => setState(() {}),
                        style: TextStyle(
                            fontFamily: 'Scheherazade', color: textColor),
                        decoration: InputDecoration(
                          hintText: l10n.amount,
                          isDense: true,
                          suffixText: p.currencySymbol,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (s1 > 0 || s2 > 0) ...[
            // Comparison result
            Row(
              children: [
                Expanded(
                    child: _scenarioResult(context,
                        l10n.scenarioOne, s1, z1, ZakatTheme.deepGreen, p, isDark)),
                const SizedBox(width: 12),
                Expanded(
                    child: _scenarioResult(context,
                        l10n.scenarioTwo, s2, z2, ZakatTheme.gold, p, isDark)),
              ],
            ),
            const SizedBox(height: 16),

            // Difference
            if (s1 > 0 && s2 > 0)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: ZakatTheme.cardShadowAdaptive(isDark),
                ),
                child: Column(
                  children: [
                    Text(l10n.differenceSection,
                        style: TextStyle(
                            fontFamily: 'Scheherazade',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: textColor)),
                    const SizedBox(height: 12),
                    _diffRow(context, l10n.amountDiff, (s1 - s2).abs(), p, isDark),
                    const SizedBox(height: 6),
                    _diffRow(context, l10n.zakatDiff, (z1 - z2).abs(), p, isDark),
                    const SizedBox(height: 6),
                    _diffRow(context, l10n.remainingAfterZakat1, (s1 - z1), p, isDark),
                    _diffRow(context, l10n.remainingAfterZakat2, (s2 - z2), p, isDark),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _scenarioResult(BuildContext context, String label, double amount, double zakat, Color color,
      ZakatProvider p, bool isDark) {
    final l10n = AppLocalizations.of(context);
    final hasNisab = amount >= p.goldNisabValue;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Scheherazade',
                  fontSize: 12)),
          const SizedBox(height: 4),
          Text('${_formatNum(amount)} ${p.currencySymbol}',
              style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Scheherazade',
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          const SizedBox(height: 8),
          Text(hasNisab ? l10n.obligatoryZakat : l10n.below,
              style: TextStyle(
                  color: hasNisab ? Colors.white70 : Colors.white38,
                  fontFamily: 'Scheherazade',
                  fontSize: 11)),
          if (hasNisab)
            Text('${_formatNum(zakat)} ${p.currencySymbol}',
                style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Scheherazade',
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
        ],
      ),
    );
  }

  Widget _diffRow(BuildContext context, String label, double value, ZakatProvider p, bool isDark) {
    final textColor =
        isDark ? ZakatTheme.darkTextSecondary : ZakatTheme.medText;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontFamily: 'Scheherazade', fontSize: 13, color: textColor)),
          Text('${_formatNum(value)} ${p.currencySymbol}',
              style: TextStyle(
                  fontFamily: 'Scheherazade',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? ZakatTheme.darkTextPrimary
                      : ZakatTheme.darkText)),
        ],
      ),
    );
  }

  String _formatNum(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}م';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}ك';
    return v.toStringAsFixed(0);
  }
}
