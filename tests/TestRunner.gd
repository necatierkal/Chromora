extends SceneTree

# Chromora - Automated Headless Test Runner

const TestMoveValidator = preload("res://tests/test_move_validator.gd")
const TestSolver = preload("res://tests/test_solver.gd")
const TestSaveManager = preload("res://tests/test_save_manager.gd")
const TestDailyQuests = preload("res://tests/test_daily_quests.gd")
const TestPowerUps = preload("res://tests/test_powerups.gd")
const TestGameplayIntegration = preload("res://tests/test_gameplay_integration.gd")
const TestUIControls = preload("res://tests/test_ui_controls.gd")

func _init() -> void:
	print("\n==========================================")
	print("   CHROMORA HEADLESS TEST SUITE")
	print("==========================================\n")

	var total_tests = 0
	var passed_tests = 0

	total_tests += 8
	passed_tests += TestMoveValidator.run_all()

	total_tests += 3
	passed_tests += TestSolver.run_all()

	total_tests += 5
	passed_tests += TestSaveManager.run_all()

	total_tests += 3
	passed_tests += TestDailyQuests.run_all()

	total_tests += 3
	passed_tests += TestPowerUps.run_all()

	total_tests += 5
	passed_tests += TestGameplayIntegration.run_all()

	total_tests += 6
	passed_tests += TestUIControls.run_all()

	print("\n==========================================")
	print("RESULTS: %d / %d TESTS PASSED" % [passed_tests, total_tests])
	print("==========================================\n")

	if passed_tests == total_tests:
		print("ALL TESTS PASSED SUCCESSFULLY! (Exit Code 0)\n")
		quit(0)
	else:
		push_error("SOME TESTS FAILED! (Exit Code 1)\n")
		quit(1)
