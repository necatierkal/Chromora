class_name TestGameplayIntegration
extends RefCounted

# Integration test simulating full gameplay flow

static func run_all() -> int:
	print("--- Running TestGameplayIntegration ---")
	var passed = 0
	var total = 5

	var loop = Engine.get_main_loop()
	var gm = loop.root.get_node("GameManager") if (loop and loop is SceneTree and loop.root and loop.root.has_node("GameManager")) else null
	var sm = loop.root.get_node("SaveManager") if (loop and loop is SceneTree and loop.root and loop.root.has_node("SaveManager")) else null

	if not gm:
		gm = preload("res://src/core/GameManager.gd").new()
		gm._ready()

	# 1. Verify 1000 levels loaded in GameManager
	assert(gm.all_levels.size() == 1000, "All 1000 levels must be loaded into memory")
	passed += 1

	# 2. Load Level 1
	gm.load_level(1)
	assert(gm.current_level_id == 1, "Current level should be 1")
	assert(not gm.current_state.is_empty(), "Current state should be populated")
	passed += 1

	# 3. Solve level 1 programmatically using PuzzleSolver
	var solution = PuzzleSolver.solve(gm.current_state, 15, 2000)
	assert(solution.solved, "Level 1 must be solved by PuzzleSolver")
	for mv in solution.moves:
		gm.select_tube(mv["from"])
		gm.select_tube(mv["to"])
	passed += 1

	# 4. Verify win state reached and recorded
	assert(gm.is_level_finished, "Level 1 should be finished")
	if sm:
		assert(sm.data["level_records"].has("1"), "SaveManager must record level 1 completion")
		assert(sm.data["unlocked_max_level"] >= 2, "Level 2 must be unlocked")
	passed += 1

	# 5. Advance to level 2
	gm.next_level()
	assert(gm.current_level_id == 2, "Current level should now be 2")
	passed += 1

	print("TestGameplayIntegration: %d/%d passed." % [passed, total])
	return passed
