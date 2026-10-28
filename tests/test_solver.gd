class_name TestSolver
extends RefCounted

# Unit tests for PuzzleSolver & Hint Generation

static func run_all() -> int:
	var passed = 0
	var total = 3

	print("--- Running TestSolver ---")

	# Test 1: 1-move trivial puzzle
	var s1 = {
		"tubes": [[0, 0, 0], [0]],
		"capacities": [4, 4]
	}
	var res1 = PuzzleSolver.solve(s1, 10, 500)
	assert(res1.solved, "Solver should solve 1-move puzzle")
	assert(res1.moves.size() == 1, "Should take exactly 1 move")
	passed += 1

	# Test 2: 3-move puzzle
	# Tube 0: [0, 1]
	# Tube 1: [1, 0]
	# Tube 2: []
	var s2 = {
		"tubes": [[0, 1], [1, 0], []],
		"capacities": [2, 2, 2]
	}
	var res2 = PuzzleSolver.solve(s2, 10, 1000)
	assert(res2.solved, "Solver should solve 3-move puzzle")
	passed += 1

	# Test 3: Hint generation
	var hint = PuzzleSolver.get_hint(s2)
	assert(not hint.is_empty(), "Hint should return a valid move")
	assert(hint.has("from") and hint.has("to"), "Hint structure must have from/to")
	passed += 1

	print("TestSolver: %d/%d passed." % [passed, total])
	return passed
