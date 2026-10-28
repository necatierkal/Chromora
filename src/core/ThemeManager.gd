extends Node

# Chromora - Central Theme & Aesthetic Palette Manager
# 7 Themes, unlockable through star progression.

signal theme_changed(theme_id: int)

const THEME_DEFINITIONS = {
	Constants.ThemeID.MIDNIGHT: {
		"name": "Gece Mavisi (Midnight)",
		"bg_top": Color("#0a0f1d"),
		"bg_bottom": Color("#161b33"),
		"tube_glass": Color(0.2, 0.4, 0.8, 0.12),
		"tube_border": Color(0.4, 0.7, 1.0, 0.45),
		"tube_glow": Color(0.3, 0.6, 1.0, 0.2),
		"accent": Color("#38bdf8")
	},
	Constants.ThemeID.AURORA: {
		"name": "Kuzey Işıkları (Aurora)",
		"bg_top": Color("#042f2e"),
		"bg_bottom": Color("#134e4a"),
		"tube_glass": Color(0.1, 0.6, 0.5, 0.15),
		"tube_border": Color(0.3, 0.9, 0.7, 0.5),
		"tube_glow": Color(0.2, 0.8, 0.6, 0.25),
		"accent": Color("#2dd4bf")
	},
	Constants.ThemeID.CANDY: {
		"name": "Şeker Diyarı (Candy)",
		"bg_top": Color("#2a1228"),
		"bg_bottom": Color("#4a1d44"),
		"tube_glass": Color(0.9, 0.4, 0.7, 0.12),
		"tube_border": Color(1.0, 0.6, 0.8, 0.5),
		"tube_glow": Color(0.9, 0.3, 0.6, 0.2),
		"accent": Color("#f472b6")
	},
	Constants.ThemeID.OCEAN: {
		"name": "Okyanus Derinliği (Ocean)",
		"bg_top": Color("#082f49"),
		"bg_bottom": Color("#0c4a6e"),
		"tube_glass": Color(0.1, 0.5, 0.9, 0.15),
		"tube_border": Color(0.2, 0.7, 1.0, 0.5),
		"tube_glow": Color(0.0, 0.5, 0.9, 0.2),
		"accent": Color("#0284c7")
	},
	Constants.ThemeID.SUNSET: {
		"name": "Gün Batımı (Sunset)",
		"bg_top": Color("#3b0764"),
		"bg_bottom": Color("#701a75"),
		"tube_glass": Color(0.9, 0.5, 0.2, 0.12),
		"tube_border": Color(1.0, 0.7, 0.3, 0.5),
		"tube_glow": Color(0.9, 0.4, 0.1, 0.2),
		"accent": Color("#f97316")
	},
	Constants.ThemeID.FOREST: {
		"name": "Zümrüt Orman (Forest)",
		"bg_top": Color("#052e16"),
		"bg_bottom": Color("#14532d"),
		"tube_glass": Color(0.2, 0.6, 0.3, 0.15),
		"tube_border": Color(0.4, 0.9, 0.5, 0.5),
		"tube_glow": Color(0.2, 0.8, 0.4, 0.2),
		"accent": Color("#22c55e")
	},
	Constants.ThemeID.MONOCHROME: {
		"name": "Minimal Gri (Monochrome)",
		"bg_top": Color("#111827"),
		"bg_bottom": Color("#1f2937"),
		"tube_glass": Color(0.5, 0.5, 0.6, 0.12),
		"tube_border": Color(0.8, 0.8, 0.9, 0.5),
		"tube_glow": Color(0.6, 0.6, 0.7, 0.2),
		"accent": Color("#9ca3af")
	}
}

var current_theme_id: int = Constants.ThemeID.MIDNIGHT

func _get_save_data() -> Dictionary:
	var loop = Engine.get_main_loop()
	if loop and loop is SceneTree and loop.root and loop.root.has_node("SaveManager"):
		return loop.root.get_node("SaveManager").data
	return {}

func _ready() -> void:
	var s_data = _get_save_data()
	if s_data.has("selected_theme"):
		current_theme_id = int(s_data["selected_theme"])

func set_theme(theme_id: int) -> bool:
	if not THEME_DEFINITIONS.has(theme_id):
		return false
	var s_data = _get_save_data()
	var unlocked: Array = s_data.get("unlocked_themes", [0])
	if not unlocked.has(theme_id):
		return false
	current_theme_id = theme_id
	s_data["selected_theme"] = theme_id
	var loop = Engine.get_main_loop()
	if loop and loop is SceneTree and loop.root and loop.root.has_node("SaveManager"):
		loop.root.get_node("SaveManager").save_game()
	emit_signal("theme_changed", theme_id)
	return true

func get_theme_data() -> Dictionary:
	return THEME_DEFINITIONS.get(current_theme_id, THEME_DEFINITIONS[Constants.ThemeID.MIDNIGHT])

func get_ball_color(color_id: int) -> Color:
	var s_data = _get_save_data()
	if s_data.get("settings", {}).get("high_contrast", false):
		var c = Constants.BASE_COLORS[color_id % Constants.BASE_COLORS.size()]
		return c.lightened(0.15)
	if color_id >= 0 and color_id < Constants.BASE_COLORS.size():
		return Constants.BASE_COLORS[color_id]
	return Color.WHITE

func get_ball_symbol(color_id: int) -> String:
	var s_data = _get_save_data()
	if s_data.get("settings", {}).get("colorblind_symbols", false):
		if color_id >= 0 and color_id < Constants.ACCESSIBILITY_SYMBOLS.size():
			return Constants.ACCESSIBILITY_SYMBOLS[color_id]
	return ""
