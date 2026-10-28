extends Control

# Chromora - Settings & Accessibility Options Modal

@onready var master_slider: HSlider = $Panel/VBox/Content/Audio/MasterRow/Slider
@onready var music_slider: HSlider = $Panel/VBox/Content/Audio/MusicRow/Slider
@onready var sfx_slider: HSlider = $Panel/VBox/Content/Audio/SfxRow/Slider
@onready var haptic_check: CheckBox = $Panel/VBox/Content/Haptic/Check
@onready var symbol_check: CheckBox = $Panel/VBox/Content/A11y/SymbolCheck
@onready var contrast_check: CheckBox = $Panel/VBox/Content/A11y/ContrastCheck
@onready var motion_check: CheckBox = $Panel/VBox/Content/A11y/MotionCheck
@onready var stats_label: Label = $Panel/VBox/Content/Stats/StatsText

func show_settings() -> void:
	visible = true
	var sets = SaveManager.data.get("settings", {})
	master_slider.value = sets.get("master_volume", 1.0)
	music_slider.value = sets.get("music_volume", 0.8)
	sfx_slider.value = sets.get("sfx_volume", 1.0)
	haptic_check.button_pressed = sets.get("haptic_enabled", true)
	symbol_check.button_pressed = sets.get("colorblind_symbols", false)
	contrast_check.button_pressed = sets.get("high_contrast", false)
	motion_check.button_pressed = sets.get("reduced_motion", false)

	var st = SaveManager.data.get("stats", {})
	stats_label.text = "Toplam Hamle: %d | Oynanan Bölüm: %d | Kusursuz: %d" % [
		st.get("total_moves", 0),
		st.get("levels_played", 0),
		st.get("perfect_levels", 0)
	]

func _on_master_slider_changed(value: float) -> void:
	SaveManager.data["settings"]["master_volume"] = value
	SaveManager.save_game()
	AudioManager.update_music_volume()

func _on_music_slider_changed(value: float) -> void:
	SaveManager.data["settings"]["music_volume"] = value
	SaveManager.save_game()
	AudioManager.update_music_volume()

func _on_sfx_slider_changed(value: float) -> void:
	SaveManager.data["settings"]["sfx_volume"] = value
	SaveManager.save_game()

func _on_haptic_toggled(toggled: bool) -> void:
	SaveManager.data["settings"]["haptic_enabled"] = toggled
	SaveManager.save_game()
	if toggled:
		AudioManager.vibrate(40)

func _on_symbol_toggled(toggled: bool) -> void:
	SaveManager.data["settings"]["colorblind_symbols"] = toggled
	SaveManager.save_game()

func _on_contrast_toggled(toggled: bool) -> void:
	SaveManager.data["settings"]["high_contrast"] = toggled
	SaveManager.save_game()

func _on_motion_toggled(toggled: bool) -> void:
	SaveManager.data["settings"]["reduced_motion"] = toggled
	SaveManager.save_game()

func _on_close_btn_pressed() -> void:
	visible = false
