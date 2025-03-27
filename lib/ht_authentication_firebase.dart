/// Firebase implementation of the `ht_authentication_client` interface.
library;

/// Required to configure email link sign-in behavior from within the main app.
export 'package:firebase_auth/firebase_auth.dart' show ActionCodeSettings;

export 'src/ht_authentication_firebase.dart';
