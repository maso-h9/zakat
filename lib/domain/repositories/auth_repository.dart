import '../entities/user_data.dart';

abstract class AuthRepository {
  bool get isSignedIn;
  Future<void> signInAnonymously();
  Future<void> signInWithEmail(String email, String password);
  Future<void> signUpWithEmail(String email, String password);
  Future<void> signInWithGoogle();
  Future<void> signOut();
  Stream<UserData?> get authStateChanges;
}
