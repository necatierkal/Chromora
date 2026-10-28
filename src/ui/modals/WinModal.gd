extends Control

# Chromora - Victory & Star Celebration Modal

signal next_level_requested()
signal restart_requested()
signal map_requested()

@onready var title_label: Label = $Panel/VBox/TitleLabel
@onready var star1: Label = $Panel/VBox/StarRow/Star1
@onready var star2: Label = $Panel/VBox/StarRow/Star2
@onready var star3: Label = $Panel/VBox/StarRow/Star3
@onready var stats_label: Label = $Panel/VBox/StatsLabel

func _gm():
	var loop = Engine.get_main_loop()
	if loop and loop is SceneTree and loop.root:
		return loop.root.get_node_or_null("GameManager")
	return null

func _am():
	var loop = Engine.get_main_loop()
	if loop and loop is SceneTree and loop.root:
		return loop.root.get_node_or_null("AudioManager")
	return null

func show_win(level_id: int, moves: int, par_moves: int, stars: int) -> void:
	visible = true
	title_label.text = "Bölüm %d Tamamlandı!" % level_id
	stats_label.text = "Yapılan Hamle: %d\nHedef Par: %d" % [moves, par_moves]

	# Star animation
	star1.modulate = Color(1, 1, 1, 0.2)
	star2.modulate = Color(1, 1, 1, 0.2)
	star3.modulate = Color(1, 1, 1, 0.2)

	var tween = create_tween()
	var am = _am()
	if stars >= 1:
		if am:
			tween.tween_callback(func(): am.play_sfx("star_collect", 1.0))
		tween.tween_property(star1, "modulate", Color("#fde047"), 0.25)
	if stars >= 2:
		tween.tween_interval(0.15)
		if am:
			tween.tween_callback(func(): am.play_sfx("star_collect", 1.15))
		tween.tween_property(star2, "modulate", Color("#fde047"), 0.25)
	if stars >= 3:
		tween.tween_interval(0.15)
		if am:
			tween.tween_callback(func(): am.play_sfx("star_collect", 1.3))
		tween.tween_property(star3, "modulate", Color("#fde047"), 0.25)

func _on_next_btn_pressed() -> void:
	visible = false
	var gm = _gm()
	if gm:
		gm.next_level()

func _on_replay_btn_pressed() -> void:
	visible = false
	var gm = _gm()
	if gm:
		gm.restart_level()

func _on_map_btn_pressed() -> void:
	visible = false
	get_tree().change_scene_to_file("res://src/ui/LevelMap.tscn")
