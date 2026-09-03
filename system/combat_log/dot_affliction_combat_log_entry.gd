class_name DoTAfflictionCombatLogEntry
extends CombatLogEntry

var dot_instance : DoTInstance

const BASIC_TEMPLATE := "> %s is afflicted with [color=%s]%s[/color]"
const ADVANCED_TEMPLATE := "> %s is afflicted with [color=%s]%d Stacks[/color] of [color=%s]%s[/color] for [color=%s]%d Turns[/color]"
const DEVELOPER_TEMPLATE := "> %s is afflicted with [color=%s]%s[/color], Base Damage = [color=%s]%.2f[/color], Stacks = [color=%s]%d[/color], Duration = [color=%s]%d[/color]"

func _init(
	p_turn_number : int, 
	p_actor : Entity, 
	p_stage : String, 
	p_dot_instance : DoTInstance,
	) -> void:
	super(p_turn_number, p_actor, p_stage)
	dot_instance = p_dot_instance

func render_basic() -> String:
	var damage_type := dot_instance.damage_type
	var dot_type := DamageAndDoT.get_dot(damage_type)
	return BASIC_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.get_damage_color_hex(damage_type), DamageAndDoT.get_damage_over_time_name(dot_type)
	]

func render_advanced() -> String:
	var damage_type := dot_instance.damage_type
	var dot_type := DamageAndDoT.get_dot(damage_type)
	return ADVANCED_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.GENERIC_COLOR_HEX, dot_instance.stacks,
		DamageAndDoT.get_damage_color_hex(damage_type), DamageAndDoT.get_damage_over_time_name(dot_type),
		DamageAndDoT.GENERIC_COLOR_HEX, dot_instance.duration
	]

func render_developer() -> String:
	var text := _get_developer_stage_prefix()
	var damage_type := dot_instance.damage_type
	var dot_type := DamageAndDoT.get_dot(damage_type)
	text += DEVELOPER_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.get_damage_color_hex(damage_type), DamageAndDoT.get_damage_over_time_name(dot_type),
		DamageAndDoT.get_damage_color_hex(damage_type), dot_instance.base_damage,
		DamageAndDoT.GENERIC_COLOR_HEX, dot_instance.stacks,
		DamageAndDoT.GENERIC_COLOR_HEX, dot_instance.duration
	]
	
	return text
