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

  /// Short sentence under the app name on the sign-in screen.
  ///
  /// In en, this message translates to:
  /// **'Shared expenses, shopping and chores in one place.'**
  String get appTagline;

  /// Tooltip of the home screen button that switches to dark mode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkModeTooltip;

  /// Tooltip of the home screen button that switches to light mode.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get lightModeTooltip;

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

  /// Title of the add expense screen and label of its button on the group screen.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get addExpenseTitle;

  /// Label of the expense title field, e.g. 'Migros'.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get expenseTitleLabel;

  /// Validation error when the expense title is empty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title.'**
  String get expenseTitleRequired;

  /// Label of the amount field.
  ///
  /// In en, this message translates to:
  /// **'Amount (₺)'**
  String get amountLabel;

  /// Validation error when the amount is empty, zero or not a number.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount, e.g. 250,50.'**
  String get amountInvalid;

  /// Label of the field that chooses who paid.
  ///
  /// In en, this message translates to:
  /// **'Paid by'**
  String get paidByLabel;

  /// Label of the category field.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// Expense category.
  ///
  /// In en, this message translates to:
  /// **'Food & groceries'**
  String get categoryFood;

  /// Expense category.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get categoryRent;

  /// Expense category: electricity, water, internet...
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get categoryBills;

  /// Expense category.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get categoryTransport;

  /// Expense category.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// Label of the expense date field.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get expenseDateLabel;

  /// Label above the equal / percentage / amount choice.
  ///
  /// In en, this message translates to:
  /// **'How should it be split?'**
  String get splitLabel;

  /// Split type: everybody pays the same.
  ///
  /// In en, this message translates to:
  /// **'Equal'**
  String get splitEqual;

  /// Split type: everybody pays a percentage.
  ///
  /// In en, this message translates to:
  /// **'Percent'**
  String get splitPercentage;

  /// Split type: everybody pays a typed amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get splitExact;

  /// Shown under the percentage fields.
  ///
  /// In en, this message translates to:
  /// **'Total: {total}% of 100%'**
  String splitPercentTotal(int total);

  /// Shown under the amount fields. Both values are formatted money.
  ///
  /// In en, this message translates to:
  /// **'Total: {total} of {amount}'**
  String splitExactTotal(String total, String amount);

  /// Shown when nobody is selected for an equal split.
  ///
  /// In en, this message translates to:
  /// **'Choose at least one person.'**
  String get splitErrorNobody;

  /// Shown when the percentages do not add up to 100.
  ///
  /// In en, this message translates to:
  /// **'The percentages must add up to 100.'**
  String get splitErrorPercent;

  /// Shown when the typed amounts do not add up to the expense amount.
  ///
  /// In en, this message translates to:
  /// **'The amounts must add up to the total.'**
  String get splitErrorExact;

  /// Button that saves the new expense.
  ///
  /// In en, this message translates to:
  /// **'Save expense'**
  String get saveExpenseButton;

  /// Title of the list of expenses and payments on the group screen.
  ///
  /// In en, this message translates to:
  /// **'Expenses and payments'**
  String get expensesTitle;

  /// Small hint under the expenses title.
  ///
  /// In en, this message translates to:
  /// **'Tap an expense to edit it. Press and hold a row to delete it.'**
  String get expensesDeleteHint;

  /// Shown on the group screen when the group has no expenses.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet. Tap \"Add expense\" to add the first one.'**
  String get noExpenses;

  /// Second line of an expense in the list.
  ///
  /// In en, this message translates to:
  /// **'{name} paid · {date}'**
  String expensePaidBy(String name, String date);

  /// Shown instead of a name when the person is not in the group anymore.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownMember;

  /// The others owe this person money.
  ///
  /// In en, this message translates to:
  /// **'gets back {amount}'**
  String balanceGetsBack(String amount);

  /// This person owes money.
  ///
  /// In en, this message translates to:
  /// **'owes {amount}'**
  String balanceOwes(String amount);

  /// This person owes nothing and gets nothing back.
  ///
  /// In en, this message translates to:
  /// **'settled up'**
  String get balanceSettled;

  /// Title of the dialog that confirms deleting an expense.
  ///
  /// In en, this message translates to:
  /// **'Delete this expense?'**
  String get deleteExpenseTitle;

  /// Text of the dialog that confirms deleting an expense.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" will be deleted for everyone in the group.'**
  String deleteExpenseMessage(String title);

  /// Button that confirms a deletion.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// Button that closes a dialog without doing anything.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// Shown after an expense was deleted.
  ///
  /// In en, this message translates to:
  /// **'Expense deleted.'**
  String get expenseDeleted;

  /// No description provided for @scanReceiptTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan receipt'**
  String get scanReceiptTitle;

  /// No description provided for @receiptCameraHint.
  ///
  /// In en, this message translates to:
  /// **'Photograph a receipt or choose a photo to try reading its text.'**
  String get receiptCameraHint;

  /// No description provided for @receiptTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get receiptTakePhoto;

  /// No description provided for @receiptChooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get receiptChooseFromGallery;

  /// No description provided for @receiptChooseAnother.
  ///
  /// In en, this message translates to:
  /// **'Choose another photo'**
  String get receiptChooseAnother;

  /// No description provided for @receiptGalleryPermissionError.
  ///
  /// In en, this message translates to:
  /// **'Photo access is denied. Allow it in your device settings and try again.'**
  String get receiptGalleryPermissionError;

  /// No description provided for @receiptGalleryUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The photo library could not be opened. Please try again.'**
  String get receiptGalleryUnavailable;

  /// No description provided for @receiptCameraPermissionError.
  ///
  /// In en, this message translates to:
  /// **'Camera access is denied. Allow it in your device settings and try again.'**
  String get receiptCameraPermissionError;

  /// No description provided for @receiptCameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The camera could not be opened. Check that your device has a working camera and try again.'**
  String get receiptCameraUnavailable;

  /// No description provided for @receiptPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Receipt photo'**
  String get receiptPreviewTitle;

  /// No description provided for @receiptImageError.
  ///
  /// In en, this message translates to:
  /// **'The photo could not be displayed. Please choose another photo or retake it.'**
  String get receiptImageError;

  /// No description provided for @receiptRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake photo'**
  String get receiptRetake;

  /// No description provided for @receiptReadText.
  ///
  /// In en, this message translates to:
  /// **'Read text'**
  String get receiptReadText;

  /// No description provided for @receiptOcrError.
  ///
  /// In en, this message translates to:
  /// **'The receipt text could not be read. Please try again.'**
  String get receiptOcrError;

  /// No description provided for @receiptRecognizedText.
  ///
  /// In en, this message translates to:
  /// **'Recognized text'**
  String get receiptRecognizedText;

  /// No description provided for @receiptNoText.
  ///
  /// In en, this message translates to:
  /// **'No text was found. Try again with a clearer photo.'**
  String get receiptNoText;

  /// Title of the card with the suggested payments on the group screen.
  ///
  /// In en, this message translates to:
  /// **'Settle up'**
  String get settleUpTitle;

  /// Small hint under the settle up title.
  ///
  /// In en, this message translates to:
  /// **'The fewest payments that settle everybody.'**
  String get settleUpHint;

  /// Shown in the settle up card when nobody owes anything.
  ///
  /// In en, this message translates to:
  /// **'Everybody is settled up.'**
  String get allSettledUp;

  /// Button next to a suggested payment; opens the record payment dialog.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get markAsPaid;

  /// Title of the dialog that saves a payment.
  ///
  /// In en, this message translates to:
  /// **'Record a payment'**
  String get recordPaymentTitle;

  /// Error when the paid amount is higher than the suggested amount.
  ///
  /// In en, this message translates to:
  /// **'The amount can be at most {amount}.'**
  String paymentTooHigh(String amount);

  /// Button that saves a dialog.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// Shown after a payment was saved.
  ///
  /// In en, this message translates to:
  /// **'Payment saved.'**
  String get paymentSaved;

  /// Second line of a payment in the expense list.
  ///
  /// In en, this message translates to:
  /// **'Payment · {date}'**
  String paymentLabel(String date);

  /// Title of the dialog that confirms deleting a payment.
  ///
  /// In en, this message translates to:
  /// **'Delete this payment?'**
  String get deletePaymentTitle;

  /// Text of the dialog that confirms deleting a payment.
  ///
  /// In en, this message translates to:
  /// **'The balances will go back to how they were before this payment.'**
  String get deletePaymentMessage;

  /// Shown after a payment was deleted.
  ///
  /// In en, this message translates to:
  /// **'Payment deleted.'**
  String get paymentDeleted;

  /// Title of the expense screen when an existing expense is edited.
  ///
  /// In en, this message translates to:
  /// **'Edit expense'**
  String get editExpenseTitle;

  /// Button that saves an edited expense.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChangesButton;

  /// Shown after an edited expense was saved.
  ///
  /// In en, this message translates to:
  /// **'Expense updated.'**
  String get expenseUpdated;

  /// Split type: every receipt item is split between the people who had it.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get splitItems;

  /// Button that adds a receipt item in the item split.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addItemButton;

  /// Label of the item name field, e.g. 'Süt 1L'.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get itemNameLabel;

  /// Tooltip of the button that removes an item.
  ///
  /// In en, this message translates to:
  /// **'Remove item'**
  String get removeItemTooltip;

  /// Label above the people chips of an item.
  ///
  /// In en, this message translates to:
  /// **'Who had it?'**
  String get itemWhoHadIt;

  /// Title above what every person pays in the item split.
  ///
  /// In en, this message translates to:
  /// **'Per person'**
  String get itemsPerPerson;

  /// Shown when the item split has no items.
  ///
  /// In en, this message translates to:
  /// **'Add at least one item.'**
  String get splitErrorNoItems;

  /// Shown when an item is not complete.
  ///
  /// In en, this message translates to:
  /// **'Every item needs a name, an amount and at least one person.'**
  String get splitErrorItem;

  /// Shown when the items do not add up to the expense amount.
  ///
  /// In en, this message translates to:
  /// **'The items must add up to the total.'**
  String get splitErrorItemsTotal;

  /// Shown above the group list when the server could not be reached.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline — showing saved data'**
  String get offlineShowingSavedData;
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
