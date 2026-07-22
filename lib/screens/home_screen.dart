// ================================================================
// home_screen.dart — الشاشة الرئيسية مع Dark Mode كامل
// ================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/zakat_provider.dart';
import '../utils/theme.dart';
import '../data/zakat_data.dart';
import '../widgets/hadith_card.dart';
import '../widgets/dashboard_card.dart';
import 'calculator_screen.dart';
import 'content_screens.dart';
import 'package:zakat_app/screens/secondary_screens.dart';
import '../presentation/features/ai_chat/ai_chat_screen.dart';
import 'ramadan_screen.dart';
import 'stats_chart_screen.dart';
import 'settings_screen.dart';
import 'madhabs_screen.dart';
import 'whatif_screen.dart';
import '../widgets/zakat_widget.dart';
import '../widgets/zakat_shimmer.dart';
import '../widgets/offline_banner.dart';
import 'package:zakat_app/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _hadithIndex = 0;

  @override
  void initState() {
    super.initState();
    _hadithIndex = DateTime.now().day % ahadith.length;
    ZakatWidgetService.init();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ZakatProvider>();
    final isDark = p.isDarkMode;

    final scaffold = Scaffold(
      backgroundColor: ZakatTheme.scaffoldBgAdaptive(isDark),
      drawer: _buildDrawer(context, p, isDark),
      body: Column(children: [
        // شريط انقطاع الإنترنت (بند 15) — يظهر تلقائياً عند Offline
        const OfflineBanner(),
        Expanded(
          child: CustomScrollView(slivers: [
            _buildSliverAppBar(context, p, isDark),
            SliverToBoxAdapter(child: _buildBody(context, p, isDark)),
          ]),
        ),
      ]),
      bottomNavigationBar: _buildBottomNav(p, isDark),
      floatingActionButton: _buildFAB(context, p),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );

    final themeData = isDark ? ZakatTheme.darkTheme : ZakatTheme.theme;

    return Directionality(
      textDirection: p.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Theme(data: themeData, child: scaffold),
    );
  }

  // ==============================
  // SliverAppBar
  // ==============================
  Widget _buildSliverAppBar(
      BuildContext context, ZakatProvider p, bool isDark) {
    final bgColor = isDark ? const Color(0xFF0A2A1A) : ZakatTheme.deepGreen;

    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: bgColor,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 28),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      actions: [
        if (p.isRamadanMode)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Center(child: Text('🌙', style: TextStyle(fontSize: 22))),
          ),
        IconButton(
          icon: const Icon(Icons.settings_outlined,
              color: Colors.white, size: 26),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const SettingsScreen())),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? ZakatTheme.darkModeGradient
                : ZakatTheme.mainGradient,
          ),
          child: Stack(children: [
            Positioned(
                right: -40,
                top: -40,
                child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.04)))),
            Positioned(
                left: -20,
                bottom: -30,
                child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ZakatTheme.gold.withValues(alpha: 0.08)))),
            Padding(
              padding: const EdgeInsets.only(top: 60, right: 20, left: 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: ZakatTheme.gold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: ZakatTheme.gold.withValues(alpha: 0.5)),
                        ),
                        child: Row(children: [
                          Text(p.isRamadanMode ? '🌙' : '⭐',
                              style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            p.isRamadanMode
                                ? AppLocalizations.of(context).ramadanKareem
                                : AppLocalizations.of(context).pillarOfIslam,
                            style: const TextStyle(
                                color: ZakatTheme.gold,
                                fontSize: 13,
                                fontFamily: 'Scheherazade'),
                          ),
                        ]),
                      ),
                    ]),
                    const SizedBox(height: 4),
                    Text(AppLocalizations.of(context).appName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Scheherazade')),
                    Text(
                        AppLocalizations.of(context).appSubtitle,
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 17,
                            fontFamily: 'Scheherazade')),
                  ]),
            ),
          ]),
        ),
      ),
    );
  }

  // ==============================
  // Body
  // ==============================
  Widget _buildBody(BuildContext context, ZakatProvider p, bool isDark) {
    ZakatWidgetService.updateWidget(p);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Shimmer أثناء أول تحميل (بند 11)
        p.isLoadingGoldPrice && p.savedMoney == 0 && p.goldGrams == 0
            ? const ShimmerDashboardGrid()
            : _buildQuickDashboard(p, isDark),
        const SizedBox(height: 20),
        _buildGoldPriceBanner(p, isDark),
        const SizedBox(height: 20),
        _buildDailyHadith(p),
        const SizedBox(height: 20),
        _buildQuickServices(context, p, isDark),
        const SizedBox(height: 20),
        _buildNisabComparison(p, isDark),
        const SizedBox(height: 20),
        _buildMasarifStrip(context, p, isDark),
        const SizedBox(height: 80),
      ]),
    );
  }

  Widget _buildQuickDashboard(ZakatProvider p, bool isDark) {
    final cardColor = ZakatTheme.cardBgAdaptive(isDark);
    const accentColor = ZakatTheme.gold;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: ZakatTheme.cardShadowAdaptive(isDark),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
      ),
      child: Column(children: [
        Row(children: [
          Expanded(
              child: DashboardCard(
            title: AppLocalizations.of(context).totalWealth,
            value: p.totalZakatableWealth > 0
                ? '${p.totalZakatableWealth.toStringAsFixed(0)} ${p.currencySymbol}'
                : AppLocalizations.of(context).notEntered,
            icon: Icons.account_balance_wallet_outlined,
            color: isDark ? ZakatTheme.lightGreen : ZakatTheme.deepGreen,
          )),
          const SizedBox(width: 12),
          Expanded(
              child: DashboardCard(
            title: AppLocalizations.of(context).zakatDue,
            value: p.zakatDue > 0
                ? '${p.zakatDue.toStringAsFixed(0)} ${p.currencySymbol}'
                : p.totalZakatableWealth > 0
                    ? AppLocalizations.of(context).belowNisab
                    : '---',
            icon: Icons.volunteer_activism,
            color: ZakatTheme.gold,
          )),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child: DashboardCard(
            title: AppLocalizations.of(context).zakatDate,
            value: p.daysUntilZakat > 0
                ? '${p.daysUntilZakat} ${AppLocalizations.of(context).daysLeft}'
                : p.nisabDate != null
                    ? AppLocalizations.of(context).zakatDueNow
                    : AppLocalizations.of(context).setNisabDate,
            icon: Icons.calendar_today,
            color: const Color(0xFF1565C0),
          )),
          const SizedBox(width: 12),
          Expanded(
              child: DashboardCard(
            title: AppLocalizations.of(context).zakatPaid,
            value: p.totalZakatPaid > 0
                ? '${p.totalZakatPaid.toStringAsFixed(0)} ${p.currencySymbol}'
                : AppLocalizations.of(context).noRecord,
            icon: Icons.check_circle_outline,
            color: const Color(0xFF2E7D32),
          )),
        ]),
      ]),
    );
  }

  Widget _buildGoldPriceBanner(ZakatProvider p, bool isDark) {
    // Shimmer أثناء التحميل الأول (بند 11)
    if (p.isLoadingGoldPrice && p.goldPricePerGram == 285.0) {
      return const ShimmerGoldBanner();
    }

    final bg = isDark ? const Color(0xFF0A2A1A) : ZakatTheme.deepGreen;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        const Text('🥇', style: TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              '${AppLocalizations.of(context).goldPriceLabel}: ${p.goldPricePerGram.toStringAsFixed(2)} ${p.currencySymbol}/${AppLocalizations.of(context).gram}',
              style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Scheherazade',
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              p.goldPriceIsLive
                  ? '${AppLocalizations.of(context).live} — ${p.goldPriceLastUpdated ?? ""}'
                  : AppLocalizations.of(context).estimatedPriceHint,
              style: const TextStyle(
                  color: Colors.white60,
                  fontFamily: 'Scheherazade',
                  fontSize: 12),
            ),
          ]),
        ),
        if (p.isLoadingGoldPrice)
          const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white))
        else
          GestureDetector(
            onTap: () => p.fetchGoldPrice(),
            child: const Icon(Icons.refresh, color: ZakatTheme.gold, size: 20),
          ),
      ]),
    );
  }

  Widget _buildDailyHadith(ZakatProvider p) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const AhadithScreen())),
      child: HadithCard(hadith: ahadith[_hadithIndex], isDaily: true),
    );
  }

  Widget _buildQuickServices(
      BuildContext context, ZakatProvider p, bool isDark) {
    final services = [
      {
        'title': AppLocalizations.of(context).calculateMyZakat,
        'icon': Icons.calculate,
        'color': isDark ? ZakatTheme.lightGreen : ZakatTheme.deepGreen,
        'screen': const CalculatorScreen()
      },
      {
        'title': AppLocalizations.of(context).zakatRequired,
        'icon': Icons.quiz_outlined,
        'color': const Color(0xFF1565C0),
        'screen': const WizardScreen()
      },
      {
        'title': AppLocalizations.of(context).masarif,
        'icon': Icons.people_outline,
        'color': const Color(0xFF9C27B0),
        'screen': const MasarifScreen()
      },
      {
        'title': AppLocalizations.of(context).ahadith,
        'icon': Icons.menu_book_outlined,
        'color': const Color(0xFFD4AF37),
        'screen': const AhadithScreen()
      },
      {
        'title': AppLocalizations.of(context).fatawa,
        'icon': Icons.question_answer_outlined,
        'color': const Color(0xFF26A69A),
        'screen': const FatawaScreen()
      },
      {
        'title': AppLocalizations.of(context).calendar,
        'icon': Icons.event_note,
        'color': const Color(0xFFEF5350),
        'screen': const CalendarScreen()
      },
    ];

    final cardColor = ZakatTheme.cardBgAdaptive(isDark);
    final textColor = isDark ? ZakatTheme.darkTextPrimary : ZakatTheme.darkText;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(AppLocalizations.of(context).services,
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
              fontFamily: 'Scheherazade')),
      const SizedBox(height: 12),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: services.length,
        itemBuilder: (context, i) {
          final s = services[i];
          final color = s['color'] as Color;
          return GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => s['screen'] as Widget)),
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: ZakatTheme.cardShadowAdaptive(isDark),
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: color.withValues(alpha: isDark ? 0.18 : 0.1),
                          shape: BoxShape.circle),
                      child:
                          Icon(s['icon'] as IconData, color: color, size: 26),
                    ),
                    const SizedBox(height: 8),
                    Text(s['title'] as String,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: color,
                            fontFamily: 'Scheherazade'),
                        textAlign: TextAlign.center),
                  ]),
            ),
          );
        },
      ),
    ]);
  }

  Widget _buildNisabComparison(ZakatProvider p, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const NisabComparisonScreen())),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isDark
              ? ZakatTheme.darkModeGradient
              : ZakatTheme.darkGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: ZakatTheme.goldShadow,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.balance, color: ZakatTheme.gold, size: 18),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context).goldSilverNisabComparison,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    fontFamily: 'Scheherazade')),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white54, size: 12),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
                child: _nisabCol(
                    AppLocalizations.of(context).goldNisab85,
                    '85 ${AppLocalizations.of(context).grams}',
                    '${p.goldNisabValue.toStringAsFixed(0)} ${p.currencySymbol}',
                    ZakatTheme.gold)),
            Container(width: 1, height: 50, color: Colors.white24),
            Expanded(
                child: _nisabCol(
                    AppLocalizations.of(context).silverNisab595,
                    '595 ${AppLocalizations.of(context).grams}',
                    '${p.silverNisabValue.toStringAsFixed(0)} ${p.currencySymbol}',
                    Colors.white70)),
          ]),
        ]),
      ),
    );
  }

  Widget _nisabCol(String title, String grams, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(children: [
        Text(title,
            style: TextStyle(
                color: color, fontSize: 12, fontFamily: 'Scheherazade')),
        const SizedBox(height: 2),
        Text(grams,
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontFamily: 'Scheherazade')),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: 'Scheherazade')),
      ]),
    );
  }

  Widget _buildMasarifStrip(
      BuildContext context, ZakatProvider p, bool isDark) {
    final cardColor = ZakatTheme.cardBgAdaptive(isDark);
    final textColor = isDark ? ZakatTheme.darkTextPrimary : ZakatTheme.darkText;
    final accent = isDark ? ZakatTheme.lightGreen : ZakatTheme.deepGreen;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(AppLocalizations.of(context).zakatRecipients,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Scheherazade',
                color: textColor)),
        TextButton(
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const MasarifScreen())),
          child: Text(p.isArabic ? 'عرض الكل' : 'View All',
              style: TextStyle(color: accent, fontFamily: 'Scheherazade')),
        ),
      ]),
      const SizedBox(height: 8),
      SizedBox(
        height: 88,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          reverse: p.isArabic,
          itemCount: masarifZakat.length,
          itemBuilder: (context, i) {
            final m = masarifZakat[i];
            return GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MasarifScreen())),
              child: Container(
                width: 78,
                margin: EdgeInsets.only(
                    left: p.isArabic ? 10 : 0, right: p.isArabic ? 0 : 10),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: ZakatTheme.cardShadowAdaptive(isDark),
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(m.icon, style: const TextStyle(fontSize: 24)),
                      const SizedBox(height: 5),
                      Text(m.name,
                          style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'Scheherazade',
                              color: textColor),
                          textAlign: TextAlign.center),
                    ]),
              ),
            );
          },
        ),
      ),
    ]);
  }

  // ==============================
  // Drawer
  // ==============================
  Widget _buildDrawer(BuildContext context, ZakatProvider p, bool isDark) {
    final items = [
      {
        'icon': Icons.account_balance_outlined,
        'title': AppLocalizations.of(context).madhabsComparison,
        'screen': const MadhabsComparisonScreen()
      },
      {
        'icon': Icons.auto_graph,
        'title': AppLocalizations.of(context).whatIfPlanning,
        'screen': const WhatIfScreen()
      },
      {
        'icon': Icons.psychology_outlined,
        'title': AppLocalizations.of(context).aiZakatAssistant,
        'screen': const AiChatScreen()
      },
      {
        'icon': Icons.quiz_outlined,
        'title': AppLocalizations.of(context).zakatTest,
        'screen': const WizardScreen()
      },
      {
        'icon': Icons.event_note,
        'title': AppLocalizations.of(context).annualCalendar,
        'screen': const CalendarScreen()
      },
      {
        'icon': Icons.bar_chart,
        'title': AppLocalizations.of(context).personalStats,
        'screen': const StatsChartScreen()
      },
      {
        'icon': Icons.business_outlined,
        'title': AppLocalizations.of(context).companyZakat,
        'screen': const CompanyZakatScreen()
      },
      {
        'icon': Icons.nights_stay_outlined,
        'title': AppLocalizations.of(context).ramadanModeLabel,
        'screen': const RamadanScreen()
      },
      {
        'icon': Icons.settings_outlined,
        'title': AppLocalizations.of(context).settings,
        'screen': const SettingsScreen()
      },
    ];

    final drawerBg = ZakatTheme.scaffoldBgAdaptive(isDark);
    final textColor = isDark ? ZakatTheme.darkTextPrimary : ZakatTheme.darkText;
    final iconBg = isDark ? ZakatTheme.lightGreen : ZakatTheme.deepGreen;

    return Drawer(
      backgroundColor: drawerBg,
      child: Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
          decoration: BoxDecoration(
              gradient: isDark
                  ? ZakatTheme.darkModeGradient
                  : ZakatTheme.mainGradient),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  color: ZakatTheme.gold.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: ZakatTheme.gold, width: 2)),
              child: const Icon(Icons.volunteer_activism,
                  color: ZakatTheme.gold, size: 30),
            ),
            const SizedBox(height: 10),
            Text(AppLocalizations.of(context).appTitle,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Scheherazade')),
            Text(
                AppLocalizations.of(context).aboutDescription,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontFamily: 'Scheherazade')),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Row(children: [
            Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                    color: ZakatTheme.gold,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context).moreServices,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? ZakatTheme.darkTextSecondary
                        : ZakatTheme.medText,
                    fontFamily: 'Scheherazade')),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: items.length,
            itemBuilder: (ctx, i) {
              final item = items[i];
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                      color: iconBg.withValues(alpha: isDark ? 0.18 : 0.1),
                      borderRadius: BorderRadius.circular(9)),
                  child:
                      Icon(item['icon'] as IconData, color: iconBg, size: 20),
                ),
                title: Text(item['title'] as String,
                    style: TextStyle(
                        fontFamily: 'Scheherazade',
                        fontSize: 15,
                        color: textColor)),
                trailing: Icon(
                    p.isArabic ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
                    size: 12,
                    color: isDark
                        ? ZakatTheme.darkTextSecondary
                        : ZakatTheme.lightText),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => item['screen'] as Widget));
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Text(
            AppLocalizations.of(context).zakatDisclaimer,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: isDark
                    ? ZakatTheme.darkTextSecondary
                    : ZakatTheme.lightText,
                fontSize: 11,
                fontFamily: 'Scheherazade',
                height: 1.6),
          ),
        ),
      ]),
    );
  }

  // ==============================
  // BottomNav + FAB
  // ==============================
  Widget _buildBottomNav(ZakatProvider p, bool isDark) {
    final bg = isDark ? ZakatTheme.darkSurface : Colors.white;

    return BottomAppBar(
      color: bg,
      elevation: 8,
      notchMargin: 8,
      shape: const CircularNotchedRectangle(),
      child: SizedBox(
          height: 60,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _navItem(0, Icons.home_outlined, Icons.home,
                AppLocalizations.of(context).home, p, isDark),
            _navItem(1, Icons.calculate_outlined, Icons.calculate,
                AppLocalizations.of(context).calculator, p, isDark),
            const SizedBox(width: 56),
            _navItem(2, Icons.menu_book_outlined, Icons.menu_book,
                AppLocalizations.of(context).ahadith, p, isDark),
            _navItem(3, Icons.bar_chart_outlined, Icons.bar_chart,
                AppLocalizations.of(context).myStats, p, isDark),
          ])),
    );
  }

  Widget _navItem(int index, IconData icon, IconData activeIcon, String label,
      ZakatProvider p, bool isDark) {
    final isSelected = _selectedIndex == index;
    final color = isDark ? ZakatTheme.gold : ZakatTheme.deepGreen;
    final inactiveColor =
        isDark ? ZakatTheme.darkTextSecondary : ZakatTheme.lightText;

    return InkWell(
      onTap: () {
        setState(() => _selectedIndex = index);
        if (index == 1) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CalculatorScreen()));
        } else if (index == 2) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AhadithScreen()));
        } else if (index == 3) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const StatsChartScreen()));
        }
      },
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(isSelected ? activeIcon : icon,
            color: isSelected ? color : inactiveColor, size: 22),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                color: isSelected ? color : inactiveColor,
                fontFamily: 'Scheherazade')),
      ]),
    );
  }

  Widget _buildFAB(BuildContext context, ZakatProvider p) {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const CalculatorScreen())),
      backgroundColor: ZakatTheme.gold,
      foregroundColor: ZakatTheme.darkText,
      elevation: 6,
      icon: const Icon(Icons.calculate, size: 20),
      label: Text(AppLocalizations.of(context).calculateMyZakat,
          style: const TextStyle(
              fontFamily: 'Scheherazade',
              fontWeight: FontWeight.bold,
              fontSize: 15)),
    );
  }
}
