extends Node

# Chromora - Audio & Haptic Feedback Manager
# Handles polyphonic SFX, looping ambient background music, and mobile tactile haptics.

var sfx_players: Array[AudioStreamPlayer] = []
var sound_cache: Dictionary = {}

var bgm_player: AudioStreamPlayer = null
var bgm_stream: AudioStream = null

const SOUND_PATHS = {
	"tube_select": "res://assets/audio/tube_select.wav",
	"ball_move": "res://assets/audio/ball_move.wav",
	"invalid_buzz": "res://assets/audio/invalid_buzz.wav",
	"level_win": "res://assets/audio/level_win.wav",
	"star_collect": "res://assets/audio/star_collect.wav",
	"quest_complete": "res://assets/audio/quest_complete.wav",
	"powerup": "res://assets/audio/powerup.wav"
}

func _ready() -> void:
	# Create pool of 6 audio stream players for polyphony
	for i in range(6):
		var asp = AudioStreamPlayer.new()
		asp.bus = "Master"
		add_child(asp)
		sfx_players.append(asp)
		
	# Preload sounds
	for s_name in SOUND_PATHS.keys():
		var path = SOUND_PATHS[s_name]
		if ResourceLoader.exists(path):
			sound_cache[s_name] = load(path)

	# Initialize ambient BGM player
	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = "Master"
	add_child(bgm_player)
	
	var bgm_path = "res://assets/audio/bgm_ambient.wav"
	if ResourceLoader.exists(bgm_path):
		bgm_stream = load(bgm_path)
		if bgm_stream is AudioStreamWAV:
			bgm_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		bgm_player.stream = bgm_stream

func _get_setting(key: String, default_val):
	var loop = Engine.get_main_loop()
	if loop and loop is SceneTree and loop.root:
		var sm = loop.root.get_node_or_null("SaveManager")
		if sm and "data" in sm:
			return sm.data.get("settings", {}).get(key, default_val)
	return default_val

func play_sfx(sound_name: String, pitch_scale: float = 1.0) -> void:
	var sfx_vol = _get_setting("sfx_volume", 1.0)
	var master_vol = _get_setting("master_volume", 1.0)
	if sfx_vol <= 0.0 or master_vol <= 0.0:
		return
		
	if not sound_cache.has(sound_name):
		return
		
	var stream = sound_cache[sound_name]
	for asp in sfx_players:
		if not asp.playing:
			asp.stream = stream
			asp.pitch_scale = pitch_scale
			asp.volume_db = linear_to_db(sfx_vol * master_vol)
			asp.play()
			return
			
	# If all busy, use first
	sfx_players[0].stream = stream
	sfx_players[0].pitch_scale = pitch_scale
	sfx_players[0].volume_db = linear_to_db(sfx_vol * master_vol)
	sfx_players[0].play()

func play_music() -> void:
	if not bgm_player or not bgm_stream:
		return
	var music_vol = _get_setting("music_volume", 0.7)
	var master_vol = _get_setting("master_volume", 1.0)
	if music_vol <= 0.0 or master_vol <= 0.0:
		bgm_player.stop()
		return
	bgm_player.volume_db = linear_to_db(music_vol * master_vol)
	if not bgm_player.playing:
		bgm_player.play()

func stop_music() -> void:
	if bgm_player and bgm_player.playing:
		bgm_player.stop()

func update_music_volume() -> void:
	if not bgm_player:
		return
	var music_vol = _get_setting("music_volume", 0.7)
	var master_vol = _get_setting("master_volume", 1.0)
	if music_vol <= 0.0 or master_vol <= 0.0:
		if bgm_player.playing:
			bgm_player.stop()
	else:
		bgm_player.volume_db = linear_to_db(music_vol * master_vol)
		if not bgm_player.playing:
			bgm_player.play()

func vibrate(ms: int = 35) -> void:
	var haptics_on = _get_setting("haptic_enabled", true)
	if haptics_on:
		Input.vibrate_handheld(ms)
