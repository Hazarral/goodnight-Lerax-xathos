extends Node

## Emitted by the action event itself to seek a single target
@warning_ignore("unused_signal")
signal target_requested(
	action_event : ActionEvent, 
	target_faction : ActionEvent.TargetFaction, 
	target_state : ActionEvent.TargetState
)

## If the entity is null, it is the same as cancelling, or there is no target and this cannot be casted
@warning_ignore("unused_signal")
signal target_resolved(entity : Entity)

## When a target die due to self-harm, typically
@warning_ignore("unused_signal")
signal force_refresh_turn_ui()

## When the combat system inished initializing
@warning_ignore("unused_signal")
signal combat_initialization_finished()

## When the CombatSystem finishes processing its queue and has released the lock
@warning_ignore("unused_signal")
signal combat_event_queue_processing_finished()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit_game"):
		get_tree().quit()
	
	if event.is_action_pressed("toggle_fullscreen"):
		toggle_fullscreen()
		print("Toggled fullscreenq")

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
