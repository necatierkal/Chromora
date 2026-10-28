extends Control

# Chromora - Paginated 1000-Level Milestone Browser
# 20 Periods of 50 levels each with mechanic milestone banners.

@onready var bg_rect: ColorRect = $Background
@onready var period_title_label: Label = $Header/PeriodBox/PeriodTitle
@onready var period_desc_label: Label = $Header/PeriodBox/PeriodDesc
@onready var stars_total_label: Label = $Header/TopBar/StarsTotal
@onready var grid_container: GridContainer = $Scroll/Center/Grid
@onready var prev_btn: Button = $Header/PeriodBox/Nav/PrevBtn
@onready var next_btn: Button = $Header/PeriodBox/Nav/NextBtn

var current_period: int = 0

func _ready() -> void:
	ThemeManager.connect("theme_changed", Callable(self, "_update_theme_bg"))
	AndroidLifecycleHandler.connect("back_pressed", Callable(self, "_on_back_pressed"))
	_update_theme_bg(ThemeManager.current_theme_id)

	# Start on the period of player's current level
	var cur_lvl = SaveManager.data.get("current_level", 1)
	current_period = (cur_lvl - 1) / 50
	_render_period()

func _update_theme_bg(_theme_id: int) -> void:
	var t_data = ThemeManager.get_theme_data()
	bg_rect.color = t_data.get("bg_top", Color("#0a0f1d"))

func _render_period() -> void:
	current_period = clampi(current_period, 0, 19)
	prev_btn.disabled = (current_period == 0)
	next_btn.disabled = (current_period == 19)

	var p_info = Constants.PERIOD_INFO[current_period]
	period_title_label.text = "Dönem %d: %s (%d - %d)" % [
		current_period + 1,
		p_info["name"],
		p_info["start"],
		p_info["end"]
	]
	period_desc_label.text = p_info["desc"]
	stars_total_label.text = "★ %d / 3000" % SaveManager.data.get("total_stars", 0)

	# Clean previous cards
	for c in grid_container.get_children():
		c.queue_free()

	var start_lvl = p_info["start"]
	var end_lvl = p_info["end"]
	var max_unlocked = SaveManager.data.get("unlocked_max_level", 1)
	var records: Dictionary = SaveManager.data.get("level_records", {})

	for lvl_id in range(start_lvl, end_lvl + 1):
		var card = _create_level_card(lvl_id, lvl_id <= max_unlocked, records.get(str(lvl_id), {}))
		grid_container.add_child(card)

func _create_level_card(lvl_id: int, is_unlocked: bool, rec: Dictionary) -> Button:
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(170, 110)
	btn.mouse_filter = MOUSE_FILTER_STOP

	var vbox = VBoxContainer.new()
	vbox.layout_mode = 1
	vbox.anchors_preset = PRESET_FULL_RECT
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	btn.add_child(vbox)

	var lbl = Label.new()
	lbl.text = str(lvl_id)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 28)
	vbox.add_child(lbl)

	var star_lbl = Label.new()
	star_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	star_lbl.add_theme_font_size_override("font_size", 20)

	if not is_unlocked:
		btn.disabled = true
		star_lbl.text = "🔒"
		lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6))
	else:
		var stars = rec.get("stars", 0)
		var star_str = ""
		for _s in range(stars):
			star_str += "★"
		for _s in range(3 - stars):
			star_str += "☆"
		star_lbl.text = star_str
		star_lbl.add_theme_color_override("font_color", Color("#fde047") if stars > 0 else Color("#6b7280"))
		btn.connect("pressed", Callable(self, "_on_level_selected").bind(lvl_id))

	vbox.add_child(star_lbl)
	return btn

func _on_level_selected(lvl_id: int) -> void:
	AudioManager.play_sfx("tube_select", 1.0)
	GameManager.load_level(lvl_id)
	get_tree().change_scene_to_file("res://src/ui/GameScreen.tscn")

func _on_prev_btn_pressed() -> void:
	if current_period > 0:
		current_period -= 1
		AudioManager.play_sfx("tube_select", 0.9)
		_render_period()

func _on_next_btn_pressed() -> void:
	if current_period < 19:
		current_period += 1
		AudioManager.play_sfx("tube_select", 1.1)
		_render_period()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://src/ui/MainMenu.tscn")
