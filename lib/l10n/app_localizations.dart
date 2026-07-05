// ================================================================
// app_localizations.dart — ترجمة عربي / إنجليزي
// lib/l10n/app_localizations.dart
// ================================================================
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  bool get isArabic => locale.languageCode == 'ar';

  // ─── نصوص عامة ───────────────────────────────────────────────
  String get appName => isArabic ? 'الزكاة' : 'Zakat';
  String get appSubtitle => isArabic
      ? 'دليلك الشامل لأداء فريضة الزكاة'
      : 'Your complete guide to Zakat';

  // ─── الشاشة الرئيسية ─────────────────────────────────────────
  String get home => isArabic ? 'الرئيسية' : 'Home';
  String get calculator => isArabic ? 'الحاسبة' : 'Calculator';
  String get ahadith => isArabic ? 'الأحاديث' : 'Hadiths';
  String get myStats => isArabic ? 'إحصائياتي' : 'My Stats';
  String get services => isArabic ? 'الخدمات' : 'Services';

  // ─── لوحة التحكم ─────────────────────────────────────────────
  String get totalWealth => isArabic ? 'إجمالي مالك' : 'Total Wealth';
  String get zakatDue => isArabic ? 'الزكاة الواجبة' : 'Zakat Due';
  String get zakatDate => isArabic ? 'موعد الزكاة' : 'Zakat Date';
  String get zakatPaid => isArabic ? 'زكاة مدفوعة' : 'Zakat Paid';
  String get notEntered => isArabic ? 'لم تُدخل بعد' : 'Not entered yet';
  String get belowNisab => isArabic ? 'لم يبلغ النصاب' : 'Below Nisab';
  String get zakatDueNow => isArabic ? '⚠️ وجبت الزكاة' : '⚠️ Zakat Due Now';
  String get setNisabDate => isArabic ? 'حدد تاريخ النصاب' : 'Set Nisab Date';
  String get noRecord => isArabic ? 'لا يوجد سجل' : 'No record';
  String get daysLeft => isArabic ? 'يوم' : 'days';

  // ─── الحاسبة ─────────────────────────────────────────────────
  String get moneyAndMetals => isArabic ? 'النقود والمعادن' : 'Cash & Metals';
  String get trade => isArabic ? 'التجارة' : 'Trade';
  String get livestock => isArabic ? 'الأنعام' : 'Livestock';
  String get crops => isArabic ? 'الزروع' : 'Crops';
  String get goldPrice => isArabic ? 'سعر الذهب' : 'Gold Price';
  String get savings => isArabic ? 'المبلغ المدخر' : 'Saved Amount';
  String get goldWeight => isArabic ? 'وزن الذهب (بالغرام)' : 'Gold (grams)';
  String get silverWeight =>
      isArabic ? 'وزن الفضة (بالغرام)' : 'Silver (grams)';
  String get debtsOwed => isArabic ? 'الديون عليك' : 'Debts Owed';
  String get debtsReceive =>
      isArabic ? 'ديون مضمونة لصالحك' : 'Guaranteed Receivables';
  String get recordPayment => isArabic ? 'سجّل الدفع' : 'Record Payment';
  String get zakatRecorded =>
      isArabic ? 'تم تسجيل الزكاة المدفوعة ✓' : 'Zakat payment recorded ✓';

  // ─── الإعدادات ────────────────────────────────────────────────
  String get settings => isArabic ? 'الإعدادات' : 'Settings';
  String get appearance => isArabic ? 'المظهر' : 'Appearance';
  String get darkMode => isArabic ? 'الوضع الداكن' : 'Dark Mode';
  String get lightMode => isArabic ? 'الوضع الفاتح' : 'Light Mode';
  String get language => isArabic ? 'اللغة' : 'Language';
  String get arabic => isArabic ? 'العربية' : 'Arabic';
  String get english => isArabic ? 'الإنجليزية' : 'English';
  String get currency => isArabic ? 'العملة' : 'Currency';
  String get currentCurrency =>
      isArabic ? 'العملة الحالية' : 'Current Currency';
  String get changeCurrency => isArabic ? 'تغيير العملة' : 'Change Currency';
  String get updateGoldPrice =>
      isArabic ? 'تحديث سعر الذهب' : 'Update Gold Price';
  String get livePrice => isArabic ? 'سعر مباشر' : 'Live price';
  String get estimatedPrice => isArabic ? 'سعر تقديري' : 'Estimated price';
  String get cloudSync => isArabic ? 'المزامنة السحابية' : 'Cloud Sync';
  String get syncNow => isArabic ? 'مزامنة الآن' : 'Sync Now';
  String get ramadanMode => isArabic ? 'وضع رمضان' : 'Ramadan Mode';
  String get enableRamadan =>
      isArabic ? 'تفعيل وضع رمضان' : 'Enable Ramadan Mode';
  String get personalAccount => isArabic ? 'الحساب الشخصي' : 'Personal Account';
  String get data => isArabic ? 'البيانات' : 'Data';
  String get clearAllData => isArabic ? 'مسح جميع البيانات' : 'Clear All Data';
  String get aboutApp => isArabic ? 'عن التطبيق' : 'About App';
  String get version => isArabic ? 'الإصدار' : 'Version';
  String get religiousContent =>
      isArabic ? 'المحتوى الديني' : 'Religious Content';
  String get goldData => isArabic ? 'بيانات الذهب' : 'Gold Data';
  String get aiAssistant => isArabic ? 'المساعد الذكي' : 'AI Assistant';

  // ─── تسجيل الدخول ────────────────────────────────────────────
  String get signIn => isArabic ? 'تسجيل الدخول' : 'Sign In';
  String get signUp => isArabic ? 'إنشاء حساب' : 'Sign Up';
  String get signOut => isArabic ? 'تسجيل الخروج' : 'Sign Out';
  String get email => isArabic ? 'البريد الإلكتروني' : 'Email';
  String get password => isArabic ? 'كلمة المرور' : 'Password';
  String get fullName => isArabic ? 'الاسم الكامل' : 'Full Name';
  String get phoneNumber => isArabic ? 'رقم الهاتف' : 'Phone Number';
  String get otpCode => isArabic ? 'رمز التحقق' : 'OTP Code';
  String get sendOtp => isArabic ? 'إرسال رمز التحقق' : 'Send OTP';
  String get verifyOtp => isArabic ? 'تحقق من الرمز' : 'Verify OTP';
  String get forgotPassword =>
      isArabic ? 'نسيت كلمة المرور؟' : 'Forgot Password?';
  String get continueWithGoogle =>
      isArabic ? 'المتابعة مع Google' : 'Continue with Google';
  String get noAccount =>
      isArabic ? 'ليس لدي حساب — إنشاء حساب' : "Don't have an account? Sign Up";
  String get haveAccount =>
      isArabic ? 'لدي حساب — تسجيل الدخول' : 'Have an account? Sign In';

  // ─── المصارف ─────────────────────────────────────────────────
  String get masarifTitle =>
      isArabic ? 'مصارف الزكاة الثمانية' : '8 Zakat Recipients';
  String get viewAll => isArabic ? 'عرض الكل' : 'View All';

  // ─── رسائل عامة ──────────────────────────────────────────────
  String get cancel => isArabic ? 'إلغاء' : 'Cancel';
  String get confirm => isArabic ? 'تأكيد' : 'Confirm';
  String get delete => isArabic ? 'حذف' : 'Delete';
  String get save => isArabic ? 'حفظ' : 'Save';
  String get loading => isArabic ? 'جارٍ التحميل...' : 'Loading...';
  String get noData => isArabic ? 'لا توجد بيانات بعد' : 'No data yet';
  String get selectCurrency => isArabic ? 'اختر العملة' : 'Select Currency';
  String get ramadanKareem => isArabic ? 'رمضان كريم' : 'Ramadan Kareem';
  String get pillarOfIslam =>
      isArabic ? 'ركن من أركان الإسلام' : 'Pillar of Islam';
  String get calculateMyZakat => isArabic ? 'احسب زكاتي' : 'Calculate My Zakat';
  String get dailyHadith => isArabic ? '✨ حديث اليوم' : '✨ Daily Hadith';
  String get islamicHadith => isArabic ? '📜 حديث شريف' : '📜 Hadith';
  String get narrator => isArabic ? 'رواه' : 'Narrated by';
}

// ─── Delegate ────────────────────────────────────────────────────
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_) => false;
}
