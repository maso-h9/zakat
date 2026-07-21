// ================================================================
// calculator_screen.dart — حاسبة الزكاة الكاملة
// ================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/zakat_provider.dart';
import '../utils/theme.dart';
import 'package:zakat_app/l10n/app_localizations.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});
  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _moneyCtrl = TextEditingController();
  final _goldCtrl = TextEditingController();
  final _silverCtrl = TextEditingController();
  final _tradeCtrl = TextEditingController();
  final _debtsOwedCtrl = TextEditingController();
  final _debtsReceiveCtrl = TextEditingController();
  final _camelsCtrl = TextEditingController();
  final _cowsCtrl = TextEditingController();
  final _sheepCtrl = TextEditingController();
  final _cropsCtrl = TextEditingController();
  bool _isIrrigated = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final c in [
      _moneyCtrl,
      _goldCtrl,
      _silverCtrl,
      _tradeCtrl,
      _debtsOwedCtrl,
      _debtsReceiveCtrl,
      _camelsCtrl,
      _cowsCtrl,
      _sheepCtrl,
      _cropsCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ZakatProvider>();
    final isDark = p.isDarkMode;
    final appBarBg = isDark ? const Color(0xFF0A2A1A) : ZakatTheme.deepGreen;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Theme(
        // تطبيق Dark Mode على كل عناصر الشاشة
        data: isDark ? ZakatTheme.darkTheme : ZakatTheme.theme,
        child: Scaffold(
          backgroundColor: ZakatTheme.scaffoldBgAdaptive(isDark),
          appBar: AppBar(
            title: Text(AppLocalizations.of(context).calculatorTitle,
                style: const TextStyle(fontFamily: 'Scheherazade')),
            backgroundColor: appBarBg,
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
                Tab(text: p.isArabic ? 'النقود' : 'Cash'),
                Tab(text: p.isArabic ? 'التجارة' : 'Trade'),
                Tab(text: p.isArabic ? 'الأنعام' : 'Livestock'),
                Tab(text: p.isArabic ? 'الزروع' : 'Crops'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildMoneyTab(p, isDark),
              _buildTradeTab(p, isDark),
              _buildAnimalsTab(p, isDark),
              _buildCropsTab(p, isDark),
            ],
          ),
          bottomNavigationBar: _buildResultBar(p, isDark),
        ),
      ),
    );
  }

  // ─── تبويب النقود ─────────────────────────────────────────────
  Widget _buildMoneyTab(ZakatProvider p, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _goldPriceCard(p, isDark),
        const SizedBox(height: 16),
        _sectionCard(
          title: AppLocalizations.of(context).cashAndSavings,
          icon: Icons.account_balance_wallet_outlined,
          isDark: isDark,
          children: [
            _inputField(
                _moneyCtrl,
                '${AppLocalizations.of(context).savedAmount} (${p.currencySymbol})',
                '',
                (v) => p.updateWealth(money: double.tryParse(v) ?? 0),
                isDark: isDark),
            const SizedBox(height: 10),
            _inputField(
                _debtsReceiveCtrl,
                '${AppLocalizations.of(context).receivables} (${p.currencySymbol})',
                '',
                (v) => p.updateWealth(debtsReceive: double.tryParse(v) ?? 0),
                isDark: isDark),
            const SizedBox(height: 10),
            _inputField(
                _debtsOwedCtrl,
                '${p.isArabic ? "الديون عليك" : "Your debts"} (${p.currencySymbol})',
                '',
                (v) => p.updateWealth(debtsOwedVal: double.tryParse(v) ?? 0),
                isDark: isDark),
          ],
        ),
        const SizedBox(height: 16),
        _sectionCard(
          title: AppLocalizations.of(context).goldSection,
          icon: Icons.circle,
          iconColor: ZakatTheme.gold,
          isDark: isDark,
          children: [
            _inputField(
                _goldCtrl,
                AppLocalizations.of(context).goldWeightGrams,
                '',
                (v) => p.updateWealth(gold: double.tryParse(v) ?? 0),
                isDark: isDark),
            const SizedBox(height: 8),
            _nisabInfo(
                '${AppLocalizations.of(context).goldNisabHint} = ${p.goldNisabValue.toStringAsFixed(0)} ${p.currencySymbol}',
                ZakatTheme.gold,
                isDark),
          ],
        ),
        const SizedBox(height: 16),
        _sectionCard(
          title: AppLocalizations.of(context).silverSection,
          icon: Icons.circle,
          iconColor: Colors.grey,
          isDark: isDark,
          children: [
            _inputField(
                _silverCtrl,
                AppLocalizations.of(context).silverWeightGrams,
                '',
                (v) => p.updateWealth(silver: double.tryParse(v) ?? 0),
                isDark: isDark),
            const SizedBox(height: 8),
            _nisabInfo(
                '${AppLocalizations.of(context).silverNisabHint} = ${p.silverNisabValue.toStringAsFixed(0)} ${p.currencySymbol}',
                Colors.blueGrey,
                isDark),
          ],
        ),
        const SizedBox(height: 100),
      ]),
    );
  }

  Widget _goldPriceCard(ZakatProvider p, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient:
            isDark ? ZakatTheme.darkModeGradient : ZakatTheme.darkGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(AppLocalizations.of(context).goldPricePerGram,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontFamily: 'Scheherazade')),
            const SizedBox(height: 4),
            Text('${p.goldPricePerGram.toStringAsFixed(2)} ${p.currencySymbol}',
                style: const TextStyle(
                    color: ZakatTheme.gold,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Scheherazade')),
            Text(
              p.goldPriceIsLive
                  ? '${AppLocalizations.of(context).live} ${p.goldPriceLastUpdated ?? ""}'
                  : AppLocalizations.of(context).estimated,
              style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontFamily: 'Scheherazade'),
            ),
          ]),
        ),
        IconButton(
          icon: p.isLoadingGoldPrice
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.refresh, color: ZakatTheme.gold),
          onPressed: () => p.fetchGoldPrice(),
          tooltip: AppLocalizations.of(context).updatePrice,
        ),
      ]),
    );
  }

  // ─── تبويب التجارة ────────────────────────────────────────────
  Widget _buildTradeTab(ZakatProvider p, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _sectionCard(
          title: AppLocalizations.of(context).tradeGoodsZakat,
          icon: Icons.store_outlined,
          isDark: isDark,
          children: [
            Text(
              AppLocalizations.of(context).tradeGoodsDescription,
              style: TextStyle(
                  fontFamily: 'Scheherazade',
                  fontSize: 14,
                  color: isDark
                      ? ZakatTheme.darkTextSecondary
                      : ZakatTheme.medText,
                  height: 1.6),
            ),
            const SizedBox(height: 14),
            _inputField(
                _tradeCtrl,
                '${AppLocalizations.of(context).goodsValue} (${p.currencySymbol})',
                '',
                (v) => p.updateWealth(trade: double.tryParse(v) ?? 0),
                isDark: isDark),
          ],
        ),
        if (p.tradeGoods > 0) ...[
          const SizedBox(height: 16),
          _resultCard(
            AppLocalizations.of(context).tradeZakatTitle,
            '${(p.tradeGoods * 0.025).toStringAsFixed(2)} ${p.currencySymbol}',
            AppLocalizations.of(context).tradeZakatFormula,
          ),
        ],
        const SizedBox(height: 80),
      ]),
    );
  }

  // ─── تبويب الأنعام (الجدول الكامل) ──────────────────────────
  Widget _buildAnimalsTab(ZakatProvider p, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _sectionCard(
          title: AppLocalizations.of(context).livestockTitle,
          icon: Icons.pets,
          isDark: isDark,
          children: [
            _inputField(
                _camelsCtrl,
                AppLocalizations.of(context).camelCount,
                '',
                (_) => setState(() {}),
                isDark: isDark),
            if (_camelsCtrl.text.isNotEmpty)
              _animalResult(_camelsCtrl.text, 'camel', p, isDark),
          ],
        ),
        const SizedBox(height: 16),
        _sectionCard(
          title: AppLocalizations.of(context).cattle,
          icon: Icons.emoji_nature,
          isDark: isDark,
          children: [
            _inputField(
                _cowsCtrl,
                AppLocalizations.of(context).cattleCount,
                '',
                (_) => setState(() {}),
                isDark: isDark),
            if (_cowsCtrl.text.isNotEmpty)
              _animalResult(_cowsCtrl.text, 'cow', p, isDark),
          ],
        ),
        const SizedBox(height: 16),
        _sectionCard(
          title: AppLocalizations.of(context).sheep,
          icon: Icons.grass,
          isDark: isDark,
          children: [
            _inputField(
                _sheepCtrl,
                AppLocalizations.of(context).sheepCount,
                '',
                (_) => setState(() {}),
                isDark: isDark),
            if (_sheepCtrl.text.isNotEmpty)
              _animalResult(_sheepCtrl.text, 'sheep', p, isDark),
          ],
        ),
        const SizedBox(height: 80),
      ]),
    );
  }

  // جدول الأنعام الكامل للأعداد الكبيرة
  Widget _animalResult(String text, String kind, ZakatProvider p, bool isDark) {
    final count = int.tryParse(text) ?? 0;

    String result = '';
    bool belowNisab = false;

    if (kind == 'camel') {
      if (count < 5) {
        belowNisab = true;
      } else if (count <= 9) {
        result = 'شاة';
      } else if (count <= 14) {
        result = 'شاتان';
      } else if (count <= 19) {
        result = 'ثلاث شياه';
      } else if (count <= 24) {
        result = 'أربع شياه';
      } else if (count <= 35) {
        result = 'بنت مخاض';
      } else if (count <= 45) {
        result = 'بنت لبون';
      } else if (count <= 60) {
        result = 'حقة';
      } else if (count <= 75) {
        result = 'جذعة';
      } else if (count <= 90) {
        result = 'بنتا لبون';
      } else if (count <= 120) {
        result = 'حقتان';
      } else {
        // فوق 120: لكل 40 بنت لبون، لكل 50 حقة
        final sets50 = count ~/ 50;
        final sets40 = (count % 50) ~/ 40;
        result = '';
        if (sets50 > 0) result += '$sets50 حقة ';
        if (sets40 > 0) result += '$sets40 بنت لبون';
        if (result.trim().isEmpty) result = 'راجع العالم لهذا العدد';
      }
    } else if (kind == 'cow') {
      if (count < 30) {
        belowNisab = true;
      } else if (count <= 39) {
        result = 'تبيع أو تبيعة';
      } else if (count <= 59) {
        result = 'مسنّة';
      } else if (count <= 69) {
        result = 'تبيعان';
      } else if (count <= 79) {
        result = 'مسنّة وتبيع';
      } else if (count <= 89) {
        result = 'مسنّتان';
      } else if (count <= 99) {
        result = 'ثلاثة أتبعة';
      } else if (count <= 109) {
        result = 'مسنّتان وتبيع';
      } else if (count <= 119) {
        result = 'ثلاث مسنّات أو أربعة أتبعة';
      } else {
        // فوق 120: لكل 30 تبيع، لكل 40 مسنّة
        final sets40 = count ~/ 40;
        final sets30 = (count % 40) ~/ 30;
        result = '';
        if (sets40 > 0) result += '$sets40 مسنّة ';
        if (sets30 > 0) result += '$sets30 تبيع';
        if (result.trim().isEmpty) result = '${count ~/ 30} تبيع';
      }
    } else {
      // sheep
      if (count < 40) {
        belowNisab = true;
      } else if (count <= 120) {
        result = 'شاة';
      } else if (count <= 200) {
        result = 'شاتان';
      } else if (count <= 300) {
        result = 'ثلاث شياه';
      } else if (count <= 399) {
        result = 'ثلاث شياه';
      } else if (count <= 499) {
        result = 'أربع شياه';
      } else if (count <= 599) {
        result = 'خمس شياه';
      } else {
        // فوق 600: لكل 100 شاة واحدة
        result = '${count ~/ 100} شاة';
      }
    }

    if (belowNisab) {
      return Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ZakatTheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ZakatTheme.error.withValues(alpha: 0.3)),
        ),
        child: Row(children: [
          const Icon(Icons.info_outline, color: ZakatTheme.error, size: 18),
          const SizedBox(width: 8),
          Text(
            AppLocalizations.of(context).belowNisab,
            style: const TextStyle(
                fontFamily: 'Scheherazade',
                color: ZakatTheme.error,
                fontSize: 14),
          ),
        ]),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: ZakatTheme.mainGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        const Icon(Icons.check_circle, color: Colors.white, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              '${p.isArabic ? "الواجب في" : "Due for"} $count: $result',
              style: const TextStyle(
                  fontFamily: 'Scheherazade',
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            if (count > 120 && kind == 'camel' ||
                count > 120 && kind == 'cow' ||
                count > 600 && kind == 'sheep')
              Text(
                AppLocalizations.of(context).reviewScholarWarning,
                style: const TextStyle(
                    fontFamily: 'Scheherazade',
                    fontSize: 12,
                    color: Colors.white70),
              ),
          ]),
        ),
      ]),
    );
  }

  // ─── تبويب الزروع ─────────────────────────────────────────────
  Widget _buildCropsTab(ZakatProvider p, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _sectionCard(
          title: AppLocalizations.of(context).cropsTitle,
          icon: Icons.eco_outlined,
          isDark: isDark,
          children: [
            Text(
              AppLocalizations.of(context).cropsObligation,
              style: TextStyle(
                  fontFamily: 'Scheherazade',
                  fontSize: 14,
                  color: isDark
                      ? ZakatTheme.darkTextSecondary
                      : ZakatTheme.medText,
                  height: 1.6),
            ),
            const SizedBox(height: 14),
            _inputField(
                _cropsCtrl,
                AppLocalizations.of(context).cropQuantityKg,
                '',
                (_) => setState(() {}),
                isDark: isDark),
            const SizedBox(height: 14),
            // اختيار طريقة الري
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? ZakatTheme.darkSurface : ZakatTheme.cream,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).irrigationMethod,
                    style: TextStyle(
                        fontFamily: 'Scheherazade',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? ZakatTheme.darkTextPrimary
                            : ZakatTheme.darkText),
                  ),
                  const SizedBox(height: 8),
                  RadioGroup<bool>(
                    groupValue: _isIrrigated,
                    onChanged: (v) => setState(() => _isIrrigated = v!),
                    child: Row(children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          value: true,
                          title: Text(
                              AppLocalizations.of(context).rainIrrigation,
                              style: const TextStyle(
                                  fontFamily: 'Scheherazade', fontSize: 13)),
                          activeColor: ZakatTheme.deepGreen,
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          value: false,
                          title: Text(AppLocalizations.of(context).machineIrrigation,
                              style: const TextStyle(
                                  fontFamily: 'Scheherazade', fontSize: 13)),
                          activeColor: ZakatTheme.deepGreen,
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            if (_cropsCtrl.text.isNotEmpty) ...[
              const SizedBox(height: 14),
              Builder(builder: (_) {
                final kg = double.tryParse(_cropsCtrl.text) ?? 0;
                if (kg < 653) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ZakatTheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      AppLocalizations.of(context).cropsBelowNisab,
                      style: const TextStyle(
                          fontFamily: 'Scheherazade', color: ZakatTheme.error),
                    ),
                  );
                }
                final rate = _isIrrigated ? 0.1 : 0.05;
                return _resultCard(
                  AppLocalizations.of(context).cropZakatResult,
                  '${(kg * rate).toStringAsFixed(1)} ${p.isArabic ? "كيلوغرام" : "kg"}',
                  _isIrrigated
                      ? AppLocalizations.of(context).rainRate
                      : AppLocalizations.of(context).machineRate,
                );
              }),
            ],
          ],
        ),
        const SizedBox(height: 80),
      ]),
    );
  }

  // ─── شريط النتيجة ─────────────────────────────────────────────
  Widget _buildResultBar(ZakatProvider p, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: isDark ? ZakatTheme.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context).zakatObligatory,
                style: TextStyle(
                    fontFamily: 'Scheherazade',
                    color: isDark
                        ? ZakatTheme.darkTextSecondary
                        : ZakatTheme.lightText,
                    fontSize: 13),
              ),
              Text(
                '${p.zakatDue.toStringAsFixed(2)} ${p.currencySymbol}',
                style: TextStyle(
                    fontFamily: 'Scheherazade',
                    color: isDark ? ZakatTheme.gold : ZakatTheme.deepGreen,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            if (p.zakatDue > 0) {
              p.addZakatRecord(ZakatRecord(
                year: DateTime.now().year,
                amount: p.zakatDue,
                wealth: p.totalZakatableWealth,
                date: DateTime.now(),
              ));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    AppLocalizations.of(context).zakatPaymentRecorded,
                    style: const TextStyle(fontFamily: 'Scheherazade')),
                backgroundColor: ZakatTheme.success,
              ));
            }
          },
          icon: const Icon(Icons.check, size: 18),
          label: Text(AppLocalizations.of(context).recordPaymentLabel,
              style: const TextStyle(fontFamily: 'Scheherazade')),
        ),
      ]),
    );
  }

  // ─── مساعدات البناء ───────────────────────────────────────────
  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required bool isDark,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ZakatTheme.cardBgAdaptive(isDark),
        borderRadius: BorderRadius.circular(16),
        boxShadow: ZakatTheme.cardShadowAdaptive(isDark),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon,
              color: iconColor ??
                  (isDark ? ZakatTheme.lightGreen : ZakatTheme.deepGreen),
              size: 20),
          const SizedBox(width: 8),
          Text(title,
              style: TextStyle(
                  fontFamily: 'Scheherazade',
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? ZakatTheme.darkTextPrimary
                      : ZakatTheme.darkText)),
        ]),
        const SizedBox(height: 12),
        Divider(
            color: isDark ? ZakatTheme.darkBorder : const Color(0xFFEEE8D5)),
        const SizedBox(height: 12),
        ...children,
      ]),
    );
  }

  Widget _inputField(TextEditingController ctrl, String label, String hint,
      Function(String) onChanged,
      {required bool isDark}) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textDirection: TextDirection.rtl,
      onChanged: onChanged,
      style: TextStyle(
          fontFamily: 'Scheherazade',
          fontSize: 16,
          color: isDark ? ZakatTheme.darkTextPrimary : ZakatTheme.darkText),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint.isEmpty ? null : hint,
        prefixIcon: const Icon(Icons.edit_outlined, size: 18),
      ),
    );
  }

  Widget _nisabInfo(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Icon(Icons.info_outline, size: 14, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: TextStyle(
                  fontFamily: 'Scheherazade',
                  fontSize: 13,
                  color: isDark ? color : ZakatTheme.medText)),
        ),
      ]),
    );
  }

  Widget _resultCard(String title, String value, String note) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: ZakatTheme.mainGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                fontFamily: 'Scheherazade',
                color: Colors.white70,
                fontSize: 13)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontFamily: 'Scheherazade',
                color: ZakatTheme.gold,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(note,
            style: const TextStyle(
                fontFamily: 'Scheherazade',
                color: Colors.white60,
                fontSize: 13)),
      ]),
    );
  }
}
