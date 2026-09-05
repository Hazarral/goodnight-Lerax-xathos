class_name VoidAfflictionCombatLogEntry
extends CombatLogEntry

var stacks : int

const BASIC_TEMPLATE := "> %s is afflicted with [color=%s]%s[/color]"
const ADVANCED_TEMPLATE := "> %s is afflicted with [color=%s]%d Stack%s[/color] of [color=%s]%s[/color]"
const DEVELOPER_TEMPLATE := "> %s is afflicted with [color=%s]%s[/color], Stacks = [color=%s]%d[/color]"

func _init(
	p_turn_number : int, 
	p_actor : Entity, 
	p_stage : String, 
	p_stacks : int,
	) -> void:
	super(p_turn_number, p_actor, p_stage)
	stacks = p_stacks

func render_basic() -> String:
	return BASIC_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.VOID_COLOR_HEX, DamageAndDoT.get_damage_over_time_name(DamageAndDoT.DoT.VOID)
	]

func render_advanced() -> String:
	return ADVANCED_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.VOID_COLOR_HEX, stacks, "s" if stacks > 1 else "",
		DamageAndDoT.VOID_COLOR_HEX, DamageAndDoT.get_damage_over_time_name(DamageAndDoT.DoT.VOID)
	]

func render_developer() -> String:
	var text := _get_developer_stage_prefix()
	text += DEVELOPER_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.VOID_COLOR_HEX, DamageAndDoT.get_damage_over_time_name(DamageAndDoT.DoT.VOID),
		DamageAndDoT.VOID_COLOR_HEX, stacks
	]
	
	return text
