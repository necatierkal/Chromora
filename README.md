# Chromora — Offline Color Sort Puzzle for Android

Chromora, Android telefonlarda tamamen yerel çalışan, sunucu veya internet bağlantısına ihtiyaç duymayan, görsel açıdan yüksek kaliteli ve özenle tasarlanmış bir mobil renk sıralama bulmaca oyunudur.

---

## 🌟 Öne Çıkan Özellikler

- **1000 Doğrulanmış Çözülebilir Bölüm**: Tüm 1000 bölüm BFS bulmaca çözücüsü ile çözülmüş, par hamle sayıları ve 3 yıldız eşikleri hesaplanmıştır.
- **20 Ana İlerleme Dönemi**: Her 50 bölümde bir oyuna yeni ve özgün bir bulmaca mekaniği dahil olur.
- **5 Özel Güç**:
  - **Geri Al (Undo)**: Son hamleyi ve önceki durumu hatasız geri yükler.
  - **İpucu (Hint)**: BFS çözücüyü kullanarak canlı durumdan bir sonraki en mantıklı hamleyi gösterir.
  - **Ek Tüp (Extra Tube)**: Zor bölümlerde ek bir boş tampon tüp açar.
  - **Karıştır (Shuffle)**: Çözülebilirliği bozmadan üst katmanları yeniden düzenler.
  - **Rengi Aç (Color Reveal)**: Gizemli topların rengini anında görünür kılar.
- **Çevrimdışı Günlük Görevler**: Cihazın yerel tarihine göre deterministik olarak üretilen 3 günlük görev; ödüller günde yalnızca bir kez alınabilir.
- **Atomik ve Güvenli Kayıt Sistemi**: `.tmp` dosyasına yazma, JSON doğrulama, `.bak` yedeği alma ve bozuk kayıt kurtarma mekanizması.
- **7 Açılabilir Görsel Tema**: Midnight, Aurora, Candy, Ocean, Sunset, Forest, Monochrome (yıldız ilerlemesiyle açılır).
- **Erişilebilirlik Desteği**: Renk körlüğü için toplar üzerinde 12 özgün sembol desteği, yüksek kontrast modu ve azaltılmış hareket seçeneği.
- **Özgün Sesler, Dinlendirici Müzik ve Haptik**: Pakete gömülü, internetsiz çalışan 16-bit PCM WAV efektleri, kesintisiz ambient arka plan müziği (BGM) ve Android titreşim desteği.
- **Dönüm Noktası Öğreticileri (Tutorial Overlays)**: Her 50 bölümde bir yeni bir oyun mekaniği devreye girdiğinde beliren açıklayıcı ve strateji ipuçları içeren rehber kartları.
- **%100 Çevrimdışı Güvencesi**: `android.permission.INTERNET` izni içermez. Analitik, reklam, harici SDK veya uzaktan indirme bulunmaz.

---

## 🎮 20 Dönüm Noktası Mekaniği (Her 50 Bölümde Bir)

| Dönem | Bölüm Aralığı | Mekanik Adı | Açıklama |
|---|---|---|---|
| **1** | 1–50 | Temel Renk Sıralama | Klasik kurallar, öğretici yapı, 3-7 tüp. |
| **2** | 51–100 | Kilitli Tüpler | Belirli sayıda hamle yapıldığında açılan asma kilitli tüpler. |
| **3** | 101–150 | Sabit Renkli Tüpler | Üzerindeki renk rozetine göre yalnızca o rengi kabul eden tüpler. |
| **4** | 151–200 | Değişken Kapasite | 3 veya 5 top kapasiteli tüplerle sıkı yerleşim kararları. |
| **5** | 201–250 | Gizli Renkler | En üste gelene kadar '?' şeklinde gizlenen gizemli toplar. |
| **6** | 251–300 | Hamle Kotası | Par hamle hedefine sıkı bağlı bütçeli seviyeler. |
| **7** | 301–350 | Sıralı Hedefler | Belirtilen sıra numarasına göre tamamlanması gereken tüpler. |
| **8** | 351–400 | Renk Dönüştürücü | Bu tüpten aktarılan topun rengini değiştiren geçitler. |
| **9** | 401–450 | İki Kademeli Tüpler | Üst yarısı boşalmadan alt bölmesi kilitli kalan tüpler. |
| **10** | 451–500 | Takas Hazneleri | Tek topluk geçici aktarma yuvaları. |
| **11** | 501–550 | Mühürlü Toplar | Birbirine zincirli, ayrılmadan taşınması gereken top çiftleri. |
| **12** | 551–600 | Tek Yönlü Aktarım | Yalnızca çıkış veya yalnızca giriş kabul eden yönlü tüpler. |
| **13** | 601–650 | Klon Haznesi | Bir top rengini çoğaltarak rezerv sağlayan mekanik. |
| **14** | 651–700 | Geçici Engeller | Hamle aralıklarıyla açılıp kapanan geçiş engelleri. |
| **15** | 701–750 | Renk Filtre Kapıları | Yalnızca sıcak veya soğuk renkleri kabul eden tüpler. |
| **16** | 751–800 | Bölünmüş Hedefler | 2 kapasiteli mini tamamlanma tüpleri. |
| **17** | 801–850 | Çok Aşamalı Sıralama | İlk hedefler tamamlandığında yeni rezervleri açan bulmacalar. |
| **18** | 851–900 | Birleşik Mekanikler | Kilitli tüp + sabit renk + gizemli topların hibrit kombinasyonları. |
| **19** | 901–950 | İleri Düzey Planlama | 10+ tüplü, derin zincirleme transfer gerektiren bölümler. |
| **20** | 951–1000 | Ustalık Seviyeleri | Tüm mekaniklerin dengeli ve zorlu büyük sentezi. |

---

## 🛠️ Sistem Gereksinimleri ve Kurulu Sürümler

- **Oyun Motoru**: Godot Engine 4.3 Stable (win64) — `D:\tools\godot\godot.exe` (Self-contained modda kurulu)
- **Export Template**: Godot 4.3 Android Templates — `D:\tools\godot\editor_data\export_templates\4.3.stable\`
- **Java Geliştirme Kiti**: Eclipse Adoptium OpenJDK 17 (`C:\Program Files\Eclipse Adoptium\jdk-17.0.20.101-hotspot`)
- **Android SDK**: `C:\Android\Sdk` (Build-Tools 34.0.0 & 36.0.0, Platforms android-34/35/36, platform-tools adb)
- **Python**: Python 3.12 (Bölüm üretici, doğrulayıcı ve ses sentezleyici araçlar için)

---

## 📂 Proje Dizin Yapısı

```
c:/Users/PC/Desktop/Önemli Projelerim/Chromora/
├── project.godot                   # Godot 4.3 proje yapılandırması
├── export_presets.cfg              # Android export ayarları (internet izni kapalı)
├── icon.svg                        # Vektörel uygulama ikonu
├── android/
│   ├── debug.keystore              # Debug imzalama anahtarı
│   └── Chromora-debug.apk          # Üretilmiş Android APK (24.7 MB)
├── src/
│   ├── core/
│   │   ├── Constants.gd            # Renkler, mekanikler, tema ve güç tanımları
│   │   ├── MoveValidator.gd        # Saf mantık hamle ve kazanma denetleyicisi
│   │   ├── PuzzleSolver.gd         # BFS / Hint arama algoritması
│   │   ├── SaveManager.gd          # Atomik yerel kayıt ve yedekleme sistemi
│   │   ├── DailyQuestManager.gd    # Tarih bazlı çevrimdışı günlük görevler
│   │   ├── ThemeManager.gd         # 7 görsel tema ve erişilebilirlik
│   │   ├── AudioManager.gd         # Ses oynatma ve titreşim yöneticisi
│   │   ├── AndroidLifecycleHandler.gd # Geri tuşu ve arka plan yönetimi
│   │   └── GameManager.gd          # Ana durum makinesi ve koordinatör
│   ├── entities/
│   │   ├── BallView.gd             # Vektör top çizimi ve erişilebilirlik sembolleri
│   │   └── TubeView.gd             # Cam tüp, rozetler ve akıcı animasyonlar
│   └── ui/
│       ├── MainMenu.gd / .tscn     # Ana menü ve profil kartı
│       ├── LevelMap.gd / .tscn     # 1000 bölümlük sayfalanmış harita
│       ├── GameScreen.gd / .tscn   # Oyun alanı, tüpler ve güç paneli
│       └── modals/
│           ├── WinModal.gd         # 3 yıldızlı zafer ekranı
│           ├── PauseModal.gd       # Duraklatma ve seçenekler ekranı
│           ├── TutorialModal.gd    # 20 dönüm noktası için mekanik tanıtım kartı
│           ├── DailyQuestsModal.gd # Günlük görev listesi ve ödül alma
│           ├── ThemesModal.gd      # Tema seçici
│           └── SettingsModal.gd    # Müzik, efekt, haptik ve erişilebilirlik ayarları
├── data/
│   └── levels/
│       └── levels_1_1000.json      # 1000 doğrulanmış bölüm verisi (892 KB)
├── assets/
│   └── audio/                      # Sentezlenmiş 7 adet WAV SFX + 1 adet ambient BGM döngüsü
├── tests/
│   ├── TestRunner.gd               # Headless test koşucusu
│   ├── test_move_validator.gd      # Kural birim testleri (8 test)
│   ├── test_solver.gd              # Çözücü birim testleri (3 test)
│   ├── test_save_manager.gd        # Kayıt sistemi testleri (5 test)
│   ├── test_daily_quests.gd        # Günlük görev testleri (3 test)
│   ├── test_powerups.gd            # Özel güç testleri (3 test)
│   ├── test_gameplay_integration.gd# Entegrasyon testi (5 test)
│   └── test_ui_controls.gd         # Tüp dokunma, transfer ve buton etkileşim testleri (6 test)
├── tools/
│   ├── level_generator.py          # 1000 bölüm üretim ve BFS doğrulama
│   ├── verify_all_levels.py        # Seviye veri bütünlüğü kontrolü
│   ├── generate_sfx.py             # Ses sentezleme aracı
│   ├── generate_bgm.py             # Ambient müzik sentezleme aracı
│   └── build_apk.ps1               # Tek tıkla APK derleme ve doğrulama betiği
└── docs/
    ├── ARCHITECTURE.md             # Teknik mimari dokümantasyonu
    ├── LEVEL_DESIGN_REPORT.md      # 1000 seviye tasarım raporu
    └── RELEASE_SIGNING_GUIDE.md    # Release anahtar oluşturma ve imzalama rehberi
```

---

## 🧪 Testlerin Çalıştırılması

Tüm testler Godot headless modunda ve Python üzerinden otomatik olarak çalıştırılabilir:

### 1. Godot Headless Birim ve Entegrasyon Testleri (33 Test)
```powershell
cmd.exe /c "D:\tools\godot\godot.exe --headless --path . -s tests/TestRunner.gd"
```
**Sonuç**: 33 / 33 test başarıyla geçti (`Exit Code 0`).

### 2. 1000 Seviye Doğrulama Testi
```powershell
& "C:\Program Files\Python312\python.exe" tools\verify_all_levels.py
```
**Sonuç**: 1000 / 1000 bölümün tamamı çözülebilir, kimlikler benzersiz, 20 mekanik dönemi eksiksiz doğrulandı.

---

## 📦 APK Üretimi ve Kurulum Talimatları

### 1. Release APK Derleme (Canlı Dağıtım / Google Play / Üretim Sürümü):
```powershell
powershell -ExecutionPolicy Bypass -File tools\build_release_apk.ps1
```
- **Dosya Yolu**: `android/Chromora-release.apk`
- **Dosya Boyutu**: **23.17 MB (24,295,838 bayt)**
- **Keystore**: `android/chromora-release.keystore` (Alias: `chromora_release_key`, RSA 2048, 10.000 gün geçerlilik)
- **Paket Kimliği**: `com.chromora.colorsort` (VersionCode: 1, VersionName: 1.0.0)
- **İzinler**: Yalnızca `android.permission.VIBRATE` (İnternet izni YOKTUR)
- **İmza Doğrulaması**: v1, v2 ve v3 şemalarıyla doğrulanmıştır (`apksigner verify`).

### 2. Debug APK Derleme (Geliştirici Sürümü):
```powershell
powershell -ExecutionPolicy Bypass -File tools\build_apk.ps1
```
- **Dosya Yolu**: `android/Chromora-debug.apk`
- **Dosya Boyutu**: **24.47 MB (25,655,663 bayt)**
- **İmza**: Debug keystore ile v1, v2, v3 imzalı.

### Android Cihaza Yükleme:
Android telefonunuzu USB ile bağlayıp USB Hata Ayıklama modunu açtıktan sonra:
```powershell
# Release APK kurulumu:
& "C:\Android\Sdk\platform-tools\adb.exe" install -r "android\Chromora-release.apk"
```
veya APK dosyasını doğrudan telefon hafızasına kopyalayarak Dosya Yöneticisi üzerinden yükleyebilirsiniz.

---

## 📱 Cihaz Durumu ve Bilinen Sınırlamalar

- **ADB Durumu**: Geliştirme ortamında çalışır durumda bir fiziksel Android cihaz veya emülatör bağlı bulunmamaktadır (`adb devices` boş dönmektedir). Bu nedenle cihaz üzerinde canlı çalıştırma testi simüle edilmemiş, dürüstçe raporlanmıştır. APK paketi `aapt` ve `apksigner` ile teknik olarak doğrulanmıştır.
- **Saat Manipülasyonu**: Günlük görevler cihazın yerel takvim saatine bağlıdır. Cihaz saati değiştirilse dahi aynı gün içinde ikinci kez ödül alınması engellenmiştir.
