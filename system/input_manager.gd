extends Node

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit_game"):
		get_tree().quit()
	
	if event.is_action_pressed("toggle_fullscreen"):
		toggle_fullscreen()
		print("Toggled fullscreenq")
	
	if event.is_action_pressed("god_mode"):
		var the_draechen := CombatSystem.get_the_draechen()
		if the_draechen:
			the_draechen.toggle_godmode()

func toggle_fullscreen() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		set_windowed()
	else:
		set_borderless_fullscreen()

func set_windowed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)

func set_borderless_fullscreen() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
