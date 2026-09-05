class_name KnownAction
extends RefCounted

var action : Action
var source : Entity
var cooldown_remaining  : int = 0

func _init(p_action : Action, p_source : Entity) -> void:
	action = p_action.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	source = p_source
	
	## NOTE: THis is for the tooltip!
	for seg in action.description_segments:
		if seg is DamageSegment or seg is HealSegment:
			seg.set_source(source)

func get_action_name() -> String:
	return action.action_name

func get_action_point_cost() -> int:
	return action.action_point_cost

func get_cooldown() -> int:
	return action.cooldown

func _is_ready() -> bool:
	return cooldown_remaining <= 0

func is_castable() -> bool:
	return _is_ready() and source.current_action_point >= action.action_point_cost

func tick_cooldown() -> void:
	if cooldown_remaining > 0:
		cooldown_remaining -= 1

func cast() -> CastResult:
	if not is_castable():
		return CastResult.new(false, 0)
	
	source.current_action_point -= action.action_point_cost
	
	var success := await action.cast(source)
	
	if not success:
		source.current_action_point += action.action_point_cost
		return CastResult.new(false, 0)
	
	cooldown_remaining = action.cooldown
	
	return CastResult.new(true, action.action_point_cost)
