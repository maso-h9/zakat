# 🕌 تطبيق الزكاة
### دليلك الشامل لأداء فريضة الزكاة

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%2B%20Auth-orange?logo=firebase)](https://firebase.google.com)
[![Dart](https://img.shields.io/badge/Dart-3.x-blue?logo=dart)](https://dart.dev)

---

## 📱 نبذة عن التطبيق

تطبيق إسلامي متكامل يساعد المسلمين على حساب وإخراج زكاة أموالهم بدقة وسهولة، مع مراجعة الأحاديث الصحيحة والأحكام الشرعية.

---

## ✨ المميزات

| المجال | التفاصيل |
|--------|---------|
| 🧮 حساب الزكاة | نقود · ذهب · فضة · تجارة · أنعام · زروع |
| 📊 نظام النصاب | عالمي (تلقائي) / رسمي (من جهات معتمدة) / مخصص |
| 🥇 سعر الذهب | تحديث تلقائي كل 6 ساعات عبر GitHub Actions |
| 🌍 16 عملة | LYD · SAR · AED · EGP · USD · EUR وأكثر |
| 🌙 وضع رمضان | ثيم ليلي + زكاة الفطر + أحاديث الصدقة |
| 🤖 مساعد ذكي | Google Gemini 2.0 Flash |
| 🏛️ المصادر الرسمية | Firestore ديناميكي — قابل للتحديث بدون نشر |
| 🔒 الخصوصية | البيانات المالية لا تغادر الجهاز أبداً |
| 📴 Offline First | Hive كاش محلي — يعمل بدون إنترنت |
| 🌓 Dark Mode | دعم كامل لكل الشاشات |
| 🇸🇦 / 🇺🇸 | ثنائي اللغة — عربي وإنجليزي |

---

## 🏗️ بنية المشروع

```
lib/
├── core/
│   ├── errors/
│   │   └── app_exception.dart     ← نظام الأخطاء الموحّد
│   ├── cache/
│   │   └── cache_manager.dart     ← إدارة الكاش المركزية
│   └── utils/
│       └── app_logger.dart        ← Logger مركزي (debug only)
│
├── data/
│   └── zakat_data.dart            ← أحاديث · مصارف · فتاوى
│
├── models/
│   └── zakat_provider.dart        ← State Management (Provider)
│
├── services/
│   ├── firebase_service.dart      ← Firestore + Auth
│   ├── gold_price_service.dart    ← سعر الذهب + Hive Cache
│   ├── nisab_service.dart         ← حسابات النصاب + Repositories
│   ├── storage_service.dart       ← SharedPreferences
│   ├── auth_service.dart          ← Email / Google / Phone
│   └── notification_service.dart  ← إشعارات محلية
│
├── screens/                       ← كل الشاشات
├── widgets/                       ← مكونات مشتركة
└── utils/
    └── theme.dart                 ← ألوان · خطوط · ثيم
```

---

## 🔄 تدفق البيانات

```
GitHub Actions (كل 6 ساعات)
  ↓ يجلب gold-api.com / GOLDAPI / METALS_API
  ↓ يحسب النصاب لـ 16 عملة
  ↓ يكتب في Firestore (prices/latest)

Flutter App
  ↓ يقرأ من Firestore → يخزن في Hive
  ↓ يحسب الزكاة محلياً (لا ترسل بيانات للخارج)
  ↓ يعرض النتائج للمستخدم

Firestore (country_sources)
  ↓ مصادر النصاب الرسمية لكل دولة (ديناميكية)
  ↓ تُحدَّث بدون تحديث التطبيق
```

---

## 🚀 تشغيل المشروع

### المتطلبات
| الأداة | الإصدار |
|--------|---------|
| Flutter | ≥ 3.0.0 |
| Dart | ≥ 3.0.0 |
| Android minSdk | 21 |
| iOS | 12+ |

### الخطوات
```bash
# 1. استنسخ المشروع
git clone https://github.com/maso-h9/zakat.git
cd zakat

# 2. ثبّت الحزم
flutter pub get

# 3. Firebase (تأكد من وجود google-services.json في android/app)
# ويعمل مع firebase_options.dart الموجود

# 4. شغّل
flutter run

# 5. بناء APK
flutter build apk --release
```

---

## 🔑 المتغيرات البيئية

لا توجد مفاتيح API داخل الكود. كلها في **GitHub Secrets**:

| المتغير | الوصف | إلزامي؟ |
|---------|--------|---------|
| `FIREBASE_SERVICE_ACCOUNT` | Service Account لـ GitHub Actions | ✅ |
| `GOLDAPI_KEY` | مفتاح goldapi.io | ⬜ |
| `METALS_API_KEY` | مفتاح metals-api.com | ⬜ |
| `GEMINI_API_KEY` | مفتاح Gemini AI (في ai_screen.dart) | ⬜ |

---

## 🗄️ Firestore Collections

| Collection | الوصف |
|-----------|--------|
| `prices/latest` | سعر الذهب + النصاب لكل عملة (تملأها GitHub Actions) |
| `country_sources/{countryCode}` | المصادر الرسمية لكل دولة (LY, EG, SA...) |
| `users/{uid}/` | بيانات المستخدم الشخصية (محفوظة بأمان) |

### Firestore Rules الموصى بها
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /prices/latest {
      allow read: if true;
      allow write: if false;  // فقط GitHub Actions (Service Account)
    }
    match /country_sources/{code} {
      allow read: if true;
      allow write: if false;
    }
    match /users/{uid}/{doc=**} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```

---

## 🧮 طريقة حساب الزكاة

```
النصاب (ذهب) = سعر الجرام × 85 جرام
الزكاة الواجبة = إجمالي الثروة × 2.5%

إجمالي الثروة = مدخرات + (ذهب × سعر الجرام) + (فضة × سعر الجرام) + عروض تجارة + ديون مستحقة - ديون مطلوبة

الحول = 354 يوماً (سنة هجرية)
```

**طرق النصاب الثلاثة:**
1. 🌍 **عالمي** — تلقائي من سعر الذهب اللحظي
2. 🏛️ **رسمي** — يدخله المستخدم من الجهة الرسمية في بلده
3. ✍️ **مخصص** — إدخال مباشر أو حساب من سعر الجرام / الأوقية

---

## 📦 الحزم المستخدمة

| الحزمة | الغرض |
|--------|--------|
| `provider` | State Management |
| `firebase_core / cloud_firestore / firebase_auth` | Firebase |
| `hive_flutter` | كاش محلي سريع |
| `shared_preferences` | إعدادات بسيطة |
| `google_generative_ai` | Gemini AI |
| `fl_chart` | رسوم بيانية |
| `url_launcher` | فتح روابط المصادر الرسمية |
| `flutter_local_notifications` | إشعارات |
| `intl` | تواريخ وأرقام عربية |

---

## 📚 مصادر المحتوى الديني

| المحتوى | المصدر |
|---------|--------|
| الأحاديث | [الدرر السنية](https://dorar.net) — صحيح وحسن فقط |
| الموسوعة الفقهية | [الشاملة](https://shamela.ws) |
| المصادر الرسمية | صندوق الزكاة الليبي · دار الإفتاء المصرية · ZATCA وغيرها |

> ⚠️ لا يحتوي التطبيق على أي محتوى ديني من مصادر مجهولة أو غير موثّقة.

---

## 🔒 الخصوصية والأمان

- **البيانات المالية** (مدخرات، ذهب، ثروة) لا تُرسَل لأي خادم
- **الحسابات** تتم محلياً على جهاز المستخدم
- **السيرفر** يرسل فقط: أسعار الذهب والنصاب
- **المزامنة السحابية** اختيارية — تُحفَظ في `users/{uid}` الخاص بالمستخدم

---

*﴿وَأَقِيمُوا الصَّلَاةَ وَآتُوا الزَّكَاةَ وَأَطِيعُوا الرَّسُولَ لَعَلَّكُمْ تُرْحَمُونَ﴾*
