# ht_authentication_firebase

Firebase implementation of the `ht_authentication_client` interface. This package provides a concrete implementation of authentication functionalities using Firebase services.

## Features

This package supports the following authentication methods:

*   **Anonymous Sign-In:** Allows users to access your app without creating an account.
*   **Email/Password Sign-In:** Enables users to sign in using their email address and password.
*   **Google Sign-In:** Integrates with Google Sign-In for a seamless authentication experience.
*   **Sign Out:** Provides functionality for users to sign out of their accounts.
*   **Account Deletion:** Allows users to delete their accounts.
*   **User Stream:** Get the current user in real time.

## Getting Started

### Prerequisites

Before using this package, you need to have a Firebase project set up and configured for your Flutter application. Follow the instructions on the [Firebase website](https://firebase.google.com/docs/flutter/setup) to set up your project.

### Installation

Add `ht_authentication_firebase` as a dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  ht_authentication_firebase:
    git:
      url: https://github.com/headlines-toolkit/ht-authentication-firebase.git
      ref: main
```
Then, run `flutter pub get` to install the package.

### Usage
Import the package:

```dart
import 'package:ht_authentication_firebase/ht_authentication_firebase.dart';
```
Create an instance of `HtAuthenticationFirebase`:

```dart
final authenticationClient = HtAuthenticationFirebase();
```
You can optionally provide instances of `FirebaseAuth` and `GoogleSignIn` to the constructor:

```dart
final authenticationClient = HtAuthenticationFirebase(
  firebaseAuth: FirebaseAuth.instance,
  googleSignIn: GoogleSignIn(),
);
```

Use the methods provided by the `HtAuthenticationFirebase` class to perform authentication actions:
```dart
// Sign in anonymously
await authenticationClient.signInAnonymously();

// Sign in with email and password
await authenticationClient.signInWithEmailAndPassword(
  email: 'user@example.com',
  password: 'your_password',
);

// Sign in with Google
await authenticationClient.signInWithGoogle();

// Sign out
await authenticationClient.signOut();

// Delete Account
await authenticationClient.deleteAccount();

// Get the User Stream
authenticationClient.user.listen((user){
  print(user);
});
```

## Error Handling

The `HtAuthenticationFirebase` class throws custom exceptions for different error scenarios:

*   `AnonymousLoginException`: Thrown when anonymous sign-in fails.
*   `EmailSignInException`: Thrown when email/password sign-in fails.
*   `GoogleSignInException`: Thrown when Google Sign-In fails.
*   `LogoutException`: Thrown when sign-out fails.
*  `DeleteAccountException`: Thrown when account deletion fails.

You should handle these exceptions appropriately in your application.

## Example
```dart
import 'package:ht_authentication_firebase/ht_authentication_firebase.dart';
import 'package:ht_authentication_client/ht_authentication_client.dart';

void main() async {
  final authenticationClient = HtAuthenticationFirebase();

  try {
    // Example: Sign in anonymously
    await authenticationClient.signInAnonymously();
    print('Signed in anonymously');

    // Example: Get the user stream
     authenticationClient.user.listen((User user) {
      if (user.isAnonymous) {
        print('User is anonymous');
      } else {
        print('User ID: ${user.uid}');
        print('Email: ${user.email}');
      }
    });

  } on AnonymousLoginException catch (e) {
    print('Anonymous sign-in failed: ${e.cause}');
  }
}
```