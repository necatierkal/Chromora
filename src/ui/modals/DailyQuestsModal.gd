extends Control

# Chromora - Daily Quests Modal (100% Offline)

@onready var quest_list_container: VBoxContainer = $Panel/VBox/Scroll/QuestList

func _ready() -> void:
	DailyQuestManager.connect("quest_progress_updated", Callable(self, "_on_quest_progress_updated"))
	DailyQuestManager.connect("quest_reward_claimed", Callable(self, "_on_reward_claimed"))

func show_quests() -> void:
	visible = true
	_refresh_quests_ui()

func _refresh_quests_ui() -> void:
	for c in quest_list_container.get_children():
		c.queue_free()

	var quests = DailyQuestManager.get_daily_quests()
	for i in range(quests.size()):
		var q = quests[i]
		var card = _create_quest_card(i, q)
		quest_list_container.add_child(card)

func _create_quest_card(idx: int, q: Dictionary) -> PanelContainer:
	var pc = PanelContainer.new()
	pc.custom_minimum_size = Vector2(0, 110)
	
	var hbox = HBoxContainer.new()
	hbox.theme_override_constants.separation = 16
	pc.add_child(hbox)

	var info_box = VBoxContainer.new()
	info_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_box.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_child(info_box)

	var title = Label.new()
	title.text = q["title"]
	title.add_theme_font_size_override("font_size", 24)
	info_box.add_child(title)

	var desc = Label.new()
	desc.text = q["desc"]
	desc.add_theme_font_size_override("font_size", 18)
	desc.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	info_box.add_child(desc)

	var prog = ProgressBar.new()
	prog.custom_minimum_size = Vector2(0, 16)
	prog.max_value = q["target"]
	prog.value = q["current"]
	info_box.add_child(prog)

	var action_btn = Button.new()
	action_btn.custom_minimum_size = Vector2(160, 64)
	action_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	if q["claimed"]:
		action_btn.text = "Alındı ✓"
		action_btn.disabled = true
	elif q["current"] >= q["target"]:
		action_btn.text = "Ödülü Al!"
		action_btn.connect("pressed", Callable(self, "_claim_quest").bind(idx))
	else:
		action_btn.text = "%d / %d" % [q["current"], q["target"]]
		action_btn.disabled = true
	hbox.add_child(action_btn)

	return pc

func _claim_quest(idx: int) -> void:
	var res = DailyQuestManager.claim_quest(idx)
	if res.get("success", false):
		AudioManager.play_sfx("quest_complete", 1.0)
		AudioManager.vibrate(60)
		_refresh_quests_ui()

func _on_quest_progress_updated(_idx: int, _cur: int, _tgt: int) -> void:
	if visible:
		_refresh_quests_ui()

func _on_reward_claimed(_idx: int, _reward: Dictionary) -> void:
	if visible:
		_refresh_quests_ui()

func _on_close_btn_pressed() -> void:
	visible = false
