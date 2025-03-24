import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ht_authentication_client/ht_authentication_client.dart';
import 'package:ht_authentication_client/src/models/user.dart';

/// {@template ht_authentication_firebase}
/// Firebase implementation of [HtAuthenticationClient].
/// {@endtemplate}
class HtAuthenticationFirebase implements HtAuthenticationClient {
  /// {@macro ht_authentication_firebase}
  HtAuthenticationFirebase({
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  @override
  Future<void> deleteAccount() async {
    try {
      await _firebaseAuth.currentUser?.delete();
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      throw DeleteAccountException(e, stackTrace);
    } catch (e, stackTrace) {
      throw DeleteAccountException(e, stackTrace);
    }
  }

  @override
  Future<void> signInAnonymously() async {
    try {
      await _firebaseAuth.signInAnonymously();
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      throw AnonymousLoginException(e, stackTrace);
    } catch (e, stackTrace) {
      throw AnonymousLoginException(e, stackTrace);
    }
  }

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      throw EmailSignInException(e, stackTrace);
    } catch (e, stackTrace) {
      throw EmailSignInException(e, stackTrace);
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const GoogleSignInException(
          'Google Sign-In was cancelled',
          StackTrace.empty,
        );
      }
      final googleAuth = await googleUser.authentication;
      final firebase_auth.AuthCredential credential = firebase_auth
          .GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _firebaseAuth.signInWithCredential(credential);
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      throw GoogleSignInException(e, stackTrace);
    } catch (e, stackTrace) {
      throw GoogleSignInException(e, stackTrace);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      throw LogoutException(e, stackTrace);
    } catch (e, stackTrace) {
      throw LogoutException(e, stackTrace);
    }
  }

  @override
  Stream<User> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) {
        return User(isAnonymous: true);
      }
      final isNewUser =
          firebaseUser.metadata.creationTime ==
          firebaseUser.metadata.lastSignInTime;
      return User(
        uid: firebaseUser.uid,
        email: firebaseUser.email,
        displayName: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
        isAnonymous: firebaseUser.isAnonymous,
        isEmailVerified: firebaseUser.emailVerified,
        isNewUser: isNewUser,
      );
    });
  }
}
