import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/utils/app_logger.dart';

class FirestoreSyncDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool get isSignedIn => _auth.currentUser != null;

  String? get _uid => _auth.currentUser?.uid;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signInAnonymously() async {
    if (_auth.currentUser != null) return;
    await _auth.signInAnonymously();
    AppLogger.firebase('signInAnonymously', collection: 'auth');
  }

  Future<void> saveData(String collection, Map<String, dynamic> data) async {
    if (_uid == null) return;
    try {
      await _firestore.collection(collection).doc(_uid).set(data, SetOptions(merge: true));
      AppLogger.firebase('save', collection: collection, doc: _uid);
    } catch (e) {
      AppLogger.error('Firestore: save failed', exception: e);
    }
  }

  Future<Map<String, dynamic>?> loadData(String collection) async {
    if (_uid == null) return null;
    try {
      final doc = await _firestore.collection(collection).doc(_uid).get();
      AppLogger.firebase('load', collection: collection, doc: _uid);
      return doc.data();
    } catch (e) {
      AppLogger.error('Firestore: load failed', exception: e);
      return null;
    }
  }

  Future<void> saveHistory(List<Map<String, dynamic>> history) async {
    await saveData('zakat_history', {'records': history});
  }

  Future<List<Map<String, dynamic>>> loadHistory() async {
    final data = await loadData('zakat_history');
    if (data == null) return [];
    final records = data['records'] as List?;
    return records?.cast<Map<String, dynamic>>() ?? [];
  }

  Future<void> signOut() async {
    await _auth.signOut();
    AppLogger.firebase('signOut', collection: 'auth');
  }
}
