class_name TestMoveValidator
extends RefCounted

# Unit tests for MoveValidator pure logic

static func run_all() -> int:
	var passed = 0
	var total = 8

	print("--- Running TestMoveValidator ---")

	# Test 1: Empty source rejected
	var s1 = {"tubes": [[], [0, 0]], "capacities": [4, 4]}
	var r1 = MoveValidator.can_move(s1, 0, 1)
	assert(not r1.valid, "Empty source should not be able to move")
	passed += 1

	# Test 2: Full target rejected
	var s2 = {"tubes": [[0], [0, 0, 0, 0]], "capacities": [4, 4]}
	var r2 = MoveValidator.can_move(s2, 0, 1)
	assert(not r2.valid, "Full destination should be rejected")
	passed += 1

	# Test 3: Color mismatch rejected
	var s3 = {"tubes": [[0], [1, 1]], "capacities": [4, 4]}
	var r3 = MoveValidator.can_move(s3, 0, 1)
	assert(not r3.valid, "Mismatched color should be rejected")
	passed += 1

	# Test 4: Valid move to empty tube
	var s4 = {"tubes": [[0, 0], []], "capacities": [4, 4]}
	var r4 = MoveValidator.can_move(s4, 0, 1)
	assert(r4.valid and r4.count == 2, "Should move 2 matching balls to empty tube")
	passed += 1

	# Test 5: Valid move to matching top color
	var s5 = {"tubes": [[1, 0], [0]], "capacities": [4, 4]}
	var r5 = MoveValidator.can_move(s5, 0, 1)
	assert(r5.valid and r5.count == 1, "Should move 1 matching ball")
	passed += 1

	# Test 6: Locked tube mechanic
	var s6 = {
		"tubes": [[0], []],
		"capacities": [4, 4],
		"locked_tubes": {0: true}
	}
	var r6 = MoveValidator.can_move(s6, 0, 1)
	assert(not r6.valid, "Locked tube should block move")
	passed += 1

	# Test 7: Fixed color mechanic
	var s7 = {
		"tubes": [[1], []],
		"capacities": [4, 4],
		"fixed_colors": {1: 0} # tube 1 only accepts color 0
	}
	var r7 = MoveValidator.can_move(s7, 0, 1)
	assert(not r7.valid, "Fixed color tube should reject non-matching color")
	passed += 1

	# Test 8: Win condition check
	var s8 = {"tubes": [[0, 0, 0, 0], [1, 1, 1, 1], []], "capacities": [4, 4, 4]}
	assert(MoveValidator.is_level_solved(s8), "Full uniform tubes should be considered solved")
	passed += 1

	print("TestMoveValidator: %d/%d passed." % [passed, total])
	return passed
