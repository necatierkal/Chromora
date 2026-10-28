# Chromora — Teknik Mimari ve Sistem Tasarımı

## 1. Mimari Prensipler
Chromora, Google Play standartlarında modern, yüksek performanslı ve tamamen internetsiz (offline) çalışacak şekilde tasarlanmıştır.

```
+-------------------------------------------------------------------+
|                           UI & SCENES                             |
|  [MainMenu]  <--->  [LevelMap (1000 Lvls)]  <--->  [GameScreen]    |
|       |                     |                           |         |
|  [Modals: DailyQuests, Themes, Settings, Pause, WinModal]         |
+-------------------------------------------------------------------+
                                  |
                                  v
+-------------------------------------------------------------------+
|                        SINGLETON MANAGER'LAR                      |
|  +--------------------+  +--------------------+  +--------------+ |
|  |    GameManager     |  |    SaveManager     |  | DailyQuestMgr| |
|  +--------------------+  +--------------------+  +--------------+ |
|  +--------------------+  +--------------------+  +--------------+ |
|  |    ThemeManager    |  |    AudioManager    |  | LifecycleHndl| |
|  +--------------------+  +--------------------+  +--------------+ |
+-------------------------------------------------------------------+
                                  |
                                  v
+-------------------------------------------------------------------+
|                         SAF MANTIK VE MOTOR                       |
|   [MoveValidator]  <--->  [PuzzleSolver]  <--->  [PowerUpManager] |
|   (Kurallar & Win)        (BFS / Hint)           (5 Özel Güç)     |
+-------------------------------------------------------------------+
                                  |
                                  v
+-------------------------------------------------------------------+
|                            VERİ KATMANI                           |
|   levels_1_1000.json (1000 Doğrulanmış Bölüm)                     |
|   user://chromora_save.json (Atomik & .bak yedekli)              |
+-------------------------------------------------------------------+
```

## 2. Temel Katmanlar ve Sorumluluklar

### 2.1. GameManager (`src/core/GameManager.gd`)
- Oyunun ana durum makinesidir.
- Aktif bölümü, hamle yığınını (Undo için history stack), seçili tüpü ve bölüm tamamlama olaylarını yönetir.
- Görsel sahneden bağımsız olarak hamle mantığını yürütür ve sinyaller yayar (`level_loaded`, `tube_selected`, `move_executed`, `level_won`).

### 2.2. MoveValidator (`src/core/MoveValidator.gd`)
- Görsel bağımsız, saf mantık (pure function) kural denetleyicisidir.
- 20 farklı dönüm noktası mekaniğini (kilitler, sabit renkler, tek yön, filtre kapıları, mühürlü çiftler, değişken kapasite vb.) doğrular.
- Hamle geçerliyse taşınabilecek top sayısını (`count`) hesaplar.
- Kazanma koşulunu (`is_level_solved`) test eder.

### 2.3. PuzzleSolver (`src/core/PuzzleSolver.gd`)
- BFS tabanlı durum uzayı arama motorudur.
- Tüp dizilimlerini string hash formatında kanonize ederek döngüleri ve simetrik durumları budar.
- İpucu (Hint) gücü için canlı oyun durumundan en kısa çözüm hamlesini üretir.

### 2.4. SaveManager (`src/core/SaveManager.gd`)
- %100 yerel ve çevrimdışı profil yönetimi sağlar.
- Atomik yazma deseni:
  1. `chromora_save.json.tmp` dosyasına yazar.
  2. JSON geçerliliğini doğrular.
  3. Mevcut dosyayı `chromora_save.json.bak` olarak yedekler.
  4. Geçici dosyayı kalıcı dosyaya atomik olarak adlandırır.
- Bozuk kayıt durumunda `.bak` yedeğine döner; her ikisi de bozuksa oyunu çökertmeden güvenli varsayılana sıfırlar.
- Yıldızların yeniden oynandığında düşmesini engeller (asla gerilemez).

### 2.5. DailyQuestManager (`src/core/DailyQuestManager.gd`)
- Cihazın yerel takvim tarihini (`YYYY-MM-DD`) deterministik tohum olarak kullanır.
- Her gün için 3 özgün görev belirler; gün boyunca aynı kalır.
- Görev ödüllerinin gün içinde yalnızca 1 kez alınmasını garanti eder.

### 2.6. ThemeManager (`src/core/ThemeManager.gd`)
- 7 görsel tema sunar: Midnight, Aurora, Candy, Ocean, Sunset, Forest, Monochrome.
- Yıldız eşiklerine göre kilitleri açar.
- Renk körlüğü sembollerini (12 özgün şekil) ve yüksek kontrast modunu yönetir.

### 2.7. AudioManager (`src/core/AudioManager.gd`)
- Polifoni için 6 kanallı `AudioStreamPlayer` havuzu yönetir.
- Sentezlenmiş 16-bit PCM WAV efektlerini çalar.
- Android `Input.vibrate_handheld(ms)` ile dokunsal geri bildirim (haptic feedback) sağlar.
