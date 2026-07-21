import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_data.dart';
import '../datasources/firestore_sync_data_source.dart';
import '../../core/utils/app_logger.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirestoreSyncDataSource _firestore;

  AuthRepositoryImpl(this._firestore);

  @override
  bool get isSignedIn => _firestore.isSignedIn;

  @override
  Future<void> signInAnonymously() async {
    try {
      await _firestore.signInAnonymously();
    } catch (e) {
      AppLogger.error('AuthRepository: signInAnonymously failed', exception: e);
    }
  }

  @override
  Future<void> signInWithEmail(String email, String password) async {
    // Delegate to AuthService for email auth
    throw UnimplementedError('Use AuthService directly for email auth');
  }

  @override
  Future<void> signUpWithEmail(String email, String password) async {
    throw UnimplementedError('Use AuthService directly for email auth');
  }

  @override
  Future<void> signInWithGoogle() async {
    throw UnimplementedError('Use AuthService directly for Google auth');
  }

  @override
  Future<void> signOut() async {
    await _firestore.signOut();
  }

  @override
  Stream<UserData?> get authStateChanges {
    return _firestore.authStateChanges.map((user) {
      if (user == null) return null;
      return UserData(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
      );
    });
  }
}
