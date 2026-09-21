// ================================================================
// core/utils/performance_helpers.dart — تحسين الأداء (بند 18+29)
// استخدم Selector بدل context.watch لتقليل Rebuilds
// ================================================================
//
// المشكلة الحالية:
//   final p = context.watch<ZakatProvider>();
//   → أي تغيير في الـ Provider يعيد بناء الشاشة كاملة
//
// الحل: استخدم context.select لقراءة قيمة محددة فقط
//
// ══════════════════════════════════════════════════════
// أمثلة الاستخدام في الشاشات
// ══════════════════════════════════════════════════════
//
// ① بدل context.watch كامل في widget صغير:
//
//   // قبل (يعيد البناء عند أي تغيير)
//   final p = context.watch<ZakatProvider>();
//   Text(p.goldPricePerGram.toString())
//
//   // بعد (يعيد البناء فقط عند تغير goldPricePerGram)
//   final price = context.select<ZakatProvider, double>(
//     (p) => p.goldPricePerGram
//   );
//   Text(price.toString())
//
// ② Consumer للـ widgets الكبيرة:
//
//   Selector<ZakatProvider, bool>(
//     selector: (_, p) => p.isLoadingGoldPrice,
//     builder: (_, isLoading, __) {
//       return isLoading
//         ? const ShimmerGoldBanner()
//         : const GoldPriceBanner();
//     },
//   )
//
// ③ للـ Dashboard cards — كل بطاقة تشترك فقط في قيمتها:
//
//   Selector<ZakatProvider, double>(
//     selector: (_, p) => p.zakatDue,
//     builder: (_, zakatDue, __) => DashboardCard(value: zakatDue),
//   )
//
// ══════════════════════════════════════════════════════
// الحالات التي يبقى فيها context.watch مناسباً
// ══════════════════════════════════════════════════════
//
// استخدم context.watch عندما:
//   - الشاشة تحتاج معظم خصائص الـ Provider (مثل home_screen)
//   - التغييرات تؤثر على معظم الـ UI
//
// استخدم context.select عندما:
//   - widget صغير يحتاج قيمة واحدة فقط
//   - بطاقة إحصاء تعرض رقماً واحداً
//   - زر حالته تعتمد على bool واحد
//

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/zakat_provider.dart';

// ── Widget محسّن: بانر الذهب ─────────────────────────────────────
// يعيد البناء فقط عند تغير السعر أو حالة التحميل
class GoldPriceSelector extends StatelessWidget {
  final Widget Function(double price, bool isLive, bool isLoading) builder;
  const GoldPriceSelector({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return Selector<ZakatProvider, (double, bool, bool)>(
      selector: (_, p) =>
          (p.goldPricePerGram, p.goldPriceIsLive, p.isLoadingGoldPrice),
      builder: (_, data, __) => builder(data.$1, data.$2, data.$3),
    );
  }
}

// ── Widget محسّن: الزكاة الواجبة ─────────────────────────────────
class ZakatDueSelector extends StatelessWidget {
  final Widget Function(double zakatDue, String symbol) builder;
  const ZakatDueSelector({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return Selector<ZakatProvider, (double, String)>(
      selector: (_, p) => (p.zakatDue, p.currencySymbol),
      builder: (_, data, __) => builder(data.$1, data.$2),
    );
  }
}

// ── Widget محسّن: أيام الزكاة ─────────────────────────────────────
class ZakatDaysSelector extends StatelessWidget {
  final Widget Function(int days) builder;
  const ZakatDaysSelector({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return Selector<ZakatProvider, int>(
      selector: (_, p) => p.daysUntilZakat,
      builder: (_, days, __) => builder(days),
    );
  }
}
