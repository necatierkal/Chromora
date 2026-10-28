extends Node

# Chromora - Central Constants & Types

# Ball Color Identifiers
enum BallColor {
	NONE = -1,
	RED = 0,
	BLUE = 1,
	GREEN = 2,
	YELLOW = 3,
	PURPLE = 4,
	ORANGE = 5,
	CYAN = 6,
	PINK = 7,
	LIME = 8,
	TEAL = 9,
	AMBER = 10,
	INDIGO = 11
}

# 20 Milestone Periods (50 levels each)
enum MechanicPeriod {
	BASIC = 0,              # 1-50: Temel Sıralama
	LOCKED_TUBES = 1,       # 51-100: Kilitli Tüpler (belirli hamle veya tüp bitince açılır)
	FIXED_COLOR = 2,        # 101-150: Sabit Renkli Tüpler (yalnızca o rengi kabul eder)
	VARIABLE_CAPACITY = 3,  # 151-200: Değişken Kapasite (3 veya 5 top kapasiteli tüpler)
	MYSTERY_BALLS = 4,      # 201-250: Gizli Renkler (en üste gelene kadar '?' görünür)
	MOVE_BUDGET = 5,        # 251-300: Hamle Kotası (sıkı hamle hedefi)
	ORDERED_TARGETS = 6,    # 301-350: Sıralı Hedefler (I, II, III tüpleri sırayla tamamlanmalı)
	COLOR_CONVERTER = 7,    # 351-400: Renk Dönüştürücü (bu tüpten geçen top renk değiştirir)
	TWO_STAGE = 8,          # 401-450: İki Kademeli Tüpler (alt bölme üst boşalınca açılır)
	SWAP_PADS = 9,          # 451-500: Takas Hazneleri (1 kapasiteli geçici aktarma yuvası)
	SEALED_PAIRS = 10,      # 501-550: Mühürlü Toplar (birlikte taşınması zorunlu çiftler)
	ONE_WAY_TUBES = 11,     # 551-600: Tek Yönlü Tüpler (yalnızca çıkış veya yalnızca giriş)
	CLONE_WELL = 12,        # 601-650: Klon Haznesi (bölümde 1 kez rengi kopyalar)
	TEMPORARY_BARRIERS = 13,# 651-700: Geçici Engeller (her 2 hamlede açılıp kapanan tüp)
	COLOR_FILTER_GATES = 14,# 701-750: Renk Filtre Kapıları (sıcak veya soğuk renk kabul eden)
	SPLIT_TARGETS = 15,     # 751-800: Bölünmüş Hedefler (2 kapasiteli mini tamamlanma tüpleri)
	MULTI_PHASE = 16,       # 801-850: Çok Aşamalı Sıralama (ilk küme bitince rezerv açılır)
	HYBRID_MECHANICS = 17,  # 851-900: Birleşik Mekanikler (kilit + gizemli + sabit renk)
	ADVANCED_PLANNING = 18, # 901-950: İleri Düzey Planlama (çoklu kısıtlı bulmacalar)
	GRANDMASTER = 19        # 951-1000+: Ustalık Seviyeleri (tüm mekaniklerin dengeli sentezi)
}

# Milestone Period Info
const PERIOD_INFO = [
	{"name": "Temel Sıralama", "desc": "Klasik renk eşleştirme ve aktarma temelleri.", "start": 1, "end": 50},
	{"name": "Kilitli Tüpler", "desc": "Kilitli tüpler belirli hamleden sonra açılır.", "start": 51, "end": 100},
	{"name": "Sabit Renkli Tüpler", "desc": "Belirlenen tüpler yalnızca kendi rengini kabul eder.", "start": 101, "end": 150},
	{"name": "Değişken Kapasite", "desc": "Farklı boyutlardaki tüpler daha sıkı yerleşim ister.", "start": 151, "end": 200},
	{"name": "Gizli Renkler", "desc": "Gizemli toplar en üste çıkana dek gizlidir.", "start": 201, "end": 250},
	{"name": "Hamle Kotası", "desc": "Hedef par hamle sınırında ustalık göster.", "start": 251, "end": 300},
	{"name": "Sıralı Hedefler", "desc": "Numaralandırılmış tüpleri sırasıyla tamamla.", "start": 301, "end": 350},
	{"name": "Renk Dönüştürücü", "desc": "Geçit tüpünden aktarılan toplar renk değiştirir.", "start": 351, "end": 400},
	{"name": "İki Kademeli Tüpler", "desc": "Üst yarısı boşalmadan alt bölme kullanılamaz.", "start": 401, "end": 450},
	{"name": "Takas Hazneleri", "desc": "Tek topluk geçici tampon tüpler.", "start": 451, "end": 500},
	{"name": "Mühürlü Toplar", "desc": "Birbirine bağlı çift toplar ayrılamaz.", "start": 501, "end": 550},
	{"name": "Tek Yönlü Aktarım", "desc": "Bazı tüplerden sadece çıkış veya sadece giriş yapılır.", "start": 551, "end": 600},
	{"name": "Klon Haznesi", "desc": "Bir topu çoğaltarak renk rezervi sağlar.", "start": 601, "end": 650},
	{"name": "Geçici Engeller", "desc": "Hamle aralıklarıyla açılıp kapanan engeller.", "start": 651, "end": 700},
	{"name": "Renk Filtre Kapıları", "desc": "Yalnızca sıcak ya da soğuk renkleri geçiren tüpler.", "start": 701, "end": 750},
	{"name": "Bölünmüş Hedefler", "desc": "Mini tüplerde ikişerli renk paketleri tamamla.", "start": 751, "end": 800},
	{"name": "Çok Aşamalı Sıralama", "desc": "Önce ilk hedefleri çöz, sonra yeni alanı aç.", "start": 801, "end": 850},
	{"name": "Birleşik Mekanikler", "desc": "Kilitler, gizemli toplar ve kısıtların birleşimi.", "start": 851, "end": 900},
	{"name": "İleri Düzey Planlama", "desc": "Büyük tüp sayıları ve derin zincirleme hamleler.", "start": 901, "end": 950},
	{"name": "Ustalık Seviyeleri", "desc": "Chromora'nın en zorlu renk sıralama zirvesi.", "start": 951, "end": 1000}
]

# Power-Up Types
enum PowerUpType {
	UNDO = 0,
	HINT = 1,
	EXTRA_TUBE = 2,
	SHUFFLE = 3,
	COLOR_REVEAL = 4
}

const POWERUP_NAMES = {
	PowerUpType.UNDO: "Geri Al",
	PowerUpType.HINT: "İpucu",
	PowerUpType.EXTRA_TUBE: "Ek Tüp",
	PowerUpType.SHUFFLE: "Karıştır",
	PowerUpType.COLOR_REVEAL: "Rengi Aç"
}

# Colorblind Accessibility Symbols
const ACCESSIBILITY_SYMBOLS = [
	"●", # 0 Red - Circle
	"◆", # 1 Blue - Diamond
	"★", # 2 Green - Star
	"▲", # 3 Yellow - Triangle
	"■", # 4 Purple - Square
	"⬢", # 5 Orange - Hexagon
	"✚", # 6 Cyan - Cross
	"♥", # 7 Pink - Heart
	"☽", # 8 Lime - Crescent
	"✿", # 9 Teal - Flower
	"✦", # 10 Amber - Sparkle
	"◎"  # 11 Indigo - Bullseye
]

# Themes (7 Themes)
enum ThemeID {
	MIDNIGHT = 0,
	AURORA = 1,
	CANDY = 2,
	OCEAN = 3,
	SUNSET = 4,
	FOREST = 5,
	MONOCHROME = 6
}

const THEME_NAMES = {
	ThemeID.MIDNIGHT: "Gece Mavisi (Midnight)",
	ThemeID.AURORA: "Kuzey Işıkları (Aurora)",
	ThemeID.CANDY: "Şeker Diyarı (Candy)",
	ThemeID.OCEAN: "Okyanus Derinliği (Ocean)",
	ThemeID.SUNSET: "Gün Batımı (Sunset)",
	ThemeID.FOREST: "Zümrüt Orman (Forest)",
	ThemeID.MONOCHROME: "Minimal Gri (Monochrome)"
}

# Default Color Palette (Color Values for 12 colors)
const BASE_COLORS = [
	Color("#ef4444"), # 0 Red
	Color("#3b82f6"), # 1 Blue
	Color("#10b981"), # 2 Green
	Color("#f59e0b"), # 3 Yellow
	Color("#8b5cf6"), # 4 Purple
	Color("#f97316"), # 5 Orange
	Color("#06b6d4"), # 6 Cyan
	Color("#ec4899"), # 7 Pink
	Color("#84cc16"), # 8 Lime
	Color("#14b8a6"), # 9 Teal
	Color("#d97706"), # 10 Amber
	Color("#6366f1")  # 11 Indigo
]

# Tube Capacity Defaults
const DEFAULT_CAPACITY: int = 4
