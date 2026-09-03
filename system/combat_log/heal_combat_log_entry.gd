class_name HealCombatLogEntry
extends CombatLogEntry

var raw_amount : int
var real_amount : int
var hp_before_heal : int
var hp_after_heal : int

const BASIC_TEMPLATE := "> %s recovered [color=%s]%d Health[/color]"
const ADVANCED_TEMPLATE := "> %s recovered [color=%s]%d Health[/color], [color=%s]%d/%d Health[/color] -> [color=%s]%d/%d Health[/color] (Raw Amount before buffs/debuffs: [color=%s]%d[/color])"
const DEVELOPER_TEMPLATE := "> %s healed for [color=%s]%d Health[/color]: [color=%s]%d/%d Health[/color] -> [color=%s]%d/%d Health[/color], raw_amount = [color=%s]%d[/color], real_amount = [color=%s]%d[/color]"

func _init(
	p_turn_number : int, 
	p_actor : Entity,
	p_stage : String, 
	p_raw_amount : int, 
	p_real_amount : int, 
	p_hp_before_heal : int, 
	p_hp_after_heal : int
	) -> void:
	super(p_turn_number, p_actor, p_stage)
	raw_amount = p_raw_amount
	real_amount = p_real_amount
	hp_before_heal = p_hp_before_heal
	hp_after_heal = p_hp_after_heal

func render_basic() -> String:
	return BASIC_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.HEALING_COLOR_HEX, real_amount
	]

func render_advanced() -> String:
	return ADVANCED_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.HEALING_COLOR_HEX, real_amount,
		DamageAndDoT.HEALING_COLOR_HEX, hp_before_heal, actor.get_max_hp(),
		DamageAndDoT.HEALING_COLOR_HEX, hp_after_heal, actor.get_max_hp(),
		DamageAndDoT.HEALING_COLOR_HEX, raw_amount
	]

func render_developer() -> String:
	var text := STAGE_TEMPLATE % [DamageAndDoT.GENERIC_COLOR_HEX, stage, turn_number] + "\n"
	text += DEVELOPER_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.HEALING_COLOR_HEX, real_amount,
		DamageAndDoT.HEALING_COLOR_HEX, hp_before_heal, actor.get_max_hp(),
		DamageAndDoT.HEALING_COLOR_HEX, hp_after_heal, actor.get_max_hp(),
		DamageAndDoT.HEALING_COLOR_HEX, raw_amount,
		DamageAndDoT.HEALING_COLOR_HEX, real_amount
	]
	return text
