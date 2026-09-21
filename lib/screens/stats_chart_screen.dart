// ================================================================
// stats_chart_screen.dart — إحصائيات + رسوم بيانية مع Dark Mode
// ================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/zakat_provider.dart';
import '../utils/theme.dart';
import '../l10n/app_localizations.dart';

class StatsChartScreen extends StatelessWidget {
  const StatsChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ZakatProvider>();
    final l10n = AppLocalizations.of(context);
    final isDark = p.isDarkMode;
    final appBarBg = isDark ? const Color(0xFF0A2A1A) : ZakatTheme.deepGreen;

    return Directionality(
      textDirection: p.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Theme(
        data: isDark ? ZakatTheme.darkTheme : ZakatTheme.theme,
        child: Scaffold(
          backgroundColor: ZakatTheme.scaffoldBgAdaptive(isDark),
          appBar: AppBar(
            title: Text(l10n.myStatsTitle,
                style: const TextStyle(fontFamily: 'Scheherazade')),
            backgroundColor: appBarBg,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _buildSummaryCards(context, p, isDark),
              const SizedBox(height: 20),
              if (p.zakatHistory.length >= 2) ...[
                _buildYearlyChart(context, p, isDark),
                const SizedBox(height: 20),
              ],
              if (p.zakatHistory.isNotEmpty) ...[
                _buildPieChart(context, p, isDark),
                const SizedBox(height: 20),
              ],
              _buildDetailedHistory(context, p, isDark),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, ZakatProvider p, bool isDark) {
    final l10n = AppLocalizations.of(context);
    return Column(children: [
      Row(children: [
        Expanded(
            child: _card(
                l10n.totalZakatLabel,
                '${p.totalZakatPaid.toStringAsFixed(0)} ${p.currencySymbol}',
                Icons.volunteer_activism,
                isDark ? ZakatTheme.lightGreen : ZakatTheme.deepGreen,
                isDark)),
        const SizedBox(width: 12),
        Expanded(
            child: _card(
                l10n.annualAverage,
                '${p.averageYearlyZakat.toStringAsFixed(0)} ${p.currencySymbol}',
                Icons.bar_chart,
                const Color(0xFF1565C0),
                isDark)),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
            child: _card(
                l10n.yearsOfCommitment,
                '${p.yearsCount}',
                Icons.calendar_today,
                const Color(0xFF6A1B9A),
                isDark)),
        const SizedBox(width: 12),
        Expanded(
            child: _card(
                l10n.lastPayment,
                p.zakatHistory.isEmpty
                    ? l10n.noData
                    : '${p.zakatHistory.last.amount.toStringAsFixed(0)} ${p.currencySymbol}',
                Icons.check_circle_outline,
                ZakatTheme.success,
                isDark)),
      ]),
    ]);
  }

  Widget _card(
      String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ZakatTheme.cardBgAdaptive(isDark),
        borderRadius: BorderRadius.circular(14),
        boxShadow: ZakatTheme.cardShadowAdaptive(isDark),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.35 : 0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 8),
        Text(value,
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'Scheherazade')),
        const SizedBox(height: 3),
        Text(title,
            style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? ZakatTheme.darkTextSecondary
                    : ZakatTheme.lightText,
                fontFamily: 'Scheherazade')),
      ]),
    );
  }

  Widget _buildYearlyChart(BuildContext context, ZakatProvider p, bool isDark) {
    final l10n = AppLocalizations.of(context);
    final yearly = p.yearlyZakat;
    final years = yearly.keys.toList()..sort();
    final maxVal = yearly.values.fold<double>(0, (m, v) => v > m ? v : m);
    final barColor = isDark ? ZakatTheme.lightGreen : ZakatTheme.deepGreen;
    final textColor = isDark ? ZakatTheme.darkTextPrimary : ZakatTheme.darkText;
    final axisColor =
        isDark ? ZakatTheme.darkTextSecondary : ZakatTheme.medText;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ZakatTheme.cardBgAdaptive(isDark),
        borderRadius: BorderRadius.circular(16),
        boxShadow: ZakatTheme.cardShadowAdaptive(isDark),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l10n.annualZakatChart,
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                fontFamily: 'Scheherazade',
                color: textColor)),
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          child: BarChart(BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxVal * 1.3,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: barColor.withValues(alpha: 0.9),
                getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                  '${rod.toY.toStringAsFixed(0)} ${p.currencySymbol}',
                  const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Scheherazade',
                      fontSize: 13),
                ),
              ),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final idx = v.toInt();
                  if (idx < 0 || idx >= years.length) return const SizedBox();
                  return Text('${years[idx]}',
                      style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'Scheherazade',
                          color: axisColor));
                },
              )),
              leftTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) =>
                  FlLine(color: barColor.withValues(alpha: 0.08), strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(years.length, (i) {
              final year = years[i];
              return BarChartGroupData(x: i, barRods: [
                BarChartRodData(
                  toY: yearly[year] ?? 0,
                  color: barColor,
                  width: 28,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)),
                ),
              ]);
            }),
          )),
        ),
      ]),
    );
  }

  Widget _buildPieChart(BuildContext context, ZakatProvider p, bool isDark) {
    final l10n = AppLocalizations.of(context);
    if (p.totalZakatableWealth <= 0) return const SizedBox();
    final zakatPct = p.zakatDue / p.totalZakatableWealth * 100;
    final remainPct = 100 - zakatPct;
    final textColor = isDark ? ZakatTheme.darkTextPrimary : ZakatTheme.darkText;
    final accent = isDark ? ZakatTheme.lightGreen : ZakatTheme.deepGreen;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ZakatTheme.cardBgAdaptive(isDark),
        borderRadius: BorderRadius.circular(16),
        boxShadow: ZakatTheme.cardShadowAdaptive(isDark),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l10n.zakatPercentageOfWealth,
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                fontFamily: 'Scheherazade',
                color: textColor)),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(
            child: SizedBox(
              height: 160,
              child: PieChart(PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 48,
                sections: [
                  PieChartSectionData(
                    value: zakatPct,
                    color: ZakatTheme.gold,
                    title: '${zakatPct.toStringAsFixed(1)}%',
                    titleStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Scheherazade'),
                    radius: 52,
                  ),
                  PieChartSectionData(
                    value: remainPct,
                    color: accent.withValues(alpha: isDark ? 0.3 : 0.2),
                    title: '',
                    radius: 44,
                  ),
                ],
              )),
            ),
          ),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _legendItem(
                ZakatTheme.gold,
                l10n.zakatDueLabel2,
                '${p.zakatDue.toStringAsFixed(0)} ${p.currencySymbol}',
                isDark),
            const SizedBox(height: 12),
            _legendItem(
                accent.withValues(alpha: 0.4),
                l10n.remainingLabel,
                '${(p.totalZakatableWealth - p.zakatDue).toStringAsFixed(0)} ${p.currencySymbol}',
                isDark),
          ]),
        ]),
      ]),
    );
  }

  Widget _legendItem(Color color, String label, String value, bool isDark) {
    final textColor = isDark ? ZakatTheme.darkTextPrimary : ZakatTheme.darkText;
    final subColor = isDark ? ZakatTheme.darkTextSecondary : ZakatTheme.medText;
    return Row(children: [
      Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 8),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: TextStyle(
                fontSize: 12, color: subColor, fontFamily: 'Scheherazade')),
        Text(value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
                fontFamily: 'Scheherazade')),
      ]),
    ]);
  }

  Widget _buildDetailedHistory(BuildContext context, ZakatProvider p, bool isDark) {
    final l10n = AppLocalizations.of(context);
    final textColor = isDark ? ZakatTheme.darkTextPrimary : ZakatTheme.darkText;
    final subColor =
        isDark ? ZakatTheme.darkTextSecondary : ZakatTheme.lightText;
    final accent = isDark ? ZakatTheme.lightGreen : ZakatTheme.deepGreen;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ZakatTheme.cardBgAdaptive(isDark),
        borderRadius: BorderRadius.circular(16),
        boxShadow: ZakatTheme.cardShadowAdaptive(isDark),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l10n.paymentHistory,
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                fontFamily: 'Scheherazade',
                color: textColor)),
        const SizedBox(height: 12),
        if (p.zakatHistory.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
                child: Text(
              l10n.noHistoryYet,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: subColor, fontFamily: 'Scheherazade', height: 1.8),
            )),
          )
        else
          ...p.zakatHistory.reversed.map((r) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: isDark ? 0.1 : 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: accent.withValues(alpha: isDark ? 0.25 : 0.1)),
                ),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color:
                            ZakatTheme.success.withValues(alpha: isDark ? 0.2 : 0.1),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.check,
                        color: ZakatTheme.success, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${r.amount.toStringAsFixed(2)} ${p.currencySymbol}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  fontFamily: 'Scheherazade',
                                  color: accent)),
                          Text('${r.date.day}/${r.date.month}/${r.date.year}',
                              style: TextStyle(
                                  color: subColor,
                                  fontSize: 12,
                                  fontFamily: 'Scheherazade')),
                        ]),
                  ),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(l10n.fromWealth,
                        style: TextStyle(
                            fontSize: 11,
                            color: subColor,
                            fontFamily: 'Scheherazade')),
                    Text(r.wealth.toStringAsFixed(0),
                        style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? ZakatTheme.darkTextSecondary
                                : ZakatTheme.medText,
                            fontFamily: 'Scheherazade')),
                  ]),
                ]),
              )),
      ]),
    );
  }
}
