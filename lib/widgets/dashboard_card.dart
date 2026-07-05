// ================================================================
// dashboard_card.dart — بطاقة لوحة التحكم مع Dark Mode
// lib/widgets/dashboard_card.dart
// ================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../models/zakat_provider.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ZakatProvider>().isDarkMode;
    final subColor =
        isDark ? ZakatTheme.darkTextSecondary : ZakatTheme.lightText;
    // في Dark Mode نفتح الألوان أكثر لتظهر بوضوح
    final adjustedColor = isDark ? color.withOpacity(0.95) : color;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            isDark ? adjustedColor.withOpacity(0.12) : color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: adjustedColor.withOpacity(isDark ? 0.35 : 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: adjustedColor, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: adjustedColor,
              fontFamily: 'Scheherazade',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
                fontSize: 12, color: subColor, fontFamily: 'Scheherazade'),
          ),
        ],
      ),
    );
  }
}
