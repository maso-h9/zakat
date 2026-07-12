// ================================================================
// firebase_service.dart — مزامنة Firestore مع Auth حقيقي
// lib/services/firebase_service.dart
// ================================================================
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/zakat_provider.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─── المستخدم الحالي ────────────────────────────────────────
  static User? get currentUser => _auth.currentUser;
  static String? get _uid => _auth.currentUser?.uid;
  static bool get isSignedIn => _auth.currentUser != null;
  static String? get userId => _uid;

  static DocumentReference? get _userDoc =>
      _uid == null ? null : _db.collection('users').doc(_uid);

  // ─── Stream لحالة Auth ───────────────────────────────────────
  static Stream<User?> authStateChanges() => _auth.authStateChanges();

  // ─── تسجيل دخول مجهول — للاستخدام قبل تسجيل الدخول الحقيقي
  static Future<void> signInAnonymously() async {
    // إذا المستخدم مسجّل دخوله بالفعل (Email/Google/Phone) لا نحتاج Anonymous
    if (_auth.currentUser != null) return;
    try {
      await _auth.signInAnonymously();
    } catch (_) {
      // فشل صامت — المزامنة ستعمل عند تسجيل الدخول الحقيقي
    }
  }

  // ─── حفظ كامل البيانات ──────────────────────────────────────
  static Future<void> saveAll(ZakatProvider p) async {
    final doc = _userDoc;
    if (doc == null) return;

    await doc.set({
      'wealth': {
        'money': p.savedMoney,
        'gold': p.goldGrams,
        'silver': p.silverGrams,
        'trade': p.tradeGoods,
        'debtsOwed': p.debtsOwed,
        'debtsToReceive': p.debtsToReceive,
      },
      'nisabDate': p.nisabDate?.toIso8601String(),
      'currency': p.selectedCurrency,
      'currencySymbol': p.currencySymbol,
      'ramadanMode': p.isRamadanMode,
      'fitrPaid': p.fitrPaid,
      'isDarkMode': p.isDarkMode,
      'language': p.isArabic ? 'ar' : 'en',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ─── تحميل البيانات ──────────────────────────────────────────
  static Future<void> loadAll(ZakatProvider p) async {
    final doc = _userDoc;
    if (doc == null) return;

    final snap = await doc.get();
    if (!snap.exists) return;

    final data = snap.data() as Map<String, dynamic>;

    final wealth = data['wealth'] as Map<String, dynamic>?;
    if (wealth != null) {
      p.updateWealth(
        money: (wealth['money'] as num?)?.toDouble() ?? 0,
        gold: (wealth['gold'] as num?)?.toDouble() ?? 0,
        silver: (wealth['silver'] as num?)?.toDouble() ?? 0,
        trade: (wealth['trade'] as num?)?.toDouble() ?? 0,
        debtsOwedVal: (wealth['debtsOwed'] as num?)?.toDouble() ?? 0,
        debtsReceive: (wealth['debtsToReceive'] as num?)?.toDouble() ?? 0,
      );
    }

    final nisabStr = data['nisabDate'] as String?;
    if (nisabStr != null) {
      final date = DateTime.tryParse(nisabStr);
      if (date != null) p.setNisabDate(date);
    }

    final currency = data['currency'] as String?;
    final symbol = data['currencySymbol'] as String?;
    if (currency != null && symbol != null) {
      p.setCurrency(currency, symbol);
    }

    if (data['ramadanMode'] == true) p.toggleRamadanMode(true);
    if (data['fitrPaid'] == true) p.markFitrPaid(true);
    if (data['isDarkMode'] == true) p.toggleDarkMode(true);
    final lang = data['language'] as String?;
    if (lang != null) await p.setLanguage(lang);
  }

  // ─── حفظ سجل الزكاة ─────────────────────────────────────────
  static Future<void> saveHistory(List<ZakatRecord> history) async {
    final doc = _userDoc;
    if (doc == null) return;

    final list = history
        .map((r) => {
              'year': r.year,
              'amount': r.amount,
              'wealth': r.wealth,
              'date': r.date.toIso8601String(),
              'note': r.note,
            })
        .toList();

    await doc.set({'history': list}, SetOptions(merge: true));
  }

  // ─── تحميل سجل الزكاة ────────────────────────────────────────
  static Future<List<ZakatRecord>> loadHistory() async {
    final doc = _userDoc;
    if (doc == null) return [];

    final snap = await doc.get();
    if (!snap.exists) return [];

    final data = snap.data() as Map<String, dynamic>;
    final rawList = data['history'] as List?;
    if (rawList == null) return [];

    return rawList.map((item) {
      final m = item as Map<String, dynamic>;
      return ZakatRecord(
        year: m['year'] as int,
        amount: (m['amount'] as num).toDouble(),
        wealth: (m['wealth'] as num).toDouble(),
        date: DateTime.parse(m['date'] as String),
        note: m['note'] as String? ?? '',
      );
    }).toList();
  }

  // ─── حذف كل البيانات ─────────────────────────────────────────
  static Future<void> deleteAll() async {
    final doc = _userDoc;
    if (doc == null) return;
    await doc.delete();
  }

  // ─── Stream للتغييرات الفورية ─────────────────────────────────
  static Stream<DocumentSnapshot>? userStream() {
    final doc = _userDoc;
    if (doc == null) return null;
    return doc.snapshots();
  }
}
