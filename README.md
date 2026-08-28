# Orjanda (Basit Sürüm)

Orman kesim işlerini pusula bazında takip etmek için Flutter + Firebase uygulaması.

## Bu projeyi GitHub'a yükledikten sonra yapman gerekenler

1. **Firebase projesi oluştur** (console.firebase.google.com üzerinden), Android uygulaması ekle.
   - Paket adı olarak şunu kullan: `com.turhan.orjanda_basit`
2. Firebase'in sana verdiği **`google-services.json`** dosyasını indir.
3. Bu dosyayı GitHub reposunun **en üst (kök) klasörüne** yükle — `android` diye bir klasör görmeyeceksin, o build sırasında otomatik oluşuyor, dosyayı doğrudan diğer dosyaların (pubspec.yaml, README.md vs.) yanına koy.
4. Firebase Console'da **Authentication → Sign-in method** kısmından **E-posta/Şifre** girişini aç.
5. Firebase Console'da **Firestore Database** oluştur (test modunda başlayabilirsin).
6. GitHub reposunda **Actions** sekmesine git, "APK Üret" iş akışını bul, **Run workflow** butonuna bas.
7. Birkaç dakika sonra iş akışı bitince, sonucun altındaki **Artifacts** kısmından `orjanda-apk` dosyasını indir, içinden `app-release.apk`'yı telefonuna kur.

## Klasör yapısı (lib/ içi Türkçe)

- `lib/main.dart` — uygulama girişi (bu dosya adı Flutter kuralı gereği değişmiyor)
- `lib/tema.dart` — renkler ve genel görünüm
- `lib/ekranlar/giris_kayit_ekrani.dart` — Giriş Yap / Kayıt Ol
- `lib/ekranlar/arsiv_ekrani.dart` — Tamamlanan İşler + Aktif İşe Dön / Yeni İş Oluştur
- `lib/ekranlar/yeni_is_ekrani.dart` — Yeni iş oluşturma formu
- `lib/ekranlar/kesim_ekrani.dart` — Kesim takibi, pusula ekle/sil, işi bitir
- `lib/modeller/` — veri modelleri (Pusula, İş Kaydı)
- `lib/servisler/` — Firebase Auth ve Firestore işlemleri

## Not

Kod içindeki değişken/fonksiyon isimleri İngilizce standartlara göre (Türkçe karakter sorunlarından kaçınmak için) yazıldı, ama sana görünen her şey — dosya adları, ekran yazıları, buton metinleri — Türkçe.
