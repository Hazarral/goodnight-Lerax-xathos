class_name BleedRuptureCombatLogEntry
extends CombatLogEntry

var healing_reduction : float
var flat_damage_bonus : float

const BASIC_TEMPLATE := "> %s's wounds [color=%s]ruptured[/color]!"
const ADVANCED_TEMPLATE := "> %s's wounds [color=%s]ruptured[/color]! [color=%s]%.2f%% Healing + %.2f %s Damage[/color] is dealt to Health"
const DEVELOPER_TEMPLATE := "> %s's wounds [color=%s]ruptured[/color], Raw Healing Reduction = [color=%s]%.2f%%[/color], Flat Damage bonus = [color=%s]%.2f[/color]"

func _init(
	p_turn_number : int, 
	p_actor : Entity, 
	p_stage : String, 
	p_healing_reduction : float,
	p_flat_damage_bonus : float
	) -> void:
	super(p_turn_number, p_actor, p_stage)
	healing_reduction = p_healing_reduction
	flat_damage_bonus = p_flat_damage_bonus

func render_basic() -> String:	
	return BASIC_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.PHYSICAL_COLOR_HEX
	]

func render_advanced() -> String:
	return ADVANCED_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.PHYSICAL_COLOR_HEX,
		DamageAndDoT.PHYSICAL_COLOR_HEX, healing_reduction * 100.0, flat_damage_bonus, DamageAndDoT.PHYSICAL
	]

func render_developer() -> String:
	var text := _get_developer_stage_prefix()
	
	text += DEVELOPER_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.PHYSICAL_COLOR_HEX,
		DamageAndDoT.PHYSICAL_COLOR_HEX, healing_reduction * 100.0,
		DamageAndDoT.PHYSICAL_COLOR_HEX, flat_damage_bonus
	]
	return text
