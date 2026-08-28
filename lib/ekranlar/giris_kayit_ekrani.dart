name: APK Üret

on:
  workflow_dispatch:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Kodu al
        uses: actions/checkout@v4

      - name: Java kur
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'

      - name: Flutter kur
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'

      - name: Paketleri indir
        run: flutter pub get

      - name: Android klasörünü oluştur
        run: flutter create --platforms=android --org com.turhan .

      - name: Uygulama adını ayarla
        run: |
          MANIFEST="android/app/src/main/AndroidManifest.xml"
          if [ -f "$MANIFEST" ]; then
            sed -i 's/android:label="[^"]*"/android:label="Orjanda+"/' "$MANIFEST"
          fi

      - name: İkonları üret
        run: dart run flutter_launcher_icons

      - name: Firebase (google-services) bağla
        run: |
          if [ ! -f "google-services.json" ]; then
            echo "UYARI: Repo kökünde google-services.json bulunamadı. Firebase bağlanmadan build alınacak."
            exit 0
          fi

          echo "google-services.json bulundu, android/app içine kopyalanıyor."
          cp google-services.json android/app/google-services.json

          # Yeni Flutter şablonu (Kotlin DSL: .kts dosyaları)
          if [ -f "android/settings.gradle.kts" ]; then
            echo "Kotlin DSL (settings.gradle.kts) formatı tespit edildi."
            sed -i 's/id("dev.flutter.flutter-plugin-loader") version "1.0.0"/id("dev.flutter.flutter-plugin-loader") version "1.0.0"\n    id("com.google.gms.google-services") version "4.4.2" apply false/' "android/settings.gradle.kts"
            sed -i 's/id("dev.flutter.flutter-gradle-plugin")/id("dev.flutter.flutter-gradle-plugin")\n    id("com.google.gms.google-services")/' "android/app/build.gradle.kts"
            echo "--- settings.gradle.kts ---"
            cat "android/settings.gradle.kts"
            echo "--- app/build.gradle.kts (plugins) ---"
            grep -A 6 "^plugins" "android/app/build.gradle.kts"
          fi

          # Eski Flutter şablonu (Groovy DSL: .gradle dosyaları)
          if [ -f "android/build.gradle" ]; then
            echo "Groovy DSL (build.gradle) formatı tespit edildi."
            awk '/dependencies *{/{print;print "        classpath (\x27com.google.gms:google-services:4.4.2\x27)";next}1' "android/build.gradle" > tmp && mv tmp "android/build.gradle"
          fi
          if [ -f "android/app/build.gradle" ]; then
            echo "" >> "android/app/build.gradle"
            echo "apply plugin: 'com.google.gms.google-services'" >> "android/app/build.gradle"
          fi

          # Doğrulama: eklenen satır gerçekten var mı, yoksa build'i durdur
          if ! grep -q "com.google.gms.google-services" "android/app/build.gradle.kts" 2>/dev/null && \
             ! grep -q "com.google.gms.google-services" "android/app/build.gradle" 2>/dev/null; then
            echo "HATA: google-services eklentisi hiçbir gradle dosyasına eklenemedi."
            echo "android/app klasöründeki gradle dosyası bekleneni içermiyor, workflow'u kontrol et."
            exit 1
          fi
          echo "Firebase eklentisi başarıyla bağlandı."

      - name: APK üret
        run: flutter build apk --release

      - name: APK'yı yükle
        uses: actions/upload-artifact@v4
        with:
          name: orjanda-apk
          path: build/app/outputs/flutter-apk/app-release.apk
