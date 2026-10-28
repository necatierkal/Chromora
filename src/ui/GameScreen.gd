extends Control

# Chromora - Main Gameplay Screen
# Responsive board, tactile glass tubes, valid target indicators, power-up dock & toast feedback.

@onready var bg_rect: ColorRect = $Background
@onready var level_label: Label = $HUD/Header/LevelInfo/LevelLabel
@onready var period_label: Label = $HUD/Header/LevelInfo/PeriodLabel
@onready var moves_label: Label = $HUD/Header/MovesCounter/MovesLabel
@onready var star1_label: Label = $HUD/Header/Stars/Star1
@onready var star2_label: Label = $HUD/Header/Stars/Star2
@onready var star3_label: Label = $HUD/Header/Stars/Star3
@onready var board_container: HBoxContainer = $Board/TubeContainer

# Power-up count badges
@onready var undo_badge: Label = $PowerUpDock/UndoBtn/Badge
@onready var hint_badge: Label = $PowerUpDock/HintBtn/Badge
@onready var extra_badge: Label = $PowerUpDock/ExtraBtn/Badge
@onready var shuffle_badge: Label = $PowerUpDock/ShuffleBtn/Badge
@onready var reveal_badge: Label = $PowerUpDock/RevealBtn/Badge

@onready var undo_btn: Button = $PowerUpDock/UndoBtn
@onready var hint_btn: Button = $PowerUpDock/HintBtn
@onready var extra_btn: Button = $PowerUpDock/ExtraBtn
@onready var shuffle_btn: Button = $PowerUpDock/ShuffleBtn
@onready var reveal_btn: Button = $PowerUpDock/RevealBtn

@onready var tutorial_modal: Control = $Modals/TutorialModal

var tube_views: Array[TubeView] = []
var toast_label: Label = null

func _gm():
	var loop = Engine.get_main_loop()
	if loop and loop is SceneTree and loop.root:
		return loop.root.get_node_or_null("GameManager")
	return null

func _sm():
	var loop = Engine.get_main_loop()
	if loop and loop is SceneTree and loop.root:
		return loop.root.get_node_or_null("SaveManager")
	return null

func _tm():
	var loop = Engine.get_main_loop()
	if loop and loop is SceneTree and loop.root:
		return loop.root.get_node_or_null("ThemeManager")
	return null

func _am():
	var loop = Engine.get_main_loop()
	if loop and loop is SceneTree and loop.root:
		return loop.root.get_node_or_null("AudioManager")
	return null

func _alh():
	var loop = Engine.get_main_loop()
	if loop and loop is SceneTree and loop.root:
		return loop.root.get_node_or_null("AndroidLifecycleHandler")
	return null

func _ready() -> void:
	var gm = _gm()
	if gm:
		gm.connect("level_loaded", Callable(self, "_on_level_loaded"))
		gm.connect("tube_selected", Callable(self, "_on_tube_selected"))
		gm.connect("tube_deselected", Callable(self, "_on_tube_deselected"))
		gm.connect("move_executed", Callable(self, "_on_move_executed"))
		gm.connect("move_invalid", Callable(self, "_on_move_invalid"))
		gm.connect("level_won", Callable(self, "_on_level_won"))
		gm.connect("state_updated", Callable(self, "_on_state_updated"))
	var tm = _tm()
	if tm:
		tm.connect("theme_changed", Callable(self, "_on_theme_changed"))
	var alh = _alh()
	if alh:
		alh.connect("back_pressed", Callable(self, "_on_back_pressed"))

	_create_toast_ui()
	_update_theme_visuals()
	_update_powerup_badges()
	_update_powerup_button_states()
	
	if gm:
		if gm.current_state.is_empty():
			var sm = _sm()
			var cur_lvl = sm.data.get("current_level", 1) if sm else 1
			gm.load_level(cur_lvl)
		else:
			_build_board()

func _create_toast_ui() -> void:
	if toast_label:
		return
	toast_label = Label.new()
	toast_label.name = "ToastLabel"
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	toast_label.modulate.a = 0.0
	toast_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toast_label.add_theme_font_size_override("font_size", 26)
	toast_label.add_theme_color_override("font_color", Color("#fde047"))
	
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.12, 0.22, 0.94)
	sb.corner_radius_top_left = 18
	sb.corner_radius_top_right = 18
	sb.corner_radius_bottom_left = 18
	sb.corner_radius_bottom_right = 18
	sb.content_margin_left = 28
	sb.content_margin_right = 28
	sb.content_margin_top = 14
	sb.content_margin_bottom = 14
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 2
	sb.border_color = Color("#38bdf8", 0.6)
	toast_label.add_theme_stylebox_override("normal", sb)
	
	toast_label.anchors_preset = Control.PRESET_CENTER_BOTTOM
	toast_label.anchor_left = 0.5
	toast_label.anchor_right = 0.5
	toast_label.anchor_top = 1.0
	toast_label.anchor_bottom = 1.0
	toast_label.offset_left = -340.0
	toast_label.offset_right = 340.0
	toast_label.offset_top = -250.0
	toast_label.offset_bottom = -190.0
	add_child(toast_label)

func _show_floating_toast(text: String) -> void:
	if not toast_label:
		_create_toast_ui()
	toast_label.text = text
	var t = create_tween().set_parallel(false)
	t.tween_property(toast_label, "modulate:a", 1.0, 0.15)
	t.tween_interval(1.8)
	t.tween_property(toast_label, "modulate:a", 0.0, 0.25)

func _update_theme_visuals() -> void:
	var tm = _tm()
	if tm:
		var t_data = tm.get_theme_data()
		bg_rect.color = t_data.get("bg_top", Color("#0a0f1d"))

func _on_theme_changed(_theme_id: int) -> void:
	_update_theme_visuals()
	_update_tubes_data()

func _on_level_loaded(_level_data: Dictionary) -> void:
	_build_board()
	_update_hud()
	_update_powerup_badges()
	_update_powerup_button_states()
	
	var period = _level_data.get("period", 0)
	var gm = _gm()
	var lvl_id = gm.current_level_id if gm else 1
	var sm = _sm()
	if period > 0 and sm and not sm.has_seen_tutorial(period):
		tutorial_modal.show_tutorial(period, lvl_id)
	elif lvl_id == 1 and sm and not sm.has_seen_tutorial(0):
		_show_floating_toast("💡 Top seçmek için bir tüpe, aktarmak için hedefe dokun!")
		sm.mark_tutorial_seen(0)

func _build_board() -> void:
	print("DEBUG: _build_board called!")
	for t in tube_views:
		t.queue_free()
	tube_views.clear()

	var gm = _gm()
	if not gm:
		print("DEBUG: _gm is null in _build_board")
		return
	var state = gm.current_state
	var tubes: Array = state.get("tubes", [])
	var caps: Array = state.get("capacities", [])
	var num_tubes = tubes.size()
	print("DEBUG: num_tubes = ", num_tubes, " board_container = ", board_container)
	if num_tubes == 0:
		return

	# Responsive spacing and sizing
	var screen_w = 1080.0
	var avail_w = screen_w - 64.0
	var spacing = 20.0
	if num_tubes <= 4:
		spacing = 32.0
	elif num_tubes <= 6:
		spacing = 22.0
	else:
		spacing = 14.0
		
	board_container.add_theme_constant_override("separation", int(spacing))
	
	var total_spacing = spacing * (num_tubes - 1)
	var calc_w = (avail_w - total_spacing) / num_tubes
	var tube_w = clampi(int(calc_w), 74, 150)

	for i in range(num_tubes):
		var cap = caps[i] if i < caps.size() else 4
		var tv = TubeView.new()
		tv.setup(i, cap, tube_w)
		tv.connect("tube_clicked", Callable(self, "_on_tube_clicked"))
		board_container.add_child(tv)
		tube_views.append(tv)

	_update_tubes_data()
	_update_hud()

func _update_tubes_data() -> void:
	var gm = _gm()
	if not gm:
		return
	var state = gm.current_state
	var tubes: Array = state.get("tubes", [])
	var locked: Dictionary = state.get("locked_tubes", {})
	var lock_reqs: Dictionary = state.get("lock_unlock_moves", {})
	var fixed: Dictionary = state.get("fixed_colors", {})
	var one_way: Dictionary = state.get("one_way", {})
	var mysteries: Dictionary = state.get("mystery_grid", {})
	var sealed: Array = state.get("sealed_pairs", [])

	for i in range(tube_views.size()):
		var tv = tube_views[i]
		if i < tubes.size():
			tv.is_locked = locked.get(str(i), false)
			tv.lock_moves_needed = lock_reqs.get(str(i), 0)
			tv.fixed_color = fixed.get(str(i), -1)
			tv.one_way_mode = one_way.get(str(i), "")
			var myst_dict = mysteries.get(str(i), {})
			tv.set_balls(tubes[i], myst_dict, sealed)

func _update_hud() -> void:
	var gm = _gm()
	if not gm:
		return
	var state = gm.current_state
	var lvl_data = gm.current_level_data
	var moves = state.get("move_count", 0)
	var par = lvl_data.get("par_moves", 10)
	var period = lvl_data.get("period", 0)

	level_label.text = "Bölüm %d" % gm.current_level_id
	if period < Constants.PERIOD_INFO.size():
		period_label.text = Constants.PERIOD_INFO[period]["name"]
	else:
		period_label.text = "Chromora"

	moves_label.text = "Hamle: %d / %d" % [moves, par]

	var stars_map = lvl_data.get("stars", {})
	var s3_threshold = int(stars_map.get("3", par))
	var s2_threshold = int(stars_map.get("2", ceil(par * 1.35)))

	star3_label.modulate = Color("#fde047") if moves <= s3_threshold else Color("#6b7280")
	star2_label.modulate = Color("#fde047") if moves <= s2_threshold else Color("#6b7280")
	star1_label.modulate = Color("#fde047")

func _update_powerup_badges() -> void:
	var sm = _sm()
	if not sm:
		return
	undo_badge.text = str(sm.get_powerup_count("undo"))
	hint_badge.text = str(sm.get_powerup_count("hint"))
	extra_badge.text = str(sm.get_powerup_count("extra_tube"))
	shuffle_badge.text = str(sm.get_powerup_count("shuffle"))
	reveal_badge.text = str(sm.get_powerup_count("color_reveal"))

func _update_powerup_button_states() -> void:
	var gm = _gm()
	if not gm:
		return
	var can_u = PowerUpManager.can_undo(gm.history_stack)
	undo_btn.modulate.a = 1.0 if can_u else 0.5
	
	var can_h = PowerUpManager.can_hint()
	hint_btn.modulate.a = 1.0 if can_h else 0.5
	
	var can_e = PowerUpManager.can_add_extra_tube(gm.current_state)
	extra_btn.modulate.a = 1.0 if can_e else 0.5
	
	var can_s = PowerUpManager.can_shuffle()
	shuffle_btn.modulate.a = 1.0 if can_s else 0.5
	
	var can_r = PowerUpManager.can_reveal_colors(gm.current_state)
	reveal_btn.modulate.a = 1.0 if can_r else 0.5

func _on_tube_clicked(tube_idx: int) -> void:
	var gm = _gm()
	if gm:
		gm.select_tube(tube_idx)

func _on_tube_selected(tube_idx: int) -> void:
	var gm = _gm()
	if not gm:
		return
	for i in range(tube_views.size()):
		var is_sel = (i == tube_idx)
		tube_views[i].set_selected(is_sel)
		if is_sel:
			tube_views[i].set_valid_target(false)
			tube_views[i].modulate = Color.WHITE
		else:
			var check = MoveValidator.can_move(gm.current_state, tube_idx, i)
			if check.valid:
				tube_views[i].set_valid_target(true)
				tube_views[i].modulate = Color.WHITE
			else:
				tube_views[i].set_valid_target(false)
				tube_views[i].modulate = Color(0.7, 0.7, 0.7, 0.55)

func _on_tube_deselected() -> void:
	for tv in tube_views:
		tv.set_selected(false)
		tv.set_valid_target(false)
		tv.modulate = Color.WHITE

func _on_move_executed(from_idx: int, to_idx: int, count: int) -> void:
	_animate_transfer(from_idx, to_idx, count)

func _animate_transfer(from_idx: int, to_idx: int, _count: int) -> void:
	var gm = _gm()
	if from_idx >= tube_views.size() or to_idx >= tube_views.size() or not gm:
		_update_tubes_data()
		_update_hud()
		if gm:
			gm.is_animating = false
		return
		
	var sm = _sm()
	var sets = sm.data.get("settings", {}) if sm else {}
	if sets.get("reduced_motion", false):
		_update_tubes_data()
		_update_hud()
		gm.is_animating = false
		return

	var src_tv = tube_views[from_idx]
	var dst_tv = tube_views[to_idx]
	
	var state_tubes = gm.current_state.get("tubes", [])
	var moving_color = 0
	if to_idx < state_tubes.size() and not state_tubes[to_idx].is_empty():
		moving_color = state_tubes[to_idx].back()
	elif not src_tv.balls.is_empty():
		moving_color = src_tv.balls.back()
		
	var r = (src_tv.tube_width - 16.0) / 2.0
	var flying_ball = BallView.new()
	flying_ball.setup(moving_color, false, false, r)
	$Board.add_child(flying_ball)
	
	var src_pos = src_tv.global_position - $Board.global_position
	var dst_pos = dst_tv.global_position - $Board.global_position
	var ball_x_offset = (src_tv.tube_width - r * 2.0) / 2.0
	var lift_y = -r * 2.0 - 24.0
	
	var start_coord = src_pos + Vector2(ball_x_offset, lift_y)
	var mid_coord = Vector2(dst_pos.x + ball_x_offset, lift_y)
	
	var target_ball_idx = max(0, state_tubes[to_idx].size() - 1)
	var bottom_y = dst_tv.tube_height - 20.0 - r
	var land_y = bottom_y - (target_ball_idx * (r * 2.0 + 4.0)) - r
	var end_coord = dst_pos + Vector2(ball_x_offset, land_y)
	
	flying_ball.position = start_coord
	src_tv.set_selected(false)
	
	_update_tubes_data()
	if not dst_tv.ball_views.is_empty():
		dst_tv.ball_views.back().visible = false

	var am = _am()
	var tween = create_tween().set_parallel(false)
	tween.tween_property(flying_ball, "position:x", mid_coord.x, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(flying_ball, "position:y", end_coord.y, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(func():
		if am:
			am.play_sfx("ball_move", 1.0)
			am.vibrate(25)
		if not dst_tv.ball_views.is_empty():
			dst_tv.ball_views.back().visible = true
		flying_ball.queue_free()
		_update_tubes_data()
		_update_hud()
		if gm:
			gm.is_animating = false
	)

func _on_move_invalid(from_idx: int, to_idx: int, reason: String) -> void:
	if from_idx < tube_views.size():
		tube_views[from_idx].play_invalid_shake()
	if to_idx >= 0 and to_idx < tube_views.size():
		tube_views[to_idx].play_invalid_shake()
	_show_floating_toast("Geçersiz Hamle: " + reason)

func _on_state_updated() -> void:
	var gm = _gm()
	if not gm:
		return
	var state = gm.current_state
	var tubes: Array = state.get("tubes", [])
	if tube_views.size() != tubes.size():
		_build_board()
	else:
		_update_tubes_data()
	_update_hud()
	_update_powerup_badges()
	_update_powerup_button_states()

func _on_level_won(level_id: int, moves: int, par_moves: int, stars: int) -> void:
	var win_modal = $Modals/WinModal
	if win_modal:
		win_modal.show_win(level_id, moves, par_moves, stars)

# Power-up button callbacks
func _on_undo_btn_pressed() -> void:
	var gm = _gm()
	if not gm or not gm.undo():
		_show_floating_toast("Geri alınacak hamle yok!")

func _on_hint_btn_pressed() -> void:
	var gm = _gm()
	if not gm:
		return
	var h = gm.hint()
	if not h.is_empty():
		var from_idx = h["from"]
		var to_idx = h["to"]
		if from_idx < tube_views.size() and to_idx < tube_views.size():
			gm.select_tube(from_idx)
			_show_floating_toast("İpucu: Tüp %d ➔ Tüp %d" % [from_idx + 1, to_idx + 1])
	else:
		_show_floating_toast("Kullanılabilir ipucu yok!")

func _on_extra_tube_btn_pressed() -> void:
	var gm = _gm()
	if gm and gm.add_extra_tube():
		_show_floating_toast("Ekstra tampon tüp eklendi!")
	else:
		_show_floating_toast("Ek tüp hakkı kalmadı!")

func _on_shuffle_btn_pressed() -> void:
	var gm = _gm()
	if gm and gm.shuffle():
		_show_floating_toast("Üst katmanlar karıştırıldı!")
	else:
		_show_floating_toast("Karıştırılacak top yok!")

func _on_color_reveal_btn_pressed() -> void:
	var gm = _gm()
	if gm and gm.reveal_colors():
		_show_floating_toast("Gizli toplar açığa çıkarıldı!")
	else:
		_show_floating_toast("Bu bölümde gizli top yok!")

func _on_restart_btn_pressed() -> void:
	var gm = _gm()
	if gm:
		gm.restart_level()

func _on_pause_btn_pressed() -> void:
	$Modals/PauseModal.show_pause()

func _on_back_pressed() -> void:
	if tutorial_modal.visible:
		tutorial_modal._on_confirm_btn_pressed()
	elif $Modals/PauseModal.visible:
		$Modals/PauseModal.hide()
	elif $Modals/WinModal.visible:
		_on_home_btn_pressed()
	else:
		$Modals/PauseModal.show_pause()

func _on_home_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://src/ui/MainMenu.tscn")
