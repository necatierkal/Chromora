extends Node

# Chromora - 100% Offline Deterministic Daily Quest Manager
# Generates daily quests based on local date string (YYYY-MM-DD).
# Tracks progress, verifies completion, and prevents duplicate reward claiming.

signal quest_progress_updated(quest_idx: int, current: int, target: int)
signal quest_reward_claimed(quest_idx: int, reward: Dictionary)

const QUEST_TEMPLATES = [
	{
		"id": "complete_levels",
		"title": "Bölüm Tamamlayıcı",
		"desc": "Bugün 3 farklı bölüm tamamla.",
		"target": 3,
		"reward_type": "undo",
		"reward_amount": 2
	},
	{
		"id": "earn_stars",
		"title": "Yıldız Avcısı",
		"desc": "En az 8 yeni yıldız kazan.",
		"target": 8,
		"reward_type": "hint",
		"reward_amount": 1
	},
	{
		"id": "perfect_moves",
		"title": "Kusursuz Hamle",
		"desc": "Par hamlesini aşmadan 2 bölüm bitir.",
		"target": 2,
		"reward_type": "extra_tube",
		"reward_amount": 1
	},
	{
		"id": "clean_run",
		"title": "Geri Almasız Başarı",
		"desc": "Geri alma gücünü kullanmadan 2 bölüm bitir.",
		"target": 2,
		"reward_type": "color_reveal",
		"reward_amount": 1
	},
	{
		"id": "transfers",
		"title": "Renk Akışı",
		"desc": "Toplam 25 başarılı renk aktarımı yap.",
		"target": 25,
		"reward_type": "shuffle",
		"reward_amount": 2
	}
]

var local_store: Dictionary = {}

func _get_save_data() -> Dictionary:
	var loop = Engine.get_main_loop()
	if loop and loop is SceneTree and loop.root and loop.root.has_node("SaveManager"):
		return loop.root.get_node("SaveManager").data
	return local_store

func _save_game_if_possible() -> void:
	var loop = Engine.get_main_loop()
	if loop and loop is SceneTree and loop.root and loop.root.has_node("SaveManager"):
		loop.root.get_node("SaveManager").save_game()

func get_today_date_str() -> String:
	var dt = Time.get_date_dict_from_system()
	return "%04d-%02d-%02d" % [dt.year, dt.month, dt.day]

func _hash_date_seed(date_str: String, salt: int) -> int:
	var h = salt * 31337
	for i in range(date_str.length()):
		h = ((h * 33) + date_str.unicode_at(i)) & 0x7FFFFFFF
	return abs(h)

func get_daily_quests() -> Array:
	var date_key = get_today_date_str()
	var s_data = _get_save_data()
	var dq_store: Dictionary = s_data.get("daily_quests", {})
	
	if dq_store.has(date_key):
		return dq_store[date_key]
		
	var indices = []
	var pool_size = QUEST_TEMPLATES.size()
	for i in range(3):
		var pick = _hash_date_seed(date_key, (i + 1) * 7) % pool_size
		while indices.has(pick):
			pick = (pick + 1) % pool_size
		indices.append(pick)
		
	var todays_quests = []
	for idx in indices:
		var tmpl = QUEST_TEMPLATES[idx]
		todays_quests.append({
			"id": tmpl["id"],
			"title": tmpl["title"],
			"desc": tmpl["desc"],
			"target": tmpl["target"],
			"current": 0,
			"reward_type": tmpl["reward_type"],
			"reward_amount": tmpl["reward_amount"],
			"claimed": false
		})
		
	dq_store[date_key] = todays_quests
	s_data["daily_quests"] = dq_store
	_save_game_if_possible()
	return todays_quests

func notify_event(event_type: String, value: int = 1) -> void:
	var date_key = get_today_date_str()
	var quests = get_daily_quests()
	var changed = false
	
	for i in range(quests.size()):
		var q = quests[i]
		if q["id"] == event_type and not q["claimed"]:
			var prev = q["current"]
			q["current"] = mini(q["current"] + value, q["target"])
			if q["current"] != prev:
				changed = true
				emit_signal("quest_progress_updated", i, q["current"], q["target"])
				
	if changed:
		var s_data = _get_save_data()
		var dq_store = s_data.get("daily_quests", {})
		dq_store[date_key] = quests
		s_data["daily_quests"] = dq_store
		_save_game_if_possible()

func claim_quest(quest_idx: int) -> Dictionary:
	var date_key = get_today_date_str()
	var quests = get_daily_quests()
	
	if quest_idx < 0 or quest_idx >= quests.size():
		return {"success": false, "reason": "Geçersiz görev."}
		
	var q = quests[quest_idx]
	if q["current"] < q["target"]:
		return {"success": false, "reason": "Görev henüz tamamlanmadı."}
	if q["claimed"]:
		return {"success": false, "reason": "Ödül zaten alındı."}
		
	q["claimed"] = true
	var loop = Engine.get_main_loop()
	if loop and loop is SceneTree and loop.root and loop.root.has_node("SaveManager"):
		loop.root.get_node("SaveManager").add_powerup(q["reward_type"], q["reward_amount"])
	
	var s_data = _get_save_data()
	var dq_store = s_data.get("daily_quests", {})
	dq_store[date_key] = quests
	s_data["daily_quests"] = dq_store
	_save_game_if_possible()
	
	var reward_info = {
		"type": q["reward_type"],
		"amount": q["reward_amount"],
		"name": Constants.POWERUP_NAMES.get(q["reward_type"], q["reward_type"])
	}
	emit_signal("quest_reward_claimed", quest_idx, reward_info)
	return {"success": true, "reward": reward_info}
