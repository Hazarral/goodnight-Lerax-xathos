class_name CrumbleSplashCombatLogEntry
extends CombatLogEntry

var effectiveness : float

const BASIC_TEMPLATE := "> %s's Shields [color=%s]corroded[/color]!"
const ADVANCED_TEMPLATE := "> %s's Shields [color=%s]corroded[/color]! [color=%s]%.2f%% %s Damage[/color] is dealt to all non-Earth Shields"
const DEVELOPER_TEMPLATE := "> %s's Shields [color=%s]corroded[/color], Effectiveness = [color=%s]%.2f%%[/color]"

func _init(
	p_turn_number : int, 
	p_actor : Entity, 
	p_stage : String, 
	p_effectiveness : float,
	) -> void:
	super(p_turn_number, p_actor, p_stage)
	effectiveness = p_effectiveness

func render_basic() -> String:	
	return BASIC_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.EARTH_COLOR_HEX
	]

func render_advanced() -> String:
	return ADVANCED_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.EARTH_COLOR_HEX,
		DamageAndDoT.EARTH_COLOR_HEX, effectiveness * 100.0, DamageAndDoT.CRUMBLE
	]

func render_developer() -> String:
	var text := _get_developer_stage_prefix()
	text += DEVELOPER_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.EARTH_COLOR_HEX,
		DamageAndDoT.EARTH_COLOR_HEX, effectiveness * 100.0
	]
	return text
