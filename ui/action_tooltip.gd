extends CanvasLayer

@onready var action_name_label := $ActionTooltip/VBoxContainer/Header/ActionName
@onready var action_point_cost_label := $ActionTooltip/VBoxContainer/Header/APCost
@onready var cooldown_label := $ActionTooltip/VBoxContainer/Header/Cooldown

const AP_COST_TEXT := "%d AP"
const COOLDOWN_TEXT := "%d CD"

@onready var description := $ActionTooltip/VBoxContainer/Description

var _current_action : Action = null
var _detailed_mode := false

func _ready() -> void:
	hide()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("show_detailed_tooltip"):
		set_detailed_mode(true)
	elif event.is_action_released("show_detailed_tooltip"):
		set_detailed_mode(false)

func set_detailed_mode(value : bool) -> void:
	if _detailed_mode == value:
		return
	_detailed_mode = value
	if _current_action != null:
		description.text = _compile_description(_current_action.description_segments, _detailed_mode)

func render(action : Action) -> void:
	_current_action = action
	action_name_label.text = action.action_name
	action_point_cost_label.text = AP_COST_TEXT % action.action_point_cost
	cooldown_label.text = COOLDOWN_TEXT % action.cooldown
	description.text = _compile_description(action.description_segments)

func _compile_description(segments : Array[DescriptionSegment], detailed : bool = false) -> String:
	var result := ""
	var previous : DescriptionSegment = null
	for seg in segments:
		var is_suppressed := previous != null and previous.suppresses_following_space()
		if previous != null and seg.wants_leading_space() and not is_suppressed:
			result += " "
		
		result += seg.to_text(detailed)
		previous = seg
	
	if not result.ends_with("."):
		result += "."
	
	return result
