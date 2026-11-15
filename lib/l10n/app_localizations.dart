import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// The name of the app, shown in the app bar.
  ///
  /// In en, this message translates to:
  /// **'CoTab'**
  String get appTitle;

  /// Greeting shown on the home screen.
  ///
  /// In en, this message translates to:
  /// **'Welcome to CoTab!'**
  String get homeWelcome;

  /// Shown on the home screen when the user has no groups.
  ///
  /// In en, this message translates to:
  /// **'You are not in any group yet.'**
  String get homeNoGroups;

  /// Title of the sign-in screen and text of its button.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInTitle;

  /// Title of the sign-up screen.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get signUpTitle;

  /// Button that creates a new account.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUpButton;

  /// Link on the sign-in screen that opens the sign-up screen.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get noAccountSignUp;

  /// Link on the sign-in screen that sends a password reset email.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// Shown after the password reset email was sent.
  ///
  /// In en, this message translates to:
  /// **'We sent a password reset email to {email}.'**
  String passwordResetSent(String email);

  /// Tooltip of the sign-out button in the home screen app bar.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOutTooltip;

  /// Label of the name field.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// Label of the email field.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Label of the password field.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// Label of the field where the password is typed a second time.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// Validation error when the name field is empty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name.'**
  String get nameRequired;

  /// Validation error when the email field is empty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email.'**
  String get emailRequired;

  /// Validation error when the email has no @.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email.'**
  String get emailInvalid;

  /// Validation error when the password field is empty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password.'**
  String get passwordRequired;

  /// Validation error when the password is shorter than 6 characters.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get passwordTooShort;

  /// Validation error when the two passwords are different.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// Firebase error: invalid-email.
  ///
  /// In en, this message translates to:
  /// **'This email address is not valid.'**
  String get authErrorInvalidEmail;

  /// Firebase error: user-not-found, wrong-password or invalid-credential.
  ///
  /// In en, this message translates to:
  /// **'Email or password is wrong.'**
  String get authErrorWrongCredentials;

  /// Firebase error: email-already-in-use.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists.'**
  String get authErrorEmailInUse;

  /// Firebase error: weak-password.
  ///
  /// In en, this message translates to:
  /// **'This password is too weak.'**
  String get authErrorWeakPassword;

  /// Firebase error: network-request-failed.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please try again.'**
  String get authErrorNetwork;

  /// Firebase error: too-many-requests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a bit and try again.'**
  String get authErrorTooManyRequests;

  /// Shown for any other sign-in or sign-up error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get authErrorUnknown;

  /// Floating button on the home screen that opens the create group screen.
  ///
  /// In en, this message translates to:
  /// **'New group'**
  String get homeCreateGroup;

  /// Title of the join group screen and tooltip of its button on the home screen.
  ///
  /// In en, this message translates to:
  /// **'Join a group'**
  String get joinGroupTitle;

  /// Title of the create group screen.
  ///
  /// In en, this message translates to:
  /// **'Create a group'**
  String get createGroupTitle;

  /// Label of the group name field.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupNameLabel;

  /// Validation error when the group name is empty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a group name.'**
  String get groupNameRequired;

  /// Label above the home/trip choice.
  ///
  /// In en, this message translates to:
  /// **'What kind of group is it?'**
  String get groupTypeLabel;

  /// Group type for people who live together.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get groupTypeHome;

  /// Group type for people who travel together.
  ///
  /// In en, this message translates to:
  /// **'Trip'**
  String get groupTypeTrip;

  /// Button that creates the group.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createGroupButton;

  /// Label of the invite code field and title of the invite code card.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get inviteCodeLabel;

  /// Validation error when the invite code is not 6 characters long.
  ///
  /// In en, this message translates to:
  /// **'Please enter the 6-character code.'**
  String get inviteCodeInvalidLength;

  /// Hint on the join group screen.
  ///
  /// In en, this message translates to:
  /// **'Ask someone in the group for the invite code.'**
  String get joinGroupHint;

  /// Button that joins the group with the typed code.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get joinGroupButton;

  /// Shown when no group has the typed invite code.
  ///
  /// In en, this message translates to:
  /// **'No group found with this code.'**
  String get joinErrorInvalidCode;

  /// Shown when an action needs internet and there is none.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please try again.'**
  String get errorNoInternet;

  /// Shown for any other error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorUnknown;

  /// Text under the invite code on the group screen.
  ///
  /// In en, this message translates to:
  /// **'Share this code so your friends can join.'**
  String get inviteCodeShareHint;

  /// Tooltip of the button that copies the invite code.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get inviteCodeCopy;

  /// Shown after the invite code was copied.
  ///
  /// In en, this message translates to:
  /// **'Invite code copied.'**
  String get inviteCodeCopied;

  /// Title of the member list on the group screen.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get membersTitle;

  /// Label next to the name of the group admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get memberRoleAdmin;

  /// Placeholder on the group screen until the expenses module is ready.
  ///
  /// In en, this message translates to:
  /// **'Expenses will appear here soon.'**
  String get expensesPlaceholder;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
