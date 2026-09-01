class_name Draechen
extends Entity

var shield_points : int

## Number of hours in a day, this is based on Denos En
const TIME_BASE := 36
const STARTING_DAY_COUNT := 7

## This is in hours
var time_to_live : int = 0

var is_god_mode : bool = false

const TIME_TO_LIVE_TEXT := "%d Day%s, %d Hour%s"

func _init(base_template : DraechenTemplate, p_magnification : float = 1.0) -> void:
	template = base_template
	magnification = p_magnification
	
	current_hp = get_max_hp()
	current_potency = get_potency()
	current_mastery = get_mastery()
	shield_points = get_shield_points()
	setup_shields()
	setup_active_dot_arrays()
	setup_action_points()
	setup_innate_actions()
	
	current_state = State.ALIVE
	setup_time_to_live()
	is_god_mode = false

func get_shield_points() -> int:
	return ceili(template.STARTING_SHIELD_POINT * magnification)

func setup_shields() -> void:
	var draechen_template := template as DraechenTemplate
	
	max_shields = PackedInt64Array()
	max_shields.resize(DamageAndDoT.ELEMENT_COUNT)
	current_shields.resize(DamageAndDoT.ELEMENT_COUNT)
	
	var base_points := shield_points / DamageAndDoT.ELEMENT_COUNT
	var remainder := shield_points % DamageAndDoT.ELEMENT_COUNT
	
	for i in range(DamageAndDoT.ELEMENT_COUNT):
		var points_for_element := base_points + (1 if i < remainder else 0)
		max_shields[i] = points_for_element * draechen_template.SHIELD_POINT_VALUE
		current_shields[i] = max_shields[i]
	
	print("Draechen max shields: %s" % max_shields)

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

func toggle_godmode() -> void:
	is_god_mode = not is_god_mode
	print("Implement god mode later, please. Godmode = %s" % is_god_mode)
