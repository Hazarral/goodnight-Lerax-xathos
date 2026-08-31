class_name Player
extends Entity

## Number of hours in a day, this is based on Denos En
const TIME_BASE := 36
const STARTING_DAY_COUNT := 7

## This is in hours
var time_to_live : int = 0

const TIME_TO_LIVE_TEXT := "%d Day%s, %d Hour%s"

func _init(base_template : EntityTemplate, p_magnification : float = 1.0) -> void:
	super(base_template, p_magnification)
	setup_time_to_live()

func setup_time_to_live() -> void:
	time_to_live = TIME_BASE * STARTING_DAY_COUNT

func add_time_to_live(hours : int) -> void:
	time_to_live += hours

func reduce_time_to_live(hours : int) -> void:
	time_to_live -= hours

func get_current_time_to_live() -> int:
	return time_to_live

func get_time_to_live_str() -> String:
	@warning_ignore("integer_division")
	var days : int = time_to_live / TIME_BASE
	var hours : int = time_to_live % TIME_BASE
	
	return TIME_TO_LIVE_TEXT % [
		days,
		"s" if days != 1 else "",
		hours,
		"s" if hours != 1 else ""
	]
