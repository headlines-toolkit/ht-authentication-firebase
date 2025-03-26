//
// ignore_for_file: lines_longer_than_80_chars

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ht_authentication_client/ht_authentication_client.dart';
import 'package:ht_authentication_firebase/src/ht_authentication_firebase.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements firebase_auth.FirebaseAuth {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockUserCredential extends Mock implements firebase_auth.UserCredential {}

class MockUser extends Mock implements firebase_auth.User {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

class MockAuthCredential extends Mock implements firebase_auth.AuthCredential {}

class FakeAuthCredential extends Fake implements firebase_auth.AuthCredential {}

class MockUserMetadata extends Mock implements firebase_auth.UserMetadata {}

// Fake ActionCodeSettings for testing
class FakeActionCodeSettings extends Fake
    implements firebase_auth.ActionCodeSettings {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeAuthCredential());
    registerFallbackValue(FakeActionCodeSettings()); // Register fallback
  });

  group('HtAuthenticationFirebase', () {
    late HtAuthenticationFirebase htAuthenticationFirebase;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockGoogleSignIn mockGoogleSignIn;
    late firebase_auth.ActionCodeSettings
    mockActionCodeSettings; // Declare mock

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockGoogleSignIn = MockGoogleSignIn();
      // Create mock ActionCodeSettings for the constructor
      mockActionCodeSettings = firebase_auth.ActionCodeSettings(
        url: 'https://test.page.link/signIn',
        handleCodeInApp: true,
        iOSBundleId: 'com.example.test.ios',
        androidPackageName: 'com.example.test.android',
        androidInstallApp: true,
        androidMinimumVersion: '12',
      );
      htAuthenticationFirebase = HtAuthenticationFirebase(
        firebaseAuth: mockFirebaseAuth,
        googleSignIn: mockGoogleSignIn,
        actionCodeSettings: mockActionCodeSettings, // Pass required settings
      );
    });

    group('sendSignInLinkToEmail', () {
      const email = 'test@example.com';
      test('should send sign-in link successfully', () async {
        when(
          () => mockFirebaseAuth.sendSignInLinkToEmail(
            email: email,
            actionCodeSettings: any(named: 'actionCodeSettings'),
          ),
        ).thenAnswer((_) async {});

        await htAuthenticationFirebase.sendSignInLinkToEmail(email: email);

        verify(
          () => mockFirebaseAuth.sendSignInLinkToEmail(
            email: email,
            actionCodeSettings:
                mockActionCodeSettings, // Verify with correct settings
          ),
        ).called(1);
      });

      test(
        'should throw SendSignInLinkException on FirebaseAuthException',
        () async {
          when(
            () => mockFirebaseAuth.sendSignInLinkToEmail(
              email: email,
              actionCodeSettings: any(named: 'actionCodeSettings'),
            ),
          ).thenThrow(
            firebase_auth.FirebaseAuthException(code: 'auth/invalid-email'),
          );

          expect(
            () async =>
                htAuthenticationFirebase.sendSignInLinkToEmail(email: email),
            throwsA(isA<SendSignInLinkException>()),
          );
        },
      );

      test(
        'should throw SendSignInLinkException on generic exception',
        () async {
          when(
            () => mockFirebaseAuth.sendSignInLinkToEmail(
              email: email,
              actionCodeSettings: any(named: 'actionCodeSettings'),
            ),
          ).thenThrow(Exception('Network error'));

          expect(
            () async =>
                htAuthenticationFirebase.sendSignInLinkToEmail(email: email),
            throwsA(isA<SendSignInLinkException>()),
          );
        },
      );
    });

    group('isSignInWithEmailLink', () {
      const link = 'https://test.page.link/signIn?email=test@example.com';
      test('should return true for a valid link', () async {
        when(
          () => mockFirebaseAuth.isSignInWithEmailLink(link),
        ).thenReturn(true);

        final result = await htAuthenticationFirebase.isSignInWithEmailLink(
          emailLink: link,
        );

        expect(result, isTrue);
        verify(() => mockFirebaseAuth.isSignInWithEmailLink(link)).called(1);
      });

      test('should return false for an invalid link', () async {
        when(
          () => mockFirebaseAuth.isSignInWithEmailLink(link),
        ).thenReturn(false);

        final result = await htAuthenticationFirebase.isSignInWithEmailLink(
          emailLink: link,
        );

        expect(result, isFalse);
        verify(() => mockFirebaseAuth.isSignInWithEmailLink(link)).called(1);
      });

      test('should return false on exception', () async {
        when(
          () => mockFirebaseAuth.isSignInWithEmailLink(link),
        ).thenThrow(Exception('Invalid link format'));

        final result = await htAuthenticationFirebase.isSignInWithEmailLink(
          emailLink: link,
        );

        expect(result, isFalse);
        verify(() => mockFirebaseAuth.isSignInWithEmailLink(link)).called(1);
      });
    });

    group('signInWithEmailLink', () {
      const email = 'test@example.com';
      const link = 'https://test.page.link/signIn?email=test@example.com';
      test('should sign in with email link successfully', () async {
        final mockUserCredential = MockUserCredential();
        when(
          () => mockFirebaseAuth.signInWithEmailLink(
            email: email,
            emailLink: link,
          ),
        ).thenAnswer((_) async => mockUserCredential);

        await htAuthenticationFirebase.signInWithEmailLink(
          email: email,
          emailLink: link,
        );

        verify(
          () => mockFirebaseAuth.signInWithEmailLink(
            email: email,
            emailLink: link,
          ),
        ).called(1);
      });

      test(
        'should throw InvalidSignInLinkException on invalid-action-code',
        () async {
          when(
            () => mockFirebaseAuth.signInWithEmailLink(
              email: email,
              emailLink: link,
            ),
          ).thenThrow(
            firebase_auth.FirebaseAuthException(code: 'invalid-action-code'),
          );

          expect(
            () async => htAuthenticationFirebase.signInWithEmailLink(
              email: email,
              emailLink: link,
            ),
            throwsA(isA<InvalidSignInLinkException>()),
          );
        },
      );

      test(
        'should throw InvalidSignInLinkException on invalid-email',
        () async {
          when(
            () => mockFirebaseAuth.signInWithEmailLink(
              email: email,
              emailLink: link,
            ),
          ).thenThrow(
            firebase_auth.FirebaseAuthException(code: 'invalid-email'),
          );

          expect(
            () async => htAuthenticationFirebase.signInWithEmailLink(
              email: email,
              emailLink: link,
            ),
            throwsA(isA<InvalidSignInLinkException>()),
          );
        },
      );

      test(
        'should throw InvalidSignInLinkException on other FirebaseAuthException',
        () async {
          when(
            () => mockFirebaseAuth.signInWithEmailLink(
              email: email,
              emailLink: link,
            ),
          ).thenThrow(
            firebase_auth.FirebaseAuthException(code: 'auth/user-disabled'),
          );

          // Defaulting to InvalidSignInLinkException for other auth errors
          expect(
            () async => htAuthenticationFirebase.signInWithEmailLink(
              email: email,
              emailLink: link,
            ),
            throwsA(isA<InvalidSignInLinkException>()),
          );
        },
      );

      test(
        'should throw InvalidSignInLinkException on generic exception',
        () async {
          when(
            () => mockFirebaseAuth.signInWithEmailLink(
              email: email,
              emailLink: link,
            ),
          ).thenThrow(Exception('Network error'));

          expect(
            () async => htAuthenticationFirebase.signInWithEmailLink(
              email: email,
              emailLink: link,
            ),
            throwsA(isA<InvalidSignInLinkException>()),
          );
        },
      );
    });

    group('deleteAccount', () {
      test('should delete the user account successfully', () async {
        final mockUser = MockUser();
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.delete).thenAnswer((_) async {});

        await htAuthenticationFirebase.deleteAccount();

        verify(mockUser.delete).called(1);
      });

      test(
        'should throw DeleteAccountException on FirebaseAuthException',
        () async {
          final mockUser = MockUser();
          when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
          when(mockUser.delete).thenThrow(
            firebase_auth.FirebaseAuthException(code: 'auth/unknown'),
          );

          expect(
            () async => htAuthenticationFirebase.deleteAccount(),
            throwsA(isA<DeleteAccountException>()),
          );
        },
      );

      test(
        'should throw DeleteAccountException on generic exception',
        () async {
          final mockUser = MockUser();
          when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
          when(mockUser.delete).thenThrow(Exception('Unknown error'));

          expect(
            () async => htAuthenticationFirebase.deleteAccount(),
            throwsA(isA<DeleteAccountException>()),
          );
        },
      );
    });

    group('signInAnonymously', () {
      test('should sign in anonymously successfully', () async {
        final mockUserCredential = MockUserCredential();
        when(
          () => mockFirebaseAuth.signInAnonymously(),
        ).thenAnswer((_) async => mockUserCredential);

        await htAuthenticationFirebase.signInAnonymously();

        verify(() => mockFirebaseAuth.signInAnonymously()).called(1);
      });

      test(
        'should throw AnonymousLoginException on FirebaseAuthException',
        () async {
          when(() => mockFirebaseAuth.signInAnonymously()).thenThrow(
            firebase_auth.FirebaseAuthException(code: 'auth/unknown'),
          );

          expect(
            () async => htAuthenticationFirebase.signInAnonymously(),
            throwsA(isA<AnonymousLoginException>()),
          );
        },
      );

      test(
        'should throw AnonymousLoginException on generic exception',
        () async {
          when(
            () => mockFirebaseAuth.signInAnonymously(),
          ).thenThrow(Exception('Unknown error'));

          expect(
            () async => htAuthenticationFirebase.signInAnonymously(),
            throwsA(isA<AnonymousLoginException>()),
          );
        },
      );
    });

    // Removed group('signInWithEmailAndPassword', ...) as the method is deleted

    group('signInWithGoogle', () {
      test('should sign in with Google successfully', () async {
        final mockGoogleSignInAccount = MockGoogleSignInAccount();
        final mockGoogleSignInAuthentication = MockGoogleSignInAuthentication();
        final mockUserCredential = MockUserCredential();

        when(
          () => mockGoogleSignIn.signIn(),
        ).thenAnswer((_) async => mockGoogleSignInAccount);
        when(
          () => mockGoogleSignInAccount.authentication,
        ).thenAnswer((_) async => mockGoogleSignInAuthentication);

        when(
          () => mockGoogleSignInAuthentication.accessToken,
        ).thenReturn('token');
        when(() => mockGoogleSignInAuthentication.idToken).thenReturn('token');
        when(
          () => mockFirebaseAuth.signInWithCredential(any()),
        ).thenAnswer((_) async => mockUserCredential);

        await htAuthenticationFirebase.signInWithGoogle();

        verify(() => mockGoogleSignIn.signIn()).called(1);
        verify(() => mockGoogleSignInAccount.authentication).called(1);
        verify(() => mockFirebaseAuth.signInWithCredential(any())).called(1);
      });

      test(
        'should throw GoogleSignInException if Google Sign-In is cancelled',
        () async {
          when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

          expect(
            () async => htAuthenticationFirebase.signInWithGoogle(),
            throwsA(isA<GoogleSignInException>()),
          );
        },
      );

      test(
        'should throw GoogleSignInException on FirebaseAuthException',
        () async {
          final mockGoogleSignInAccount = MockGoogleSignInAccount();
          final mockGoogleSignInAuthentication =
              MockGoogleSignInAuthentication();

          when(
            () => mockGoogleSignIn.signIn(),
          ).thenAnswer((_) async => mockGoogleSignInAccount);
          when(
            () => mockGoogleSignInAccount.authentication,
          ).thenAnswer((_) async => mockGoogleSignInAuthentication);
          when(
            () => mockGoogleSignInAuthentication.accessToken,
          ).thenReturn('token');
          when(
            () => mockGoogleSignInAuthentication.idToken,
          ).thenReturn('token');
          when(() => mockFirebaseAuth.signInWithCredential(any())).thenThrow(
            firebase_auth.FirebaseAuthException(code: 'auth/unknown'),
          );
          expect(
            () async => htAuthenticationFirebase.signInWithGoogle(),
            throwsA(isA<GoogleSignInException>()),
          );
        },
      );

      test('should throw GoogleSignInException on generic exception', () async {
        final mockGoogleSignInAccount = MockGoogleSignInAccount();
        final mockGoogleSignInAuthentication = MockGoogleSignInAuthentication();

        when(
          () => mockGoogleSignIn.signIn(),
        ).thenAnswer((_) async => mockGoogleSignInAccount);
        when(
          () => mockGoogleSignInAccount.authentication,
        ).thenAnswer((_) async => mockGoogleSignInAuthentication);
        when(
          () => mockGoogleSignInAuthentication.accessToken,
        ).thenReturn('token');
        when(() => mockGoogleSignInAuthentication.idToken).thenReturn('token');

        when(
          () => mockFirebaseAuth.signInWithCredential(any()),
        ).thenThrow(Exception('Unknown error'));

        expect(
          () async => htAuthenticationFirebase.signInWithGoogle(),
          throwsA(isA<GoogleSignInException>()),
        );
      });
    });

    group('signOut', () {
      test('should sign out successfully', () async {
        when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});
        when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async {
          return null;
        });

        await htAuthenticationFirebase.signOut();

        verify(() => mockFirebaseAuth.signOut()).called(1);
        verify(() => mockGoogleSignIn.signOut()).called(1);
      });

      test('should throw LogoutException on FirebaseAuthException', () async {
        when(
          () => mockFirebaseAuth.signOut(),
        ).thenThrow(firebase_auth.FirebaseAuthException(code: 'auth/unknown'));
        when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async {
          return null;
        });

        try {
          await htAuthenticationFirebase.signOut();
        } on LogoutException catch (e) {
          expect(e, isA<LogoutException>());
          return;
        }
        fail('LogoutException not thrown');
      });

      test('should throw LogoutException on generic exception', () async {
        when(
          () => mockFirebaseAuth.signOut(),
        ).thenThrow(Exception('Unknown error'));
        when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async {
          return null;
        });

        try {
          await htAuthenticationFirebase.signOut();
        } on LogoutException catch (e) {
          expect(e, isA<LogoutException>());
          return;
        }
        fail('LogoutException not thrown');
      });
      test(
        'should throw LogoutException on Google Sign Out Exception',
        () async {
          when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});
          when(
            () => mockGoogleSignIn.signOut(),
          ).thenThrow(Exception('Unknown error'));

          try {
            await htAuthenticationFirebase.signOut();
          } on LogoutException catch (e) {
            expect(e, isA<LogoutException>());
            return;
          }
          fail('LogoutException not thrown');
        },
      );
    });
    group('user', () {
      test('should return a stream of User objects', () {
        final mockFirebaseUser = MockUser();
        final mockUserMetadata = MockUserMetadata();

        when(
          () => mockFirebaseAuth.authStateChanges(),
        ).thenAnswer((_) => Stream.value(mockFirebaseUser));
        when(() => mockFirebaseUser.uid).thenReturn('uid');
        when(() => mockFirebaseUser.email).thenReturn('email');
        when(() => mockFirebaseUser.displayName).thenReturn('displayName');
        when(() => mockFirebaseUser.photoURL).thenReturn('photoUrl');
        when(() => mockFirebaseUser.isAnonymous).thenReturn(false);
        when(() => mockFirebaseUser.emailVerified).thenReturn(true);
        when(() => mockFirebaseUser.metadata).thenReturn(mockUserMetadata);
        final now = DateTime.now();
        when(
          () => mockUserMetadata.creationTime,
        ).thenReturn(now.subtract(const Duration(seconds: 1)));
        when(() => mockUserMetadata.lastSignInTime).thenReturn(now);

        expect(
          htAuthenticationFirebase.user,
          emitsInOrder([
            isA<User>()
                .having((u) => u.uid, 'uid', 'uid')
                .having((u) => u.email, 'email', 'email')
                .having((u) => u.displayName, 'displayName', 'displayName')
                .having((u) => u.photoUrl, 'photoUrl', 'photoUrl')
                .having(
                  (u) => u.authenticationStatus,
                  'authenticationStatus',
                  AuthenticationStatus.authenticated,
                )
                .having((u) => u.isEmailVerified, 'isEmailVerified', true)
                .having((u) => u.isNewUser, 'isNewUser', false),
          ]),
        );
      });

      test(
        'should return a User object with authenticationStatus unauthenticated when firebaseUser is null',
        () {
          when(
            () => mockFirebaseAuth.authStateChanges(),
          ).thenAnswer((_) => Stream.value(null));

          expect(
            htAuthenticationFirebase.user,
            emits(
              isA<User>().having(
                (u) => u.authenticationStatus,
                'authenticationStatus',
                AuthenticationStatus.unauthenticated,
              ),
            ),
          );
        },
      );

      test(
        'should return a User object with isNewUser false when creationTime and lastSignInTime are different',
        () {
          final mockFirebaseUser = MockUser();
          final mockUserMetadata = MockUserMetadata();
          final now = DateTime.now();

          when(
            () => mockFirebaseAuth.authStateChanges(),
          ).thenAnswer((_) => Stream.value(mockFirebaseUser));
          when(() => mockFirebaseUser.uid).thenReturn('uid');
          when(() => mockFirebaseUser.email).thenReturn('email');
          when(() => mockFirebaseUser.displayName).thenReturn('displayName');
          when(() => mockFirebaseUser.photoURL).thenReturn('photoUrl');
          when(() => mockFirebaseUser.isAnonymous).thenReturn(false);
          when(() => mockFirebaseUser.emailVerified).thenReturn(true);
          when(() => mockFirebaseUser.metadata).thenReturn(mockUserMetadata);
          when(
            () => mockUserMetadata.creationTime,
          ).thenReturn(now.subtract(const Duration(days: 1)));
          when(() => mockUserMetadata.lastSignInTime).thenReturn(now);

          expect(
            htAuthenticationFirebase.user,
            emitsInOrder([
              isA<User>()
                  .having((u) => u.uid, 'uid', 'uid')
                  .having((u) => u.email, 'email', 'email')
                  .having((u) => u.displayName, 'displayName', 'displayName')
                  .having((u) => u.photoUrl, 'photoUrl', 'photoUrl')
                  .having(
                    (u) => u.authenticationStatus,
                    'authenticationStatus',
                    AuthenticationStatus.authenticated,
                  )
                  .having((u) => u.isEmailVerified, 'isEmailVerified', true)
                  .having((u) => u.isNewUser, 'isNewUser', false),
            ]),
          );
        },
      );
    });
  });
}
