//
// ignore_for_file: lines_longer_than_80_chars

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ht_authentication_client/ht_authentication_client.dart';
// Added import for User model

/// {@template ht_authentication_firebase}
/// Firebase implementation of [HtAuthenticationClient].
/// {@endtemplate}
class HtAuthenticationFirebase implements HtAuthenticationClient {
  /// {@macro ht_authentication_firebase}
  ///
  /// Requires [actionCodeSettings] to configure email link sign-in behavior.
  HtAuthenticationFirebase({
    required firebase_auth.ActionCodeSettings
    actionCodeSettings, // Made required
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn(),
       _actionCodeSettings = actionCodeSettings; // Initialize here

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final firebase_auth.ActionCodeSettings _actionCodeSettings; // Store settings

  @override
  Future<void> sendSignInLinkToEmail({required String email}) async {
    try {
      // Use the configured actionCodeSettings
      await _firebaseAuth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: _actionCodeSettings,
      );
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      // Throw the specific exception from the client package
      throw SendSignInLinkException(e, stackTrace);
    } catch (e, stackTrace) {
      // Catch any other potential errors
      throw SendSignInLinkException(e, stackTrace);
    }
  }

  @override
  Future<bool> isSignInWithEmailLink({required String emailLink}) async {
    try {
      // Directly use the Firebase check
      return _firebaseAuth.isSignInWithEmailLink(emailLink);
    } on Exception catch (_) {
      // Specify Exception type
      // Assume any exception means it's not a valid link
      return false;
    }
  }

  @override
  Future<void> signInWithEmailLink({
    required String email,
    required String emailLink,
  }) async {
    try {
      // Perform sign-in using the provided email and link
      await _firebaseAuth.signInWithEmailLink(
        email: email,
        emailLink: emailLink,
      );
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      // Map Firebase exceptions to client-defined exceptions
      if (e.code == 'invalid-email' || e.code == 'invalid-action-code') {
        throw InvalidSignInLinkException(e, stackTrace);
      }
      // Firebase might not have a specific 'user-not-found' code for email link sign-in
      // If the user needs to exist beforehand, this logic might need adjustment
      // based on the app's user creation flow. For now, default to invalid link.
      throw InvalidSignInLinkException(e, stackTrace);
    } catch (e, stackTrace) {
      // Catch any other potential errors
      throw InvalidSignInLinkException(e, stackTrace);
    }
  }

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

  // Removed signInWithEmailAndPassword as it's not in the HtAuthenticationClient interface

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
      final isNewUser =
          // Compare timestamps correctly
          firebaseUser?.metadata.creationTime?.millisecondsSinceEpoch ==
          firebaseUser?.metadata.lastSignInTime?.millisecondsSinceEpoch;
      return User(
        // Let the User model handle default UUID generation if uid is null
        uid: firebaseUser?.uid,
        email: firebaseUser?.email,
        displayName: firebaseUser?.displayName,
        photoUrl: firebaseUser?.photoURL,
        // Map Firebase user state to the client's AuthenticationStatus enum
        authenticationStatus:
            firebaseUser == null
                ? AuthenticationStatus.unauthenticated
                : firebaseUser.isAnonymous
                ? AuthenticationStatus.anonymous
                : AuthenticationStatus.authenticated,
        isEmailVerified: firebaseUser?.emailVerified ?? false,
        // Handle potential null for isNewUser calculation result
        isNewUser: isNewUser,
      );
    });
  }
}
