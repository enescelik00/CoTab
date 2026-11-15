# CoTab — Ekip Notları

Son güncelleme: 15 Kasım 2026 · Ahmet Anıl Çay

## Bu doküman ne?

Enes Çelik ve Enes Yahya için: benim modülümden (Firebase, giriş, gruplar, senkron) sizin bilmeniz gerekenler.

Kodlar şu PR'larda. Her biri bir öncekinin üzerine kurulu, bu yüzden sırayla incelenip merge edilecek:

`feature/firebase-setup` → `feature/auth` → `feature/groups` → `feature/sync`

PR'ları en alttan başlayarak, yani `feature/firebase-setup`'tan itibaren inceleyin.

## Kurulum (herkes bir kez yapmalı)

### Flutter

`.metadata`'daki revizyon Flutter **3.41.1** (stable). Farklı sürüm `pubspec.lock`'u değiştiriyor ve yeni sürümler `material.dart` için uyarı veriyor. Herkes 3.41.1 kullansın: Flutter SDK klasöründe `git checkout 3.41.1` yapın ya da 3.41.1'i indirin.

### Java

Android Studio'nun içindeki Java 25, projedeki Gradle 8.14 ile çalışmıyor. JDK 21 kurun (ör. `winget install Microsoft.OpenJDK.21`) ve şunu çalıştırın:

```bash
flutter config --jdk-dir "<JDK 21 klasörü>"
```

### Kotlin

Firebase Auth'un Android kütüphanesi Kotlin 2.4 istiyor. Bu yüzden `feature/firebase-setup` PR'ında:

- `android/settings.gradle.kts`'te Kotlin eklentisi 2.4.21'e yükseltildi.
- `android/app/build.gradle.kts`'teki `kotlinOptions` bloğu yeni `kotlin { compilerOptions { ... } }` yazımına geçirildi.

### Firebase

Proje: `cotab-7a4dc`. İkiniz de **Editor** olarak eklendiniz (Firebase'e girdiğiniz Gmail hesaplarıyla). Adımlar:

```bash
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
flutterfire configure --project=cotab-7a4dc --platforms=android
```

Son komut `android/app/google-services.json` ve `lib/firebase_options.dart` dosyalarını üretir. İkisi de `.gitignore`'da, **asla commit'lemeyin**. Bu dosyalar olmadan uygulama derlenmez. iOS henüz yapılandırılmadı.

Firestore güvenlik kuralı: yalnızca giriş yapmış kullanıcılar okuyup yazabiliyor (`allow read, write: if request.auth != null;`). Firestore konumu `eur3`.

## Veri ve senkron kuralları

Bu kısım en önemlisi.

- Uygulama hep SQLite'tan okur ve yazar. Firestore yalnızca veriyi diğer üyelere taşır.
- Her Firestore dokümanı SQLite satırının **birebir aynısı**: aynı snake_case alanlar (`id` dahil), koleksiyon adı = tablo adı, doküman id = satır id. Modelin `toMap()` / `fromMap()` metotları hem SQLite hem Firestore için kullanılır.
- Senkronlanan her tabloda `group_id`, `updated_at` ve `deleted_at` olmalı. `expense_items` ve `expense_shares` da kendi `group_id` sütununu taşımalı, yoksa grup bazında indirilemezler.
- Para her zaman `int` kuruş.
- Okurken her sorguda `WHERE deleted_at IS NULL`.
- Çakışmada "son yazan kazanır": `updated_at` büyük olan satır kazanır.

Kayıt eklerken veya değiştirirken `updated_at = DateTime.now().millisecondsSinceEpoch` yazın. Silmek için `deleted_at` doldurulur (`DELETE` yok). Sonra:

```dart
await SyncService.saveRow('expenses', expense.toMap());
```

Bu çağrı satırı SQLite'a yazar, `sync_queue`'ya ekler, internet varsa hemen Firestore'a yollar, yoksa sonra yollar.

Diğer telefonların tabloyu indirebilmesi için tablo adını `SyncService.groupTables` listesine ekleyin (`lib/services/sync_service.dart`).

## Veritabanı sürümleri

| Sürüm | Tablolar | Kim |
| --- | --- | --- |
| 1 | `users`, `groups` | İskelet |
| 2 | `group_members`, `sync_queue` | Ahmet Anıl |
| 3 | `expenses`, `expense_items`, `expense_shares`, sonra `settlements` | Enes Çelik |

Sürüm 3 için `lib/services/database_helper.dart`'ta:

- `_databaseVersion = 3` yapın.
- `_upgradeTables` içine `if (oldVersion < 3) { ... }` bloğunu ekleyin.
- Aynı tabloları `_createTables`'a da ekleyin.

İki kişi aynı anda sürüm artırmasın diye harcama tabloları `feature/sync` merge edildikten sonra (ya da onun üzerine) eklenmeli.

## Hazır kullanabileceğiniz kodlar

| Ne | Nerede | Not |
| --- | --- | --- |
| `AuthService.currentUserId` | `lib/services/auth_service.dart` | Giriş yapan kullanıcının uid'i |
| `GroupService.getMyGroups()` | `lib/services/group_service.dart` | Kullanıcının grupları, SQLite'tan |
| `GroupService.getMembers(groupId)` | `lib/services/group_service.dart` | Üyelerin adı ve rolü; bölüştürme ekranında kişileri listelemek için |
| `SyncService.saveRow(...)`, `SyncService.pullGroup(groupId)`, `SyncService.syncAll()` | `lib/services/sync_service.dart` | Kaydetme ve senkron |
| `GroupDetailScreen` | `lib/screens/group_detail_screen.dart` | Harcamalar için yer tutucu metin var (`expensesPlaceholder`); Enes Çelik harcama listesini buraya koyabilir |
| `CoTabApp(home: ...)`, `HomeScreen(groupLoader: ...)` | `lib/main.dart`, `lib/screens/` | Testlerde Firebase'e dokunmamak için parametreler |

## İş bölümü hatırlatması

- **Enes Çelik:** harcama tabloları (sürüm 3), harcama ekleme, bölüştürme, bakiye. Kayıtlar `saveRow` ile yapılır.
- **Enes Yahya:** kamera ve OCR. Fiş görselleri yalnızca telefonda kalıyor, Firestore'a sadece tutar ve kalemler gider.

Sorularınız için bana (Ahmet Anıl) yazın.
