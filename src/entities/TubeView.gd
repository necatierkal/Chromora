class_name TubeView
extends Control

# Chromora - Enhanced Glass Tube Visual Component
# High-polish vector rendering, touch button target, valid move highlight & animations.

signal tube_clicked(tube_idx: int)

var tube_index: int = 0
var capacity: int = 4
var balls: Array = [] # Color IDs [bottom ... top]
var is_selected: bool = false
var is_valid_target: bool = false
var is_locked: bool = false
var lock_moves_needed: int = 0
var fixed_color: int = -1
var one_way_mode: String = "" # "in_only", "out_only", or ""
var has_barrier: bool = false

var ball_views: Array[BallView] = []
var touch_button: Button = null
var base_y: float = 0.0
var tube_width: float = 96.0
var tube_height: float = 380.0

static func _get_theme_mgr():
	var loop = Engine.get_main_loop()
	if loop and loop is SceneTree and loop.root:
		return loop.root.get_node_or_null("ThemeManager")
	return null

func _get_theme_data() -> Dictionary:
	var tm = _get_theme_mgr()
	if tm:
		return tm.get_theme_data()
	return {
		"bg_top": Color("#0a0f1d"),
		"accent": Color("#38bdf8"),
		"tube_glass": Color(0.2, 0.4, 0.8, 0.12),
		"tube_border": Color(0.4, 0.7, 1.0, 0.5),
		"tube_glow": Color(0.3, 0.6, 1.0, 0.4)
	}

func setup(p_index: int, p_cap: int = 4, p_width: float = 96.0) -> void:
	tube_index = p_index
	capacity = p_cap
	tube_width = p_width
	var ball_diam = tube_width - 16.0
	tube_height = (capacity * (ball_diam + 4.0)) + 46.0
	custom_minimum_size = Vector2(tube_width, tube_height)
	size = custom_minimum_size
	mouse_filter = MOUSE_FILTER_STOP

	if not touch_button:
		touch_button = Button.new()
		touch_button.flat = true
		touch_button.focus_mode = Control.FOCUS_NONE
		touch_button.mouse_filter = Control.MOUSE_FILTER_STOP
		touch_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		var empty_sb = StyleBoxEmpty.new()
		touch_button.add_theme_stylebox_override("normal", empty_sb)
		touch_button.add_theme_stylebox_override("pressed", empty_sb)
		touch_button.add_theme_stylebox_override("hover", empty_sb)
		touch_button.add_theme_stylebox_override("focus", empty_sb)
		touch_button.connect("pressed", Callable(self, "_on_touch_button_pressed"))
		add_child(touch_button)

	touch_button.position = Vector2.ZERO
	touch_button.size = size
	touch_button.move_to_front()
	queue_redraw()

func _ready() -> void:
	base_y = position.y

func _on_touch_button_pressed() -> void:
	emit_signal("tube_clicked", tube_index)

func set_balls(p_balls: Array, mystery_info: Dictionary = {}, sealed_info: Array = []) -> void:
	balls = p_balls.duplicate()
	for b in ball_views:
		b.queue_free()
	ball_views.clear()

	var r = (tube_width - 16.0) / 2.0
	var bottom_y = tube_height - 20.0 - r

	for i in range(balls.size()):
		var c_id = balls[i]
		var is_myst = mystery_info.get(str(i), false)
		var is_seal = (i in sealed_info)

		var bv = BallView.new()
		bv.setup(c_id, is_myst, is_seal, r)
		add_child(bv)
		
		var target_y = bottom_y - (i * (r * 2.0 + 4.0)) - r
		var target_x = (tube_width / 2.0) - r
		bv.position = Vector2(target_x, target_y)
		ball_views.append(bv)

	if touch_button:
		touch_button.move_to_front()

	queue_redraw()

func set_selected(selected: bool) -> void:
	if is_selected == selected:
		return
	is_selected = selected
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if is_selected:
		tween.tween_property(self, "position:y", base_y - 32.0, 0.16)
		if not ball_views.is_empty():
			var top_ball = ball_views.back()
			var lift_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			lift_tween.tween_property(top_ball, "position:y", top_ball.position.y - 32.0, 0.14)
	else:
		tween.tween_property(self, "position:y", base_y, 0.14)
		_realign_balls()
	queue_redraw()

func set_valid_target(val: bool) -> void:
	if is_valid_target == val:
		return
	is_valid_target = val
	queue_redraw()

func _realign_balls() -> void:
	var r = (tube_width - 16.0) / 2.0
	var bottom_y = tube_height - 20.0 - r
	for i in range(ball_views.size()):
		var target_y = bottom_y - (i * (r * 2.0 + 4.0)) - r
		ball_views[i].position.y = target_y

func play_invalid_shake() -> void:
	var orig_x = position.x
	var tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position:x", orig_x - 12.0, 0.05)
	tween.tween_property(self, "position:x", orig_x + 12.0, 0.05)
	tween.tween_property(self, "position:x", orig_x - 8.0, 0.05)
	tween.tween_property(self, "position:x", orig_x, 0.05)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("tube_clicked", tube_index)
	elif event is InputEventScreenTouch and event.pressed:
		emit_signal("tube_clicked", tube_index)

func _draw() -> void:
	var theme_data = _get_theme_data()
	var w = tube_width
	var h = tube_height
	var r = w / 2.0

	# 1. Valid Target Highlight (Cyan glow + Top Arrow)
	if is_valid_target:
		var target_glow = Color("#38bdf8")
		target_glow.a = 0.5
		draw_rect(Rect2(-6, -6, w + 12, h + 12), target_glow, false, 5.0, true)
		var font = ThemeDB.fallback_font
		draw_string(font, Vector2(r - 9, -12), "▼", HORIZONTAL_ALIGNMENT_CENTER, -1, 26, Color("#38bdf8"))

	# 2. Selection Glow
	if is_selected:
		var glow_col = theme_data.get("tube_glow", Color(0.3, 0.6, 1.0, 0.4))
		glow_col.a = 0.6
		draw_rect(Rect2(-8, -8, w + 16, h + 16), glow_col, false, 8.0, true)

	# 3. Glass Tube Body Shadow
	draw_rect(Rect2(2, 6, w, h), Color(0, 0, 0, 0.28), false, 4.0, true)

	# 4. Glass Tube Fill (semi-transparent frosted glass)
	var glass_col = theme_data.get("tube_glass", Color(0.2, 0.4, 0.8, 0.12))
	draw_rect(Rect2(0, 0, w, h - r), glass_col, true)
	draw_circle(Vector2(r, h - r), r, glass_col)

	# 5. Glass Border Stroke
	var border_col = theme_data.get("tube_border", Color(0.4, 0.7, 1.0, 0.5))
	if is_selected:
		border_col = theme_data.get("accent", Color("#38bdf8"))
	elif is_valid_target:
		border_col = Color("#38bdf8")

	# Left wall
	draw_line(Vector2(0, 0), Vector2(0, h - r), border_col, 3.5)
	# Right wall
	draw_line(Vector2(w, 0), Vector2(w, h - r), border_col, 3.5)
	# Bottom rounded arc
	draw_arc(Vector2(r, h - r), r, 0, PI, 24, border_col, 3.5)

	# 6. Tube Lip Rim Flange at Top
	draw_line(Vector2(-6, 0), Vector2(w + 6, 0), border_col, 5.0, true)
	draw_line(Vector2(-4, -3), Vector2(w + 4, -3), Color(1, 1, 1, 0.45), 2.0, true)

	# 7. Badges
	if is_locked:
		var lock_center = Vector2(r, h / 2.0)
		draw_circle(lock_center, 28, Color(0.1, 0.1, 0.1, 0.85))
		draw_arc(lock_center, 28, 0, TAU, 24, Color("#f59e0b"), 3.0)
		var font = ThemeDB.fallback_font
		draw_string(font, lock_center + Vector2(-9, 8), "🔒", HORIZONTAL_ALIGNMENT_CENTER, -1, 26, Color.WHITE)
		if lock_moves_needed > 0:
			draw_string(font, lock_center + Vector2(-6, 26), str(lock_moves_needed), HORIZONTAL_ALIGNMENT_CENTER, -1, 18, Color("#fde047"))

	if fixed_color >= 0:
		var col = BallView.get_ball_color_safe(fixed_color)
		var badge_pos = Vector2(r, h + 20)
		draw_circle(badge_pos, 14, col)
		draw_arc(badge_pos, 14, 0, TAU, 16, Color.WHITE, 2.0)

	if one_way_mode != "":
		var font = ThemeDB.fallback_font
		var arrow_symbol = "↓" if one_way_mode == "in_only" else "↑"
		draw_string(font, Vector2(r - 8, h + 22), arrow_symbol, HORIZONTAL_ALIGNMENT_CENTER, -1, 28, Color("#a855f7"))
