import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_data.dart';
import '../datasources/firestore_sync_data_source.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/app_logger.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirestoreSyncDataSource _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl(
    this._firestore, {
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  bool get isSignedIn => _firestore.isSignedIn;

  @override
  Future<void> signInAnonymously() async {
    try {
      await _firestore.signInAnonymously();
    } catch (e) {
      AppLogger.error('AuthRepository: signInAnonymously failed', exception: e);
      rethrow;
    }
  }

  @override
  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      AppLogger.error('AuthRepository: signInWithEmail failed', exception: e);
      throw AuthException(e.code);
    }
  }

  @override
  Future<void> signUpWithEmail(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      AppLogger.error('AuthRepository: signUpWithEmail failed', exception: e);
      throw AuthException(e.code);
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw AuthException('sign-in-cancelled');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    } on AuthException {
      rethrow;
    } catch (e) {
      AppLogger.error('AuthRepository: signInWithGoogle failed', exception: e);
      throw AuthException('google-sign-in-failed');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      AppLogger.error('AuthRepository: signOut failed', exception: e);
    }
  }

  @override
  Stream<UserData?> get authStateChanges {
    return _auth.authStateChanges().map((user) {
      if (user == null) return null;
      return UserData(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
      );
    });
  }
}
