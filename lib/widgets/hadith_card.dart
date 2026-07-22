// ================================================================
// hadith_card.dart — بطاقة حديث مع دعم Dark Mode
// lib/widgets/hadith_card.dart
// ================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/zakat_data.dart';
import '../utils/theme.dart';
import '../models/zakat_provider.dart';
import '../l10n/app_localizations.dart';

class HadithCard extends StatelessWidget {
  final HadithModel hadith;
  final bool isDaily;

  const HadithCard({super.key, required this.hadith, this.isDaily = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = context.watch<ZakatProvider>().isDarkMode;
    final cardColor = ZakatTheme.cardBgAdaptive(isDark);
    final textColor = isDark ? ZakatTheme.darkTextPrimary : ZakatTheme.darkText;
    final subColor = isDark ? ZakatTheme.darkTextSecondary : ZakatTheme.medText;
    final lightColor =
        isDark ? ZakatTheme.darkTextSecondary : ZakatTheme.lightText;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: ZakatTheme.cardShadowAdaptive(isDark),
        border:
            Border.all(color: ZakatTheme.gold.withValues(alpha: isDark ? 0.25 : 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: ZakatTheme.goldGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isDaily ? l10n.dailyHadith : l10n.islamicHadith,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontFamily: 'Scheherazade',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ZakatTheme.success.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  hadith.grade,
                  style: const TextStyle(
                    color: ZakatTheme.success,
                    fontSize: 12,
                    fontFamily: 'Scheherazade',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '❝ ${hadith.text} ❞',
            style: TextStyle(
              fontSize: 18,
              height: 2.0,
              color: textColor,
              fontFamily: 'Scheherazade',
              fontWeight: FontWeight.w600,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.person_outline, size: 14, color: lightColor),
              const SizedBox(width: 4),
              Text(
                l10n.hadithNarratedBy(hadith.narrator),
                style: TextStyle(
                    color: subColor, fontSize: 13, fontFamily: 'Scheherazade'),
              ),
              const Spacer(),
              Text(
                hadith.source,
                style: TextStyle(
                    color: lightColor,
                    fontSize: 12,
                    fontFamily: 'Scheherazade'),
              ),
            ],
          ),
          if (isDaily) ...[
            const SizedBox(height: 12),
            Divider(
                color:
                    isDark ? ZakatTheme.darkBorder : const Color(0xFFEEE8D5)),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline,
                    size: 16, color: ZakatTheme.gold),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hadith.benefit,
                    style: TextStyle(
                        color: subColor,
                        fontSize: 14,
                        height: 1.7,
                        fontFamily: 'Scheherazade'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
