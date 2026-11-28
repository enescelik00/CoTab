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
  String get appTagline =>
      'Ortak harcamalar, alışveriş ve ev işleri tek yerde.';

  @override
  String get darkModeTooltip => 'Koyu mod';

  @override
  String get lightModeTooltip => 'Açık mod';

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
  String get addExpenseTitle => 'Harcama ekle';

  @override
  String get expenseTitleLabel => 'Başlık';

  @override
  String get expenseTitleRequired => 'Lütfen bir başlık yaz.';

  @override
  String get amountLabel => 'Tutar (₺)';

  @override
  String get amountInvalid => 'Lütfen geçerli bir tutar yaz, ör. 250,50.';

  @override
  String get paidByLabel => 'Ödeyen';

  @override
  String get categoryLabel => 'Kategori';

  @override
  String get categoryFood => 'Yemek ve market';

  @override
  String get categoryRent => 'Kira';

  @override
  String get categoryBills => 'Faturalar';

  @override
  String get categoryTransport => 'Ulaşım';

  @override
  String get categoryOther => 'Diğer';

  @override
  String get expenseDateLabel => 'Tarih';

  @override
  String get splitLabel => 'Nasıl bölüşülsün?';

  @override
  String get splitEqual => 'Eşit';

  @override
  String get splitPercentage => 'Yüzde';

  @override
  String get splitExact => 'Tutar';

  @override
  String splitPercentTotal(int total) {
    return 'Toplam: %$total / %100';
  }

  @override
  String splitExactTotal(String total, String amount) {
    return 'Toplam: $total / $amount';
  }

  @override
  String get splitErrorNobody => 'En az bir kişi seç.';

  @override
  String get splitErrorPercent => 'Yüzdelerin toplamı 100 olmalı.';

  @override
  String get splitErrorExact =>
      'Tutarların toplamı harcama tutarına eşit olmalı.';

  @override
  String get saveExpenseButton => 'Harcamayı kaydet';

  @override
  String get expensesTitle => 'Harcamalar ve ödemeler';

  @override
  String get expensesDeleteHint => 'Silmek için satıra basılı tut.';

  @override
  String get noExpenses =>
      'Henüz harcama yok. İlkini eklemek için \"Harcama ekle\"ye dokun.';

  @override
  String expensePaidBy(String name, String date) {
    return '$name ödedi · $date';
  }

  @override
  String get unknownMember => 'Bilinmeyen';

  @override
  String balanceGetsBack(String amount) {
    return '$amount alacaklı';
  }

  @override
  String balanceOwes(String amount) {
    return '$amount borçlu';
  }

  @override
  String get balanceSettled => 'hesap kapalı';

  @override
  String get deleteExpenseTitle => 'Bu harcama silinsin mi?';

  @override
  String deleteExpenseMessage(String title) {
    return '\"$title\" gruptaki herkes için silinecek.';
  }

  @override
  String get deleteButton => 'Sil';

  @override
  String get cancelButton => 'Vazgeç';

  @override
  String get expenseDeleted => 'Harcama silindi.';

  @override
  String get scanReceiptTitle => 'Fiş tara';

  @override
  String get receiptCameraHint =>
      'Fişin fotoğrafını çek veya galeriden seçip metnini okumayı dene.';

  @override
  String get receiptTakePhoto => 'Fotoğraf çek';

  @override
  String get receiptChooseFromGallery => 'Galeriden seç';

  @override
  String get receiptChooseAnother => 'Başka fotoğraf seç';

  @override
  String get receiptGalleryPermissionError =>
      'Fotoğraf izni verilmedi. Cihaz ayarlarından izin verip tekrar dene.';

  @override
  String get receiptGalleryUnavailable =>
      'Fotoğraf galerisi açılamadı. Lütfen tekrar dene.';

  @override
  String get receiptCameraPermissionError =>
      'Kamera izni verilmedi. Cihaz ayarlarından izin verip tekrar dene.';

  @override
  String get receiptCameraUnavailable =>
      'Kamera açılamadı. Cihazın kamerasını kontrol edip tekrar dene.';

  @override
  String get receiptPreviewTitle => 'Fiş fotoğrafı';

  @override
  String get receiptImageError =>
      'Fotoğraf gösterilemedi. Lütfen başka bir fotoğraf seç veya yeniden çek.';

  @override
  String get receiptRetake => 'Yeniden çek';

  @override
  String get receiptReadText => 'Metni oku';

  @override
  String get receiptOcrError => 'Fiş metni okunamadı. Lütfen tekrar dene.';

  @override
  String get receiptRecognizedText => 'Okunan metin';

  @override
  String get receiptNoText =>
      'Metin bulunamadı. Daha net bir fotoğrafla tekrar dene.';

  @override
  String get settleUpTitle => 'Hesaplaşma';

  @override
  String get settleUpHint => 'Herkesin hesabını en az ödemeyle kapatır.';

  @override
  String get allSettledUp => 'Herkesin hesabı kapalı.';

  @override
  String get markAsPaid => 'Ödendi';

  @override
  String get recordPaymentTitle => 'Ödemeyi kaydet';

  @override
  String paymentTooHigh(String amount) {
    return 'Tutar en fazla $amount olabilir.';
  }

  @override
  String get saveButton => 'Kaydet';

  @override
  String get paymentSaved => 'Ödeme kaydedildi.';

  @override
  String paymentLabel(String date) {
    return 'Ödeme · $date';
  }

  @override
  String get deletePaymentTitle => 'Bu ödeme silinsin mi?';

  @override
  String get deletePaymentMessage =>
      'Bakiyeler bu ödemeden önceki haline döner.';

  @override
  String get paymentDeleted => 'Ödeme silindi.';

  @override
  String get offlineShowingSavedData =>
      'Çevrimdışısın — kayıtlı veriler gösteriliyor';
}
