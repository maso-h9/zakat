// ================================================================
// settings_screen.dart — V12
// تغييرات عن V11:
//   - _officialNisabPanel يقرأ من p.currentCountrySource (Firestore ديناميكي)
//   - دعم أكثر من رابط للمصدر (links list)
//   - عرض مستوى الثقة ونوع المصدر
//   - بطاقة مقارنة النصاب (بند 7)
//   - فتح الرابط الحقيقي عبر url_launcher
// ================================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/zakat_provider.dart';
import '../services/storage_service.dart';
import '../services/nisab_service.dart';
import '../utils/theme.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ZakatProvider>();
    final isDark = p.isDarkMode;
    final bg = ZakatTheme.scaffoldBgAdaptive(isDark);
    final cardColor = ZakatTheme.cardBgAdaptive(isDark);
    final textColor = isDark ? ZakatTheme.darkTextPrimary : ZakatTheme.darkText;
    final subColor =
        isDark ? ZakatTheme.darkTextSecondary : ZakatTheme.lightText;
    final appBarBg = isDark ? const Color(0xFF0A2A1A) : ZakatTheme.deepGreen;
    final divColor = isDark ? ZakatTheme.darkBorder : const Color(0xFFEEE8D5);

    return Directionality(
      textDirection: p.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          title: Text(p.isArabic ? 'الإعدادات' : 'Settings',
              style: const TextStyle(fontFamily: 'Scheherazade')),
          backgroundColor: appBarBg,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── الحساب الشخصي ─────────────────────────────────
            _sectionHeader(
                p.isArabic ? 'الحساب الشخصي' : 'Personal Account', isDark),
            _card(cardColor: cardColor, isDark: isDark, children: [
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      gradient: ZakatTheme.mainGradient,
                      shape: BoxShape.circle),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                title: Text(p.isArabic ? 'حسابي' : 'My Account',
                    style: TextStyle(
                        fontFamily: 'Scheherazade',
                        fontWeight: FontWeight.w600,
                        color: textColor)),
                subtitle: Text(
                    p.isArabic
                        ? 'عرض وتعديل معلوماتك'
                        : 'View and edit your info',
                    style: TextStyle(
                        fontFamily: 'Scheherazade',
                        color: subColor,
                        fontSize: 12)),
                trailing: Icon(
                    p.isArabic ? Icons.chevron_left : Icons.chevron_right,
                    color: subColor),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen())),
              ),
            ]),
            const SizedBox(height: 16),

            // ── المظهر ────────────────────────────────────────
            _sectionHeader(p.isArabic ? 'المظهر' : 'Appearance', isDark),
            _card(cardColor: cardColor, isDark: isDark, children: [
              SwitchListTile(
                value: p.isDarkMode,
                onChanged: p.toggleDarkMode,
                title: Text(p.isArabic ? 'الوضع الداكن' : 'Dark Mode',
                    style: TextStyle(
                        fontFamily: 'Scheherazade', color: textColor)),
                secondary: Icon(
                    p.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: ZakatTheme.deepGreen),
              ),
            ]),
            const SizedBox(height: 16),

            // ── اللغة ─────────────────────────────────────────
            _sectionHeader(p.isArabic ? 'اللغة' : 'Language', isDark),
            _card(cardColor: cardColor, isDark: isDark, children: [
              _langTile(context, p, isDark, textColor, subColor, 'ar',
                  'العربية', '🇸🇦'),
              Divider(height: 1, color: divColor),
              _langTile(context, p, isDark, textColor, subColor, 'en',
                  'English', '🇬🇧'),
            ]),
            const SizedBox(height: 16),

            // ── العملة ────────────────────────────────────────
            _sectionHeader(p.isArabic ? 'العملة' : 'Currency', isDark),
            _card(cardColor: cardColor, isDark: isDark, children: [
              ...currencies.map((c) => Column(children: [
                    ListTile(
                      title: Text('${c.symbol} — ${c.name}',
                          style: TextStyle(
                              fontFamily: 'Scheherazade',
                              color: textColor,
                              fontSize: 14)),
                      trailing: p.selectedCurrency == c.code
                          ? const Icon(Icons.check_circle,
                              color: ZakatTheme.deepGreen)
                          : null,
                      onTap: () => p.setCurrency(c.code, c.symbol),
                    ),
                    if (c != currencies.last)
                      Divider(height: 1, color: divColor),
                  ])),
            ]),
            const SizedBox(height: 16),

            // ── سعر الذهب ─────────────────────────────────────
            _sectionHeader(p.isArabic ? 'سعر الذهب' : 'Gold Price', isDark),
            _card(cardColor: cardColor, isDark: isDark, children: [
              ListTile(
                leading: const Text('🥇', style: TextStyle(fontSize: 24)),
                title: Text(
                  '${p.goldPricePerGram.toStringAsFixed(2)} ${p.currencySymbol} / ${p.isArabic ? "جرام" : "gram"}',
                  style: TextStyle(
                      fontFamily: 'Scheherazade',
                      fontWeight: FontWeight.bold,
                      color: textColor),
                ),
                subtitle: Text(
                  p.goldPriceIsLive
                      ? (p.isArabic
                          ? '✅ سعر مباشر — آخر تحديث: ${p.goldPriceLastUpdated ?? ""}'
                          : '✅ Live — Updated: ${p.goldPriceLastUpdated ?? ""}')
                      : (p.isArabic ? '🕐 سعر مخزن مؤقتاً' : '🕐 Cached price'),
                  style: TextStyle(
                      fontFamily: 'Scheherazade',
                      color: subColor,
                      fontSize: 12),
                ),
                trailing: p.isLoadingGoldPrice
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : IconButton(
                        icon: const Icon(Icons.refresh,
                            color: ZakatTheme.deepGreen),
                        onPressed: () => p.fetchGoldPrice(),
                      ),
              ),
            ]),
            const SizedBox(height: 16),

            // ── وضع رمضان ─────────────────────────────────────
            _sectionHeader(p.isArabic ? 'وضع رمضان' : 'Ramadan Mode', isDark),
            _card(cardColor: cardColor, isDark: isDark, children: [
              SwitchListTile(
                value: p.isRamadanMode,
                onChanged: p.toggleRamadanMode,
                title: Text(
                    p.isArabic ? 'تفعيل وضع رمضان' : 'Enable Ramadan Mode',
                    style: TextStyle(
                        fontFamily: 'Scheherazade', color: textColor)),
                secondary: const Text('🌙', style: TextStyle(fontSize: 22)),
              ),
            ]),
            const SizedBox(height: 16),

            // ── البيانات ──────────────────────────────────────
            _sectionHeader(p.isArabic ? 'البيانات' : 'Data', isDark),
            _card(cardColor: cardColor, isDark: isDark, children: [
              SwitchListTile(
                value: p.cloudSyncEnabled,
                onChanged: p.toggleCloudSync,
                title: Text(p.isArabic ? 'مزامنة سحابية' : 'Cloud Sync',
                    style: TextStyle(
                        fontFamily: 'Scheherazade', color: textColor)),
                secondary: Icon(Icons.cloud_sync, color: ZakatTheme.deepGreen),
              ),
              Divider(height: 1, color: divColor),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: Text(p.isArabic ? 'مسح جميع البيانات' : 'Clear All Data',
                    style: const TextStyle(
                        fontFamily: 'Scheherazade', color: Colors.red)),
                onTap: () => _confirmClear(context, p),
              ),
            ]),
            const SizedBox(height: 16),

            // ══════════════════════════════════════════════════
            // طريقة حساب النصاب — V11/V12
            // ══════════════════════════════════════════════════
            _sectionHeader(
              p.isArabic ? 'طريقة حساب النصاب' : 'Nisab Calculation Method',
              isDark,
              info: p.isArabic
                  ? '🌍 الحساب العالمي\nيعتمد على سعر الذهب العالمي وسعر الصرف.\n\n🏛️ النصاب الرسمي\nيعتمد على القيمة التي تعلنها الجهة الرسمية في بلدك.\n\n✍️ الحساب المخصص\nيتيح إدخال قيمة النصاب أو أسعار الذهب يدوياً.\n\nقد تختلف النتائج بين الطرق بسبب اختلاف مصدر الأسعار.'
                  : '🌍 Global Calculation\nBased on world gold price and exchange rate.\n\n🏛️ Official Nisab\nBased on the value announced by your country\'s official body.\n\n✍️ Custom Calculation\nEnter your own Nisab value or gold prices.\n\nResults may differ between methods due to different price sources.',
            ),
            _card(cardColor: cardColor, isDark: isDark, children: [
              _nisabMethodTile(
                  context: context,
                  p: p,
                  isDark: isDark,
                  textColor: textColor,
                  subColor: subColor,
                  method: NisabMethod.global,
                  icon: '🌍',
                  title: p.isArabic ? 'الحساب العالمي' : 'Global Calculation',
                  subtitle: p.isArabic
                      ? 'سعر الذهب العالمي × سعر الصرف (موصى به)'
                      : 'World gold price × exchange rate (recommended)'),
              Divider(height: 1, color: divColor),
              _nisabMethodTile(
                  context: context,
                  p: p,
                  isDark: isDark,
                  textColor: textColor,
                  subColor: subColor,
                  method: NisabMethod.official,
                  icon: '🏛️',
                  title: p.isArabic
                      ? 'النصاب الرسمي للدولة'
                      : 'Official Country Nisab',
                  subtitle: p.isArabic
                      ? 'القيمة المُعلنة من الجهة الرسمية في بلدك'
                      : 'Value announced by your country\'s official body'),
              if (p.nisabMethod == NisabMethod.official) ...[
                Divider(height: 1, color: divColor),
                _officialNisabPanel(
                    context, p, isDark, textColor, subColor, cardColor),
              ],
              Divider(height: 1, color: divColor),
              _nisabMethodTile(
                  context: context,
                  p: p,
                  isDark: isDark,
                  textColor: textColor,
                  subColor: subColor,
                  method: NisabMethod.custom,
                  icon: '✍️',
                  title: p.isArabic ? 'حساب مخصص' : 'Custom Calculation',
                  subtitle: p.isArabic
                      ? 'أدخل قيمة النصاب أو أسعار الذهب يدوياً'
                      : 'Enter Nisab value or gold prices manually'),
              if (p.nisabMethod == NisabMethod.custom) ...[
                Divider(height: 1, color: divColor),
                _customNisabPanel(
                    context, p, isDark, textColor, subColor, cardColor),
              ],
            ]),
            const SizedBox(height: 16),

            // ── بطاقة مقارنة النصاب (بند 7) ──────────────────
            if (p.nisabMethod != NisabMethod.global)
              _nisabComparisonCard(p, isDark, textColor, subColor, cardColor),

            const SizedBox(height: 16),

            // ── عن التطبيق ────────────────────────────────────
            _sectionHeader(p.isArabic ? 'عن التطبيق' : 'About', isDark),
            _card(cardColor: cardColor, isDark: isDark, children: [
              ListTile(
                leading:
                    const Icon(Icons.info_outline, color: ZakatTheme.deepGreen),
                title: Text(p.isArabic ? 'تطبيق الزكاة' : 'Zakat App',
                    style: TextStyle(
                        fontFamily: 'Scheherazade', color: textColor)),
                subtitle: Text(
                    'v2.0 — ${p.isArabic ? "نسخة متطورة" : "Advanced Edition"}',
                    style: TextStyle(
                        fontFamily: 'Scheherazade',
                        color: subColor,
                        fontSize: 12)),
              ),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // لوحة النصاب الرسمي — V12 ديناميكي من Firestore
  // ════════════════════════════════════════════════════════════
  Widget _officialNisabPanel(BuildContext context, ZakatProvider p, bool isDark,
      Color textColor, Color subColor, Color cardColor) {
    final source = p.currentCountrySource;
    final ctrl = TextEditingController(
        text: p.officialNisabValue > 0
            ? p.officialNisabValue.toStringAsFixed(0)
            : '');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── حالة التحميل ──────────────────────────────────────
        if (p.isLoadingSource)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )

        // ── مصدر رسمي موجود ──────────────────────────────────
        else if (source != null && source.isActive) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ZakatTheme.deepGreen.withOpacity(isDark ? 0.12 : 0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ZakatTheme.deepGreen.withOpacity(0.35)),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // اسم الجهة
              Row(children: [
                const Icon(Icons.verified,
                    color: ZakatTheme.deepGreen, size: 18),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(source.name,
                        style: TextStyle(
                            fontFamily: 'Scheherazade',
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            fontSize: 15))),
              ]),
              // آخر مراجعة + نوع المصدر
              if (source.lastReviewed.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${p.isArabic ? "آخر مراجعة" : "Last reviewed"}: ${source.lastReviewed}',
                    style: TextStyle(
                        fontFamily: 'Scheherazade',
                        fontSize: 12,
                        color: subColor),
                  ),
                ),
              if (source.links.isNotEmpty) ...[
                const SizedBox(height: 12),
                // روابط المصدر (مرتبة حسب priority)
                ...(source.links
                      ..sort((a, b) => a.priority.compareTo(b.priority)))
                    .map((link) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(children: [
                            // مستوى الثقة + نوع المصدر
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _trustColor(link.trustLevel)
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: _trustColor(link.trustLevel)
                                        .withOpacity(0.4)),
                              ),
                              child: Text('${link.typeIcon} ${link.trustLabel}',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontFamily: 'Scheherazade',
                                      color: _trustColor(link.trustLevel))),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _openUrl(context, link.url, p.isArabic),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      ZakatTheme.deepGreen.withOpacity(0.85),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                ),
                                icon: const Icon(Icons.open_in_new,
                                    size: 14, color: Colors.white),
                                label: Text(
                                    p.isArabic ? 'فتح المصدر' : 'Open Source',
                                    style: const TextStyle(
                                        fontFamily: 'Scheherazade',
                                        fontSize: 12,
                                        color: Colors.white)),
                              ),
                            ),
                          ]),
                        )),
              ],
            ]),
          ),
          const SizedBox(height: 14),

          // ── لا يوجد مصدر ─────────────────────────────────────
        ] else ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ZakatTheme.gold.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ZakatTheme.gold.withOpacity(0.3)),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline, color: ZakatTheme.gold, size: 18),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(
                p.isArabic
                    ? 'لا يتوفر مصدر رسمي معروف لهذه الدولة — سيُستخدم الحساب العالمي إذا لم تدخل قيمة.'
                    : 'No known official source for this country — global calculation will be used if no value entered.',
                style: TextStyle(
                    fontFamily: 'Scheherazade',
                    fontSize: 13,
                    color: subColor,
                    height: 1.6),
              )),
            ]),
          ),
          const SizedBox(height: 12),
        ],

        // ── حقل إدخال القيمة ─────────────────────────────────
        Text(
            p.isArabic
                ? 'أدخل قيمة النصاب الرسمية:'
                : 'Enter official Nisab value:',
            style: TextStyle(
                fontFamily: 'Scheherazade', fontSize: 14, color: subColor)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: TextField(
              controller: ctrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textDirection: TextDirection.rtl,
              style: TextStyle(fontFamily: 'Scheherazade', color: textColor),
              decoration: InputDecoration(
                hintText: p.isArabic ? 'مثال: 97495' : 'Example: 97495',
                suffixText: p.currencySymbol,
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(ctrl.text.replaceAll(',', ''));
              if (val != null && val > 0) {
                p.setOfficialNisab(val);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                    p.isArabic
                        ? 'تم حفظ النصاب: ${val.toStringAsFixed(0)} ${p.currencySymbol}'
                        : 'Saved: ${val.toStringAsFixed(0)} ${p.currencySymbol}',
                    style: const TextStyle(fontFamily: 'Scheherazade'),
                  ),
                ));
              }
            },
            style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
            child: Text(p.isArabic ? 'حفظ' : 'Save',
                style: const TextStyle(fontFamily: 'Scheherazade')),
          ),
        ]),
        if (p.officialNisabValue > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${p.isArabic ? "النصاب المحفوظ" : "Saved Nisab"}: ${p.officialNisabValue.toStringAsFixed(0)} ${p.currencySymbol}',
              style: const TextStyle(
                  color: ZakatTheme.deepGreen,
                  fontFamily: 'Scheherazade',
                  fontSize: 13),
            ),
          ),
      ]),
    );
  }

  // ════════════════════════════════════════════════════════════
  // بطاقة مقارنة النصاب (بند 7) — V12
  // ════════════════════════════════════════════════════════════
  Widget _nisabComparisonCard(ZakatProvider p, bool isDark, Color textColor,
      Color subColor, Color cardColor) {
    final cmp = p.nisabComparison;
    if (cmp.isSameAsGlobal) return const SizedBox.shrink();

    return Column(children: [
      _sectionHeader(p.isArabic ? 'مقارنة النصاب' : 'Nisab Comparison', isDark),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: ZakatTheme.cardShadowAdaptive(isDark),
          border: Border.all(
            color: cmp.isHigherThanGlobal
                ? Colors.orange.withOpacity(0.4)
                : Colors.green.withOpacity(0.4),
          ),
        ),
        child: Column(children: [
          Row(children: [
            Expanded(
                child: _cmpItem(
              p.isArabic ? 'النصاب العالمي' : 'Global Nisab',
              '${cmp.globalValue.toStringAsFixed(0)} ${p.currencySymbol}',
              ZakatTheme.deepGreen,
              textColor,
              subColor,
            )),
            Container(
                width: 1,
                height: 50,
                color: isDark ? ZakatTheme.darkBorder : Colors.grey.shade200),
            Expanded(
                child: _cmpItem(
              p.isArabic
                  ? (p.nisabMethod == NisabMethod.official
                      ? 'النصاب الرسمي'
                      : 'النصاب المخصص')
                  : (p.nisabMethod == NisabMethod.official
                      ? 'Official Nisab'
                      : 'Custom Nisab'),
              '${cmp.activeValue.toStringAsFixed(0)} ${p.currencySymbol}',
              ZakatTheme.gold,
              textColor,
              subColor,
            )),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (cmp.isHigherThanGlobal ? Colors.orange : Colors.green)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(
                cmp.isHigherThanGlobal
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                size: 16,
                color: cmp.isHigherThanGlobal ? Colors.orange : Colors.green,
              ),
              const SizedBox(width: 6),
              Text(
                '${p.isArabic ? "الفرق" : "Difference"}: ${cmp.difference.abs().toStringAsFixed(0)} ${p.currencySymbol}',
                style: TextStyle(
                  fontFamily: 'Scheherazade',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: cmp.isHigherThanGlobal ? Colors.orange : Colors.green,
                ),
              ),
            ]),
          ),
          const SizedBox(height: 8),
          Text(
            p.isArabic
                ? 'الاختلاف ناتج عن اختلاف مصدر الأسعار أو طريقة الحساب المستخدمة.'
                : 'The difference is due to different price sources or calculation methods.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Scheherazade',
                fontSize: 12,
                color: subColor,
                height: 1.6),
          ),
        ]),
      ),
    ]);
  }

  Widget _cmpItem(String label, String value, Color accent, Color textColor,
      Color subColor) {
    return Column(children: [
      Text(label,
          style: TextStyle(
              fontFamily: 'Scheherazade', fontSize: 12, color: subColor)),
      const SizedBox(height: 4),
      Text(value,
          style: TextStyle(
              fontFamily: 'Scheherazade',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: accent)),
    ]);
  }

  // ════════════════════════════════════════════════════════════
  // لوحة الحساب المخصص — كما هي من V11
  // ════════════════════════════════════════════════════════════
  Widget _customNisabPanel(BuildContext context, ZakatProvider p, bool isDark,
      Color textColor, Color subColor, Color cardColor) {
    final directCtrl = TextEditingController(
        text: p.customNisabValue > 0
            ? p.customNisabValue.toStringAsFixed(0)
            : '');
    final gramCtrl = TextEditingController();
    final ozCtrl = TextEditingController();
    final fxCtrl = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _customSubHeader(
            p.isArabic
                ? 'الخيار 1 — إدخال القيمة مباشرة'
                : 'Option 1 — Enter value directly',
            subColor),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
              child: TextField(
            controller: directCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textDirection: TextDirection.rtl,
            style: TextStyle(fontFamily: 'Scheherazade', color: textColor),
            decoration: InputDecoration(
              hintText: p.isArabic ? 'مثال: 97495' : 'Example: 97495',
              suffixText: p.currencySymbol,
              filled: true,
              fillColor: cardColor,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          )),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(directCtrl.text.replaceAll(',', ''));
              if (val != null && val > 0) {
                p.setCustomNisab(val);
                _showSaved(context, p, val);
              }
            },
            style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
            child: Text(p.isArabic ? 'حفظ' : 'Save',
                style: const TextStyle(fontFamily: 'Scheherazade')),
          ),
        ]),
        const SizedBox(height: 16),
        _customSubHeader(
            p.isArabic
                ? 'الخيار 2 — من سعر جرام الذهب'
                : 'Option 2 — From gold gram price',
            subColor),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
              child: TextField(
            controller: gramCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textDirection: TextDirection.rtl,
            style: TextStyle(fontFamily: 'Scheherazade', color: textColor),
            decoration: InputDecoration(
              hintText: p.isArabic ? 'سعر الجرام' : 'Price per gram',
              suffixText: p.currencySymbol,
              filled: true,
              fillColor: cardColor,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          )),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              final g = double.tryParse(gramCtrl.text.replaceAll(',', ''));
              if (g != null && g > 0) {
                final n = p.calcNisabFromGramPrice(g);
                p.setCustomNisab(n);
                _showCalcResult(context, p, g, n);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: ZakatTheme.gold,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
            child: Text(p.isArabic ? 'احسب' : 'Calc',
                style: const TextStyle(
                    fontFamily: 'Scheherazade', color: Colors.black)),
          ),
        ]),
        const SizedBox(height: 16),
        _customSubHeader(
            p.isArabic
                ? 'الخيار 3 — من سعر الأوقية وسعر الصرف'
                : 'Option 3 — From oz price + exchange rate',
            subColor),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
              child: TextField(
            controller: ozCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textDirection: TextDirection.rtl,
            style: TextStyle(fontFamily: 'Scheherazade', color: textColor),
            decoration: InputDecoration(
              hintText: p.isArabic ? 'سعر الأوقية (USD)' : 'Oz price (USD)',
              filled: true,
              fillColor: cardColor,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          )),
          const SizedBox(width: 8),
          Expanded(
              child: TextField(
            controller: fxCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textDirection: TextDirection.rtl,
            style: TextStyle(fontFamily: 'Scheherazade', color: textColor),
            decoration: InputDecoration(
              hintText: p.isArabic ? 'سعر صرف الدولار' : 'USD exchange rate',
              filled: true,
              fillColor: cardColor,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          )),
        ]),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              final oz = double.tryParse(ozCtrl.text.replaceAll(',', ''));
              final fx = double.tryParse(fxCtrl.text.replaceAll(',', ''));
              if (oz != null && fx != null && oz > 0 && fx > 0) {
                final n = p.calcNisabFromOz(oz, fx);
                p.setCustomNisab(n);
                _showCalcResult(context, p, oz / 31.1035 * fx, n);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: ZakatTheme.gold,
                padding: const EdgeInsets.symmetric(vertical: 12)),
            icon: const Icon(Icons.calculate_outlined,
                color: Colors.black, size: 20),
            label: Text(p.isArabic ? 'احسب واحفظ' : 'Calculate & Save',
                style: const TextStyle(
                    fontFamily: 'Scheherazade', color: Colors.black)),
          ),
        ),
        if (p.customNisabValue > 0)
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ZakatTheme.deepGreen.withOpacity(isDark ? 0.15 : 0.07),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: ZakatTheme.deepGreen.withOpacity(0.3)),
              ),
              child: Row(children: [
                const Icon(Icons.check_circle,
                    color: ZakatTheme.deepGreen, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${p.isArabic ? "النصاب المخصص" : "Custom Nisab"}: ${p.customNisabValue.toStringAsFixed(0)} ${p.currencySymbol}',
                  style: const TextStyle(
                      color: ZakatTheme.deepGreen,
                      fontFamily: 'Scheherazade',
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ]),
            ),
          ),
      ]),
    );
  }

  // ════════════════════════════════════════════════════════════
  // مساعدات
  // ════════════════════════════════════════════════════════════
  Future<void> _openUrl(BuildContext context, String url, bool isArabic) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // نسخ الرابط للحافظة إذا تعذّر الفتح
      await Clipboard.setData(ClipboardData(text: url));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isArabic ? 'تم نسخ الرابط' : 'Link copied',
              style: const TextStyle(fontFamily: 'Scheherazade')),
        ));
      }
    }
  }

  Color _trustColor(String level) {
    switch (level) {
      case 'official':
        return ZakatTheme.deepGreen;
      case 'government':
        return Colors.blue.shade700;
      case 'verified':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  Widget _nisabMethodTile({
    required BuildContext context,
    required ZakatProvider p,
    required bool isDark,
    required Color textColor,
    required Color subColor,
    required NisabMethod method,
    required String icon,
    required String title,
    required String subtitle,
  }) {
    final selected = p.nisabMethod == method;
    return ListTile(
      leading: Text(icon, style: const TextStyle(fontSize: 24)),
      title: Text(title,
          style: TextStyle(
              fontFamily: 'Scheherazade',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: textColor)),
      subtitle: Text(subtitle,
          style: TextStyle(
              fontFamily: 'Scheherazade', fontSize: 12, color: subColor)),
      trailing: selected
          ? const Icon(Icons.radio_button_checked, color: ZakatTheme.deepGreen)
          : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
      onTap: () => p.setNisabMethod(method),
    );
  }

  Widget _sectionHeader(String title, bool isDark, {String? info}) {
    return Builder(
        builder: (context) => Padding(
              padding: const EdgeInsets.only(bottom: 8, right: 4, left: 4),
              child: Row(children: [
                Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                        color: ZakatTheme.gold,
                        borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(title,
                        style: TextStyle(
                            fontFamily: 'Scheherazade',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? ZakatTheme.darkTextSecondary
                                : ZakatTheme.medText))),
                if (info != null)
                  GestureDetector(
                    onTap: () => showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                              backgroundColor:
                                  isDark ? ZakatTheme.darkCard : Colors.white,
                              title: Text(title,
                                  style: const TextStyle(
                                      fontFamily: 'Scheherazade',
                                      fontSize: 16)),
                              content: Text(info,
                                  style: const TextStyle(
                                      fontFamily: 'Scheherazade',
                                      height: 1.8,
                                      fontSize: 14)),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('حسناً',
                                        style: TextStyle(
                                            fontFamily: 'Scheherazade')))
                              ],
                            )),
                    child: Icon(Icons.info_outline,
                        size: 18,
                        color: isDark
                            ? ZakatTheme.darkTextSecondary
                            : ZakatTheme.medText),
                  ),
              ]),
            ));
  }

  Widget _card(
          {required List<Widget> children,
          required Color cardColor,
          required bool isDark}) =>
      Container(
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: ZakatTheme.cardShadowAdaptive(isDark)),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Column(children: children)),
      );

  Widget _langTile(
          BuildContext context,
          ZakatProvider p,
          bool isDark,
          Color textColor,
          Color subColor,
          String code,
          String label,
          String flag) =>
      ListTile(
        leading: Text(flag, style: const TextStyle(fontSize: 24)),
        title: Text(label,
            style: TextStyle(fontFamily: 'Scheherazade', color: textColor)),
        trailing: p.isArabic == (code == 'ar')
            ? const Icon(Icons.check_circle, color: ZakatTheme.deepGreen)
            : null,
        onTap: () => p.setLanguage(code),
      );

  Widget _customSubHeader(String title, Color color) => Text(title,
      style: TextStyle(
          fontFamily: 'Scheherazade',
          fontSize: 13,
          color: color,
          fontWeight: FontWeight.w600));

  void _showSaved(BuildContext context, ZakatProvider p, double val) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          '${p.isArabic ? "تم حفظ النصاب" : "Saved Nisab"}: ${val.toStringAsFixed(0)} ${p.currencySymbol}',
          style: const TextStyle(fontFamily: 'Scheherazade')),
    ));
  }

  void _showCalcResult(
      BuildContext context, ZakatProvider p, double gramPrice, double nisab) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          '${p.isArabic ? "النصاب المحسوب" : "Calculated Nisab"}: ${nisab.toStringAsFixed(0)} ${p.currencySymbol}',
          style: const TextStyle(fontFamily: 'Scheherazade')),
      duration: const Duration(seconds: 3),
    ));
  }

  void _confirmClear(BuildContext context, ZakatProvider p) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(p.isArabic ? 'تأكيد الحذف' : 'Confirm Delete',
                  style: const TextStyle(fontFamily: 'Scheherazade')),
              content: Text(
                  p.isArabic
                      ? 'هل تريد مسح جميع البيانات؟ لا يمكن التراجع.'
                      : 'Clear all data? This cannot be undone.',
                  style: const TextStyle(fontFamily: 'Scheherazade')),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(p.isArabic ? 'إلغاء' : 'Cancel',
                        style: const TextStyle(fontFamily: 'Scheherazade'))),
                TextButton(
                  onPressed: () async {
                    await StorageService.clearAll();
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text(p.isArabic ? 'مسح' : 'Clear',
                      style: const TextStyle(
                          color: Colors.red, fontFamily: 'Scheherazade')),
                ),
              ],
            ));
  }
}
