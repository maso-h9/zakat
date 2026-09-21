import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/zakat_provider.dart';
import '../utils/theme.dart';
import '../l10n/app_localizations.dart';

// ==============================
// نموذج بيانات مسألة المذاهب
// ==============================
class MadhabIssue {
  final String title;
  final String description;
  final String hanafi;
  final String maliki;
  final String shafii;
  final String hanbali;
  final String? preferred; // الراجح عند المحققين

  const MadhabIssue({
    required this.title,
    required this.description,
    required this.hanafi,
    required this.maliki,
    required this.shafii,
    required this.hanbali,
    this.preferred,
  });
}

const List<MadhabIssue> madhabIssues = [
];

// ==============================
// الشاشة الرئيسية
// ==============================
class MadhabsComparisonScreen extends StatefulWidget {
  const MadhabsComparisonScreen({super.key});

  @override
  State<MadhabsComparisonScreen> createState() =>
      _MadhabsComparisonScreenState();
}

class _MadhabsComparisonScreenState extends State<MadhabsComparisonScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _expandedIndex = -1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ZakatProvider>();
    final l10n = AppLocalizations.of(context);
    final isDark = p.isDarkMode;
    final bg = ZakatTheme.scaffoldBgAdaptive(isDark);
    final appBarColor = isDark ? const Color(0xFF0A2A1A) : ZakatTheme.deepGreen;

    return Directionality(
      textDirection: p.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: appBarColor,
          title: Text(l10n.madhabsComparison),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: ZakatTheme.gold,
            indicatorWeight: 3,
            labelColor: ZakatTheme.gold,
            unselectedLabelColor: Colors.white60,
            labelStyle: const TextStyle(
                fontFamily: 'Scheherazade',
                fontSize: 14,
                fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: l10n.comparedIssues),
              Tab(text: l10n.quickTable),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildIssuesList(isDark),
            _buildQuickTable(isDark),
          ],
        ),
      ),
    );
  }

  // ==============================
  // تبويب 1: قائمة المسائل
  // ==============================
  Widget _buildIssuesList(bool isDark) {
    final l10n = AppLocalizations.of(context);
    final cardColor = ZakatTheme.cardBgAdaptive(isDark);
    final textColor = isDark ? ZakatTheme.darkTextPrimary : ZakatTheme.darkText;

    final issues = List.generate(8, (i) => MadhabIssue(
      title: l10n.madhabIssueTitle(i),
      description: l10n.madhabIssueDesc(i),
      hanafi: l10n.madhabOpinion(i, 0),
      maliki: l10n.madhabOpinion(i, 1),
      shafii: l10n.madhabOpinion(i, 2),
      hanbali: l10n.madhabOpinion(i, 3),
      preferred: l10n.preferredMadhab(i),
    ));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient:
                isDark ? ZakatTheme.darkModeGradient : ZakatTheme.mainGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Text('📚', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.madhabNote,
                  style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Scheherazade',
                      fontSize: 13,
                      height: 1.6),
                ),
              ),
            ],
          ),
        ),

        ...List.generate(issues.length, (i) {
          final issue = issues[i];
          final isExpanded = _expandedIndex == i;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: ZakatTheme.cardShadowAdaptive(isDark),
              border: Border.all(
                color: isExpanded
                    ? ZakatTheme.gold.withValues(alpha: 0.5)
                    : Colors.transparent,
              ),
            ),
            child: Column(
              children: [
                // Header
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () =>
                      setState(() => _expandedIndex = isExpanded ? -1 : i),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: ZakatTheme.gold.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text('${i + 1}',
                                style: const TextStyle(
                                    color: ZakatTheme.gold,
                                    fontFamily: 'Scheherazade',
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(issue.title,
                                  style: TextStyle(
                                      fontFamily: 'Scheherazade',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: textColor)),
                              const SizedBox(height: 2),
                              Text(issue.description,
                                  style: TextStyle(
                                      fontFamily: 'Scheherazade',
                                      fontSize: 12,
                                      color: isDark
                                          ? ZakatTheme.darkTextSecondary
                                          : ZakatTheme.lightText)),
                            ],
                          ),
                        ),
                        Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: ZakatTheme.gold,
                        ),
                      ],
                    ),
                  ),
                ),

                // Expanded content
                if (isExpanded) ...[
                  Divider(
                      height: 1,
                      color: isDark
                          ? ZakatTheme.darkBorder
                          : const Color(0xFFEEE8D5)),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _madhabRow(l10n.hanafi, issue.hanafi,
                            const Color(0xFF1565C0), isDark),
                        const SizedBox(height: 10),
                        _madhabRow(l10n.maliki, issue.maliki,
                            const Color(0xFF6A1B9A), isDark),
                        const SizedBox(height: 10),
                        _madhabRow(l10n.shafii, issue.shafii,
                            const Color(0xFF00695C), isDark),
                        const SizedBox(height: 10),
                        _madhabRow(l10n.hanbali, issue.hanbali,
                            const Color(0xFFC62828), isDark),
                        if (issue.preferred?.isNotEmpty == true) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: ZakatTheme.gold.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: ZakatTheme.gold.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.lightbulb_outline,
                                    color: ZakatTheme.gold, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${l10n.preferred}: ${issue.preferred}',
                                    style: TextStyle(
                                        fontFamily: 'Scheherazade',
                                        fontSize: 13,
                                        height: 1.7,
                                        color: isDark
                                            ? ZakatTheme.gold
                                            : ZakatTheme.medText),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _madhabRow(String name, String opinion, Color color, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(name,
              style: TextStyle(
                  color: color,
                  fontFamily: 'Scheherazade',
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            opinion,
            style: TextStyle(
              fontFamily: 'Scheherazade',
              fontSize: 14,
              height: 1.6,
              color: isDark ? ZakatTheme.darkTextSecondary : ZakatTheme.medText,
            ),
          ),
        ),
      ],
    );
  }

  // ==============================
  // تبويب 2: جدول سريع
  // ==============================
  Widget _buildQuickTable(bool isDark) {
    final l10n = AppLocalizations.of(context);
    final cardColor = ZakatTheme.cardBgAdaptive(isDark);
    final headerColor = isDark ? const Color(0xFF0A2A1A) : ZakatTheme.deepGreen;
    final textColor = isDark ? ZakatTheme.darkTextPrimary : ZakatTheme.darkText;

    final rows = [
      ['نصاب الذهب', '85 غ', '85 غ', '85 غ', '85 غ'],
      ['نصاب الفضة', '595 غ', '595 غ', '595 غ', '595 غ'],
      ['حلي الذهب', 'تُزكَّى', 'لا تُزكَّى', 'لا تُزكَّى', 'لا تُزكَّى'],
      ['ضم الذهب والفضة', 'يُضم', 'يُضم', 'لا يُضم', 'لا يُضم'],
      ['نسبة النقود', '2.5%', '2.5%', '2.5%', '2.5%'],
      ['زكاة الزروع', 'بلا نصاب', '653 كغ', '653 كغ', '653 كغ'],
      ['تعجيل الزكاة', 'يجوز', 'يُكره', 'يجوز', 'يجوز'],
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: ZakatTheme.cardShadowAdaptive(isDark),
        ),
        child: Column(
          children: [
            // Header row
            Container(
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Table(
                children: [
                  TableRow(
                    children: [
                      _headerCell(l10n.issue),
                      _headerCell(l10n.preferredMadhab(0)),
                      _headerCell(l10n.preferredMadhab(1)),
                      _headerCell(l10n.preferredMadhab(2)),
                      _headerCell(l10n.preferredMadhab(3)),
                    ],
                  ),
                ],
              ),
            ),
            // Data rows
            Table(
              border: TableBorder(
                horizontalInside: BorderSide(
                    color: isDark
                        ? ZakatTheme.darkBorder
                        : const Color(0xFFEEE8D5),
                    width: 0.5),
              ),
              children: List.generate(rows.length, (i) {
                final row = rows[i];
                final isEven = i % 2 == 0;
                return TableRow(
                  decoration: BoxDecoration(
                    color: isEven
                        ? (isDark
                            ? Colors.white.withValues(alpha: 0.02)
                            : ZakatTheme.cream.withValues(alpha: 0.3))
                        : Colors.transparent,
                  ),
                  children: row
                      .map((cell) => Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 10),
                            child: Text(
                              cell,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Scheherazade',
                                  fontSize: 12,
                                  color: textColor),
                            ),
                          ))
                      .toList(),
                );
              }),
            ),
            // Footer note
            Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                l10n.recommendedConsult,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Scheherazade',
                    fontSize: 12,
                    color: isDark
                        ? ZakatTheme.darkTextSecondary
                        : ZakatTheme.lightText,
                    height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Scheherazade',
            fontSize: 12,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}
