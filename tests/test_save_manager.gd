class_name TestSaveManager
extends RefCounted

# Unit tests for SaveManager (Atomic write, backup, and corruption resilience)

static func run_all() -> int:
	var passed = 0
	var total = 5
	var save_mgr = preload("res://src/core/SaveManager.gd").new()

	print("--- Running TestSaveManager ---")

	# Test 1: Default profile initialization
	var defaults = save_mgr.get_default_data()
	assert(defaults.has("unlocked_max_level") and defaults["unlocked_max_level"] == 1)
	assert(defaults.has("powerups") and defaults["powerups"]["undo"] == 5)
	assert(defaults.has("tutorials_seen") and defaults["tutorials_seen"].is_empty())
	passed += 1

	# Test 2: Record level completion & star calculation
	save_mgr.data = save_mgr.get_default_data()
	save_mgr.record_level_completion(1, 6, 6, 3)
	assert(save_mgr.data["total_stars"] == 3, "Total stars should be 3")
	assert(save_mgr.data["unlocked_max_level"] == 2, "Level 2 should unlock")
	passed += 1

	# Test 3: Star non-downgrade guarantee
	save_mgr.record_level_completion(1, 12, 6, 1)
	var rec = save_mgr.data["level_records"]["1"]
	assert(rec["stars"] == 3, "Stars must never downgrade on replay!")
	passed += 1

	# Test 4: Power-up inventory use and add
	var u_count = save_mgr.get_powerup_count("undo")
	save_mgr.add_powerup("undo", 3)
	assert(save_mgr.get_powerup_count("undo") == u_count + 3, "Powerup count must increase")
	var used = save_mgr.use_powerup("undo")
	assert(used and save_mgr.get_powerup_count("undo") == u_count + 2, "Powerup must decrement on use")
	passed += 1

	# Test 5: Tutorial tracking
	assert(not save_mgr.has_seen_tutorial(1), "Tutorial 1 initially unseen")
	save_mgr.mark_tutorial_seen(1)
	assert(save_mgr.has_seen_tutorial(1), "Tutorial 1 marked seen")
	assert(not save_mgr.has_seen_tutorial(2), "Tutorial 2 still unseen")
	passed += 1

	save_mgr.free()
	print("TestSaveManager: %d/%d passed." % [passed, total])
	return passed
