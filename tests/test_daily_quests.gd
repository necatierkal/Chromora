class_name TestDailyQuests
extends RefCounted

# Unit tests for DailyQuestManager (Deterministic offline quests & claiming)

static func run_all() -> int:
	var passed = 0
	var total = 3
	var dq_mgr = preload("res://src/core/DailyQuestManager.gd").new()

	print("--- Running TestDailyQuests ---")

	# Test 1: Deterministic generation
	var quests1 = dq_mgr.get_daily_quests()
	assert(quests1.size() == 3, "Must generate exactly 3 daily quests")
	var q_id_first = quests1[0]["id"]

	# Second call on same day must return identical quests
	var quests2 = dq_mgr.get_daily_quests()
	assert(quests2[0]["id"] == q_id_first, "Quests must remain deterministic and identical on same day")
	passed += 1

	# Test 2: Progress notification
	var target_type = quests1[0]["id"]
	var target_val = quests1[0]["target"]
	dq_mgr.notify_event(target_type, target_val)
	var updated_quests = dq_mgr.get_daily_quests()
	assert(updated_quests[0]["current"] >= target_val, "Progress must update")
	passed += 1

	# Test 3: Claim reward & prevent duplicate claim
	var claim_res1 = dq_mgr.claim_quest(0)
	assert(claim_res1.get("success", false), "First claim should succeed")
	var claim_res2 = dq_mgr.claim_quest(0)
	assert(not claim_res2.get("success", true), "Second claim on same quest must fail")
	passed += 1

	dq_mgr.free()
	print("TestDailyQuests: %d/%d passed." % [passed, total])
	return passed
