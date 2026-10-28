extends Control

# Chromora - New Mechanic & Milestone Tutorial Modal
# Explains game mechanics when entering a new 50-level milestone period.

signal tutorial_closed()

@onready var title_label: Label = $Panel/VBox/TitleLabel
@onready var period_badge: Label = $Panel/VBox/PeriodBadge
@onready var desc_label: Label = $Panel/VBox/DescLabel
@onready var tip_label: Label = $Panel/VBox/TipPanel/TipLabel
@onready var confirm_btn: Button = $Panel/VBox/ConfirmBtn

const PERIOD_TIPS = [
	"Aynı renkteki topları tek tüpte topla. Boş tüpleri manevra alanı olarak kullan.",
	"Kilitli tüpler üzerindeki sayaç kadar hamle yaptıktan sonra otomatik açılır.",
	"Bu tüpün altındaki renk işaretine dikkat et; yalnızca o rengi kabul eder.",
	"Tüpler 3 veya 5 top alabilir. Kapasite sınırlarını dikkatli planla.",
	"'?' işaretli gizemli topların rengi, en üst kata çıktığında ortaya çıkar.",
	"Yıldız hedeflerini kaçırmamak için en kısa çözümü bulmaya odaklan.",
	"Tüpleri üzerindeki Roma rakamı sırasına göre tamamla.",
	"Bu tüpe giren toplar dönüştürücü prizmadan geçerek yeni renge bürünür.",
	"Üst kattaki topları boşaltmadan alt kattaki kilitli bölmeye erişemezsin.",
	"1 kapasiteli küçük yuvalar, kritik renk geçişlerinde tampon görevi görür.",
	"Altın halkalı mühürlü çiftler birbirinden ayrılamaz; birlikte hareket eder.",
	"Ok işaretlerine dikkat: Yalnızca giriş yapılan veya yalnızca çıkış yapılan tüpler!",
	"Bu haznede top bekletildiğinde rengi çoğalarak stratejik avantaj sağlar.",
	"Belirli hamle aralıklarında engel kalkanı açılıp kapanır; zamanlamanı ayarla.",
	"Yalnızca soğuk (mavi/yeşil/mor) veya sıcak (kırmızı/sarı/turuncu) renkleri geçirir.",
	"İkişerli mini renk paketlerini tamamlayarak alanı temizle.",
	"İlk hedef kombinasyonunu çözünce yeni tüpler ve rezervler sahneye eklenir.",
	"Kilit, gizem ve sabit kurallar artık bir arada; tüm ustalığını sergile!",
	"Genişletilmiş tüp tablosunda derin hamle zincirleri oluştur.",
	"Chromora'nın büyük finali! Tüm mekaniklerin harmanlandığı zirve bulmacalar."
]

var current_period: int = 0

func _am():
	var loop = Engine.get_main_loop()
	if loop and loop is SceneTree and loop.root:
		return loop.root.get_node_or_null("AudioManager")
	return null

func _sm():
	var loop = Engine.get_main_loop()
	if loop and loop is SceneTree and loop.root:
		return loop.root.get_node_or_null("SaveManager")
	return null

func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func show_tutorial(period_idx: int, level_id: int) -> void:
	current_period = period_idx
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	var period_name = "Yeni Mekanik"
	var period_desc = "Yeni bir bulmaca özelliği aktifleşti!"
	if period_idx >= 0 and period_idx < Constants.PERIOD_INFO.size():
		var p_info = Constants.PERIOD_INFO[period_idx]
		period_name = p_info.get("name", period_name)
		period_desc = p_info.get("desc", period_desc)
		
	title_label.text = "✨ YENİ MEKANİK KEŞFEDİLDİ!"
	period_badge.text = "Dönem %d: %s (Bölüm %d)" % [period_idx + 1, period_name, level_id]
	desc_label.text = period_desc
	
	var tip = ""
	if period_idx >= 0 and period_idx < PERIOD_TIPS.size():
		tip = PERIOD_TIPS[period_idx]
	else:
		tip = "Tüm tüpleri renklerine göre sıralayarak bölümü tamamla!"
	tip_label.text = "💡 Strateji: %s" % tip
	
	var am = _am()
	if am:
		am.play_sfx("quest_complete", 1.0)
		am.vibrate(50)

func _on_confirm_btn_pressed() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sm = _sm()
	if sm:
		sm.mark_tutorial_seen(current_period)
	var am = _am()
	if am:
		am.play_sfx("tube_select", 1.2)
	emit_signal("tutorial_closed")
