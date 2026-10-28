class_name PowerUpManager
extends RefCounted

# Chromora - Power-Up Logic & Execution Controller

static func _get_save_mgr():
	var loop = Engine.get_main_loop()
	if loop and loop is SceneTree and loop.root:
		return loop.root.get_node_or_null("SaveManager")
	return null

# Undo: Pops last state from history stack
static func can_undo(history_stack: Array) -> bool:
	var sm = _get_save_mgr()
	var count = sm.get_powerup_count("undo") if sm else 1
	return history_stack.size() > 1 and count > 0

static func execute_undo(history_stack: Array) -> Dictionary:
	if not can_undo(history_stack):
		return {}
	var sm = _get_save_mgr()
	if sm:
		sm.use_powerup("undo")
	history_stack.pop_back() # Discard current state
	var previous_state = history_stack.back()
	return previous_state

# Hint: Finds next valid move using BFS solver
static func can_hint() -> bool:
	var sm = _get_save_mgr()
	var count = sm.get_powerup_count("hint") if sm else 1
	return count > 0

static func execute_hint(current_state: Dictionary) -> Dictionary:
	if not can_hint():
		return {}
	var hint_move = PuzzleSolver.get_hint(current_state)
	if not hint_move.is_empty():
		var sm = _get_save_mgr()
		if sm:
			sm.use_powerup("hint")
	return hint_move

# Extra Tube: Adds temporary empty buffer tube
static func can_add_extra_tube(current_state: Dictionary) -> bool:
	var sm = _get_save_mgr()
	var count = sm.get_powerup_count("extra_tube") if sm else 1
	if count <= 0:
		return false
	var tubes: Array = current_state.get("tubes", [])
	return tubes.size() < 12 # Safety max tube limit

static func execute_extra_tube(current_state: Dictionary, cap: int = 4) -> Dictionary:
	if not can_add_extra_tube(current_state):
		return current_state
	var sm = _get_save_mgr()
	if sm:
		sm.use_powerup("extra_tube")
	var new_state = current_state.duplicate(true)
	new_state["tubes"].append([])
	new_state["capacities"].append(cap)
	return new_state

# Shuffle: Valid reordering of top balls across non-empty tubes
static func can_shuffle() -> bool:
	var sm = _get_save_mgr()
	var count = sm.get_powerup_count("shuffle") if sm else 1
	return count > 0

static func execute_shuffle(current_state: Dictionary) -> Dictionary:
	if not can_shuffle():
		return current_state
		
	var tubes: Array = current_state.get("tubes", [])
	var top_balls = []
	var source_indices = []
	
	for i in range(tubes.size()):
		if not tubes[i].is_empty():
			top_balls.append(tubes[i].pop_back())
			source_indices.append(i)
			
	if top_balls.size() <= 1:
		for idx in range(top_balls.size()):
			tubes[source_indices[idx]].append(top_balls[idx])
		return current_state
		
	# Rotate top balls
	top_balls.push_back(top_balls.pop_front())
	for idx in range(top_balls.size()):
		tubes[source_indices[idx]].append(top_balls[idx])
		
	var sm = _get_save_mgr()
	if sm:
		sm.use_powerup("shuffle")
	return current_state

# Color Reveal: Reveals all mystery balls in current level
static func can_reveal_colors(current_state: Dictionary) -> bool:
	var sm = _get_save_mgr()
	var count = sm.get_powerup_count("color_reveal") if sm else 1
	if count <= 0:
		return false
	return current_state.has("mystery_grid") and not current_state["mystery_grid"].is_empty()

static func execute_color_reveal(current_state: Dictionary) -> Dictionary:
	if not can_reveal_colors(current_state):
		return current_state
	var sm = _get_save_mgr()
	if sm:
		sm.use_powerup("color_reveal")
	var new_state = current_state.duplicate(true)
	new_state["mystery_grid"] = {} # All revealed!
	return new_state
