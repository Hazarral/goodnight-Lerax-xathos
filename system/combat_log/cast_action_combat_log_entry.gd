class_name CastActionCombatLogEntry 
extends CombatLogEntry

var action_name : String
var action_point_cost : int
var cooldown : int

## Either single target or all target
const BASIC_TEMPLATE := "> %s casted [color=%s]%s[/color]"
const ADVANCED_TEMPLATE := "> %s casted [color=%s]%s[/color] (%d AP, %d CD)"
const DEVELOPER_TEMPLATE := "> %s casted [color=%s]%s[/color], AP spent = [color=%s]%d[/color], Cooldown = [color=%s]%d[/color]"

func _init(
	p_turn_number : int, 
	p_actor : Entity, 
	p_stage : String, 
	p_action_name : String, 
	p_action_point_cost : int,
	p_cooldown : int
	) -> void:
	super(p_turn_number, p_actor, p_stage)
	action_name = p_action_name
	action_point_cost = p_action_point_cost
	cooldown = p_cooldown

func render_basic() -> String:
	return BASIC_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.GENERIC_COLOR_HEX, action_name
	]

func render_advanced() -> String:
	return ADVANCED_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.GENERIC_COLOR_HEX, action_name,
		action_point_cost,
		cooldown
	]

func render_developer() -> String:
	var text := _get_developer_stage_prefix()
	text += DEVELOPER_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.GENERIC_COLOR_HEX, action_name,
		DamageAndDoT.GENERIC_COLOR_HEX, action_point_cost,
		DamageAndDoT.GENERIC_COLOR_HEX, cooldown
	]
	return text
