# Chromora — Android Release İmzalama ve Yayınlama Kılavuzu

Bu belge, Google Play Store veya harici Android dağıtımı için Chromora'nın imzalı sürüm (Release APK / AAB) üretim sürecini adım adım açıklar.

---

## 1. Release Keystore Oluşturma

Terminal / PowerShell üzerinden OpenJDK 17 `keytool` aracını kullanarak kendi özel release anahtarınızı oluşturun:

```powershell
& "C:\Program Files\Eclipse Adoptium\jdk-17.0.20.101-hotspot\bin\keytool.exe" `
    -genkeypair -v `
    -keystore "android\chromora-release.keystore" `
    -alias "chromora_release_key" `
    -keyalg RSA `
    -keysize 2048 `
    -validity 10000 `
    -storepass "GIZLI_PAROLANIZ" `
    -keypass "GIZLI_PAROLANIZ" `
    -dname "CN=Chromora Developer, O=Chromora, C=TR"
```

> [!CAUTION]
> `chromora-release.keystore` dosyasını ve parolanızı asla Git reposuna eklemeyin ve güvenli bir yerde yedekleyin. Bu anahtarı kaybederseniz Google Play'deki uygulamanızı güncelleyemezsiniz.

---

## 2. Export Preset Ayarlarını Güncelleme

`export_presets.cfg` dosyasındaki Android preset altına release anahtar bilgilerinizi tanımlayın:

```ini
[preset.0.options]

keystore/release="android/chromora-release.keystore"
keystore/release_user="chromora_release_key"
keystore/release_password="GIZLI_PAROLANIZ"
```

---

## 3. Release APK / AAB Üretimi

Godot headless arayüzü ile release paketini derleyin:

```powershell
# Release APK için:
cmd.exe /c "D:\tools\godot\godot.exe --headless --export-release Android android\Chromora-release.apk"

# Google Play Android App Bundle (AAB) için export_presets.cfg içinde:
# package/export_format = 1 (AAB) ayarlanıp aynı komut çalıştırılır.
```

---

## 4. İmza ve Hizalama Doğrulaması

Android SDK içindeki `apksigner` ile APK imzasını doğrulayın:

```powershell
& "C:\Android\Sdk\build-tools\34.0.0\apksigner.bat" verify --verbose "android\Chromora-release.apk"
```

Çıktıda `Verified using v1 scheme: true`, `Verified using v2 scheme: true`, `Verified using v3 scheme: true` görüldüğünde paket Google Play'e yüklenmeye hazırdır.
