extends Control

# Chromora - Main Menu Controller

@onready var bg_rect: ColorRect = $Background
@onready var continue_btn: Button = $Menu/Buttons/ContinueBtn
@onready var level_summary_label: Label = $Menu/ProfileCard/VBox/LevelSummary
@onready var stars_label: Label = $Menu/ProfileCard/VBox/StarsLabel
@onready var daily_badge: Label = $Menu/Buttons/DailyBtn/Badge

@onready var daily_modal: Control = $Modals/DailyQuestsModal
@onready var themes_modal: Control = $Modals/ThemesModal
@onready var settings_modal: Control = $Modals/SettingsModal

func _ready() -> void:
	ThemeManager.connect("theme_changed", Callable(self, "_update_theme_bg"))
	AndroidLifecycleHandler.connect("back_pressed", Callable(self, "_on_back_pressed"))
	_update_theme_bg(ThemeManager.current_theme_id)
	_refresh_profile()
	AudioManager.play_music()

func _update_theme_bg(_theme_id: int) -> void:
	var t_data = ThemeManager.get_theme_data()
	bg_rect.color = t_data.get("bg_top", Color("#0a0f1d"))

func _refresh_profile() -> void:
	var cur_lvl = SaveManager.data.get("current_level", 1)
	var total_stars = SaveManager.data.get("total_stars", 0)
	
	continue_btn.text = "Devam Et (Bölüm %d) ▶" % cur_lvl
	level_summary_label.text = "Mevcut İlerleme: Bölüm %d / 1000" % cur_lvl
	stars_label.text = "★ Toplam Kazanılan Yıldız: %d" % total_stars

	# Check uncompleted daily quests
	var quests = DailyQuestManager.get_daily_quests()
	var pending_claim = 0
	for q in quests:
		if q["current"] >= q["target"] and not q["claimed"]:
			pending_claim += 1
	daily_badge.text = "!" if pending_claim > 0 else ""
	daily_badge.visible = (pending_claim > 0)

func _on_continue_btn_pressed() -> void:
	AudioManager.play_sfx("tube_select", 1.1)
	var lvl = SaveManager.data.get("current_level", 1)
	GameManager.load_level(lvl)
	get_tree().change_scene_to_file("res://src/ui/GameScreen.tscn")

func _on_levels_btn_pressed() -> void:
	AudioManager.play_sfx("tube_select", 1.0)
	get_tree().change_scene_to_file("res://src/ui/LevelMap.tscn")

func _on_daily_btn_pressed() -> void:
	AudioManager.play_sfx("tube_select", 1.0)
	daily_modal.show_quests()

func _on_themes_btn_pressed() -> void:
	AudioManager.play_sfx("tube_select", 1.0)
	themes_modal.show_themes()

func _on_settings_btn_pressed() -> void:
	AudioManager.play_sfx("tube_select", 1.0)
	settings_modal.show_settings()

func _on_back_pressed() -> void:
	if daily_modal.visible:
		daily_modal.visible = false
	elif themes_modal.visible:
		themes_modal.visible = false
	elif settings_modal.visible:
		settings_modal.visible = false
	else:
		# Minimize or exit on Android
		get_tree().quit()
