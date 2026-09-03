class_name ShieldRegenCombatLogEntry
extends CombatLogEntry

var max_shields : PackedInt64Array
var attrition : PackedInt64Array
var shield_before_regen : PackedInt64Array
var shield_after_regen : PackedInt64Array

const BASIC_TEMPLATE := "> %s's [color=%s]%s Shield[/color] regenerated to [color=%s]%d/%d[/color]"
const ADVANCED_TEMPLATE := "> %s's [color=%s]%s Shield[/color] regenerated from [color=%s]%d/%d[/color] to [color=%s]%d/%d[/color] ([color=%s]%d Attrition[/color])"
const DEVELOPER_TEMPLATE := "> %s's [color=%s]%s Shield[/color]: [color=%s]%d/%d[/color] -> [color=%s]%d/%d[/color], Attrition = [color=%s]%d[/color], Magnification = [color=%s]%.2f%%[/color]"

## This is when shield_before_regen[i] == shield_after_regen[i]
const ADVANCED_SHIELD_INTACT_TEMPLATE := "> %s's [color=%s]%s Shield[/color] stayed intact"
const DEVELOPER_SHIELD_INTACT_TEMPLATE := "> %s's [color=%s]%s Shield[/color] stayed intact, Max Shield = [color=%s]%d[/color], Attrition = [color=%s]%d[/color]"

## This replaces the above 2 templates for attrition = max shield
const BASIC_FULL_ATTRITION_TEMPLATE := "> %s's [color=%s]%s Shield[/color] failed to regenerate and stayed breached!"
const ADVANCED_FULL_ATTRITION_TEMPLATE := "> %s's [color=%s]%s Shield[/color] failed to regenerate and stayed breached! (%d Max Shield, %d effective Attrition, %d real Attrition)"
const DEVELOPER_FULL_ATTRITION_TEMPLATE := "> %s's [color=%s]%s Shield[/color] cannot regenerate, Max Shield = %d, Effective Attrition = %d, Real Attrition = %d, Magnification = %.2f%%"

const DEVELOPER_NO_SHIELD_TEMPLATE := "> %s has no [color=%s]%s Shield[/color]"

func _init(
	p_turn_number : int,
	p_actor : Entity,
	p_stage : String,
	p_max_shields : PackedInt64Array,
	p_attrition : PackedInt64Array,
	p_shield_before_regen : PackedInt64Array,
	p_shield_after_regen : PackedInt64Array
) -> void:
	super(p_turn_number, p_actor, p_stage)
	max_shields = p_max_shields
	attrition = p_attrition
	shield_before_regen = p_shield_before_regen
	shield_after_regen = p_shield_after_regen

func render_basic() -> String:
	var text := ""
	for i in range(max_shields.size()):
		if max_shields[i] <= 0:
			continue
		
		var damage_type := i as DamageAndDoT.DamageType
		var damage_type_name := DamageAndDoT.get_damage_type_name(damage_type)
		var element_color := DamageAndDoT.get_damage_color_hex(damage_type)
		
		if shield_before_regen[i] == shield_after_regen[i]:
			continue
		
		if attrition[i] < max_shields[i]:
			text += BASIC_TEMPLATE % [
				actor.get_entity_name_with_suffix(),
				element_color, damage_type_name,
				element_color, shield_after_regen[i], max_shields[i]
			]
		else:
			text += BASIC_FULL_ATTRITION_TEMPLATE % [
				actor.get_entity_name_with_suffix(),
				element_color, damage_type_name
			]
		
		text += "\n"
	
	return text.trim_suffix("\n")
 
func render_advanced() -> String:
	var text := ""
	for i in range(max_shields.size()):
		if max_shields[i] <= 0:
			continue
		
		var damage_type := i as DamageAndDoT.DamageType
		var damage_type_name := DamageAndDoT.get_damage_type_name(damage_type)
		var element_color := DamageAndDoT.get_damage_color_hex(damage_type)
		
		if shield_before_regen[i] == shield_after_regen[i]:
			text += ADVANCED_SHIELD_INTACT_TEMPLATE % [
				actor.get_entity_name_with_suffix(),
				element_color, damage_type_name
			] + "\n"
			continue
		
		if attrition[i] < max_shields[i]:
			text += ADVANCED_TEMPLATE % [
				actor.get_entity_name_with_suffix(),
				element_color, damage_type_name,
				element_color, shield_before_regen[i], max_shields[i],
				element_color, shield_after_regen[i], max_shields[i],
				DamageAndDoT.VOID_COLOR_HEX, attrition[i]
			]
		else:
			text += ADVANCED_FULL_ATTRITION_TEMPLATE % [
				actor.get_entity_name_with_suffix(),
				element_color, damage_type_name,
				element_color, max_shields[i],
				DamageAndDoT.VOID_COLOR_HEX, mini(max_shields[i], attrition[i]),
				DamageAndDoT.VOID_COLOR_HEX, attrition[i]
			]
		
		text += "\n"
	
	return text.trim_suffix("\n")
 
func render_developer() -> String:
	var text := STAGE_TEMPLATE % [DamageAndDoT.GENERIC_COLOR_HEX, stage, turn_number] + "\n"
	for i in range(max_shields.size()):
		var damage_type := i as DamageAndDoT.DamageType
		var damage_type_name := DamageAndDoT.get_damage_type_name(damage_type)
		var element_color := DamageAndDoT.get_damage_color_hex(damage_type)
		var magnification_percent := actor.magnification * 100.0
		
		if max_shields[i] <= 0:
			text += DEVELOPER_NO_SHIELD_TEMPLATE % [
				actor.get_entity_name_with_suffix(),
				element_color, damage_type_name
			] + "\n"
			continue
		
		if shield_before_regen[i] == shield_after_regen[i]:
			text += DEVELOPER_SHIELD_INTACT_TEMPLATE % [
				actor.get_entity_name_with_suffix(),
				element_color, damage_type_name,
				element_color, max_shields[i],
				DamageAndDoT.VOID_COLOR_HEX, attrition[i]
			] + "\n"
			continue
		
		if attrition[i] < max_shields[i]:
			text += DEVELOPER_TEMPLATE % [
				actor.get_entity_name_with_suffix(),
				element_color, damage_type_name, 
				element_color, shield_before_regen[i], max_shields[i],
				element_color, shield_after_regen[i], max_shields[i],
				DamageAndDoT.VOID_COLOR_HEX, attrition[i],
				DamageAndDoT.GENERIC_COLOR_HEX, magnification_percent
			]
		else:
			text += DEVELOPER_FULL_ATTRITION_TEMPLATE % [
				actor.get_entity_name_with_suffix(),
				element_color, damage_type_name,
				element_color, max_shields[i],
				DamageAndDoT.VOID_COLOR_HEX, mini(max_shields[i], attrition[i]),
				DamageAndDoT.VOID_COLOR_HEX, attrition[i],
				DamageAndDoT.GENERIC_COLOR_HEX, magnification_percent
			]
		
		text += "\n"
	
	return text.trim_suffix("\n")
