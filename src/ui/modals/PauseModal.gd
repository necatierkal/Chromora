extends Control

# Chromora - Pause & In-Game Options Modal

func _gm():
	var loop = Engine.get_main_loop()
	if loop and loop is SceneTree and loop.root:
		return loop.root.get_node_or_null("GameManager")
	return null

func show_pause() -> void:
	visible = true

func _on_resume_btn_pressed() -> void:
	visible = false

func _on_restart_btn_pressed() -> void:
	visible = false
	var gm = _gm()
	if gm:
		gm.restart_level()

func _on_map_btn_pressed() -> void:
	visible = false
	get_tree().change_scene_to_file("res://src/ui/LevelMap.tscn")

func _on_home_btn_pressed() -> void:
	visible = false
	get_tree().change_scene_to_file("res://src/ui/MainMenu.tscn")
