class_name TestUIControls
extends RefCounted

# Unit tests verifying TubeView touch interaction, valid move highlights,
# power-up buttons, and dynamic board rebuilding.

static func run_all() -> int:
	print("--- Running TestUIControls ---")
	var passed = 0
	var total = 6
	
	var loop = Engine.get_main_loop()
	var root = loop.root if (loop and loop is SceneTree) else null
	
	var sm = root.get_node("SaveManager") if (root and root.has_node("SaveManager")) else null
	if not sm:
		sm = preload("res://src/core/SaveManager.gd").new()
		sm.name = "SaveManager"
		sm._ready()
		if root:
			root.add_child(sm)

	var tm = root.get_node("ThemeManager") if (root and root.has_node("ThemeManager")) else null
	if not tm:
		tm = preload("res://src/core/ThemeManager.gd").new()
		tm.name = "ThemeManager"
		tm._ready()
		if root:
			root.add_child(tm)

	var am = root.get_node("AudioManager") if (root and root.has_node("AudioManager")) else null
	if not am:
		am = preload("res://src/core/AudioManager.gd").new()
		am.name = "AudioManager"
		am._ready()
		if root:
			root.add_child(am)

	var gm = root.get_node("GameManager") if (root and root.has_node("GameManager")) else null
	if not gm:
		gm = preload("res://src/core/GameManager.gd").new()
		gm.name = "GameManager"
		gm._ready()
		if root:
			root.add_child(gm)

	# 1. Test TubeView setup and touch button presence
	var tv0 = TubeView.new()
	tv0.setup(0, 4, 110.0)
	tv0.set_balls([0, 0, 1, 1])
	assert(tv0.touch_button != null, "TubeView must have dedicated touch_button for 100% reliable mobile tapping")
	assert(tv0.touch_button.mouse_filter == Control.MOUSE_FILTER_STOP, "touch_button must stop mouse events to capture clicks")
	for b in tv0.ball_views:
		assert(b.mouse_filter == Control.MOUSE_FILTER_IGNORE, "BallView must IGNORE mouse filter so it doesn't block tube clicks")
	passed += 1

	# 2. Test touch button click signal emission & selection
	var click_box = [-1]
	tv0.connect("tube_clicked", func(idx): click_box[0] = idx)
	tv0._on_touch_button_pressed()
	assert(click_box[0] == 0, "touch_button press must emit tube_clicked with tube index")
	tv0.set_selected(true)
	assert(tv0.is_selected, "TubeView must be in selected state")
	passed += 1

	# 3. Test valid target highlight
	var tv2 = TubeView.new()
	tv2.setup(2, 4, 110.0)
	tv2.set_balls([])
	tv2.set_valid_target(true)
	assert(tv2.is_valid_target, "Empty tube must be marked as valid target")
	passed += 1

	# 4. Test ball transfer in GameManager via tube clicks
	gm.load_level(1)
	assert(gm.current_state["tubes"][0].size() == 2, "Tube 0 must initially have 2 balls")
	assert(gm.current_state["tubes"][2].size() == 4, "Tube 2 must initially have 4 balls")
	# Transfer red ball from Tube 2 to Tube 0
	gm.select_tube(2) # Select tube 2
	assert(gm.selected_tube_idx == 2, "Tube 2 must be selected in GameManager")
	gm.select_tube(0) # Transfer to tube 0
	assert(gm.selected_tube_idx == -1, "Tube must be deselected after transfer")
	assert(gm.current_state["tubes"][0].size() > 2, "Tube 0 must now have the transferred red ball")
	passed += 1

	# 5. Test Undo execution
	var before_undo = gm.current_state["tubes"][0].size()
	assert(before_undo > 2, "Tube 0 must have gained a ball before undo")
	assert(gm.undo(), "GameManager.undo() must succeed")
	assert(gm.current_state["tubes"][0].size() == 2, "Tube 0 must be back to 2 balls after undo")
	passed += 1

	# 6. Test Extra Tube addition
	var initial_tubes = gm.current_state["tubes"].size()
	assert(gm.add_extra_tube(), "GameManager.add_extra_tube() must succeed")
	assert(gm.current_state["tubes"].size() == initial_tubes + 1, "State tubes count must increase by 1")
	passed += 1

	tv0.free()
	tv2.free()

	print("TestUIControls: %d/%d passed." % [passed, total])
	return passed
