extends Node

# Chromora - Central Game Coordinator & State Machine
# Controls level loading, move transitions, victory flow, and scene routing.

signal level_loaded(level_data: Dictionary)
signal tube_selected(tube_idx: int)
signal tube_deselected()
signal move_executed(from_idx: int, to_idx: int, count: int)
signal move_invalid(from_idx: int, to_idx: int, reason: String)
signal level_won(level_id: int, moves: int, par_moves: int, stars: int)
signal state_updated()

var all_levels: Array = []
var current_level_id: int = 1
var current_level_data: Dictionary = {}
var current_state: Dictionary = {}
var history_stack: Array = []
var selected_tube_idx: int = -1
var is_animating: bool = false
var is_level_finished: bool = false

func _get_audio():
	var loop = Engine.get_main_loop()
	if loop and loop is SceneTree and loop.root and loop.root.has_node("AudioManager"):
		return loop.root.get_node("AudioManager")
	return null

func _get_save():
	var loop = Engine.get_main_loop()
	if loop and loop is SceneTree and loop.root and loop.root.has_node("SaveManager"):
		return loop.root.get_node("SaveManager")
	return null

func _get_daily():
	var loop = Engine.get_main_loop()
	if loop and loop is SceneTree and loop.root and loop.root.has_node("DailyQuestManager"):
		return loop.root.get_node("DailyQuestManager")
	return null

func _ready() -> void:
	_load_all_levels_data()

func _load_all_levels_data() -> void:
	var path = "res://data/levels/levels_1_1000.json"
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var text = file.get_as_text()
		file.close()
		var json = JSON.new()
		if json.parse(text) == OK and json.data is Array:
			all_levels = json.data
			print("GameManager: Loaded %d levels successfully." % all_levels.size())
		else:
			push_error("GameManager: Failed to parse levels JSON!")
	else:
		push_error("GameManager: levels JSON file not found at " + path)

func get_level_data(level_id: int) -> Dictionary:
	if level_id >= 1 and level_id <= all_levels.size():
		return all_levels[level_id - 1]
	return {}

func load_level(level_id: int) -> void:
	current_level_id = clampi(level_id, 1, maxi(all_levels.size(), 1))
	current_level_data = get_level_data(current_level_id)
	
	current_state = {
		"level_id": current_level_id,
		"tubes": current_level_data.get("tubes", []).duplicate(true),
		"capacities": current_level_data.get("capacities", []).duplicate(true),
		"mechanics": current_level_data.get("mechanics", {}).duplicate(true),
		"move_count": 0,
		"max_moves": current_level_data.get("mechanics", {}).get("max_moves", -1)
	}
	
	for k in current_state["mechanics"].keys():
		current_state[k] = current_state["mechanics"][k]
		
	history_stack.clear()
	history_stack.append(current_state.duplicate(true))
	
	selected_tube_idx = -1
	is_animating = false
	is_level_finished = false
	
	emit_signal("level_loaded", current_level_data)
	emit_signal("state_updated")

func select_tube(tube_idx: int) -> void:
	if is_animating or is_level_finished:
		return
		
	if selected_tube_idx == -1:
		var tubes: Array = current_state.get("tubes", [])
		if tube_idx < 0 or tube_idx >= tubes.size() or tubes[tube_idx].is_empty():
			return
		selected_tube_idx = tube_idx
		var audio = _get_audio()
		if audio:
			audio.play_sfx("tube_select", 1.05)
			audio.vibrate(25)
		emit_signal("tube_selected", tube_idx)
	elif selected_tube_idx == tube_idx:
		selected_tube_idx = -1
		var audio = _get_audio()
		if audio:
			audio.play_sfx("tube_select", 0.95)
		emit_signal("tube_deselected")
	else:
		var from_idx = selected_tube_idx
		var to_idx = tube_idx
		selected_tube_idx = -1
		emit_signal("tube_deselected")
		_attempt_move(from_idx, to_idx)

func _attempt_move(from_idx: int, to_idx: int) -> void:
	var check = MoveValidator.can_move(current_state, from_idx, to_idx)
	if not check.valid:
		var audio = _get_audio()
		if audio:
			audio.play_sfx("invalid_buzz", 1.0)
			audio.vibrate(50)
		emit_signal("move_invalid", from_idx, to_idx, check.reason)
		return
		
	is_animating = true
	var count = check.count
	current_state = MoveValidator.apply_move(current_state, from_idx, to_idx)
	history_stack.append(current_state.duplicate(true))
	
	var audio = _get_audio()
	if audio:
		audio.play_sfx("ball_move", 1.0 + (current_state["move_count"] % 5) * 0.05)
		audio.vibrate(20)
	var daily = _get_daily()
	if daily:
		daily.notify_event("transfers", count)
	emit_signal("move_executed", from_idx, to_idx, count)
	emit_signal("state_updated")
	
	if MoveValidator.is_level_solved(current_state):
		_on_level_completed()
	else:
		is_animating = false

func _on_level_completed() -> void:
	is_level_finished = true
	is_animating = false
	var moves = current_state.get("move_count", 0)
	var par = current_level_data.get("par_moves", moves)
	var stars_map = current_level_data.get("stars", {})
	
	var stars = 1
	if moves <= int(stars_map.get("3", par)):
		stars = 3
	elif moves <= int(stars_map.get("2", ceil(par * 1.35))):
		stars = 2
		
	var audio = _get_audio()
	if audio:
		audio.play_sfx("level_win", 1.0)
		audio.vibrate(80)
	
	var sm = _get_save()
	if sm:
		sm.record_level_completion(current_level_id, moves, par, stars)
	var daily = _get_daily()
	if daily:
		daily.notify_event("complete_levels", 1)
		daily.notify_event("earn_stars", stars)
		if moves <= par:
			daily.notify_event("perfect_moves", 1)
		
	emit_signal("level_won", current_level_id, moves, par, stars)

func undo() -> bool:
	if is_animating or is_level_finished:
		return false
	var prev = PowerUpManager.execute_undo(history_stack)
	if not prev.is_empty():
		current_state = prev.duplicate(true)
		selected_tube_idx = -1
		var audio = _get_audio()
		if audio:
			audio.play_sfx("powerup", 1.1)
			audio.vibrate(30)
		emit_signal("tube_deselected")
		emit_signal("state_updated")
		return true
	return false

func hint() -> Dictionary:
	if is_animating or is_level_finished:
		return {}
	var h = PowerUpManager.execute_hint(current_state)
	if not h.is_empty():
		var audio = _get_audio()
		if audio:
			audio.play_sfx("powerup", 1.2)
			audio.vibrate(30)
		return h
	return {}

func add_extra_tube() -> bool:
	if is_animating or is_level_finished:
		return false
	if PowerUpManager.can_add_extra_tube(current_state):
		current_state = PowerUpManager.execute_extra_tube(current_state)
		history_stack.append(current_state.duplicate(true))
		var audio = _get_audio()
		if audio:
			audio.play_sfx("powerup", 1.0)
			audio.vibrate(40)
		emit_signal("state_updated")
		return true
	return false

func shuffle() -> bool:
	if is_animating or is_level_finished:
		return false
	if PowerUpManager.can_shuffle():
		current_state = PowerUpManager.execute_shuffle(current_state)
		history_stack.append(current_state.duplicate(true))
		var audio = _get_audio()
		if audio:
			audio.play_sfx("powerup", 0.9)
			audio.vibrate(30)
		emit_signal("state_updated")
		return true
	return false

func reveal_colors() -> bool:
	if is_animating or is_level_finished:
		return false
	if PowerUpManager.can_reveal_colors(current_state):
		current_state = PowerUpManager.execute_color_reveal(current_state)
		history_stack.append(current_state.duplicate(true))
		var audio = _get_audio()
		if audio:
			audio.play_sfx("powerup", 1.3)
			audio.vibrate(30)
		emit_signal("state_updated")
		return true
	return false

func restart_level() -> void:
	load_level(current_level_id)

func next_level() -> void:
	load_level(current_level_id + 1)
