extends Control

# Chromora - Themes Modal (7 Unlockable Themes)

@onready var theme_grid: GridContainer = $Panel/VBox/Scroll/ThemeGrid

func show_themes() -> void:
	visible = true
	_refresh_themes()

func _refresh_themes() -> void:
	for c in theme_grid.get_children():
		c.queue_free()

	var unlocked: Array = SaveManager.data.get("unlocked_themes", [0])
	var cur_theme = ThemeManager.current_theme_id

	for theme_id in ThemeManager.THEME_DEFINITIONS.keys():
		var t_info = ThemeManager.THEME_DEFINITIONS[theme_id]
		var card = _create_theme_card(theme_id, t_info, unlocked.has(theme_id), theme_id == cur_theme)
		theme_grid.add_child(card)

func _create_theme_card(t_id: int, t_info: Dictionary, is_unlocked: bool, is_active: bool) -> PanelContainer:
	var pc = PanelContainer.new()
	pc.custom_minimum_size = Vector2(340, 140)

	var vbox = VBoxContainer.new()
	vbox.theme_override_constants.separation = 10
	pc.add_child(vbox)

	var name_lbl = Label.new()
	name_lbl.text = t_info["name"]
	name_lbl.add_theme_font_size_override("font_size", 22)
	vbox.add_child(name_lbl)

	var preview_bar = HBoxContainer.new()
	preview_bar.theme_override_constants.separation = 8
	vbox.add_child(preview_bar)

	var colors_preview = [t_info["bg_top"], t_info["accent"], Color("#ef4444"), Color("#3b82f6")]
	for col in colors_preview:
		var c_rect = ColorRect.new()
		c_rect.custom_minimum_size = Vector2(32, 32)
		c_rect.color = col
		preview_bar.add_child(c_rect)

	var btn = Button.new()
	btn.custom_minimum_size = Vector2(0, 48)
	if is_active:
		btn.text = "Seçili ✓"
		btn.disabled = true
	elif is_unlocked:
		btn.text = "Uygula"
		btn.connect("pressed", Callable(self, "_select_theme").bind(t_id))
	else:
		btn.text = "🔒 Kilitli"
		btn.disabled = true
	vbox.add_child(btn)

	return pc

func _select_theme(t_id: int) -> void:
	ThemeManager.set_theme(t_id)
	AudioManager.play_sfx("tube_select", 1.1)
	_refresh_themes()

func _on_close_btn_pressed() -> void:
	visible = false
