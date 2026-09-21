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

  // ═══════════════════════════════════════════════════════════════════
  // General
  // ═══════════════════════════════════════════════════════════════════
  String get appName => isArabic ? 'الزكاة' : 'Zakat';
  String get appSubtitle => isArabic ? 'دليلك الشامل لأداء فريضة الزكاة' : 'Your complete guide to Zakat';
  String get ok => isArabic ? 'حسناً' : 'OK';
  String get cancel => isArabic ? 'إلغاء' : 'Cancel';
  String get confirm => isArabic ? 'تأكيد' : 'Confirm';
  String get delete => isArabic ? 'حذف' : 'Delete';
  String get save => isArabic ? 'حفظ' : 'Save';
  String get close => isArabic ? 'إغلاق' : 'Close';
  String get done => isArabic ? 'تم' : 'Done';
  String get retry => isArabic ? 'إعادة' : 'Retry';
  String get loading => isArabic ? 'جارٍ التحميل...' : 'Loading...';
  String get noData => isArabic ? 'لا توجد بيانات بعد' : 'No data yet';
  String get search => isArabic ? 'بحث...' : 'Search...';
  String get noResults => isArabic ? 'لا توجد نتائج' : 'No results';
  String get result => isArabic ? 'نتيجة' : 'Result';
  String get ofLabel => isArabic ? 'من' : 'of';
  String get grams => isArabic ? 'غرام' : 'grams';
  String get gram => isArabic ? 'جرام' : 'gram';

  // ═══════════════════════════════════════════════════════════════════
  // Bottom Navigation
  // ═══════════════════════════════════════════════════════════════════
  String get home => isArabic ? 'الرئيسية' : 'Home';
  String get calculator => isArabic ? 'الحاسبة' : 'Calculator';
  String get ahadith => isArabic ? 'الأحاديث' : 'Hadiths';
  String get myStats => isArabic ? 'إحصائياتي' : 'My Stats';
  String get services => isArabic ? 'الخدمات' : 'Services';

  // ═══════════════════════════════════════════════════════════════════
  // Dashboard
  // ═══════════════════════════════════════════════════════════════════
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
  String get calculateMyZakat => isArabic ? 'احسب زكاتي' : 'Calculate My Zakat';
  String get pillarOfIslam => isArabic ? 'ركن من أركان الإسلام' : 'Pillar of Islam';
  String get ramadanKareem => isArabic ? 'رمضان كريم' : 'Ramadan Kareem';
  String get dailyHadith => isArabic ? '✨ حديث اليوم' : '✨ Daily Hadith';
  String get islamicHadith => isArabic ? '📜 حديث شريف' : '📜 Hadith';
  String get narrator => isArabic ? 'رواه' : 'Narrated by';
  String get goldPriceLabel => isArabic ? 'سعر الذهب' : 'Gold Price';
  String get estimatedPriceHint => isArabic ? 'سعر تقديري — اضغط للتحديث' : 'Estimated — tap to update';
  String get zakatRequired => isArabic ? 'هل تجب؟' : 'Due?';
  String get masarif => isArabic ? 'المصارف' : 'Recipients';
  String get fatawa => isArabic ? 'الفتاوى' : 'Rulings';
  String get calendar => isArabic ? 'التقويم' : 'Calendar';
  String get moreServices => isArabic ? 'المزيد من الخدمات' : 'More Services';
  String get zakatDisclaimer => isArabic ? 'المحتوى من الدرر السنية والمصادر الفقهية المعتمدة' : 'Content from Ad-Durar Al-Saniyyah and trusted jurisprudential sources';
  String get appTitle => isArabic ? 'تطبيق الزكاة' : 'Zakat Application';
  String get aboutDescription => isArabic ? 'دليلك الشامل لأداء فريضة الزكاة' : 'Your complete guide to Zakat';

  // ═══════════════════════════════════════════════════════════════════
  // Calculator
  // ═══════════════════════════════════════════════════════════════════
  String get calculatorTitle => isArabic ? 'حاسبة الزكاة' : 'Zakat Calculator';
  String get cashAndSavings => isArabic ? 'النقود والمدخرات' : 'Cash & Savings';
  String get savedAmount => isArabic ? 'المبلغ المدخر' : 'Saved Amount';
  String get receivables => isArabic ? 'ديون لصالحك' : 'Receivables';
  String get goldSection => isArabic ? 'الذهب' : 'Gold';
  String get goldWeightGrams => isArabic ? 'وزن الذهب (غرام)' : 'Gold (grams)';
  String get goldNisabHint => isArabic ? 'النصاب: 85 غرام' : 'Nisab: 85 grams';
  String get silverSection => isArabic ? 'الفضة' : 'Silver';
  String get silverWeightGrams => isArabic ? 'وزن الفضة (غرام)' : 'Silver (grams)';
  String get silverNisabHint => isArabic ? 'النصاب: 595 غرام' : 'Nisab: 595 grams';
  String get goldPricePerGram => isArabic ? 'سعر الذهب (غرام)' : 'Gold Price (per gram)';
  String get live => isArabic ? 'مباشر' : 'Live';
  String get estimated => isArabic ? 'تقديري' : 'Estimated';
  String get updatePrice => isArabic ? 'تحديث السعر' : 'Update Price';
  String get tradeGoodsZakat => isArabic ? 'زكاة عروض التجارة' : 'Trade Goods Zakat';
  String get tradeGoodsDescription => isArabic ? 'كل ما أُعدَّ للبيع والربح من بضاعة ومواد وعقارات تجارية' : 'Everything prepared for sale and profit: goods, materials, commercial real estate';
  String get goodsValue => isArabic ? 'قيمة البضاعة' : 'Goods Value';
  String get tradeZakatTitle => isArabic ? 'زكاة التجارة' : 'Trade Zakat';
  String get tradeZakatFormula => isArabic ? 'ربع العشر (2.5%) من قيمة البضاعة' : 'Quarter of tithe (2.5%) of goods value';
  String get livestockTitle => isArabic ? 'الإبل' : 'Camels';
  String get camelCount => isArabic ? 'عدد الإبل' : 'Camel Count';
  String get cattle => isArabic ? 'البقر' : 'Cattle';
  String get cattleCount => isArabic ? 'عدد البقر' : 'Cattle Count';
  String get sheep => isArabic ? 'الغنم' : 'Sheep';
  String get sheepCount => isArabic ? 'عدد الغنم' : 'Sheep Count';
  String get consultScholar => isArabic ? 'راجع العالم لهذا العدد' : 'Consult a scholar for this count';
  String get cropsTitle => isArabic ? 'زكاة الزروع والثمار' : 'Crops & Fruits Zakat';
  String get cropsObligation => isArabic ? 'تجب عند الحصاد إذا بلغت 5 أوسق (≈ 653 كيلوغرام)' : 'Obligated at harvest if reaching 5Awsuq (~653 kg)';
  String get cropQuantityKg => isArabic ? 'كمية المحصول (كيلوغرام)' : 'Crop Quantity (kg)';
  String get irrigationMethod => isArabic ? 'طريقة الري:' : 'Irrigation method:';
  String get rainIrrigation => isArabic ? 'مطر أو نهر (10%)' : 'Rain or river (10%)';
  String get machineIrrigation => isArabic ? 'آلة (5%)' : 'Machine (5%)';
  String get cropsBelowNisab => isArabic ? 'لم يبلغ النصاب (أقل من 653 كيلو)' : 'Below Nisab (less than 653 kg)';
  String get cropZakatResult => isArabic ? 'زكاة المحصول' : 'Crop Zakat';
  String get rainRate => isArabic ? 'العشر (10%) — ري بمطر أو نهر' : 'Tithe (10%) — rain or river irrigation';
  String get machineRate => isArabic ? 'نصف العشر (5%) — ري بآلة' : 'Half tithe (5%) — machine irrigation';
  String get zakatObligatory => isArabic ? 'الزكاة الواجبة' : 'Zakat Due';
  String get recordPaymentLabel => isArabic ? 'سجّل الدفع' : 'Record Payment';
  String get zakatPaymentRecorded => isArabic ? 'تم تسجيل الزكاة المدفوعة ✓' : 'Zakat payment recorded ✓';
  String get reviewScholarWarning => isArabic ? 'يُنصح بمراجعة عالِم للتأكد من الحساب' : 'Consult a scholar to verify the calculation';

  // ═══════════════════════════════════════════════════════════════════
  // Livestock results
  // ═══════════════════════════════════════════════════════════════════
  String get sheepSingular => isArabic ? 'شاة' : 'One sheep';
  String get sheepDual => isArabic ? 'شاتان' : 'Two sheep';
  String get sheepFew => isArabic ? 'ثلاث شياه' : 'Three sheep';
  String get sheepFour => isArabic ? 'أربع شياه' : 'Four sheep';
  String get cowSell => isArabic ? 'تبيع أو تبيعة' : "Cow for sale (tabi'a)";
  String get cowMusenna => isArabic ? 'مسنّة' : 'Mature cow (musenna)';
  String get camelHicca => isArabic ? 'حِقة' : 'Hicca (camel)';
  String get camelJaza => isArabic ? 'جذعة' : 'Jaza (camel)';
  String get camelBintLabun => isArabic ? 'بنت لبون' : 'Bint Labun';
  String get camelBintMakhadh => isArabic ? 'بنت مخاض' : 'Bint Makhadh';
  String get camelHubla => isArabic ? 'حِبلى' : 'Hubla (pregnant)';
  String get camelSyed => isArabic ? 'سَّائبة' : 'Sa\'iba (free camel)';
  String get camelWaliqa => isArabic ? 'وَلِيقة' : 'Waliqa';
  String get camelRadha => isArabic ? 'رَضَاعة' : 'Radha (nursing)';
  String get cowBintLabun => isArabic ? 'بنت لبون' : 'Bint Labun';
  String get cowBintMakhadh => isArabic ? 'بنت مخاض' : 'Bint Makhadh';
  String get cowTabia => isArabic ? 'تبيع أو تبيعة' : 'Tabi\'a';
  String get sheepBintMakhadh => isArabic ? 'بنت مخاض' : 'Bint Makhadh';
  String get sheepBintLabun => isArabic ? 'بنت لبون' : 'Bint Labun';
  String get notObligatory => isArabic ? 'لم يبلغ النصاب' : 'Not obligatory';

  // ═══════════════════════════════════════════════════════════════════
  // Settings
  // ═══════════════════════════════════════════════════════════════════
  String get settings => isArabic ? 'الإعدادات' : 'Settings';
  String get appearance => isArabic ? 'المظهر' : 'Appearance';
  String get darkMode => isArabic ? 'الوضع الداكن' : 'Dark Mode';
  String get lightMode => isArabic ? 'الوضع الفاتح' : 'Light Mode';
  String get language => isArabic ? 'اللغة' : 'Language';
  String get arabic => isArabic ? 'العربية' : 'Arabic';
  String get english => isArabic ? 'الإنجليزية' : 'English';
  String get currency => isArabic ? 'العملة' : 'Currency';
  String get currentCurrency => isArabic ? 'العملة الحالية' : 'Current Currency';
  String get changeCurrency => isArabic ? 'تغيير العملة' : 'Change Currency';
  String get updateGoldPriceLabel => isArabic ? 'تحديث سعر الذهب' : 'Update Gold Price';
  String get livePrice => isArabic ? 'سعر مباشر' : 'Live price';
  String get estimatedPrice => isArabic ? 'سعر تقديري' : 'Estimated price';
  String get cloudSync => isArabic ? 'المزامنة السحابية' : 'Cloud Sync';
  String get syncNow => isArabic ? 'مزامنة الآن' : 'Sync Now';
  String get ramadanMode => isArabic ? 'وضع رمضان' : 'Ramadan Mode';
  String get enableRamadan => isArabic ? 'تفعيل وضع رمضان' : 'Enable Ramadan Mode';
  String get personalAccount => isArabic ? 'الحساب الشخصي' : 'Personal Account';
  String get myAccount => isArabic ? 'حسابي' : 'My Account';
  String get viewAndEditProfile => isArabic ? 'عرض وتعديل معلوماتك' : 'View and edit your info';
  String get data => isArabic ? 'البيانات' : 'Data';
  String get cloudSyncLabel => isArabic ? 'مزامنة سحابية' : 'Cloud Sync';
  String get clearAllData => isArabic ? 'مسح جميع البيانات' : 'Clear All Data';
  String get aboutApp => isArabic ? 'عن التطبيق' : 'About App';
  String get version => isArabic ? 'الإصدار' : 'Version';
  String get religiousContent => isArabic ? 'المحتوى الديني' : 'Religious Content';
  String get religiousContentSource => isArabic ? 'الدرر السنية + الشاملة' : 'Ad-Durar + Al-Shamela';
  String get goldData => isArabic ? 'بيانات الذهب' : 'Gold Data';
  String get aiAssistant => isArabic ? 'المساعد الذكي' : 'AI Assistant';
  String get nisabSources => isArabic ? 'مصادر النصاب' : 'Nisab Sources';
  String get nisabSourcesDesc => isArabic ? 'Firestore — محدَّثة ديناميكياً' : 'Firestore — dynamically updated';
  String get globalNisab => isArabic ? 'الحساب العالمي' : 'Global Calculation';
  String get globalNisabDesc => isArabic ? 'سعر الذهب العالمي × سعر الصرف (موصى به)' : 'Global gold price × exchange rate (recommended)';
  String get officialNisab => isArabic ? 'النصاب الرسمي للدولة' : 'Official State Nisab';
  String get officialNisabDesc => isArabic ? 'القيمة المُعلنة من الجهة الرسمية في بلدك' : 'Value declared by the official authority in your country';
  String get customCalculation => isArabic ? 'حساب مخصص' : 'Custom Calculation';
  String get customCalculationDesc => isArabic ? 'أدخل قيمة النصاب أو أسعار الذهب يدوياً' : 'Enter nisab value or gold prices manually';
  String get lastReview => isArabic ? 'آخر مراجعة' : 'Last review';
  String get openSource => isArabic ? 'فتح المصدر' : 'Open Source';
  String get noOfficialSource => isArabic ? 'لا يتوفر مصدر رسمي معروف لهذه الدولة...' : 'No official source available for this country...';
  String get enterOfficialNisab => isArabic ? 'أدخل قيمة النصاب الرسمية:' : 'Enter the official nisab value:';
  String get exampleNisab => isArabic ? 'مثال: 97495' : 'Example: 97495';
  String get nisabSaved => isArabic ? 'تم حفظ النصاب...' : 'Nisab saved...';
  String get savedNisab => isArabic ? 'النصاب المحفوظ' : 'Saved Nisab';
  String get nisabComparison => isArabic ? 'مقارنة النصاب' : 'Nisab Comparison';
  String get globalNisabLabel => isArabic ? 'النصاب العالمي' : 'Global Nisab';
  String get officialNisabLabel => isArabic ? 'النصاب الرسمي' : 'Official Nisab';
  String get customNisabLabel => isArabic ? 'النصاب المخصص' : 'Custom Nisab';
  String get difference => isArabic ? 'الفرق' : 'Difference';
  String get nisabDifferenceNote => isArabic ? 'الاختلاف ناتج عن اختلاف مصدر الأسعار...' : 'Difference due to different price sources...';
  String get option1DirectEntry => isArabic ? 'الخيار 1 — إدخال القيمة مباشرة' : 'Option 1 — Enter value directly';
  String get option2FromGram => isArabic ? 'الخيار 2 — من سعر جرام الذهب' : 'Option 2 — From gold gram price';
  String get option3FromOz => isArabic ? 'الخيار 3 — من سعر الأوقية وسعر الصرف' : 'Option 3 — From ounce price and exchange rate';
  String get calculateAndSave => isArabic ? 'احسب واحفظ' : 'Calculate & Save';
  String get customNisabSaved => isArabic ? 'النصاب المخصص' : 'Custom Nisab';
  String get linkCopied => isArabic ? 'تم نسخ الرابط' : 'Link copied';
  String get nisabCalculated => isArabic ? 'تم حفظ النصاب' : 'Nisab saved';
  String get calculatedNisab => isArabic ? 'النصاب المحسوب' : 'Calculated Nisab';
  String get confirmDelete => isArabic ? 'تأكيد الحذف' : 'Confirm Delete';
  String get deleteAllDataConfirm => isArabic ? 'هل تريد مسح جميع البيانات؟ لا يمكن التراجع.' : 'Clear all data? This cannot be undone.';
  String get clear => isArabic ? 'مسح' : 'Clear';
  String get searchCurrency => isArabic ? 'ابحث عن عملة...' : 'Search currency...';

  // ═══════════════════════════════════════════════════════════════════
  // Hadiths / Content
  // ═══════════════════════════════════════════════════════════════════
  String get zakatHadiths => isArabic ? 'أحاديث الزكاة' : 'Zakat Hadiths';
  String get hadithsSourceNote => isArabic ? 'جميع الأحاديث مستخرجة من موقع الدرر السنية والمصادر الفقهية المعتمدة' : 'All hadiths from Ad-Durar Al-Saniyyah and trusted jurisprudential sources';
  String get zakatRecipients => isArabic ? 'مصارف الزكاة الثمانية' : '8 Zakat Recipients';
  String get recipientsQuranVerse => isArabic ? '﴿إِنَّمَا الصَّدَقَاتُ لِلْفُقَرَاءِ...﴾' : '“Charities are only for the poor...”';
  String get realExamples => isArabic ? 'أمثلة واقعية:' : 'Real examples:';
  String get zakatRulings => isArabic ? 'فتاوى الزكاة' : 'Zakat Rulings';
  String get searchRulings => isArabic ? 'ابحث في الفتاوى...' : 'Search rulings...';
  String get sourceLabel => isArabic ? '📚 المصدر' : '📚 Source';
  String get zakatObligatoryYes => isArabic ? '✅ تجب عليك الزكاة' : '✅ Zakat is obligatory for you';
  String get zakatObligatoryYesDesc => isArabic ? 'استوفيت جميع شروط وجوب الزكاة' : 'You meet all conditions for Zakat obligation';
  String get isZakatObligatory => isArabic ? 'هل تجب عليك الزكاة؟' : 'Is Zakat obligatory for you?';
  String get questionStep => isArabic ? 'السؤال' : 'Question';
  String get retakeTest => isArabic ? 'إعادة الاختبار' : 'Retake Test';
  String get calculateZakatAmount => isArabic ? 'احسب مقدار الزكاة' : 'Calculate Zakat Amount';

  // ═══════════════════════════════════════════════════════════════════
  // AI Assistant
  // ═══════════════════════════════════════════════════════════════════
  String get aiAssistantTitle => isArabic ? 'المساعد الذكي' : 'AI Assistant';
  String get clearChat => isArabic ? 'مسح المحادثة' : 'Clear Chat';
  String get aiPlaceholder => isArabic ? 'اسأل أي شيء...' : 'Ask anything...';
  String get apiKeyRequired => isArabic ? 'مفتاح API مطلوب' : 'API Key Required';
  String get apiKeyMessage => isArabic
      ? 'يجب تكوين مفتاح Gemini API في Firebase Console → Remote Config\n\nالclé: gemini_api_key\n\nاحصل عليه مجاناً:\nhttps://aistudio.google.com/app/apikey'
      : 'Configure Gemini API key in Firebase Console → Remote Config\n\nKey: gemini_api_key\n\nGet it free:\nhttps://aistudio.google.com/app/apikey';

  // ═══════════════════════════════════════════════════════════════════
  // Services
  // ═══════════════════════════════════════════════════════════════════
  String get zakatServices => isArabic ? 'خدمات الزكاة' : 'Zakat Services';
  String get madhabsComparison => isArabic ? 'مقارنة المذاهب الأربعة' : 'Four Madhabs Comparison';
  String get whatIfPlanning => isArabic ? 'ماذا لو؟ - التخطيط' : 'What If? — Planning';
  String get aiZakatAssistant => isArabic ? 'مساعد الزكاة الذكي (AI)' : 'AI Zakat Assistant';
  String get zakatTest => isArabic ? 'اختبار وجوب الزكاة' : 'Zakat Obligation Test';
  String get annualCalendar => isArabic ? 'تقويم الزكاة السنوي' : 'Annual Zakat Calendar';
  String get personalStats => isArabic ? 'إحصائياتي الشخصية' : 'My Personal Stats';
  String get companyZakat => isArabic ? 'حاسبة زكاة الشركات' : 'Company Zakat Calculator';
  String get ramadanModeLabel => isArabic ? 'وضع رمضان 🌙' : 'Ramadan Mode 🌙';

  // ═══════════════════════════════════════════════════════════════════
  // Ramadan Screen
  // ═══════════════════════════════════════════════════════════════════
  String get ramadanModeToggle => isArabic ? 'وضع رمضان' : 'Ramadan Mode';
  String get ramadanVerse => isArabic ? '﴿شَهْرُ رَمَضَانَ الَّذِي أُنزِلَ فِيهِ الْقُرْآنُ﴾' : '"The month of Ramadan in which the Quran was revealed"';
  String get fitrZakat => isArabic ? 'زكاة الفطر' : 'Zakat al-Fitr';
  String get fitrDescription => isArabic ? 'فرضها رسول الله ﷺ طهرةً للصائم...' : 'Obligated by the Prophet ﷺ to purify the fasting person...';
  String get fitrAmount => isArabic ? 'المقدار' : 'Amount';
  String get fitrAmountDetail => isArabic ? 'صاع = 2.5 كيلوغرام من قوت البلد' : 'Sa\' = 2.5 kg of local staple food';
  String get fitrTiming => isArabic ? 'وقتها' : 'Timing';
  String get fitrTimingDetail => isArabic ? 'من غروب آخر يوم رمضان حتى صلاة العيد' : 'From sunset on the last day of Ramadan until Eid prayer';
  String get fitrValue => isArabic ? 'قيمتها التقريبية' : 'Approximate value';
  String get fitrPaidLabel => isArabic ? 'تم إخراجها ✓' : 'Paid ✓';
  String get fitrRecordPayment => isArabic ? 'سجّل إخراج الفطر' : 'Record Fitr payment';
  String get dayOfRamadan => isArabic ? 'اليوم من رمضان' : 'Day of Ramadan';
  String get daysUntilEnd => isArabic ? 'يوم على نهاية الشهر' : 'days until end of month';
  String get charityHadith => isArabic ? '✨ حديث الصدقة' : '✨ Hadith on Charity';
  String get tapForNext => isArabic ? 'اضغط للتالي' : 'Tap for next';
  String get dailyReminders => isArabic ? 'تذكيرات يومية' : 'Daily Reminders';
  String get suhoor => isArabic ? 'السحور' : 'Suhoor';
  String get dua => isArabic ? 'الدعاء' : 'Dua';
  String get quran => isArabic ? 'القرآن' : 'Quran';
  String get charity => isArabic ? 'الصدقة' : 'Charity';
  String get charityVirtues => isArabic ? 'فضائل الصدقة في رمضان' : 'Virtues of Charity in Ramadan';
  String get ramadanModeDescription => isArabic ? 'فعّل الوضع عند دخول شهر رمضان المبارك...' : 'Enable during the blessed month of Ramadan...';
  String get enableRamadanButton => isArabic ? 'تفعيل وضع رمضان' : 'Enable Ramadan Mode';

  // ═══════════════════════════════════════════════════════════════════
  // Login
  // ═══════════════════════════════════════════════════════════════════
  String get fillAllFields => isArabic ? 'يرجى تعبئة جميع الحقول' : 'Please fill all fields';
  String get enterPhoneNumber => isArabic ? 'أدخل رقم الهاتف' : 'Enter phone number';
  String get otpSent => isArabic ? 'تم إرسال رمز التحقق' : 'OTP sent';
  String get createNewAccount => isArabic ? 'إنشاء حساب جديد' : 'Create New Account';
  String get loginTitle => isArabic ? 'تسجيل الدخول' : 'Sign In';
  String get welcomeBack => isArabic ? 'مرحباً بك' : 'Welcome Back';
  String get createAccountButton => isArabic ? 'إنشاء الحساب' : 'Create Account';
  String get loginButton => isArabic ? 'تسجيل الدخول' : 'Sign In';
  String get enterEmailFirst => isArabic ? 'أدخل بريدك الإلكتروني أولاً' : 'Enter your email first';
  String get email => isArabic ? 'البريد الإلكتروني' : 'Email';
  String get password => isArabic ? 'كلمة المرور' : 'Password';
  String get forgotPassword => isArabic ? 'نسيت كلمة المرور؟' : 'Forgot Password?';
  String get continueWithGoogle => isArabic ? 'المتابعة مع Google' : 'Continue with Google';
  String get loginWithGoogle => isArabic ? 'تسجيل الدخول بـ Google' : 'Sign in with Google';
  String get loginWithEmail => isArabic ? 'تسجيل الدخول بالبريد الإلكتروني' : 'Sign in with Email';
  String get loginWithPhone => isArabic ? 'تسجيل الدخول برقم الهاتف' : 'Sign in with Phone';
  String get phoneAuthWarning => isArabic
      ? '⚠️ يجب تفعيل Phone Auth في Firebase Console\nAuthentication → Sign-in method → Phone'
      : '⚠️ Phone Auth must be enabled in Firebase Console\nAuthentication → Sign-in method → Phone';
  String get phoneHint => isArabic ? 'رقم الهاتف الدولي (مثال: +218912345678)' : 'International phone (e.g. +218912345678)';
  String get otpHint => isArabic ? 'رمز التحقق (6 أرقام)' : 'Verification code (6 digits)';
  String get verifyCode => isArabic ? 'تحقق من الرمز' : 'Verify Code';
  String get sendCode => isArabic ? 'إرسال رمز التحقق' : 'Send OTP';
  String get changePhone => isArabic ? 'تغيير رقم الهاتف' : 'Change phone number';

  // ═══════════════════════════════════════════════════════════════════
  // Profile
  // ═══════════════════════════════════════════════════════════════════
  String get profileTitle => isArabic ? 'الحساب الشخصي' : 'Personal Account';
  String get loginToSave => isArabic ? 'سجّل الدخول لحفظ بياناتك' : 'Sign in to save your data';
  String get loginToSaveDesc => isArabic ? 'احفظ بيانات زكاتك ومدخراتك...' : 'Save your Zakat data and savings...';
  String get userLabel => isArabic ? 'مستخدم' : 'User';
  String get accountSummary => isArabic ? 'ملخص حسابك' : 'Account Summary';
  String get totalZakatPaid => isArabic ? 'إجمالي الزكاة المدفوعة' : 'Total Zakat Paid';
  String get yearsOfCompliance => isArabic ? 'سنوات الالتزام' : 'Years of Compliance';
  String get cloudSyncEnabled => isArabic ? 'مفعّلة ✓' : 'Enabled ✓';
  String get cloudSyncDisabled => isArabic ? 'معطّلة' : 'Disabled';
  String get syncDataNow => isArabic ? 'مزامنة البيانات الآن' : 'Sync data now';
  String get lastSync => isArabic ? 'آخر مزامنة' : 'Last sync';
  String get neverSynced => isArabic ? 'لم تتم مزامنة بعد' : 'Never synced';
  String get logoutButton => isArabic ? 'تسجيل الخروج' : 'Sign Out';
  String get logoutDesc => isArabic ? 'ستبقى البيانات محفوظة محلياً' : 'Data will remain saved locally';
  String get deleteAccount => isArabic ? 'حذف الحساب' : 'Delete Account';
  String get deleteAccountDesc => isArabic ? 'يحذف الحساب وجميع بياناته السحابية' : 'Deletes account and all cloud data';
  String get logoutConfirm => isArabic ? 'تسجيل الخروج؟' : 'Sign Out?';
  String get logoutConfirmMessage => isArabic ? 'هل تريد تسجيل الخروج من حسابك؟' : 'Do you want to sign out?';
  String get signOutAction => isArabic ? 'خروج' : 'Sign Out';
  String get deleteAccountConfirm => isArabic ? 'حذف الحساب؟' : 'Delete Account?';
  String get deleteAccountMessage => isArabic ? 'سيتم حذف حسابك وجميع بياناتك السحابية نهائياً' : 'Your account and all cloud data will be permanently deleted';
  String get permanentDelete => isArabic ? 'حذف نهائي' : 'Permanent Delete';

  // ═══════════════════════════════════════════════════════════════════
  // Secondary Screens (Calendar, Company, Nisab)
  // ═══════════════════════════════════════════════════════════════════
  String get annualZakatCalendar => isArabic ? 'تقويم الزكاة السنوي' : 'Annual Zakat Calendar';
  String get nextZakatDate => isArabic ? 'موعد الزكاة القادم' : 'Next Zakat Date';
  String get daysRemaining => isArabic ? 'يوم متبقٍ' : 'days remaining';
  String get zakatObligatoryNow => isArabic ? 'وجبت الزكاة!' : 'Zakat is due!';
  String get payNow => isArabic ? 'بادر بإخراجها الآن' : 'Pay now';
  String get setNisabDatePrompt => isArabic ? 'حدد تاريخ بلوغ النصاب' : 'Set Nisab date';
  String get nisabDateTitle => isArabic ? 'تاريخ بلوغ النصاب' : 'Nisab Date';
  String get nisabDateDescription => isArabic ? 'سجّل اليوم الذي امتلكت فيه النصاب لأول مرة' : 'Record the day you first held Nisab';
  String get chooseDate => isArabic ? 'اختر تاريخ بلوغ النصاب' : 'Choose Nisab date';
  String get dateOfNisab => isArabic ? 'تاريخ البلوغ' : 'Date of reaching Nisab';
  String get nextObligationDate => isArabic ? 'موعد وجوب الزكاة' : 'Next obligation date';
  String get daysUntilObligation => isArabic ? 'الأيام المتبقية' : 'Days remaining';
  String get hijriYearNote => isArabic ? 'الحول الهجري = 354 يوماً' : 'Hijri year = 354 days';
  String get zakatAssistantTitle => isArabic ? 'مساعد الزكاة الذكي' : 'AI Zakat Assistant';
  String get assistantPlaceholder => isArabic ? 'اكتب حالتك المالية وسأساعدك...' : 'Describe your financial situation and I\'ll help...';
  String get askQuestion => isArabic ? 'اكتب سؤالك هنا...' : 'Type your question here...';
  String get examplesToStart => isArabic ? 'أمثلة للبدء:' : 'Examples to start:';
  String get companyZakatTitle => isArabic ? 'حاسبة زكاة الشركات' : 'Company Zakat Calculator';
  String get companyZakatElements => isArabic ? 'عناصر وعاء الزكاة التجارية' : 'Trade Zakat pool elements';
  String get companyFormula => isArabic ? 'الصيغة: (رأس المال + البضاعة + الأرباح + الديون المستحقة)' : 'Formula: (Capital + Goods + Profits + Debts Due)';
  String get cashCapital => isArabic ? '+ رأس المال النقدي' : '+ Cash Capital';
  String get currentGoodsValue => isArabic ? '+ قيمة البضاعة الحالية' : '+ Current goods value';
  String get netProfits => isArabic ? '+ صافي الأرباح' : '+ Net profits';
  String get companyDebtsDue => isArabic ? '+ الديون المستحقة لل החברה' : '+ Debts due to company';
  String get companyDebtsOwed => isArabic ? '− الديون على الشركة' : '− Debts owed by company';
  String get zakatPool => isArabic ? 'وعاء الزكاة' : 'Zakat Pool';
  String get zakatDueLabel => isArabic ? 'الزكاة الواجبة (2.5%)' : 'Zakat Due (2.5%)';
  String get poolBelowNisab => isArabic ? 'الوعاء لم يبلغ النصاب' : 'Pool below Nisab';
  String get goldSilverNisabComparison => isArabic ? 'مقارنة نصاب الذهب والفضة' : 'Gold & Silver Nisab Comparison';
  String get goldNisab85 => isArabic ? '🥇 نصاب الذهب' : '🥇 Gold Nisab';
  String get goldNisabGrams => isArabic ? '85 غراماً' : '85 grams';
  String get silverNisab595 => isArabic ? '🥈 نصاب الفضة' : '🥈 Silver Nisab';
  String get silverNisabGrams => isArabic ? '595 غراماً' : '595 grams';
  String get whichIsAdopted => isArabic ? 'أيهما يُعتمد؟' : 'Which is adopted?';
  String get scholarsNote => isArabic ? 'يُنصح بمراجعة عالم متخصص...' : 'Consult a specialist scholar...';
  String get reachedNisab => isArabic ? 'وصل النصاب ✓' : 'Nisab reached ✓';
  String get notReached => isArabic ? 'لم يصل' : 'Not reached';

  // ═══════════════════════════════════════════════════════════════════
  // Madhabs
  // ═══════════════════════════════════════════════════════════════════
  String get hanafi => isArabic ? '🟢 الحنفية' : '🟢 Hanafi';
  String get maliki => isArabic ? '🟡 المالكية' : '🟡 Maliki';
  String get shafii => isArabic ? '🔵 الشافعية' : '🔵 Shafi\'i';
  String get hanbali => isArabic ? '🔴 الحنابلة' : '🔴 Hanbali';
  String get comparedIssues => isArabic ? 'المسائل المقارنة' : 'Compared Issues';
  String get quickTable => isArabic ? 'جدول سريع' : 'Quick Table';
  String get madhabNote => isArabic ? 'يُعرض رأي كل مذهب من المذاهب الأربعة...' : 'Shows the opinion of each of the four madhabs...';
  String get preferred => isArabic ? 'الراجح' : 'Preferred';
  String get issue => isArabic ? 'المسألة' : 'Issue';
  String get recommendedConsult => isArabic ? '* يُنصح بمراجعة عالم متخصص' : '* Consult a specialist scholar';

  // ═══════════════════════════════════════════════════════════════════
  // What If
  // ═══════════════════════════════════════════════════════════════════
  String get whatIfTitle => isArabic ? 'ماذا لو؟ — التخطيط المالي' : 'What If? — Financial Planning';
  String get instantCalculator => isArabic ? 'حاسبة فورية' : 'Instant Calculator';
  String get annualForecast => isArabic ? 'توقع سنوي' : 'Annual Forecast';
  String get scenarioComparison => isArabic ? 'مقارنة سيناريوهات' : 'Compare Scenarios';
  String get ifYouOwn => isArabic ? 'إذا كان مالك...' : 'If you own...';
  String get amount => isArabic ? 'المبلغ' : 'Amount';
  String get zakatObligatoryShort => isArabic ? '✅ تجب الزكاة' : '✅ Zakat due';
  String get belowNisabShort => isArabic ? '❌ لم يبلغ النصاب' : '❌ Below Nisab';
  String get zakatDuePercent => isArabic ? 'الزكاة الواجبة (2.5%)' : 'Zakat Due (2.5%)';
  String get remainingAfterZakat => isArabic ? 'يبقى بعد الزكاة' : 'Remaining after Zakat';
  String get nisabInfo => isArabic ? 'النصاب' : 'Nisab';
  String get remainingToNisab => isArabic ? 'متبقٍ للنصاب' : 'Remaining to Nisab';
  String get quickComparisonTable => isArabic ? 'جدول المقارنة السريع' : 'Quick Comparison Table';
  String get below => isArabic ? 'دون النصاب' : 'Below Nisab';
  String get forecastSettings => isArabic ? 'إعدادات التوقع' : 'Forecast Settings';
  String get monthlyIncome => isArabic ? 'الدخل الشهري' : 'Monthly Income';
  String get monthlySavingsRate => isArabic ? 'نسبة الادخار الشهري' : 'Monthly savings rate';
  String get yearsCount => isArabic ? 'عدد السنوات' : 'Number of years';
  String get yearLabel => isArabic ? 'السنة' : 'Year';
  String get savingsLabel => isArabic ? 'المدخرات' : 'Savings';
  String get zakatLabel => isArabic ? 'الزكاة' : 'Zakat';
  String get yearNumber => isArabic ? 'السنة' : 'Year';
  String get enterIncomeHint => isArabic ? 'أدخل دخلك الشهري لرؤية التوقعات' : 'Enter your monthly income to see forecasts';
  String get scenarioOne => isArabic ? 'السيناريو الأول' : 'Scenario 1';
  String get scenarioTwo => isArabic ? 'السيناريو الثاني' : 'Scenario 2';
  String get differenceSection => isArabic ? 'الفرق بين السيناريوهين' : 'Difference between scenarios';
  String get amountDiff => isArabic ? 'فرق المبلغ' : 'Amount difference';
  String get zakatDiff => isArabic ? 'فرق الزكاة' : 'Zakat difference';
  String get remainingAfterZakat1 => isArabic ? 'الباقي بعد الزكاة (1)' : 'Remaining after Zakat (1)';
  String get remainingAfterZakat2 => isArabic ? 'الباقي بعد الزكاة (2)' : 'Remaining after Zakat (2)';
  String get obligatoryZakat => isArabic ? 'زكاة واجبة' : 'Zakat obligatory';

  // ═══════════════════════════════════════════════════════════════════
  // Stats
  // ═══════════════════════════════════════════════════════════════════
  String get myStatsTitle => isArabic ? 'إحصائياتي' : 'My Stats';
  String get totalZakatLabel => isArabic ? 'إجمالي الزكاة' : 'Total Zakat';
  String get annualAverage => isArabic ? 'المتوسط السنوي' : 'Annual Average';
  String get yearsOfCommitment => isArabic ? 'سنوات الالتزام' : 'Years of Commitment';
  String get lastPayment => isArabic ? 'آخر دفعة' : 'Last Payment';
  String get annualZakatChart => isArabic ? 'الزكاة السنوية' : 'Annual Zakat';
  String get zakatPercentageOfWealth => isArabic ? 'نسبة الزكاة من ثروتك' : 'Zakat as % of your wealth';
  String get zakatDueLabel2 => isArabic ? 'الزكاة الواجبة' : 'Zakat Due';
  String get remainingLabel => isArabic ? 'الباقي' : 'Remaining';
  String get paymentHistory => isArabic ? 'سجل الزكاة المدفوعة' : 'Payment History';
  String get noHistoryYet => isArabic ? 'لا يوجد سجل بعد.\nسجّل دفع الزكاة من شاشة الحاسبة.' : 'No records yet.\nRecord a payment from the calculator screen.';
  String get fromWealth => isArabic ? 'من ثروة' : 'From wealth of';

  // ═══════════════════════════════════════════════════════════════════
  // Madhabs Issues (data-driven)
  // ═══════════════════════════════════════════════════════════════════
  String madhabIssueTitle(int index) {
    final titles = isArabic
        ? ['نصاب الذهب', 'زكاة الأسهم', 'زكاة العروض', 'زكاة المستودع', 'زكاة الإجارات', 'زكاة المعدات', 'ديون المتاجرة', 'زكاة العملات الرقمية']
        : ['Gold Nisab', 'Stock Zakat', 'Trade Goods Zakat', 'Warehouse Zakat', 'Rental Zakat', 'Equipment Zakat', 'Trading Debts', 'Cryptocurrency Zakat'];
    return index < titles.length ? titles[index] : '';
  }

  String madhabIssueDesc(int index) {
    final descs = isArabic
        ? [
            'هل يُحتسب نصاب الذهب بالسعر المحلي أم العالمي؟',
            'هل تُزكَّى الأسهم حسب القيمة السوقية أم الربح فقط؟',
            'كيف تُزكَّى عروض التجارة المُعدة للبيع؟',
            'هل تُزكَّى البضاعة في المستودع عند الشراء أم البيع؟',
            'هل تُزكَّى الإيرادات من الإيجارات العقارية؟',
            'هل تُزكَّى المعدات المستخدمة في التجارة؟',
            'كيف تُتعامل الديون في حساب التجارة؟',
            'هل تُزكَّى العملات الرقمية كذهب أم كتجارة؟',
          ]
        : [
            'Should gold nisab use local or global price?',
            'Are stocks zakatable by market value or profit only?',
            'How to calculate zakat on trade goods for sale?',
            'Is warehouse inventory zakatable at purchase or sale?',
            'Are rental incomes subject to zakat?',
            'Is commercial equipment subject to zakat?',
            'How to handle debts in trade calculation?',
            'Is cryptocurrency zakatable as gold or trade goods?',
          ];
    return index < descs.length ? descs[index] : '';
  }

  String madhabOpinion(int issueIndex, int madhabIndex) {
    final opinions = isArabic
        ? [
            ['بالسعر المحلي', 'بالسعر المحلي', 'بالسعر العالمي', 'بالسعر المحلي'],
            ['القيمة السوقية', 'القيمة السوقية', 'الربح فقط', 'القيمة السوقية'],
            ['عند الشراء', 'عند البيع', 'عند البيع', 'عند الشراء'],
            ['عند الشراء', 'عند البيع', 'عند الشراء', 'عند البيع'],
            ['تُزكَّى', 'تُزكَّى', 'تُزكَّى إذا بلغت', 'لا تُزكَّى'],
            ['تُزكَّى', 'لا تُزكَّى', 'تُزكَّى إذا بلغت', 'تُزكَّى'],
            ['تُخصَم أولاً', 'تُحتسب مع المبيعات', 'تُخصَم أولاً', 'تُخصَم أولاً'],
            ['كذهب', 'كتجارة', 'كذهب', 'كذهب'],
          ]
        : [
            ['By local price', 'By local price', 'By global price', 'By local price'],
            ['Market value', 'Market value', 'Profit only', 'Market value'],
            ['At purchase', 'At sale', 'At sale', 'At purchase'],
            ['At purchase', 'At sale', 'At purchase', 'At sale'],
            ['Zakatable', 'Zakatable', 'Zakatable if reached', 'Not zakatable'],
            ['Zakatable', 'Not zakatable', 'Zakatable if reached', 'Zakatable'],
            ['Deducted first', 'Included in sales', 'Deducted first', 'Deducted first'],
            ['As gold', 'As trade', 'As gold', 'As gold'],
          ];
    if (issueIndex < opinions.length && madhabIndex < opinions[issueIndex].length) {
      return opinions[issueIndex][madhabIndex];
    }
    return '';
  }

  String preferredMadhab(int index) {
    final preferred = isArabic
        ? ['الحنفية', 'المالكية', 'الشافعية', 'الحنابلة']
        : ['Hanafi', 'Maliki', 'Shafi\'i', 'Hanbali'];
    return index < preferred.length ? preferred[index] : '';
  }

  // ═══════════════════════════════════════════════════════════════════
  // Hadith data
  // ═══════════════════════════════════════════════════════════════════
  String hadithNarratedBy(String narrator) {
    return isArabic ? 'رواه $narrator' : 'Narrated by $narrator';
  }

  String daysRemainingCount(int days) {
    return isArabic ? '$days يوم على نهاية الشهر' : '$days days until end of month';
  }

  String questionOf(int current, int total) {
    return isArabic ? 'السؤال $current من $total' : 'Question $current of $total';
  }

  String yearLabel2(int year) {
    return isArabic ? 'السنة $year' : 'Year $year';
  }

  String scenarioLabel(int num) {
    return isArabic ? 'السيناريو $num' : 'Scenario $num';
  }

  String fromWealthOf(String amount) {
    return isArabic ? 'من ثروة $amount' : 'From wealth of $amount';
  }

  String lastReviewDate(String date) {
    return isArabic ? 'آخر مراجعة: $date' : 'Last review: $date';
  }

  String lastSyncDate(String date) {
    return isArabic ? 'آخر مزامنة: $date' : 'Last sync: $date';
  }

  String versionLabel(String v) {
    return isArabic ? 'الإصدار $v' : 'Version $v';
  }

  String priceSourceText(String source) {
    return isArabic ? '📊 المصدر: $source' : '📊 Source: $source';
  }
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
