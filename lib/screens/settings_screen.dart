// ================================================================
// settings_screen.dart — الإعدادات النهائية
// ================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.person, color: Colors.white, size: 20),
                ),
                title: Text(p.isArabic ? 'إدارة حسابي' : 'Manage My Account',
                    style: TextStyle(
                        fontFamily: 'Scheherazade',
                        fontSize: 16,
                        color: textColor,
                        fontWeight: FontWeight.w600)),
                subtitle: Text(
                    p.isArabic
                        ? 'تسجيل الدخول · المزامنة · الحذف'
                        : 'Sign in · Sync · Delete',
                    style: TextStyle(
                        fontFamily: 'Scheherazade',
                        fontSize: 13,
                        color: subColor)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen())),
              ),
            ]),
            const SizedBox(height: 16),

            // ── المظهر ────────────────────────────────────────
            _sectionHeader(p.isArabic ? 'المظهر' : 'Appearance', isDark),
            _card(cardColor: cardColor, isDark: isDark, children: [
              SwitchListTile.adaptive(
                secondary: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: isDark ? ZakatTheme.gold : ZakatTheme.deepGreen,
                ),
                title: Text(
                    isDark
                        ? (p.isArabic ? 'الوضع الداكن' : 'Dark Mode')
                        : (p.isArabic ? 'الوضع الفاتح' : 'Light Mode'),
                    style: TextStyle(
                        fontFamily: 'Scheherazade',
                        fontSize: 16,
                        color: textColor)),
                value: isDark,
                activeColor: ZakatTheme.gold,
                onChanged: p.toggleDarkMode,
              ),
            ]),
            const SizedBox(height: 16),

            // ── اللغة ─────────────────────────────────────────
            _sectionHeader(p.isArabic ? 'اللغة' : 'Language', isDark),
            _card(cardColor: cardColor, isDark: isDark, children: [
              _langTile(
                flag: '🇸🇦',
                label: p.isArabic ? 'العربية' : 'Arabic',
                selected: p.isArabic,
                isDark: isDark,
                textColor: textColor,
                onTap: () => p.setLanguage('ar'),
              ),
              Divider(height: 1, color: divColor),
              _langTile(
                flag: '🇺🇸',
                label: p.isArabic ? 'الإنجليزية' : 'English',
                selected: !p.isArabic,
                isDark: isDark,
                textColor: textColor,
                onTap: () => p.setLanguage('en'),
              ),
            ]),
            const SizedBox(height: 16),

            // ── العملة والأسعار ───────────────────────────────
            _sectionHeader(
                p.isArabic ? 'العملة والأسعار' : 'Currency & Prices', isDark),
            _card(cardColor: cardColor, isDark: isDark, children: [
              _tileLabel(p.isArabic ? 'العملة الحالية' : 'Current Currency',
                  '${p.selectedCurrency} — ${p.currencySymbol}', isDark),
              Divider(height: 1, color: divColor),
              ListTile(
                leading: Icon(Icons.currency_exchange,
                    color: isDark ? ZakatTheme.gold : ZakatTheme.deepGreen),
                title: Text(p.isArabic ? 'تغيير العملة' : 'Change Currency',
                    style: TextStyle(
                        fontFamily: 'Scheherazade',
                        fontSize: 16,
                        color: textColor)),
                trailing:
                    Icon(Icons.arrow_forward_ios, size: 14, color: subColor),
                onTap: () => _showCurrencyPicker(context, p),
              ),
              Divider(height: 1, color: divColor),
              ListTile(
                leading: Icon(Icons.refresh,
                    color: isDark ? ZakatTheme.gold : ZakatTheme.deepGreen),
                title: Text(
                    p.isArabic ? 'تحديث سعر الذهب' : 'Update Gold Price',
                    style: TextStyle(
                        fontFamily: 'Scheherazade',
                        fontSize: 16,
                        color: textColor)),
                subtitle: Text(
                    p.goldPriceIsLive
                        ? '${p.isArabic ? "سعر مباشر" : "Live"} — ${p.goldPriceLastUpdated ?? ""}'
                        : (p.isArabic ? 'سعر تقديري' : 'Estimated price'),
                    style: TextStyle(
                        fontFamily: 'Scheherazade',
                        fontSize: 13,
                        color: subColor)),
                trailing: p.isLoadingGoldPrice
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(Icons.cloud_download_outlined,
                        color: isDark ? ZakatTheme.gold : ZakatTheme.deepGreen),
                onTap: () => p.fetchGoldPrice(),
              ),
            ]),
            const SizedBox(height: 16),

            // ── المزامنة السحابية ─────────────────────────────
            _sectionHeader(
                p.isArabic ? 'المزامنة السحابية' : 'Cloud Sync', isDark),
            _card(cardColor: cardColor, isDark: isDark, children: [
              SwitchListTile.adaptive(
                secondary: Icon(Icons.cloud_outlined,
                    color: isDark ? ZakatTheme.gold : ZakatTheme.deepGreen),
                title: Text(p.isArabic ? 'مزامنة Firebase' : 'Firebase Sync',
                    style: TextStyle(
                        fontFamily: 'Scheherazade',
                        fontSize: 16,
                        color: textColor)),
                subtitle: Text(
                    p.cloudSyncEnabled
                        ? p.lastSyncTime != null
                            ? '${p.isArabic ? "آخر مزامنة" : "Last sync"}: ${_fmt(p.lastSyncTime!)}'
                            : (p.isArabic ? 'جارٍ...' : 'Syncing...')
                        : (p.isArabic ? 'محفوظ محلياً فقط' : 'Local only'),
                    style: TextStyle(
                        fontFamily: 'Scheherazade',
                        fontSize: 13,
                        color: subColor)),
                value: p.cloudSyncEnabled,
                activeColor: ZakatTheme.gold,
                onChanged: (v) => p.toggleCloudSync(v),
              ),
              if (p.cloudSyncEnabled) ...[
                Divider(height: 1, color: divColor),
                ListTile(
                  leading: p.isSyncing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: ZakatTheme.deepGreen))
                      : Icon(Icons.sync,
                          color:
                              isDark ? ZakatTheme.gold : ZakatTheme.deepGreen),
                  title: Text(p.isArabic ? 'مزامنة الآن' : 'Sync Now',
                      style: TextStyle(
                          fontFamily: 'Scheherazade',
                          fontSize: 16,
                          color: textColor)),
                  onTap: p.isSyncing ? null : () => p.syncNow(),
                ),
              ],
            ]),
            const SizedBox(height: 16),

            // ── رمضان ─────────────────────────────────────────
            _sectionHeader(p.isArabic ? 'وضع رمضان' : 'Ramadan Mode', isDark),
            _card(cardColor: cardColor, isDark: isDark, children: [
              SwitchListTile.adaptive(
                secondary: const Text('🌙', style: TextStyle(fontSize: 22)),
                title: Text(
                    p.isArabic ? 'تفعيل وضع رمضان' : 'Enable Ramadan Mode',
                    style: TextStyle(
                        fontFamily: 'Scheherazade',
                        fontSize: 16,
                        color: textColor)),
                subtitle: Text(
                    p.isArabic
                        ? 'ثيم ليلي وزكاة الفطر'
                        : 'Night theme & Zakat Al-Fitr',
                    style: TextStyle(
                        fontFamily: 'Scheherazade',
                        fontSize: 13,
                        color: subColor)),
                value: p.isRamadanMode,
                activeColor: ZakatTheme.gold,
                onChanged: p.toggleRamadanMode,
              ),
            ]),
            const SizedBox(height: 16),

            // ── البيانات ──────────────────────────────────────
            _sectionHeader(p.isArabic ? 'البيانات' : 'Data', isDark),
            _card(cardColor: cardColor, isDark: isDark, children: [
              ListTile(
                leading:
                    const Icon(Icons.delete_outline, color: ZakatTheme.error),
                title: Text(p.isArabic ? 'مسح جميع البيانات' : 'Clear All Data',
                    style: const TextStyle(
                        fontFamily: 'Scheherazade',
                        fontSize: 16,
                        color: ZakatTheme.error)),
                subtitle: Text(
                    p.isArabic
                        ? 'يحذف الثروة والتاريخ وكل الإعدادات'
                        : 'Deletes wealth, history and all settings',
                    style: TextStyle(
                        fontFamily: 'Scheherazade',
                        fontSize: 13,
                        color: subColor)),
                onTap: () => _confirmClear(context, p),
              ),
            ]),
            const SizedBox(height: 16),

            // ══════════════════════════════════════════════════
            // ── طريقة حساب النصاب (جديد V11) ─────────────────
            // ══════════════════════════════════════════════════
            _sectionHeader(
              p.isArabic ? 'طريقة حساب النصاب' : 'Nisab Calculation Method',
              isDark,
              info: p.isArabic
                  ? '🌍 الحساب العالمي\nيعتمد على سعر الذهب العالمي وسعر الصرف.\n\n🏛️ النصاب الرسمي\nيعتمد على القيمة التي تعلنها الجهة الرسمية في بلدك.\n\n✍️ الحساب المخصص\nيتيح إدخال قيمة النصاب أو أسعار الذهب يدوياً.\n\nقد تختلف النتائج بين الطرق بسبب اختلاف مصدر الأسعار.'
                  : '🌍 Global Calculation\nBased on world gold price and exchange rate.\n\n🏛️ Official Nisab\nBased on the value announced by your country\'s official body.\n\n✍️ Custom Calculation\nEnter your own Nisab value or gold prices.\n\nResults may differ between methods due to different price sources.',
            ),
            _card(cardColor: cardColor, isDark: isDark, children: [
              // الخيار 1: الحساب العالمي
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
                    : 'World gold price × exchange rate (recommended)',
              ),
              Divider(height: 1, color: divColor),
              // الخيار 2: النصاب الرسمي
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
                    : 'Value announced by your country\'s official body',
              ),
              if (p.nisabMethod == NisabMethod.official) ...[
                Divider(height: 1, color: divColor),
                _officialNisabPanel(
                    context, p, isDark, textColor, subColor, cardColor),
              ],
              Divider(height: 1, color: divColor),
              // الخيار 3: الحساب المخصص
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
                    : 'Enter Nisab value or gold prices manually',
              ),
              if (p.nisabMethod == NisabMethod.custom) ...[
                Divider(height: 1, color: divColor),
                _customNisabPanel(
                    context, p, isDark, textColor, subColor, cardColor),
              ],
            ]),
            const SizedBox(height: 16),

            // ── عن التطبيق ────────────────────────────────────
            _sectionHeader(p.isArabic ? 'عن التطبيق' : 'About', isDark),
            _card(cardColor: cardColor, isDark: isDark, children: [
              _tileLabel(p.isArabic ? 'الإصدار' : 'Version', '1.4.0', isDark),
              Divider(height: 1, color: divColor),
              _tileLabel(
                  p.isArabic ? 'المحتوى الديني' : 'Islamic Content',
                  p.isArabic ? 'الدرر السنية + الشاملة' : 'Dorar + Shamela',
                  isDark),
              Divider(height: 1, color: divColor),
              _tileLabel(p.isArabic ? 'بيانات الذهب' : 'Gold Data',
                  'metals.live + open.er-api.com', isDark),
              Divider(height: 1, color: divColor),
              _tileLabel(p.isArabic ? 'المساعد الذكي' : 'AI Assistant',
                  'Google Gemini 2.0 Flash', isDark),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Widget _langTile({
    required String flag,
    required String label,
    required bool selected,
    required bool isDark,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(label,
          style: TextStyle(
              fontFamily: 'Scheherazade', fontSize: 15, color: textColor)),
      trailing: selected
          ? const Icon(Icons.check_circle, color: ZakatTheme.deepGreen)
          : null,
      onTap: onTap,
    );
  }

  // _sectionHeader المُوحَّد موجود في الأسفل (مع دعم info)

  Widget _card({
    required List<Widget> children,
    required bool isDark,
    required Color cardColor,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: ZakatTheme.cardShadowAdaptive(isDark),
        ),
        child: Column(children: children),
      );

  Widget _tileLabel(String label, String value, bool isDark) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    fontFamily: 'Scheherazade',
                    fontSize: 15,
                    color: isDark
                        ? ZakatTheme.darkTextPrimary
                        : ZakatTheme.darkText)),
            Text(value,
                style: TextStyle(
                    fontFamily: 'Scheherazade',
                    fontSize: 14,
                    color: isDark
                        ? ZakatTheme.darkTextSecondary
                        : ZakatTheme.medText)),
          ],
        ),
      );

  void _showCurrencyPicker(BuildContext context, ZakatProvider p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CurrencyPickerSheet(p: p),
    );
  }

  void _confirmClear(BuildContext context, ZakatProvider p) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: p.isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: p.isDarkMode ? ZakatTheme.darkCard : Colors.white,
          title: Text(p.isArabic ? 'مسح البيانات؟' : 'Clear Data?',
              style: const TextStyle(fontFamily: 'Scheherazade', fontSize: 18)),
          content: Text(
              p.isArabic
                  ? 'سيتم حذف جميع بياناتك. هذا الإجراء لا يمكن التراجع عنه.'
                  : 'All your data will be deleted. This cannot be undone.',
              style: const TextStyle(fontFamily: 'Scheherazade', height: 1.7)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(p.isArabic ? 'إلغاء' : 'Cancel',
                  style: const TextStyle(
                      fontFamily: 'Scheherazade', color: ZakatTheme.deepGreen)),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: ZakatTheme.error),
              onPressed: () async {
                await StorageService.clearAll();
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(p.isArabic ? 'مسح' : 'Clear',
                  style: const TextStyle(fontFamily: 'Scheherazade')),
            ),
          ],
        ),
      ),
    );
  }

  // ── مساعد: _sectionHeader مع زر معلومات ─────────────────────
  Widget _sectionHeader(String title, bool isDark, {String? info}) {
    final isDarkFinal = isDark;
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
                            color: isDarkFinal
                                ? ZakatTheme.darkTextSecondary
                                : ZakatTheme.medText))),
                if (info != null)
                  GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor:
                            isDarkFinal ? ZakatTheme.darkCard : Colors.white,
                        title: Text(title,
                            style: const TextStyle(
                                fontFamily: 'Scheherazade', fontSize: 16)),
                        content: Text(info,
                            style: const TextStyle(
                                fontFamily: 'Scheherazade',
                                height: 1.8,
                                fontSize: 14)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('حسناً',
                                style: TextStyle(fontFamily: 'Scheherazade')),
                          )
                        ],
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.info_outline,
                          size: 18,
                          color: isDarkFinal
                              ? ZakatTheme.darkTextSecondary
                              : ZakatTheme.medText),
                    ),
                  ),
              ]),
            ));
  }

  // ── tile اختيار طريقة النصاب ─────────────────────────────────
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

  // ── لوحة النصاب الرسمي ───────────────────────────────────────
  Widget _officialNisabPanel(BuildContext context, ZakatProvider p, bool isDark,
      Color textColor, Color subColor, Color cardColor) {
    // V12: يقرأ من Firestore ديناميكياً عبر p.currentCountrySource
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ZakatTheme.deepGreen.withOpacity(isDark ? 0.12 : 0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ZakatTheme.deepGreen.withOpacity(0.3)),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.verified,
                    color: ZakatTheme.deepGreen, size: 18),
                const SizedBox(width: 6),
                Expanded(
                    child: Text(
                  source.name,
                  style: TextStyle(
                      fontFamily: 'Scheherazade',
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontSize: 14),
                )),
              ]),
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
              const SizedBox(height: 8),
              // عرض كل الروابط المتاحة مرتبة حسب priority
              ...(source.links
                    ..sort((a, b) => a.priority.compareTo(b.priority)))
                  .map((link) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('${link.typeIcon} ${link.url}',
                                  style: const TextStyle(
                                      fontFamily: 'Scheherazade')),
                              action: SnackBarAction(
                                  label: p.isArabic ? 'نسخ' : 'Copy',
                                  onPressed: () {}),
                            ));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                ZakatTheme.deepGreen.withOpacity(0.85),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                          ),
                          icon: Text(link.typeIcon,
                              style: const TextStyle(fontSize: 14)),
                          label: Text(
                              p.isArabic
                                  ? 'فتح المصدر الرسمي'
                                  : 'Open Official Source',
                              style: const TextStyle(
                                  fontFamily: 'Scheherazade',
                                  fontSize: 13,
                                  color: Colors.white)),
                        ),
                      )),
            ]),
          ),
          const SizedBox(height: 12),
        ] else ...[
          // لا يوجد مصدر رسمي لهذه الدولة
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
        // حقل إدخال القيمة
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

  // ── لوحة الحساب المخصص ───────────────────────────────────────
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
        // ── الخيار 1: إدخال مباشر ──────────────────────────────
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

        // ── الخيار 2: من سعر الجرام ────────────────────────────
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
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
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
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              final gPrice = double.tryParse(gramCtrl.text.replaceAll(',', ''));
              if (gPrice != null && gPrice > 0) {
                final nisab = p.calcNisabFromGramPrice(gPrice);
                p.setCustomNisab(nisab);
                _showCalcResult(context, p, gPrice, nisab);
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

        // ── الخيار 3: من الأوقية + الصرف ──────────────────────
        _customSubHeader(
          p.isArabic
              ? 'الخيار 3 — من سعر الأوقية وسعر الصرف'
              : 'Option 3 — From oz price + exchange rate',
          subColor,
        ),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: TextField(
              controller: ozCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
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
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: fxCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
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
            ),
          ),
        ]),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              final oz = double.tryParse(ozCtrl.text.replaceAll(',', ''));
              final fx = double.tryParse(fxCtrl.text.replaceAll(',', ''));
              if (oz != null && fx != null && oz > 0 && fx > 0) {
                final nisab = p.calcNisabFromOz(oz, fx);
                p.setCustomNisab(nisab);
                _showCalcResult(context, p, oz / 31.1035 * fx, nisab);
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

        // النتيجة المحفوظة
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
        style: const TextStyle(fontFamily: 'Scheherazade'),
      ),
      duration: const Duration(seconds: 3),
    ));
  }
}

// ════════════════════════════════════════════════════════════════
// _CurrencyPickerSheet — BottomSheet قابل للسحب مع بحث
// ════════════════════════════════════════════════════════════════
class _CurrencyPickerSheet extends StatefulWidget {
  final ZakatProvider p;
  const _CurrencyPickerSheet({required this.p});

  @override
  State<_CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<_CurrencyPickerSheet> {
  String _query = '';
  final _ctrl = TextEditingController();

  List<CurrencyModel> get _filtered => _query.isEmpty
      ? currencies
      : currencies
          .where((c) =>
              c.name.contains(_query) ||
              c.code.contains(_query.toUpperCase()) ||
              c.symbol.contains(_query))
          .toList();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final isDark = p.isDarkMode;
    final bg = isDark ? ZakatTheme.darkCard : Colors.white;
    final text = isDark ? ZakatTheme.darkTextPrimary : ZakatTheme.darkText;
    final sub = isDark ? ZakatTheme.darkTextSecondary : ZakatTheme.lightText;
    final fill = isDark ? const Color(0xFF1E3A2A) : const Color(0xFFF5F0E8);

    return Directionality(
      textDirection: p.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (ctx, scrollCtrl) => Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20)
            ],
          ),
          child: Column(children: [
            // ── مقبض السحب ───────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // ── العنوان + العملة الحالية ──────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(children: [
                Expanded(
                  child: Text(
                    p.isArabic ? 'اختر العملة' : 'Select Currency',
                    style: TextStyle(
                        fontFamily: 'Scheherazade',
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: text),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: ZakatTheme.deepGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: ZakatTheme.deepGreen.withOpacity(0.3)),
                  ),
                  child: Text(
                    '${p.selectedCurrency} ${p.currencySymbol}',
                    style: const TextStyle(
                        fontFamily: 'Scheherazade',
                        fontSize: 13,
                        color: ZakatTheme.deepGreen,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ]),
            ),

            // ── حقل البحث ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller: _ctrl,
                textDirection: TextDirection.rtl,
                onChanged: (v) => setState(() => _query = v),
                style: TextStyle(fontFamily: 'Scheherazade', color: text),
                decoration: InputDecoration(
                  hintText:
                      p.isArabic ? 'ابحث عن عملة...' : 'Search currency...',
                  hintStyle: TextStyle(fontFamily: 'Scheherazade', color: sub),
                  prefixIcon: Icon(Icons.search,
                      color: isDark ? ZakatTheme.gold : ZakatTheme.deepGreen),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _ctrl.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: fill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ),

            // ── عدد النتائج ───────────────────────────────────
            if (_query.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 6, right: 20, left: 20),
                child: Align(
                  alignment:
                      p.isArabic ? Alignment.centerRight : Alignment.centerLeft,
                  child: Text(
                    '${_filtered.length} ${p.isArabic ? "نتيجة" : "results"}',
                    style: TextStyle(
                        fontFamily: 'Scheherazade', fontSize: 12, color: sub),
                  ),
                ),
              ),

            Divider(
                height: 1,
                color:
                    isDark ? ZakatTheme.darkBorder : const Color(0xFFEEE8D5)),

            // ── قائمة العملات ─────────────────────────────────
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Text('🔍', style: TextStyle(fontSize: 36)),
                        const SizedBox(height: 8),
                        Text(
                          p.isArabic ? 'لا توجد نتائج' : 'No results found',
                          style: TextStyle(
                              fontFamily: 'Scheherazade',
                              color: sub,
                              fontSize: 15),
                        ),
                      ]),
                    )
                  : ListView.separated(
                      controller: scrollCtrl,
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: isDark
                              ? ZakatTheme.darkBorder
                              : const Color(0xFFEEE8D5)),
                      itemBuilder: (_, i) {
                        final c = _filtered[i];
                        final selected = p.selectedCurrency == c.code;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 4),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: selected
                                  ? ZakatTheme.deepGreen.withOpacity(0.12)
                                  : fill,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(c.symbol,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'Scheherazade',
                                      color: selected
                                          ? ZakatTheme.deepGreen
                                          : text,
                                      fontWeight: selected
                                          ? FontWeight.bold
                                          : FontWeight.normal)),
                            ),
                          ),
                          title: Text(c.name,
                              style: TextStyle(
                                  fontFamily: 'Scheherazade',
                                  fontSize: 15,
                                  color: text,
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.normal)),
                          subtitle: Text(c.code,
                              style: TextStyle(
                                  fontFamily: 'Scheherazade',
                                  fontSize: 12,
                                  color: sub)),
                          trailing: selected
                              ? const Icon(Icons.check_circle,
                                  color: ZakatTheme.deepGreen)
                              : Icon(
                                  p.isArabic
                                      ? Icons.chevron_left
                                      : Icons.chevron_right,
                                  color: sub,
                                  size: 18),
                          onTap: () {
                            p.setCurrency(c.code, c.symbol);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }
}
