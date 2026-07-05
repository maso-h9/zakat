// ================================================================
// settings_screen.dart — الإعدادات النهائية
// ================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/zakat_provider.dart';
import '../services/storage_service.dart';
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

  Widget _sectionHeader(String title, bool isDark) => Padding(
        padding: const EdgeInsets.only(bottom: 8, right: 4, left: 4),
        child: Row(children: [
          Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                  color: ZakatTheme.gold,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(title,
              style: TextStyle(
                  fontFamily: 'Scheherazade',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? ZakatTheme.darkTextSecondary
                      : ZakatTheme.medText)),
        ]),
      );

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
      backgroundColor: p.isDarkMode ? ZakatTheme.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Directionality(
        textDirection: p.isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Column(children: [
          const SizedBox(height: 12),
          Text(p.isArabic ? 'اختر العملة' : 'Select Currency',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Scheherazade',
                  color: p.isDarkMode
                      ? ZakatTheme.darkTextPrimary
                      : ZakatTheme.darkText)),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: currencies
                  .map((c) => ListTile(
                        leading: Text(c.symbol,
                            style: const TextStyle(
                                fontSize: 20, fontFamily: 'Scheherazade')),
                        title: Text(c.name,
                            style: TextStyle(
                                fontFamily: 'Scheherazade',
                                fontSize: 15,
                                color: p.isDarkMode
                                    ? ZakatTheme.darkTextPrimary
                                    : ZakatTheme.darkText)),
                        subtitle: Text(c.code,
                            style: const TextStyle(fontFamily: 'Scheherazade')),
                        trailing: p.selectedCurrency == c.code
                            ? const Icon(Icons.check_circle,
                                color: ZakatTheme.deepGreen)
                            : null,
                        onTap: () {
                          p.setCurrency(c.code, c.symbol);
                          Navigator.pop(context);
                        },
                      ))
                  .toList(),
            ),
          ),
        ]),
      ),
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
}
