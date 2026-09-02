class_name ShieldRegenCombatLogEntry
extends CombatLogEntry

var max_shields : PackedInt64Array
var attrition : PackedInt64Array
var shield_before_regen : PackedInt64Array
var shield_after_regen : PackedInt64Array

const TURN_START := "- Turn %d -"

const BASIC_TEMPLATE := "%s's %s Shield regenerated to %d/%d"
const ADVANCED_TEMPLATE := "%s's %s Shield regenerated from %d/%d to %d/%d (%d Attrition)"
const DEVELOPER_TEMPLATE := "%s's %s Shield: %d/%d -> %d/%d, Attrition = %d, Magnification = %.2f%%"

## This is when shield_before_regen[i] == shield_after_regen[i]
const ADVANCED_SHIELD_INTACT_TEMPLATE := "%s's %s Shield stayed intact"
const DEVELOPER_SHIELD_INTACT_TEMPLATE := "%s's %s Shield stayed intact, Max Shield = %d, Attrition = %d"

## This replaces the above 2 templates for attrition = max shield
const BASIC_FULL_ATTRITION_TEMPLATE := "%s's %s Shield failed to regenerate and stayed breached!"
const ADVANCED_FULL_ATTRITION_TEMPLATE := "%s's %s Shield failed to regenerate and stayed breached! (%d Max Shield, %d effective Attrition, %d real Attrition)"
const DEVELOPER_FULL_ATTRITION_TEMPLATE := "%s's %s Shield cannot regenerate, Max Shield = %d, Effective Attrition = %d, Real Attrition = %d, Magnification = %.2f%%"

const DEVELOPER_NO_SHIELD_TEMPLATE := "%s has no %s Shield"

const STAGE_TEMPLATE := "[Stage %s]"

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
	var text := (TURN_START % turn_number) + "\n"
	for i in range(max_shields.size()):
		if max_shields[i] <= 0:
			continue
		
		var damage_type := i as DamageAndDoT.DamageType
		var damage_type_name := DamageAndDoT.get_damage_type_name(damage_type)
		
		if shield_before_regen[i] == shield_after_regen[i]:
			continue
		
		if attrition[i] < max_shields[i]:
			text += "> " + BASIC_TEMPLATE % [
				actor.template.entity_name,
				damage_type_name,
				shield_after_regen[i],
				max_shields[i]
			]
		else:
			text += "> " + BASIC_FULL_ATTRITION_TEMPLATE % [
				actor.template.entity_name,
				damage_type_name
			]
		
		text += "\n"
	
	return text

func render_advanced() -> String:
	var text := (TURN_START % turn_number) + "\n"
	for i in range(max_shields.size()):
		if max_shields[i] <= 0:
			continue
		
		var damage_type := i as DamageAndDoT.DamageType
		var damage_type_name := DamageAndDoT.get_damage_type_name(damage_type)
		
		if shield_before_regen[i] == shield_after_regen[i]:
			text += "> " + ADVANCED_SHIELD_INTACT_TEMPLATE % [
				actor.template.entity_name,
				damage_type_name
			] + "\n"
			continue
		
		if attrition[i] < max_shields[i]:
			text += "> " + ADVANCED_TEMPLATE % [
				actor.template.entity_name,
				damage_type_name,
				shield_before_regen[i],
				max_shields[i],
				shield_after_regen[i],
				max_shields[i],
				attrition[i]
			]
		else:
			text += "> " + ADVANCED_FULL_ATTRITION_TEMPLATE % [
				actor.template.entity_name,
				damage_type_name,
				max_shields[i],
				mini(max_shields[i], attrition[i]),
				attrition[i]
			]
		
		text += "\n"
	
	return text

func render_developer() -> String:
	var text := (TURN_START % turn_number) + "\n"
	text += (STAGE_TEMPLATE % stage) + "\n"
	for i in range(max_shields.size()):
		var damage_type := i as DamageAndDoT.DamageType
		var damage_type_name := DamageAndDoT.get_damage_type_name(damage_type)
		var magnification_percent := actor.magnification * 100.0
		
		if max_shields[i] <= 0:
			text += DEVELOPER_NO_SHIELD_TEMPLATE % [
				actor.template.entity_name,
				damage_type_name
			] + "\n"
			continue
		
		if shield_before_regen[i] == shield_after_regen[i]:
			text += "> " + DEVELOPER_SHIELD_INTACT_TEMPLATE % [
				actor.template.entity_name,
				damage_type_name,
				max_shields[i],
				attrition[i]
			] + "\n"
			continue
		
		if attrition[i] < max_shields[i]:
			text += "> " + DEVELOPER_TEMPLATE % [
				actor.template.entity_name,
				damage_type_name,
				shield_before_regen[i],
				max_shields[i],
				shield_after_regen[i],
				max_shields[i],
				attrition[i],
				magnification_percent
			]
		else:
			text += "> " + DEVELOPER_FULL_ATTRITION_TEMPLATE % [
				actor.template.entity_name,
				damage_type_name,
				max_shields[i],
				mini(max_shields[i], attrition[i]),
				attrition[i],
				magnification_percent
			]
		
		text += "\n"
	
	return text
