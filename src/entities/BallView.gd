class_name BallView
extends Control

# Chromora - Ball Visual Component
# High-polish vector rendering: spherical lighting, specular reflection & accessibility symbol.

var color_id: int = 0
var is_mystery: bool = false
var is_sealed: bool = false
var ball_radius: float = 38.0

const FALLBACK_PALETTE = [
	Color("#ef4444"), # Red
	Color("#3b82f6"), # Blue
	Color("#10b981"), # Green
	Color("#f59e0b"), # Yellow
	Color("#8b5cf6"), # Purple
	Color("#f97316"), # Orange
	Color("#06b6d4"), # Cyan
	Color("#ec4899"), # Pink
	Color("#84cc16"), # Lime
	Color("#14b8a6"), # Teal
	Color("#d97706"), # Amber
	Color("#6366f1")  # Indigo
]

static func _get_theme_mgr():
	var loop = Engine.get_main_loop()
	if loop and loop is SceneTree and loop.root:
		return loop.root.get_node_or_null("ThemeManager")
	return null

static func get_ball_color_safe(p_color_id: int) -> Color:
	var tm = _get_theme_mgr()
	if tm:
		return tm.get_ball_color(p_color_id)
	if p_color_id >= 0 and p_color_id < FALLBACK_PALETTE.size():
		return FALLBACK_PALETTE[p_color_id]
	return Color("#94a3b8")

static func get_ball_symbol_safe(p_color_id: int) -> String:
	var tm = _get_theme_mgr()
	if tm:
		return tm.get_ball_symbol(p_color_id)
	return ""

func setup(p_color_id: int, p_mystery: bool = false, p_sealed: bool = false, p_radius: float = 38.0) -> void:
	color_id = p_color_id
	is_mystery = p_mystery
	is_sealed = p_sealed
	ball_radius = p_radius
	custom_minimum_size = Vector2(ball_radius * 2, ball_radius * 2)
	size = custom_minimum_size
	mouse_filter = MOUSE_FILTER_IGNORE
	queue_redraw()

func _draw() -> void:
	var center = size / 2.0
	var r = ball_radius
	
	# Drop shadow beneath ball
	draw_circle(center + Vector2(0, 4), r * 0.95, Color(0, 0, 0, 0.25))

	if is_mystery:
		draw_circle(center, r, Color("#2e1065"))
		draw_arc(center, r, 0, TAU, 32, Color("#a855f7", 0.7), 2.5)
		var font = ThemeDB.fallback_font
		draw_string(font, center + Vector2(-9, 10), "?", HORIZONTAL_ALIGNMENT_CENTER, -1, 32, Color.WHITE)
		return

	var base_col = get_ball_color_safe(color_id)
	
	# Spherical shading: dark rim + bright center gradient
	var dark_rim = base_col.darkened(0.35)
	var mid_tone = base_col
	var highlight = base_col.lightened(0.5)

	# Main base circle
	draw_circle(center, r, mid_tone)
	
	# Subtle bottom shadow rim
	draw_arc(center + Vector2(0, 2), r - 1.5, 0.2, PI - 0.2, 24, dark_rim, 4.0)

	# Upper-left specular highlight
	var spec_center = center + Vector2(-r * 0.32, -r * 0.32)
	draw_circle(spec_center, r * 0.38, Color(1, 1, 1, 0.35))
	draw_circle(spec_center + Vector2(-2, -2), r * 0.18, Color(1, 1, 1, 0.75))

	# Outer border ring
	draw_arc(center, r, 0, TAU, 36, Color(1, 1, 1, 0.15), 1.5)

	# Accessibility Symbol
	var symbol = get_ball_symbol_safe(color_id)
	if symbol != "":
		var font = ThemeDB.fallback_font
		draw_string(font, center + Vector2(-8, 9), symbol, HORIZONTAL_ALIGNMENT_CENTER, -1, 22, Color(1, 1, 1, 0.9))

	# Sealed icon
	if is_sealed:
		draw_arc(center, r * 0.75, 0, TAU, 16, Color("#eab308"), 3.0)
