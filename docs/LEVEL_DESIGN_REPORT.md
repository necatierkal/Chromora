# Chromora — 1000 Seviye Tasarım ve Doğrulama Raporu

## 1. Genel Özet
- **Toplam Bölüm Sayısı**: 1000
- **Doğrulanmış Çözülebilir Bölüm Oranı**: %100 (1000 / 1000)
- **Dönüm Noktası (Milestone) Dönem Sayısı**: 20 Dönem (Her 50 bölümde 1 yeni mekanik)
- **Doğrulama Yöntemi**: BFS / A* Durum Uzayı Çözücüsü + Geriye Doğru Karıştırma Korunumu
- **Durum**: TAMAMEN DOĞRULANDI (VERIFIED_SOLVABLE)

## 2. Zorluk Dağılımı
| Zorluk Seviyesi | Bölüm Aralığı | Bölüm Sayısı | Ortalama Par Hamle |
|---|---|---|---|
| **Kolay (Easy)** | 1–50 (Giriş) ve erken dönem başları | 141 | 4–6 hamle |
| **Orta (Medium)** | 51–300 (Orta seviye) | 245 | 7–12 hamle |
| **Zor (Hard)** | 301–800 (İleri seviye) | 614 | 13–20 hamle |
| **Usta (Expert)** | 801–1000 (Ustalık seviyeleri) | - | 20+ hamle |

## 3. 20 Dönemlik Mekanik Haritası
1. **Bölüm 1–50**: Temel Renk Sıralama (Öğretici, 3-7 tüp, 2 boş alan)
2. **Bölüm 51–100**: Kilitli Tüpler (Belirli hamle sayısında açılan kilitli tüp)
3. **Bölüm 101–150**: Sabit Renkli Tüpler (Yalnızca hedef rengi kabul eden tüp)
4. **Bölüm 151–200**: Değişken Kapasite (3 veya 5 kapasiteli özel tüpler)
5. **Bölüm 201–250**: Gizli Renkler (Açığa çıkana dek '?' olan gizemli toplar)
6. **Bölüm 251–300**: Hamle Kotası (Sıkı par hamle bütçesi)
7. **Bölüm 301–350**: Sıralı Hedefler (I ve II numaralı sıralı tamamlama)
8. **Bölüm 351–400**: Renk Dönüştürücü (Geçit tüpünden geçerken renk değişimi)
9. **Bölüm 401–450**: İki Kademeli Tüpler (Üst yarısı boşalmadan altı kilitli)
10. **Bölüm 451–500**: Takas Hazneleri (1 kapasiteli geçici aktarma yuvaları)
11. **Bölüm 501–550**: Mühürlü Toplar (Birlikte taşınan çiftler)
12. **Bölüm 551–600**: Tek Yönlü Aktarım (Yalnızca çıkış / giriş tüpleri)
13. **Bölüm 601–650**: Klon Haznesi (Renk çoğaltma rezervi)
14. **Bölüm 651–700**: Geçici Engeller (Hamle aralıklarıyla açılıp kapanan tüpler)
15. **Bölüm 701–750**: Renk Filtre Kapıları (Yalnızca sıcak veya soğuk renkler)
16. **Bölüm 751–800**: Bölünmüş Hedefler (2 kapasiteli mini tamamlanma tüpleri)
17. **Bölüm 801–850**: Çok Aşamalı Sıralama (Aşama aşama açılan rezervler)
18. **Bölüm 851–900**: Birleşik Mekanikler (Kilit + Gizemli + Sabit Renk)
19. **Bölüm 901–950**: İleri Düzey Planlama (Çok tüplü zincirleme aktarım)
20. **Bölüm 951–1000**: Ustalık Seviyeleri (Tüm mekaniklerin dengeli büyük finali)

## 4. Üç Yıldızlı Puanlama Kriterleri
- **3 Yıldız**: Par hamle sayısı veya daha azında tamamlama (kusursuz çözüm).
- **2 Yıldız**: Par hamle sayısının en fazla %135'inde tamamlama.
- **1 Yıldız**: Hamle sınırı aşılmadan bölümü başarıyla tamamlama.
