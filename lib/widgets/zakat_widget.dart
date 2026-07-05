// ================================================================
// zakat_widget.dart — ويدجت الشاشة الرئيسية (الجانب Dart)
// ================================================================
import 'package:home_widget/home_widget.dart';
import '../models/zakat_provider.dart';

class ZakatWidgetService {
  // معرف التطبيق — غيّره لـ bundle ID الخاص بك
  static const String _appGroupId = 'group.com.yourapp.zakat';
  static const String _iOSWidgetName = 'ZakatWidget';
  static const String _androidWidgetName = 'ZakatWidgetProvider';

  // ─── تهيئة ──────────────────────────────────────────────────────
  static Future<void> init() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  // ─── تحديث بيانات الويدجت ────────────────────────────────────────
  static Future<void> updateWidget(ZakatProvider p) async {
    try {
      // حفظ البيانات
      await HomeWidget.saveWidgetData<String>(
          'zakat_due', '${p.zakatDue.toStringAsFixed(0)} ${p.currencySymbol}');

      await HomeWidget.saveWidgetData<String>(
          'days_left',
          p.daysUntilZakat > 0
              ? '${p.daysUntilZakat} يوم'
              : p.nisabDate != null
                  ? 'وجبت الزكاة!'
                  : '---');

      await HomeWidget.saveWidgetData<String>('nisab_status',
          p.hasReachedNisab ? 'بلغ النصاب ✓' : 'لم يبلغ النصاب');

      await HomeWidget.saveWidgetData<String>('gold_price',
          '${p.goldPricePerGram.toStringAsFixed(1)} ${p.currencySymbol}');

      await HomeWidget.saveWidgetData<String>('total_wealth',
          '${p.totalZakatableWealth.toStringAsFixed(0)} ${p.currencySymbol}');

      await HomeWidget.saveWidgetData<bool>('is_ramadan', p.isRamadanMode);

      // تحديث عرض الويدجت
      await HomeWidget.updateWidget(
        iOSName: _iOSWidgetName,
        androidName: _androidWidgetName,
      );
    } catch (_) {
      // فشل صامت — الويدجت اختياري
    }
  }

  // ─── الاستماع لنقرات الويدجت ─────────────────────────────────────
  /// استدعه في initState بالشاشة الرئيسية
  static void listenForWidgetTap(Function(Uri?) onTap) {
    HomeWidget.widgetClicked.listen(onTap);
  }

  // ─── فحص إذا كان التطبيق فُتح من الويدجت ─────────────────────────
  static Future<Uri?> getInitialWidgetUri() async {
    return await HomeWidget.initiallyLaunchedFromHomeWidget();
  }
}
