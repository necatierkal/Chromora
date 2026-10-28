extends Node

# Chromora - Atomic, Robust, Versioned Local Save Manager
# 100% offline. Uses atomic temporary writes, backup rollback (.bak), and corruption recovery.

const SAVE_PATH: String = "user://chromora_save.json"
const TMP_PATH: String = "user://chromora_save.json.tmp"
const BAK_PATH: String = "user://chromora_save.json.bak"
const CURRENT_VERSION: int = 1

signal save_loaded()
signal save_updated()

var data: Dictionary = {}

func _ready() -> void:
	load_game()

func get_default_data() -> Dictionary:
	return {
		"version": CURRENT_VERSION,
		"unlocked_max_level": 1,
		"current_level": 1,
		"total_stars": 0,
		"level_records": {},
		"powerups": {
			"undo": 5,
			"hint": 3,
			"extra_tube": 2,
			"shuffle": 3,
			"color_reveal": 2
		},
		"unlocked_themes": [0], # ThemeID.MIDNIGHT default
		"selected_theme": 0,
		"tutorials_seen": [],
		"daily_quests": {},
		"settings": {
			"master_volume": 1.0,
			"music_volume": 0.8,
			"sfx_volume": 1.0,
			"haptic_enabled": true,
			"colorblind_symbols": false,
			"high_contrast": false,
			"reduced_motion": false
		},
		"stats": {
			"total_moves": 0,
			"levels_played": 0,
			"perfect_levels": 0
		}
	}

# Atomic Save to Disk
func save_game() -> bool:
	data["version"] = CURRENT_VERSION
	var json_str = JSON.stringify(data, "\t")
	
	# 1. Write to temporary file
	var tmp_file = FileAccess.open(TMP_PATH, FileAccess.WRITE)
	if not tmp_file:
		push_error("Failed to open temp save file for writing: " + str(FileAccess.get_open_error()))
		return false
	tmp_file.store_string(json_str)
	tmp_file.close()

	# 2. Verify temp file is non-empty and valid JSON
	var verify_file = FileAccess.open(TMP_PATH, FileAccess.READ)
	if not verify_file:
		return false
	var content = verify_file.get_as_text()
	verify_file.close()
	
	var test_json = JSON.new()
	if test_json.parse(content) != OK:
		push_error("Temp save file failed JSON parse check!")
		return false

	# 3. Rotate backup: if save exists, copy to .bak
	if FileAccess.file_exists(SAVE_PATH):
		if FileAccess.file_exists(BAK_PATH):
			DirAccess.remove_absolute(BAK_PATH)
		DirAccess.copy_absolute(SAVE_PATH, BAK_PATH)

	# 4. Rename temp to real save file
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	var err = DirAccess.rename_absolute(TMP_PATH, SAVE_PATH)
	if err != OK:
		# Fallback direct copy
		DirAccess.copy_absolute(TMP_PATH, SAVE_PATH)
		DirAccess.remove_absolute(TMP_PATH)

	emit_signal("save_updated")
	return true

# Load Game with Backup Rollback & Migration
func load_game() -> bool:
	var loaded_data = _try_read_json(SAVE_PATH)
	if loaded_data.is_empty() and FileAccess.file_exists(BAK_PATH):
		print("Primary save corrupted or missing; attempting backup rollback...")
		loaded_data = _try_read_json(BAK_PATH)
		
	if loaded_data.is_empty():
		print("No valid save found, initializing clean default profile.")
		data = get_default_data()
		save_game()
	else:
		data = _migrate_and_sanitize(loaded_data)
		
	emit_signal("save_loaded")
	return true

func _try_read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}
	var text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	if json.parse(text) != OK:
		return {}
	if json.data is Dictionary:
		return json.data
	return {}

func _migrate_and_sanitize(raw: Dictionary) -> Dictionary:
	var defaults = get_default_data()
	var sanitized = defaults.duplicate(true)
	
	for key in defaults.keys():
		if raw.has(key):
			if typeof(raw[key]) == typeof(defaults[key]):
				sanitized[key] = raw[key]
				
	# Re-calculate total stars safely
	var total_s = 0
	var records: Dictionary = sanitized.get("level_records", {})
	for r in records.values():
		if r is Dictionary and r.has("stars"):
			total_s += int(r["stars"])
	sanitized["total_stars"] = total_s
	
	return sanitized

# Level Record Update
func record_level_completion(level_id: int, moves: int, par_moves: int, stars: int) -> void:
	var lid_str = str(level_id)
	var records: Dictionary = data.get("level_records", {})
	var prev_record = records.get(lid_str, {})
	var prev_stars = prev_record.get("stars", 0) if prev_record is Dictionary else 0
	var prev_best_moves = prev_record.get("best_moves", 9999) if prev_record is Dictionary else 9999
	var prev_attempts = prev_record.get("attempts", 0) if prev_record is Dictionary else 0

	var new_stars = maxi(stars, prev_stars) # Stars never degrade!
	var new_best_moves = mini(moves, prev_best_moves)

	records[lid_str] = {
		"completed": true,
		"stars": new_stars,
		"best_moves": new_best_moves,
		"attempts": prev_attempts + 1,
		"completed_at": Time.get_datetime_string_from_system()
	}
	data["level_records"] = records

	# Advance unlocked max level
	var max_lvl = data.get("unlocked_max_level", 1)
	if level_id >= max_lvl and level_id < 1000:
		data["unlocked_max_level"] = level_id + 1
	data["current_level"] = mini(level_id + 1, 1000)

	# Update total stars
	var total = 0
	for rec in records.values():
		total += int(rec.get("stars", 0))
	data["total_stars"] = total

	# Stats
	var stats: Dictionary = data.get("stats", {})
	stats["total_moves"] = stats.get("total_moves", 0) + moves
	stats["levels_played"] = stats.get("levels_played", 0) + 1
	if moves <= par_moves:
		stats["perfect_levels"] = stats.get("perfect_levels", 0) + 1
	data["stats"] = stats

	# Check theme unlocks based on total stars
	_check_theme_unlocks()
	save_game()

func _check_theme_unlocks() -> void:
	var stars = data.get("total_stars", 0)
	var unlocked: Array = data.get("unlocked_themes", [0])
	
	# Unlock thresholds
	var thresholds = {
		1: 25,  # Aurora at 25 stars
		2: 75,  # Candy at 75 stars
		3: 150, # Ocean at 150 stars
		4: 250, # Sunset at 250 stars
		5: 400, # Forest at 400 stars
		6: 600  # Monochrome at 600 stars
	}
	
	for theme_id in thresholds.keys():
		if stars >= thresholds[theme_id] and not unlocked.has(theme_id):
			unlocked.append(theme_id)
			
	data["unlocked_themes"] = unlocked

# Power-up inventory management
func get_powerup_count(type_str: String) -> int:
	var p: Dictionary = data.get("powerups", {})
	return p.get(type_str, 0)

func use_powerup(type_str: String) -> bool:
	var p: Dictionary = data.get("powerups", {})
	var count = p.get(type_str, 0)
	if count > 0:
		p[type_str] = count - 1
		data["powerups"] = p
		save_game()
		return true
	return false

func add_powerup(type_str: String, amount: int = 1) -> void:
	var p: Dictionary = data.get("powerups", {})
	p[type_str] = p.get(type_str, 0) + amount
	data["powerups"] = p
	save_game()

# Tutorial tracking
func has_seen_tutorial(period_idx: int) -> bool:
	var seen: Array = data.get("tutorials_seen", [])
	return period_idx in seen

func mark_tutorial_seen(period_idx: int) -> void:
	if not data.has("tutorials_seen"):
		data["tutorials_seen"] = []
	var seen: Array = data["tutorials_seen"]
	if not (period_idx in seen):
		seen.append(period_idx)
		data["tutorials_seen"] = seen
		save_game()
