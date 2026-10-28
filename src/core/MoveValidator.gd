class_name MoveValidator
extends RefCounted

# Chromora - Pure Logic Move Validator
# Validates moves, calculates transferable ball count, and tests win condition.

const WARM_COLORS = [0, 3, 5, 7, 10] # Red, Yellow, Orange, Pink, Amber
const COOL_COLORS = [1, 2, 4, 6, 8, 9, 11] # Blue, Green, Purple, Cyan, Lime, Teal, Indigo

static func can_move(state: Dictionary, from_idx: int, to_idx: int) -> Dictionary:
	var result = {
		"valid": false,
		"count": 0,
		"reason": ""
	}
	
	var tubes = state.get("tubes", [])
	var capacities = state.get("capacities", [])
	var num_tubes = tubes.size()
	
	# Range checks
	if from_idx < 0 or from_idx >= num_tubes or to_idx < 0 or to_idx >= num_tubes:
		result.reason = "Geçersiz tüp indeksi."
		return result
	
	if from_idx == to_idx:
		result.reason = "Aynı tüp seçilemez."
		return result
		
	var src: Array = tubes[from_idx]
	var dst: Array = tubes[to_idx]
	
	if src.is_empty():
		result.reason = "Kaynak tüp boş."
		return result
		
	var dst_cap = capacities[to_idx] if to_idx < capacities.size() else 4
	var free_space = dst_cap - dst.size()
	if free_space <= 0:
		result.reason = "Hedef tüp tamamen dolu."
		return result

	# Check Locked Tubes mechanic
	var locked = state.get("locked_tubes", {})
	if locked.has(from_idx) and locked[from_idx] == true:
		result.reason = "Kaynak tüp kilitli!"
		return result
	if locked.has(to_idx) and locked[to_idx] == true:
		result.reason = "Hedef tüp kilitli!"
		return result

	# Check Temporary Barriers (pulsing barrier: blocked on odd moves)
	var barriers = state.get("barriers", {})
	var move_count = state.get("move_count", 0)
	if barriers.has(from_idx) and (move_count % 2 == 1):
		result.reason = "Tüp bariyeri şu an kapalı."
		return result
	if barriers.has(to_idx) and (move_count % 2 == 1):
		result.reason = "Tüp bariyeri şu an kapalı."
		return result

	# Check One-Way Tubes mechanic
	var one_way = state.get("one_way", {})
	if one_way.has(from_idx) and one_way[from_idx] == "in_only":
		result.reason = "Bu tüp yalnızca giriş kabul eder."
		return result
	if one_way.has(to_idx) and one_way[to_idx] == "out_only":
		result.reason = "Bu tüpten yalnızca top çıkarılabilir."
		return result

	var top_color: int = src.back()
	
	# Check Fixed Color Tube mechanic
	var fixed_colors = state.get("fixed_colors", {})
	if fixed_colors.has(to_idx):
		var req_color = fixed_colors[to_idx]
		if req_color != top_color:
			result.reason = "Bu tüp yalnızca belirlenen rengi kabul eder."
			return result

	# Check Color Filter Gates mechanic
	var color_filters = state.get("color_filters", {})
	if color_filters.has(to_idx):
		var filter_type = color_filters[to_idx]
		if filter_type == "warm" and not (top_color in WARM_COLORS):
			result.reason = "Bu tüp yalnızca sıcak renkleri kabul eder."
			return result
		elif filter_type == "cool" and not (top_color in COOL_COLORS):
			result.reason = "Bu tüp yalnızca soğuk renkleri kabul eder."
			return result

	# Check Standard Color Compatibility:
	# Target must be either empty OR top ball must match source top ball
	if not dst.is_empty():
		var dst_top: int = dst.back()
		if dst_top != top_color:
			result.reason = "Renkler eşleşmiyor."
			return result

	# Check count of contiguous matching balls at top of source
	var matching_count = 0
	for i in range(src.size() - 1, -1, -1):
		if src[i] == top_color:
			matching_count += 1
		else:
			break
			
	# Move count is minimum of matching balls and available destination space
	var count_to_move = mini(matching_count, free_space)
	if count_to_move <= 0:
		result.reason = "Taşınacak top yok veya yer yetersiz."
		return result

	# Check Sealed Pairs mechanic (balls that cannot be separated)
	var sealed_pairs = state.get("sealed_pairs", [])
	if sealed_pairs.has(from_idx):
		# If a pair is sealed in this tube and count_to_move would break it
		if count_to_move < 2 and src.size() >= 2 and src[src.size() - 1] == src[src.size() - 2]:
			if free_space < 2:
				result.reason = "Mühürlü top çifti ayrılamaz; hedefte 2 boşluk gerekli."
				return result
			count_to_move = 2

	# Move Budget mechanic (fail if budget is exhausted)
	var max_moves = state.get("max_moves", -1)
	if max_moves > 0 and move_count >= max_moves:
		result.reason = "Hamle kotası doldu!"
		return result

	result.valid = true
	result.count = count_to_move
	result.reason = "Geçerli hamle."
	return result

# Applies move and returns updated state dictionary
static func apply_move(state: Dictionary, from_idx: int, to_idx: int) -> Dictionary:
	var check = can_move(state, from_idx, to_idx)
	if not check.valid:
		return state
		
	# Deep copy state
	var new_state = state.duplicate(true)
	var count = check.count
	var src: Array = new_state["tubes"][from_idx]
	var dst: Array = new_state["tubes"][to_idx]
	
	var moving_balls = []
	for _i in range(count):
		moving_balls.append(src.pop_back())
		
	# Check Color Converter mechanic on target tube
	var converters = new_state.get("converters", {})
	if converters.has(to_idx):
		var conv_map: Dictionary = converters[to_idx]
		for i in range(moving_balls.size()):
			var c = moving_balls[i]
			if conv_map.has(c):
				moving_balls[i] = conv_map[c]
				
	for b in moving_balls:
		dst.append(b)
		
	new_state["move_count"] = new_state.get("move_count", 0) + 1
	
	# Update unlock status for locked tubes if unlock condition met
	var locked = new_state.get("locked_tubes", {})
	var lock_unlock_moves = new_state.get("lock_unlock_moves", {})
	for tube_idx in locked.keys():
		if locked[tube_idx] == true and lock_unlock_moves.has(tube_idx):
			if new_state["move_count"] >= lock_unlock_moves[tube_idx]:
				locked[tube_idx] = false
				
	# Reveal mystery ball under uncovered slot if applicable
	var mystery_grid = new_state.get("mystery_grid", {})
	if mystery_grid.has(from_idx):
		var tube_mysteries: Dictionary = mystery_grid[from_idx]
		var new_top_idx = src.size() - 1
		if tube_mysteries.has(new_top_idx):
			tube_mysteries[new_top_idx] = false # Revealed!
			
	return new_state

# Checks if the entire puzzle state meets win criteria
static func is_level_solved(state: Dictionary) -> bool:
	var tubes: Array = state.get("tubes", [])
	var capacities: Array = state.get("capacities", [])
	
	# Check Ordered Targets mechanic
	var ordered_targets = state.get("ordered_targets", [])
	var ordered_order = state.get("ordered_order", []) # desired color order for target tubes
	if not ordered_targets.is_empty():
		for i in range(ordered_targets.size()):
			var t_idx = ordered_targets[i]
			if t_idx >= tubes.size():
				return false
			var target_tube: Array = tubes[t_idx]
			var cap = capacities[t_idx] if t_idx < capacities.size() else 4
			if target_tube.size() != cap:
				return false
			if not is_tube_uniform(target_tube):
				return false
			if i < ordered_order.size() and target_tube[0] != ordered_order[i]:
				return false

	# Standard win rule:
	# Every non-empty tube must be FULL and contain only ONE color!
	for i in range(tubes.size()):
		var tube: Array = tubes[i]
		if tube.is_empty():
			continue
		var cap = capacities[i] if i < capacities.size() else 4
		if tube.size() != cap:
			return false
		if not is_tube_uniform(tube):
			return false
			
	return true

static func is_tube_uniform(tube: Array) -> bool:
	if tube.is_empty():
		return true
	var color = tube[0]
	for c in tube:
		if c != color:
			return false
	return true

static func get_valid_moves(state: Dictionary) -> Array:
	var valid_moves = []
	var tubes: Array = state.get("tubes", [])
	var count = tubes.size()
	for i in range(count):
		if tubes[i].is_empty():
			continue
		for j in range(count):
			if i == j:
				continue
			var check = can_move(state, i, j)
			if check.valid:
				valid_moves.append({"from": i, "to": j, "count": check.count})
	return valid_moves
