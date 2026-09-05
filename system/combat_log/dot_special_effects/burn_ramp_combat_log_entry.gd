class_name BurnRampCombatLogEntry
extends CombatLogEntry

var burn_instance : BurnInstance

const BASIC_TEMPLATE := "> One of %s's [color=%s]Burn[/color] is now [color=%s]%.2f%% Effective[/color]"
const ADVANCED_TEMPLATE := "> One of %s's [color=%s]Burn[/color] is now [color=%s]%.2f%% Effective[/color] (%d Turn%s elapsed)"
const DEVELOPER_TEMPLATE := "> One of %s's [color=%s]Burn[/color] is now [color=%s]%.2f%%[/color], turns_elapsed = [color=%s]%d[/color]"

func _init(p_turn_number : int, p_actor : Entity, p_stage : String, p_burn_instance : BurnInstance) -> void:
	turn_number = p_turn_number
	actor = p_actor
	stage = p_stage
	burn_instance = p_burn_instance

func render_basic() -> String:
	return BASIC_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.FIRE_COLOR_HEX,
		DamageAndDoT.FIRE_COLOR_HEX, burn_instance.get_burn_multiplier() * 100.0
	]

func render_advanced() -> String:
	return ADVANCED_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.FIRE_COLOR_HEX,
		DamageAndDoT.FIRE_COLOR_HEX, burn_instance.get_burn_multiplier() * 100.0,
		burn_instance.turns_elapsed, "s" if burn_instance.turns_elapsed > 1 else ""
	]

func render_developer() -> String:
	var text := _get_developer_stage_prefix()
	text += DEVELOPER_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.FIRE_COLOR_HEX,
		DamageAndDoT.FIRE_COLOR_HEX, burn_instance.get_burn_multiplier() * 100.0,
		DamageAndDoT.FIRE_COLOR_HEX, burn_instance.turns_elapsed
	]
	return text
