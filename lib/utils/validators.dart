import '../l10n/app_localizations.dart';

// Form field checks shared by the sign-in and sign-up screens.
// Each function returns an error text, or null when the value is fine.

String? validateName(AppLocalizations texts, String? value) {
  if (value == null || value.trim().isEmpty) {
    return texts.nameRequired;
  }
  return null;
}

String? validateEmail(AppLocalizations texts, String? value) {
  if (value == null || value.trim().isEmpty) {
    return texts.emailRequired;
  }
  if (!value.contains('@')) {
    return texts.emailInvalid;
  }
  return null;
}

String? validatePassword(AppLocalizations texts, String? value) {
  if (value == null || value.isEmpty) {
    return texts.passwordRequired;
  }
  if (value.length < 6) {
    return texts.passwordTooShort;
  }
  return null;
}
