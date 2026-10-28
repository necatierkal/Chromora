class_name TestPowerUps
extends RefCounted

# Unit tests for PowerUpManager

static func run_all() -> int:
	var passed = 0
	var total = 3

	print("--- Running TestPowerUps ---")

	# Test 1: Extra Tube
	var s1 = {"tubes": [[0], [1]], "capacities": [4, 4]}
	var s1_after = PowerUpManager.execute_extra_tube(s1)
	assert(s1_after["tubes"].size() == 3, "Extra tube must add 1 empty tube")
	assert(s1_after["tubes"][2].is_empty(), "Extra tube must be empty")
	passed += 1

	# Test 2: Color Reveal
	var s2 = {
		"tubes": [[0, 1]],
		"mystery_grid": {"0": {"0": true}}
	}
	var s2_after = PowerUpManager.execute_color_reveal(s2)
	assert(s2_after["mystery_grid"].is_empty(), "Color reveal must clear mystery grid")
	passed += 1

	# Test 3: Undo
	var stack = [
		{"tubes": [[0, 1], []]},
		{"tubes": [[0], [1]]}
	]
	var prev_state = PowerUpManager.execute_undo(stack)
	assert(prev_state["tubes"][0].size() == 2, "Undo must restore previous state")
	passed += 1

	print("TestPowerUps: %d/%d passed." % [passed, total])
	return passed
