class_name KnownAction
extends RefCounted

var action : Action
var source : Entity
var cooldown_remaining  : int = 0

func _init(p_action : Action, p_source : Entity) -> void:
	action = p_action
	source = p_source

func is_ready() -> bool:
	return cooldown_remaining <= 0

func tick_cooldown() -> void:
	if cooldown_remaining > 0:
		cooldown_remaining -= 1

func cast() -> bool:
	if not is_ready():
		return false
	
	if source.current_ap < action.action_point_cost:
		return false
	
	source.current_ap -= action.action_point_cost
	cooldown_remaining = action.cooldown
	action.cast(source)
	return true
