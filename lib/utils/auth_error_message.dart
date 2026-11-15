import '../l10n/app_localizations.dart';

// Turns a FirebaseAuthException code (e.g. 'invalid-email') into a text
// the user can understand.
String authErrorMessage(AppLocalizations texts, String code) {
  switch (code) {
    case 'invalid-email':
      return texts.authErrorInvalidEmail;
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return texts.authErrorWrongCredentials;
    case 'email-already-in-use':
      return texts.authErrorEmailInUse;
    case 'weak-password':
      return texts.authErrorWeakPassword;
    case 'network-request-failed':
      return texts.authErrorNetwork;
    case 'too-many-requests':
      return texts.authErrorTooManyRequests;
    default:
      return texts.authErrorUnknown;
  }
}
