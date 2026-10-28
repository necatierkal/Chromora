class_name PuzzleSolver
extends RefCounted

# Chromora - Fast BFS / A* Puzzle Solver
# Used for in-game Hint generation, solvability verification, and par calculations.

# Canonicalizes state into a string key to prune symmetric states
static func state_to_key(state: Dictionary) -> String:
	var tubes: Array = state.get("tubes", [])
	var parts: Array[String] = []
	for tube in tubes:
		if tube.is_empty():
			parts.append("E")
		else:
			parts.append(",".join(tube))
	# Note: We keep tube order preserved to respect tube-specific mechanics
	return "|".join(parts)

# Solves puzzle from state, returns {"solved": bool, "moves": Array, "states_explored": int}
static func solve(initial_state: Dictionary, max_depth: int = 60, max_states: int = 15000) -> Dictionary:
	var result = {
		"solved": false,
		"moves": [],
		"states_explored": 0
	}
	
	if MoveValidator.is_level_solved(initial_state):
		result.solved = true
		return result
		
	# Queue entries: [state, move_history]
	var queue: Array = []
	var visited: Dictionary = {}
	
	var start_key = state_to_key(initial_state)
	visited[start_key] = 0
	queue.append({"state": initial_state, "moves": []})
	
	var states_count = 0
	
	while not queue.is_empty():
		var current = queue.pop_front()
		var state = current["state"]
		var moves = current["moves"]
		states_count += 1
		
		if moves.size() >= max_depth:
			continue
		if states_count >= max_states:
			break
			
		var valid_moves = MoveValidator.get_valid_moves(state)
		
		# Heuristic sort: prefer moves that complete a tube or group with existing matching color
		valid_moves.sort_custom(func(a, b):
			var dst_a: Array = state["tubes"][a["to"]]
			var dst_b: Array = state["tubes"][b["to"]]
			var score_a = 0
			var score_b = 0
			if not dst_a.is_empty(): score_a += 10
			if not dst_b.is_empty(): score_b += 10
			score_a += a["count"]
			score_b += b["count"]
			return score_a > score_b
		)
		
		for mv in valid_moves:
			var next_state = MoveValidator.apply_move(state, mv["from"], mv["to"])
			
			if MoveValidator.is_level_solved(next_state):
				var final_moves = moves.duplicate()
				final_moves.append(mv)
				result.solved = true
				result.moves = final_moves
				result.states_explored = states_count
				return result
				
			var key = state_to_key(next_state)
			var new_depth = moves.size() + 1
			if not visited.has(key) or visited[key] > new_depth:
				visited[key] = new_depth
				var next_history = moves.duplicate()
				next_history.append(mv)
				queue.append({"state": next_state, "moves": next_history})
				
	result.states_explored = states_count
	return result

# Returns the best next move for Hint power-up
static func get_hint(current_state: Dictionary) -> Dictionary:
	var solution = solve(current_state, 50, 8000)
	if solution.solved and not solution.moves.is_empty():
		return solution.moves[0]
	return {}
