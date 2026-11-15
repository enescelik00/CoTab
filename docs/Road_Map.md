# CoTab — Yol Haritası

Son güncelleme: 16 Kasım 2026 · Enes Yahya Bodur

## Özet ve takvim

Hedef: 22 Kasım'a kadar iki cihazda çalışan bir çekirdek sürüm, 25 Aralık'ta özellik dondurma, 14. haftadaki son derste final sunumu. Dönem 14 ders haftası ve aradaki 2 haftalık vize döneminden oluşuyor; aşağıdaki hafta numaralarına vize dahil değil.

| Hafta | Tarih | Ne oluyor |
| --- | --- | --- |
| 1.–7. hafta | 14 Eylül–30 Ekim | Konu seçimi, kapsam ve iş planı dokümanı, GitHub deposu |
| Vize dönemi | 2–13 Kasım | Çekirdek geliştirme, hafif tempo |
| 8. hafta | 16–20 Kasım | İlk tur sunumu (5–10 dk) |
| 8.–11. hafta | 16 Kasım–11 Aralık | Çekirdek sürümün bitişi (22 Kasım) ve ek modüller |
| 12.–13. hafta | 14–25 Aralık | Entegrasyon, test, özellik dondurma (25 Aralık) |
| 14. hafta | 28 Aralık–1 Ocak | Final sunumu, demo videosu, proje raporu |

Bu tarihler ekip içi takip içindir. Hocaya giden dokümanda aşamalar yalnızca "vize öncesi", "vize sonrası" ve "final öncesi" olarak yazılıdır.

## Ürün kapsamı

Ürün üç katmanda büyür: önce grup ve harcama çekirdeği çalışır, sonra fiş tarama, nöbet ve alışveriş listesi eklenir, en son modüller birbirine bağlanır. Her katman tek başına sunulabilir durumda olmalı.

**Hedef kitle:** öğrenci evinde yaşayan 2–6 kişilik gruplar (birincil), birlikte seyahat eden arkadaş grupları (ikincil). İkisi de aynı "grup" kavramını kullandığı için ayrı mimari gerekmez.

| Katman | Özellikler | Hedef |
| --- | --- | --- |
| Çekirdek sürüm (MVP) | Kayıt/giriş; grup oluşturma ve davet koduyla katılma; manuel harcama ekleme; eşit, yüzde ve tutar bazlı bölüştürme; kişi bakiyeleri; harcama geçmişi; SQLite'ta offline kayıt + sunucuya senkron | 22 Kasım |
| Genişletilmiş sürüm | Fiş tarama (OCR) ve kalem bazlı bölüştürme; QR ile gruba katılma; borç sadeleştirme ve "ödeme yaptım" kaydı; nöbet çizelgesi (rotasyon + hatırlatma bildirimi); ortak alışveriş listesi (gerçek zamanlı); alınan ürünün tek dokunuşla harcamaya dönüşmesi; Türkçe dil seçeneği | 25 Aralık |
| Opsiyonel | Aylık harcama grafikleri ve kategori istatistikleri; seyahat için döviz desteği; tekrarlayan harcamalar (kira, internet); ~~karanlık mod~~ (15 Kasım'da yapıldı); Play Store kapalı test yayını | Zaman kalırsa |

**Splitwise'tan farkımız (sunumda öne çıkarılacak):**

- **Kalem bazlı fiş bölüştürme:** fiş taranır, her ürün bir veya birkaç kişiye atanır.
- **Türk fişlerine özel ayrıştırma:** market adı, tarih, TOPLAM ve KDV satırları otomatik bulunur; kullanıcı onay ekranında düzeltir.
- **Ev yönetimi tek yerde:** harcama, nöbet ve alışveriş listesi birbirine bağlı. Listeden alınan ürün harcamaya, harcama bakiyeye dönüşür.

**Kapsam dışı:** gerçek para transferi veya ödeme entegrasyonu, web sürümü, sohbet/mesajlaşma.

## Teknik mimari

Kod öğrenci seviyesinde ve sade tutulur: ek mimari katmanı, kod üretimi gerektiren paket ve gereksiz soyutlama yok. Uygulama her zaman yerel SQLite veritabanından okur ve yazar, Firebase değişiklikleri diğer üyelere taşır; böylece 6. maddedeki SQLite ve uzak sunucu şartlarının ikisi de karşılanır.

| Katman | Kullanılan | Not |
| --- | --- | --- |
| Arayüz | Flutter + Material 3 | Ekranlar lib/screens, ortak parçalar lib/widgets altında |
| Tasarım | lib/utils/app_theme.dart | Orman yeşili + krem + tek hardal vurgu, Plus Jakarta Sans fontu (assets/fonts), açık/koyu mod. Kurallar CLAUDE.md'de "Design rules" bölümünde, logo docs/logo.svg |
| Durum yönetimi | StatefulWidget + setState | Ek paket yok. Tek istisna: açık/koyu mod bütün uygulamayı etkilediği için Flutter'ın kendi ValueNotifier'ı kullanılıyor |
| Navigasyon | Navigator.push | Flutter'ın kendi yöntemi |
| Yerel veritabanı | sqflite + path, düz SQL | DatabaseHelper sınıfı lib/services altında |
| Uzak sunucu | firebase\_auth, cloud\_firestore | Eklendi (Ahmet Anıl Çay); senkron SyncService ile |
| Fiş okuma | google\_mlkit\_text\_recognition | Faz 1'de ham metin denemesi eklendi; fiş alanlarını ayrıştırma Faz 2'de |
| Kamera ve galeri | image\_picker | Faz 1'de fotoğraf çekme/seçme ve önizleme eklendi |
| Bildirim | flutter\_local\_notifications | Nöbet hatırlatmaları, Faz 2 |
| QR ile davet | qr\_flutter (üretme) + mobile\_scanner (okuma) | Faz 2'de eklenecek |
| Dil desteği | flutter\_localizations + intl, ARB dosyaları | İngilizce varsayılan, Türkçe ikinci dil |
| Test | flutter\_test | Modeller, bölüştürme, bakiye, para biçimi, senkron kuralları, form ekranları, tema ve fiş tarama hata durumları için testler |

Kural: yukarıdakiler dışında paket eklemeden önce ekipte konuşulur. Klasör yapısı: lib/models, lib/screens, lib/services, lib/widgets, lib/utils. Kurallar depodaki CLAUDE.md'de, değişiklikler CHANGELOG'da.

Firestore'un kendi offline önbelleği olsa da veri kaynağı SQLite olarak kalır. Tutarlar kuruş cinsinden int tutulur. ID'ler TEXT tipindedir: users tablosunda Firebase Auth'un verdiği uid, diğer tablolarda Firestore'un ürettiği ID'ler kullanılır (`collection(...).doc().id` internet yokken de çalışır). Fiş görselleri şimdilik yalnızca fişi tarayan kişinin telefonunda saklanır, buluta yüklenmez; diğer üyeler tutarı ve kalemleri görür. Final sunumunda kaynak koddan soru geleceği için her üye kendi modülündeki kodu baştan sona açıklayabilmeli.

**Veri modeli (SQLite tabloları):**

sync\_queue dışındaki her tabloda ayrıca iki kolon bulunur: updated\_at (son değişiklik zamanı) ve deleted\_at (yumuşak silme; boşsa kayıt silinmemiştir). İkisi de INTEGER, milisaniye cinsinden (`DateTime.now().millisecondsSinceEpoch`).

| Tablo | Temel alanlar |
| --- | --- |
| users | id, ad, e-posta, avatar |
| groups | id, ad, tür (ev/seyahat), para birimi, davet kodu |
| group\_members | group\_id, user\_id, rol, katılma tarihi |
| expenses | id, group\_id, başlık, ödeyen, tutar, kategori, tarih, fiş görseli (telefondaki dosya yolu), bölüştürme tipi |
| expense\_items | id, group\_id, expense\_id, ürün adı, tutar (fişten gelen kalemler) |
| expense\_shares | id (expenseId\_userId), group\_id, expense\_id, item\_id (yalnızca kalem payında), user\_id, pay tutarı |
| settlements | id, group\_id, ödeyen, alan, tutar, tarih |
| chores | id, group\_id, ad, tekrar sıklığı, rotasyon sırası |
| chore\_assignments | chore\_id, user\_id, tarih, tamamlandı mı |
| shopping\_items | id, group\_id, ad, ekleyen, alındı mı, bağlı harcama |
| sync\_queue | tablo, kayıt id, zaman damgası (yalnızca yerelde) |
| settings | anahtar, değer; açık/koyu mod seçimi (yalnızca yerelde, senkron edilmez) |

Senkronlanan her tabloda group\_id bulunur; gruba ait veriler bu sütunla indirilir. Veritabanı şu an sürüm 4: sürüm 1 users ve groups, sürüm 2 group\_members ve sync\_queue, sürüm 3 harcama tabloları ve settlements, sürüm 4 settings. Sıradaki tablo değişikliği (chores, shopping\_items) sürüm 5 olur.

**Kilit algoritmalar:**

- **Borç sadeleştirme:** herkesin net bakiyesini hesapla, en çok borçlu olanla en çok alacaklı olanı eşleştir, biri sıfırlanana kadar tekrarla. n kişide en fazla n−1 ödeme çıkar. Birim testi yazın; sunumda gösterilecek parça bu.
- **Fiş ayrıştırma:** OCR metnini satırlara böl, "TOPLAM", "KDV", tarih ve fiyat desenlerini düzenli ifadelerle yakala, sonucu düzenlenebilir bir onay ekranında göster.
- **Senkron çakışması:** harcamalar ekleme-ağırlıklı olduğu için "son yazan kazanır" (updated\_at'i büyük olan) ve silmede yumuşak silme (deleted\_at) yeterli.

## Ekip organizasyonu

Her üye bir yönetim rolü ve bir kod modülü üstlenir; böylece herkesin kod katkısı %5'in çok üstünde kalır ve performans raporu modül bazında tutulabilir.

| Üye | Yönetim rolü | Kod modülü | Destek verdiği alan |
| --- | --- | --- | --- |
| Enes Çelik | Proje yöneticisi (yürütücü) | Flutter proje iskeleti; grup ve harcama modülü, veri modeli ve SQLite, bölüştürme ve borç sadeleştirme algoritması | Haftalık rapor, sprint planı, performans kaydı |
| Enes Yahya Bodur | Teknik lider (QA) | Fiş tarama: kamera, OCR, ayrıştırma, onay ekranı, kalem bazlı paylaşım | Kod incelemesi, test, sürüm (APK) çıkarma |
| Ahmet Anıl Çay | Halkla ilişkiler sorumlusu | Backend ve senkron: Firebase, auth, bildirimler; nöbet ve alışveriş listesi | Blog, YouTube, LinkedIn paylaşımları |

**Performans kaydı:** PM her hafta GitHub Issues üzerinden her üyenin aldığı ve kapattığı görevleri, PR sayısını ve gecikmeleri bir tabloya işler. Dönem sonunda GitHub Insights (Contributors) ekran görüntüsüyle birlikte rapora eklenir.

Hocaya giden dokümandan iki fark var ve ilk haftalık raporda bildirilecek: proje iskeletini Enes Yahya yerine Enes Çelik kurdu; teknik yığın sadeleştirildi (Riverpod → setState, drift → sqflite, FCM yerine yalnızca yerel bildirimler).

## Faz faz yol haritası

Beş faz ve üç kapı var: çekirdek sürüm (22 Kasım), özellik dondurma (25 Aralık) ve final teslimi. Bir kapıdan geçmeden sonraki faza yeni özellik eklenmez.

Çekirdek sürüm ilk ve en kritik kapı: vize döneminde tempo düşük olacağı için 8. haftadaki ilk tur sunumuna kadar en azından grup ve harcama ekranları çalışır durumda olmalı.

### Faz 0 — Kuruluş (20 Ekim–1 Kasım)

- [x] Kapsam ve iş planı dokümanı, organizasyon şeması (Enes Çelik)
- [x] Proje adı: CoTab; public GitHub deposu (enescelik00/CoTab) ve README
- [x] Teknoloji kararı: Flutter + Dart, sade kod (setState, sqflite, Navigator)
- [x] Flutter proje iskeleti: klasör yapısı, DatabaseHelper (users, groups), Material 3 tema, İngilizce/Türkçe l10n, CLAUDE.md ve CHANGELOG (Enes Çelik)
- [x] İskeletin main'e commit edilip push edilmesi; arkadaşların klonlayıp flutter run ile denemesi
- [ ] Enes Yahya ve Ahmet Anıl'ın collaborator olarak eklenmesi, ardından main'in korumaya alınması (Ahmet Anıl eklendi; Enes Yahya ve main koruması kontrol edilecek)
- [x] Firebase projesi, Auth ve Firestore kurulumu (Ahmet Anıl Çay)
- [x] Tasarım: Figma tel kafesi yerine tasarım doğrudan uygulamada yapıldı; renkler, font ve bileşen stilleri lib/utils/app_theme.dart'ta, logo docs/logo.svg'de (Enes Çelik)

### Faz 1 — Çekirdek MVP (2–22 Kasım, vize dönemi dahil)

- [x] group\_members tablosu (Ahmet Anıl Çay); expenses, expense\_items, expense\_shares ve settlements tabloları, model sınıfları (toMap/fromMap) (Enes Çelik)
- [x] Grup oluşturma ve davet koduyla katılma (Ahmet Anıl Çay)
- [x] Harcama ekleme, eşit/yüzde/tutar bölüştürme, harcama listesi ve silme, kişi bakiyeleri (Enes Çelik)
- [x] Kayıt ve giriş, Firestore'a offline-first senkron (Ahmet Anıl Çay)
- [x] Uygulama teması, logo ve açık/koyu mod (Enes Çelik)
- [x] Kamera/galeriden fiş fotoğrafı seçme, önizleme ve ML Kit ile ham metin çıkarma denemesi (Enes Yahya Bodur; gerçek fişte metin görüldü, doğruluk ölçümü bekliyor)
- [ ] enes branch'inin PR ile main'e alınması (Enes Çelik; inceleme: Ahmet Anıl Çay veya Enes Yahya Bodur)
- [ ] **İlk tur sunumu (8. hafta, 16–20 Kasım):** amaç, kapsam, ekip, iş planı ve o ana kadarki ekran görüntüleri
- [ ] **Kapı 1 (22 Kasım):** iki gerçek telefonda aynı grubu gören, harcama ekleyip bakiye hesaplayan çekirdek sürüm. Kod hazır; iki cihazla test bekliyor

### Faz 2 — Ek modüller (23 Kasım–11 Aralık)

- Fiş ayrıştırma (toplam, tarih, kalemler) ve düzenlenebilir onay ekranı (Enes Yahya Bodur)
- Kalem bazlı bölüştürme arayüzü (Enes Yahya Bodur + Enes Çelik)
- Borç sadeleştirme algoritması, birim testleri, "ödeme yaptım" akışı (Enes Çelik)
- Harcama düzenleme; çekirdek sürümde yalnızca ekleme ve silme var (Enes Çelik)
- Nöbet çizelgesi, rotasyon ve hatırlatma bildirimleri (Ahmet Anıl Çay)
- Ortak alışveriş listesi, gerçek zamanlı güncelleme (Ahmet Anıl Çay)
- QR ile gruba katılma: qr\_flutter ile kod üretme, mobile\_scanner ile okuma (Ahmet Anıl Çay)
- Türkçe çevirilerin gözden geçirilmesi; her metin baştan iki ARB dosyasına da yazıldığı için ayrı bir kurulum gerekmez (herkes, kendi ekranları için)

### Faz 3 — Entegrasyon ve cila (14–25 Aralık)

- Alınan ürünün harcamaya dönüşmesi, modüller arası bağlantılar (Enes Çelik + Ahmet Anıl Çay)
- Offline senaryolar ve senkron çakışma testleri (Ahmet Anıl Çay)
- Fiş okuma doğruluğunu 20+ gerçek fişle ölçme ve iyileştirme (Enes Yahya Bodur)
- Boş durum ekranları, hata mesajları, yükleme durumları, karanlık mod (herkes)
- 3–5 kişilik gerçek kullanıcı testi (Enes Yahya Bodur)
- **Kapı 2 (25 Aralık):** özellik dondurma, bundan sonra yalnızca hata düzeltme

### Faz 4 — Teslim (28 Aralık–son ders)

- Son hata düzeltmeleri ve kararlı APK'nın etiketlenmesi (Enes Yahya Bodur)
- Demo videosu çekimi ve kurgusu (Ahmet Anıl Çay)
- Proje raporu: tüm haftalık raporlar, dokümanlar, performans raporu (Enes Çelik)
- Final sunumu provası, kaynak kod sorularına hazırlık (herkes)
- Opsiyonel: Play Store kapalı test yayını
- **Kapı 3:** 14. haftadaki son derste final sunumu; video ve rapor teslimi

## Ders gereksinimleri kontrol listesi

Dokuz maddenin sekizi zorunlu; hepsi yukarıdaki fazlara bağlandı.

| # | Gereksinim | Nasıl karşılanıyor | Durum |
| --- | --- | --- | --- |
| 1 | Başlık, kapsam, iş planı dokümanı | Proje Başlığı, Kapsam ve İş Planı dokümanı (CoTab) | Hazır |
| 2 | Yürütücü ve organizasyon şeması | Dokümanın 7. bölümü: şema ve görev tablosu | Hazır |
| 3 | Public GitHub, herkes katkıcı, kişi başı en az %5 kod | github.com/enescelik00/CoTab; her üye kendi modülünde PR açar | Enes Çelik ve Ahmet Anıl Çay katkı veriyor; Enes Yahya Bodur'un ilk PR'ı bekleniyor |
| 4 | Haftalık ilerleme raporu ve sırayla sunum | Haftalık rutin bölümündeki şablon | Her hafta |
| 5 | Halkla ilişkiler sorumlusu ve tanıtım | Ahmet Anıl Çay; blog, YouTube, LinkedIn takvimi | İlk paylaşım ilk tur sunumuyla |
| 6 | SQLite ve/veya uzak sunucu | İkisi birden: sqflite (SQLite) + Cloud Firestore | Çalışıyor |
| 7 | Ara prototip, final sunumu, final videosu | Kapı 1 (çekirdek sürüm) ve Kapı 3 | 22 Kasım, son ders |
| 8 | Proje raporu, süreçteki tüm dosyalar dahil | Tüm dokümanlar repo içinde /docs klasöründe | Faz 4 |
| 9 | (Opsiyonel) Mağazada yayın | Play Store kapalı test | Zaman kalırsa |

Dikkat: ödevde listelenen başlıklar bitirme projesi olarak sunulursa reddediliyor. Bu proje o listede yok, ama yine de bitirme projenizle örtüşmemesine dikkat edin.

## Haftalık rutin

Haftada bir 30 dakikalık toplantı ve sabit bir rapor şablonu, hem ilerleme sunumlarını hem de final raporunu neredeyse kendiliğinden üretir.

**Haftalık döngü:**

1. Pazartesi: 30 dk planlama toplantısı; geçen haftanın Issues'ları kapatılır, yeni görevler atanır.
2. Hafta içi: her görev bir branch ve bir PR; PR'ı en az bir başka üye onaylar.
3. Cuma: PM ilerleme raporunu doldurur, PR sorumlusu o haftanın paylaşımını yapar.

**İlerleme raporu şablonu (1 sayfa / 3–4 slayt):**

- Bu hafta tamamlananlar (kişi bazında, Issue linkleriyle)
- Ekran görüntüleri veya kısa GIF
- Gelecek hafta planı
- Riskler ve engeller
- Tanıtım faaliyetleri (paylaşım linkleri)
- Kişi bazında katkı tablosu (açılan/kapanan görev, PR sayısı)

**GitHub iş akışı:**

- main korumalı; doğrudan push yok, yalnızca PR ile birleştirme
- Branch adı İngilizce: feature/receipt-scan, fix/balance-rounding gibi
- Commit mesajı: feat:, fix:, docs:, test:, refactor: önekleri
- Her PR docs/CHANGELOG.md'ye kısa bir kayıt ekler
- Her Issue'da sorumlu, etiket (modül) ve hedef faz (milestone)
- Görevler GitHub Projects panosunda: Yapılacak, Devam ediyor, İncelemede, Bitti

**Tanıtım içerik takvimi:**

| Ne zaman | İçerik | Kanal |
| --- | --- | --- |
| İlk tur sunumu (8. hafta) | Proje tanıtımı: problem, fikir, ekip | Blog (Medium) + LinkedIn |
| Kapı 1 sonrası (9. hafta) | 1–2 dk uygulama demosu | YouTube |
| Faz 2 ortası (10. hafta) | "Fişi tara, hesabı böl" kısa video | YouTube Shorts / LinkedIn |
| Faz 3 (12. hafta) | Teknik yazı: offline-first senkron veya borç sadeleştirme algoritması | Blog |
| Kapı 3 (14. hafta) | Final tanıtım videosu (ders teslimi ile aynı video) | YouTube |

## Riskler ve önlemler

En büyük iki risk kapsamın şişmesi ve fiş okumanın beklenenden zayıf çıkması; ikisinin de geri dönüş planı hazır.

| Risk | Etki | Önlem |
| --- | --- | --- |
| Kapsam şişmesi, üç uygulamayı birden yetiştirememek | Yüksek | Katman sırası sabit: MVP bitmeden v1'e geçilmez; opsiyoneller yalnızca Kapı 2'den önce boş zaman varsa |
| Buruşuk/soluk termal fişte OCR kalemleri yanlış eşleştiriyor | Yüksek | Önce yalnızca TOPLAM ve tarih otomatik; kalemler onay ekranında düzeltilebilir; kırpma ve kontrast ön işleme |
| Senkron çakışmaları ve veri kaybı | Orta | sync\_queue tablosu, yumuşak silme, son yazan kazanır; Faz 3'te uçak modu testleri |
| Üyelerin zamanı kısıtlı (iş, staj, diğer dersler) | Orta | Haftalık küçük görevler; tıkanan görev 3 gün içinde PM'e bildirilir ve yeniden dağıtılır |
| Bir üyenin kod katkısının %5'in altında kalması | Orta | Modül sahipliği; PM her hafta GitHub Insights'ı kontrol eder |
| Firebase ücretsiz kota veya yapılandırma sorunları | Düşük | Spark planı bu ölçek için yeterli; okuma sayısını azaltmak için yerel önbellek zaten SQLite |
| Demo günü canlı hata | Orta | Kapı 2 sonrası kararlı APK etiketlenir; demo için hazır test grubu ve örnek fişler; yedek ekran kaydı |

## Sıradaki adımlar (8. hafta, 16–22 Kasım)

Çekirdek sürümün kodu hazır. Bu haftanın amacı onu iki cihazda doğrulamak, main'e almak ve ilk tur sunumunu yapmak.

Vize döneminde tamamlananlar: kapsam dokümanı hocaya gönderildi, iskelet main'e alındı, Firebase kuruldu, giriş, gruplar, senkron ve harcama modülü yazıldı.

- [ ] Kapı 1 testi: iki cihazda aynı gruba gir, harcama ekle, bakiyelerin iki tarafta da doğru olduğunu ve internetsiz eklenen harcamanın sonradan gittiğini kontrol et (Enes Çelik + Ahmet Anıl Çay)
- [ ] enes branch'i için main'e PR aç, incelet ve birleştir (Enes Çelik)
- [ ] Ahmet Anıl'a haber ver: veritabanı sürüm 4 oldu (onun tabloları sürüm 5), SyncService.pushPending ve GroupService.getMembers değişti, ana ekran, giriş ve grup ekranları yeni temaya geçti (Enes Çelik)
- [ ] İlk haftalık raporda iş planından farkları bildir: iskeletin sahibi ve sadeleştirilen teknik yığın (Enes Çelik)
- [ ] İlk tur sunumu slaytları: problem, çözüm, Splitwise'tan farkı, kapsam, ekip, iş planı, ekran görüntüleri (herkes)
- [ ] Enes Yahya'nın collaborator olduğunu ve main'in korumada olduğunu kontrol et (Enes Çelik)
- [ ] GitHub Projects panosunu aç, Faz 2 görevlerini Issue olarak gir (Enes Çelik)
- [x] Kamera ekranı ve ML Kit ile ham metin denemesini ayrı branch'te geliştir (Enes Yahya Bodur)
- [ ] Fiş tarama branch'i için PR aç ve incelet (Enes Yahya Bodur)
- [ ] İlk blog/LinkedIn yazısının taslağı (Ahmet Anıl Çay)
