class_name BurnRampCombatLogEntry
extends CombatLogEntry

var burn_instance : BurnInstance

const BASIC_TEMPLATE := "[ul][color=%s]Burn[/color] is now [color=%s]%.2f%% Effective[/color][/ul]"
const ADVANCED_TEMPLATE := "[ul][color=%s]Burn[/color] is now [color=%s]%.2f%% Effective[/color] (%d Turn%s elapsed)[/ul]"
const DEVELOPER_TEMPLATE := "[ul][color=%s]Burn[/color] is now [color=%s]%.2f%%[/color], turns_elapsed = [color=%s]%d[/color][/ul]"

func _init(p_turn_number : int, p_actor : Entity, p_stage : String, p_burn_instance : BurnInstance) -> void:
	turn_number = p_turn_number
	actor = p_actor
	stage = p_stage
	burn_instance = p_burn_instance

func render_basic() -> String:
	return BASIC_TEMPLATE % [
		DamageAndDoT.FIRE_COLOR_HEX,
		DamageAndDoT.FIRE_COLOR_HEX, burn_instance.get_burn_multiplier() * 100.0
	]

func render_advanced() -> String:
	return ADVANCED_TEMPLATE % [
		DamageAndDoT.FIRE_COLOR_HEX,
		DamageAndDoT.FIRE_COLOR_HEX, burn_instance.get_burn_multiplier() * 100.0,
		burn_instance.turns_elapsed, "s" if burn_instance.turns_elapsed > 1 else ""
	]

func render_developer() -> String:
	return DEVELOPER_TEMPLATE % [
		DamageAndDoT.FIRE_COLOR_HEX,
		DamageAndDoT.FIRE_COLOR_HEX, burn_instance.get_burn_multiplier() * 100.0,
		DamageAndDoT.FIRE_COLOR_HEX, burn_instance.turns_elapsed
	]
