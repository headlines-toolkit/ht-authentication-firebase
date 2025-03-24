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

void main() {
  setUpAll(() {
    registerFallbackValue(FakeAuthCredential());
  });

  group('HtAuthenticationFirebase', () {
    late HtAuthenticationFirebase htAuthenticationFirebase;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockGoogleSignIn mockGoogleSignIn;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockGoogleSignIn = MockGoogleSignIn();
      htAuthenticationFirebase = HtAuthenticationFirebase(
        firebaseAuth: mockFirebaseAuth,
        googleSignIn: mockGoogleSignIn,
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

    group('signInWithEmailAndPassword', () {
      const email = 'test@example.com';
      const password = 'password';
      test('should sign in with email and password successfully', () async {
        final mockUserCredential = MockUserCredential();
        when(
          () => mockFirebaseAuth.signInWithEmailAndPassword(
            email: email,
            password: password,
          ),
        ).thenAnswer((_) async => mockUserCredential);

        await htAuthenticationFirebase.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        verify(
          () => mockFirebaseAuth.signInWithEmailAndPassword(
            email: email,
            password: password,
          ),
        ).called(1);
      });

      test(
        'should throw EmailSignInException on FirebaseAuthException',
        () async {
          when(
            () => mockFirebaseAuth.signInWithEmailAndPassword(
              email: email,
              password: password,
            ),
          ).thenThrow(
            firebase_auth.FirebaseAuthException(code: 'auth/unknown'),
          );

          expect(
            () async => htAuthenticationFirebase.signInWithEmailAndPassword(
              email: email,
              password: password,
            ),
            throwsA(isA<EmailSignInException>()),
          );
        },
      );

      test('should throw EmailSignInException on generic exception', () async {
        when(
          () => mockFirebaseAuth.signInWithEmailAndPassword(
            email: email,
            password: password,
          ),
        ).thenThrow(Exception('Unknown error'));

        expect(
          () async => htAuthenticationFirebase.signInWithEmailAndPassword(
            email: email,
            password: password,
          ),
          throwsA(isA<EmailSignInException>()),
        );
      });
    });

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
        when(() => mockUserMetadata.creationTime).thenReturn(DateTime.now());
        when(() => mockUserMetadata.lastSignInTime).thenReturn(DateTime.now());

        expect(
          htAuthenticationFirebase.user,
          emitsInOrder([
            isA<User>()
                .having((u) => u.uid, 'uid', 'uid')
                .having((u) => u.email, 'email', 'email')
                .having((u) => u.displayName, 'displayName', 'displayName')
                .having((u) => u.photoUrl, 'photoUrl', 'photoUrl')
                .having((u) => u.isAnonymous, 'isAnonymous', false)
                .having((u) => u.isEmailVerified, 'isEmailVerified', true)
                .having((u) => u.isNewUser, 'isNewUser', true),
          ]),
        );
      });

      test(
        'should return a User object with isAnonymous true when firebaseUser is null',
        () {
          when(
            () => mockFirebaseAuth.authStateChanges(),
          ).thenAnswer((_) => Stream.value(null));

          expect(
            htAuthenticationFirebase.user,
            emits(
              isA<User>().having((u) => u.isAnonymous, 'isAnonymous', true),
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
                  .having((u) => u.isAnonymous, 'isAnonymous', false)
                  .having((u) => u.isEmailVerified, 'isEmailVerified', true)
                  .having((u) => u.isNewUser, 'isNewUser', false),
            ]),
          );
        },
      );
    });
  });
}
