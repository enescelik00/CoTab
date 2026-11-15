// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'CoTab';

  @override
  String get homeWelcome => 'CoTab\'e hoş geldin!';

  @override
  String get homeNoGroups => 'Henüz hiçbir gruba üye değilsin.';

  @override
  String get signInTitle => 'Giriş yap';

  @override
  String get signUpTitle => 'Hesap oluştur';

  @override
  String get signUpButton => 'Kayıt ol';

  @override
  String get noAccountSignUp => 'Hesabın yok mu? Kayıt ol';

  @override
  String get forgotPassword => 'Şifreni mi unuttun?';

  @override
  String passwordResetSent(String email) {
    return '$email adresine şifre sıfırlama e-postası gönderdik.';
  }

  @override
  String get signOutTooltip => 'Çıkış yap';

  @override
  String get nameLabel => 'Ad';

  @override
  String get emailLabel => 'E-posta';

  @override
  String get passwordLabel => 'Şifre';

  @override
  String get confirmPasswordLabel => 'Şifreyi tekrar gir';

  @override
  String get nameRequired => 'Lütfen adını yaz.';

  @override
  String get emailRequired => 'Lütfen e-posta adresini yaz.';

  @override
  String get emailInvalid => 'Lütfen geçerli bir e-posta adresi yaz.';

  @override
  String get passwordRequired => 'Lütfen şifreni yaz.';

  @override
  String get passwordTooShort => 'Şifre en az 6 karakter olmalı.';

  @override
  String get passwordsDoNotMatch => 'Şifreler eşleşmiyor.';

  @override
  String get authErrorInvalidEmail => 'Bu e-posta adresi geçerli değil.';

  @override
  String get authErrorWrongCredentials => 'E-posta ya da şifre yanlış.';

  @override
  String get authErrorEmailInUse => 'Bu e-posta adresiyle zaten bir hesap var.';

  @override
  String get authErrorWeakPassword => 'Bu şifre çok zayıf.';

  @override
  String get authErrorNetwork => 'İnternet bağlantısı yok. Lütfen tekrar dene.';

  @override
  String get authErrorTooManyRequests =>
      'Çok fazla deneme yapıldı. Biraz bekleyip tekrar dene.';

  @override
  String get authErrorUnknown => 'Bir şeyler ters gitti. Lütfen tekrar dene.';

  @override
  String get homeCreateGroup => 'Yeni grup';

  @override
  String get joinGroupTitle => 'Gruba katıl';

  @override
  String get createGroupTitle => 'Grup oluştur';

  @override
  String get groupNameLabel => 'Grup adı';

  @override
  String get groupNameRequired => 'Lütfen grup adını yaz.';

  @override
  String get groupTypeLabel => 'Ne tür bir grup?';

  @override
  String get groupTypeHome => 'Ev';

  @override
  String get groupTypeTrip => 'Seyahat';

  @override
  String get createGroupButton => 'Oluştur';

  @override
  String get inviteCodeLabel => 'Davet kodu';

  @override
  String get inviteCodeInvalidLength => 'Lütfen 6 karakterlik kodu yaz.';

  @override
  String get joinGroupHint => 'Davet kodunu gruptaki birinden iste.';

  @override
  String get joinGroupButton => 'Katıl';

  @override
  String get joinErrorInvalidCode => 'Bu kodla bir grup bulunamadı.';

  @override
  String get errorNoInternet => 'İnternet bağlantısı yok. Lütfen tekrar dene.';

  @override
  String get errorUnknown => 'Bir şeyler ters gitti. Lütfen tekrar dene.';

  @override
  String get inviteCodeShareHint =>
      'Arkadaşların katılabilsin diye bu kodu paylaş.';

  @override
  String get inviteCodeCopy => 'Kodu kopyala';

  @override
  String get inviteCodeCopied => 'Davet kodu kopyalandı.';

  @override
  String get membersTitle => 'Üyeler';

  @override
  String get memberRoleAdmin => 'Yönetici';

  @override
  String get expensesPlaceholder => 'Harcamalar yakında burada görünecek.';
}
