class_name KnownAction
extends RefCounted

var action : Action
var source : Entity
var cooldown_remaining  : int = 0

func _init(p_action : Action, p_source : Entity) -> void:
	action = p_action
	source = p_source

func _is_ready() -> bool:
	return cooldown_remaining <= 0

func is_castable() -> bool:
	return _is_ready() and source.current_action_point >= action.action_point_cost

func tick_cooldown() -> void:
	if cooldown_remaining > 0:
		cooldown_remaining -= 1

func cast() -> bool:
	if not is_castable():
		return false
	
	source.current_action_point -= action.action_point_cost
	cooldown_remaining = action.cooldown
	await action.cast(source)
	return true
