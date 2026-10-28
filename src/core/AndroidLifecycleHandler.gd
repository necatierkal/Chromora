extends Node

# Chromora - Android Lifecycle, Hardware Back Button & Safe Area Handler

signal back_pressed()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT:
			# Backgrounding event: ensure player progress is persistently saved
			SaveManager.save_game()
		NOTIFICATION_WM_GO_BACK_REQUEST:
			# Hardware Android Back Button pressed
			_handle_back_request()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_BACK or event.keycode == KEY_ESCAPE:
			_handle_back_request()
			get_viewport().set_input_as_handled()

func _handle_back_request() -> void:
	emit_signal("back_pressed")

func get_safe_area_margins() -> Rect2:
	# Checks display safe area insets (camera cutouts, notches)
	var safe_area = DisplayServer.get_display_safe_area()
	var window_size = DisplayServer.window_get_size()
	if safe_area.size.x == 0 or safe_area.size.y == 0:
		return Rect2(0, 0, window_size.x, window_size.y)
	return safe_area
