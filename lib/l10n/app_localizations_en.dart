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
  String get appTagline => 'Shared expenses, shopping and chores in one place.';

  @override
  String get darkModeTooltip => 'Dark mode';

  @override
  String get lightModeTooltip => 'Light mode';

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
  String get addExpenseTitle => 'Add expense';

  @override
  String get expenseTitleLabel => 'Title';

  @override
  String get expenseTitleRequired => 'Please enter a title.';

  @override
  String get amountLabel => 'Amount (₺)';

  @override
  String get amountInvalid => 'Please enter a valid amount, e.g. 250,50.';

  @override
  String get paidByLabel => 'Paid by';

  @override
  String get categoryLabel => 'Category';

  @override
  String get categoryFood => 'Food & groceries';

  @override
  String get categoryRent => 'Rent';

  @override
  String get categoryBills => 'Bills';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryOther => 'Other';

  @override
  String get expenseDateLabel => 'Date';

  @override
  String get splitLabel => 'How should it be split?';

  @override
  String get splitEqual => 'Equal';

  @override
  String get splitPercentage => 'Percent';

  @override
  String get splitExact => 'Amount';

  @override
  String splitPercentTotal(int total) {
    return 'Total: $total% of 100%';
  }

  @override
  String splitExactTotal(String total, String amount) {
    return 'Total: $total of $amount';
  }

  @override
  String get splitErrorNobody => 'Choose at least one person.';

  @override
  String get splitErrorPercent => 'The percentages must add up to 100.';

  @override
  String get splitErrorExact => 'The amounts must add up to the total.';

  @override
  String get saveExpenseButton => 'Save expense';

  @override
  String get expensesTitle => 'Expenses and payments';

  @override
  String get expensesDeleteHint =>
      'Tap an expense to edit it. Press and hold a row to delete it.';

  @override
  String get noExpenses =>
      'No expenses yet. Tap \"Add expense\" to add the first one.';

  @override
  String expensePaidBy(String name, String date) {
    return '$name paid · $date';
  }

  @override
  String get unknownMember => 'Unknown';

  @override
  String balanceGetsBack(String amount) {
    return 'gets back $amount';
  }

  @override
  String balanceOwes(String amount) {
    return 'owes $amount';
  }

  @override
  String get balanceSettled => 'settled up';

  @override
  String get deleteExpenseTitle => 'Delete this expense?';

  @override
  String deleteExpenseMessage(String title) {
    return '\"$title\" will be deleted for everyone in the group.';
  }

  @override
  String get deleteButton => 'Delete';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get expenseDeleted => 'Expense deleted.';

  @override
  String get scanReceiptTitle => 'Scan receipt';

  @override
  String get receiptCameraHint =>
      'Photograph a receipt or choose a photo to try reading its text.';

  @override
  String get receiptTakePhoto => 'Take photo';

  @override
  String get receiptChooseFromGallery => 'Choose from gallery';

  @override
  String get receiptChooseAnother => 'Choose another photo';

  @override
  String get receiptGalleryPermissionError =>
      'Photo access is denied. Allow it in your device settings and try again.';

  @override
  String get receiptGalleryUnavailable =>
      'The photo library could not be opened. Please try again.';

  @override
  String get receiptCameraPermissionError =>
      'Camera access is denied. Allow it in your device settings and try again.';

  @override
  String get receiptCameraUnavailable =>
      'The camera could not be opened. Check that your device has a working camera and try again.';

  @override
  String get receiptPreviewTitle => 'Receipt photo';

  @override
  String get receiptImageError =>
      'The photo could not be displayed. Please choose another photo or retake it.';

  @override
  String get receiptRetake => 'Retake photo';

  @override
  String get receiptReadText => 'Read text';

  @override
  String get receiptOcrError =>
      'The receipt text could not be read. Please try again.';

  @override
  String get receiptRecognizedText => 'Recognized text';

  @override
  String get receiptNoText =>
      'No text was found. Try again with a clearer photo.';

  @override
  String get settleUpTitle => 'Settle up';

  @override
  String get settleUpHint => 'The fewest payments that settle everybody.';

  @override
  String get allSettledUp => 'Everybody is settled up.';

  @override
  String get markAsPaid => 'Paid';

  @override
  String get recordPaymentTitle => 'Record a payment';

  @override
  String paymentTooHigh(String amount) {
    return 'The amount can be at most $amount.';
  }

  @override
  String get saveButton => 'Save';

  @override
  String get paymentSaved => 'Payment saved.';

  @override
  String paymentLabel(String date) {
    return 'Payment · $date';
  }

  @override
  String get deletePaymentTitle => 'Delete this payment?';

  @override
  String get deletePaymentMessage =>
      'The balances will go back to how they were before this payment.';

  @override
  String get paymentDeleted => 'Payment deleted.';

  @override
  String get editExpenseTitle => 'Edit expense';

  @override
  String get saveChangesButton => 'Save changes';

  @override
  String get expenseUpdated => 'Expense updated.';

  @override
  String get splitItems => 'Items';

  @override
  String get addItemButton => 'Add item';

  @override
  String get itemNameLabel => 'Item';

  @override
  String get removeItemTooltip => 'Remove item';

  @override
  String get itemWhoHadIt => 'Who had it?';

  @override
  String get itemsPerPerson => 'Per person';

  @override
  String get splitErrorNoItems => 'Add at least one item.';

  @override
  String get splitErrorItem =>
      'Every item needs a name, an amount and at least one person.';

  @override
  String get splitErrorItemsTotal => 'The items must add up to the total.';

  @override
  String get offlineShowingSavedData => 'You\'re offline — showing saved data';
}
