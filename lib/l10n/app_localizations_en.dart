// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CoTab';

  @override
  String get homeWelcome => 'Welcome to CoTab!';

  @override
  String get homeNoGroups => 'You are not in any group yet.';

  @override
  String get signInTitle => 'Sign in';

  @override
  String get signUpTitle => 'Create an account';

  @override
  String get signUpButton => 'Sign up';

  @override
  String get noAccountSignUp => 'Don\'t have an account? Sign up';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String passwordResetSent(String email) {
    return 'We sent a password reset email to $email.';
  }

  @override
  String get signOutTooltip => 'Sign out';

  @override
  String get nameLabel => 'Name';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get nameRequired => 'Please enter your name.';

  @override
  String get emailRequired => 'Please enter your email.';

  @override
  String get emailInvalid => 'Please enter a valid email.';

  @override
  String get passwordRequired => 'Please enter your password.';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters.';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match.';

  @override
  String get authErrorInvalidEmail => 'This email address is not valid.';

  @override
  String get authErrorWrongCredentials => 'Email or password is wrong.';

  @override
  String get authErrorEmailInUse =>
      'An account with this email already exists.';

  @override
  String get authErrorWeakPassword => 'This password is too weak.';

  @override
  String get authErrorNetwork => 'No internet connection. Please try again.';

  @override
  String get authErrorTooManyRequests =>
      'Too many attempts. Please wait a bit and try again.';

  @override
  String get authErrorUnknown => 'Something went wrong. Please try again.';

  @override
  String get homeCreateGroup => 'New group';

  @override
  String get joinGroupTitle => 'Join a group';

  @override
  String get createGroupTitle => 'Create a group';

  @override
  String get groupNameLabel => 'Group name';

  @override
  String get groupNameRequired => 'Please enter a group name.';

  @override
  String get groupTypeLabel => 'What kind of group is it?';

  @override
  String get groupTypeHome => 'Home';

  @override
  String get groupTypeTrip => 'Trip';

  @override
  String get createGroupButton => 'Create';

  @override
  String get inviteCodeLabel => 'Invite code';

  @override
  String get inviteCodeInvalidLength => 'Please enter the 6-character code.';

  @override
  String get joinGroupHint => 'Ask someone in the group for the invite code.';

  @override
  String get joinGroupButton => 'Join';

  @override
  String get joinErrorInvalidCode => 'No group found with this code.';

  @override
  String get errorNoInternet => 'No internet connection. Please try again.';

  @override
  String get errorUnknown => 'Something went wrong. Please try again.';

  @override
  String get inviteCodeShareHint => 'Share this code so your friends can join.';

  @override
  String get inviteCodeCopy => 'Copy code';

  @override
  String get inviteCodeCopied => 'Invite code copied.';

  @override
  String get membersTitle => 'Members';

  @override
  String get memberRoleAdmin => 'Admin';

  @override
  String get expensesPlaceholder => 'Expenses will appear here soon.';
}
