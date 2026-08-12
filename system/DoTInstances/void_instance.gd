class_name VoidInstance
extends RefCounted

var target : Entity
var damage_type : DamageAndDoT.DamageType
var stacks : int
var base_damage : float
var duration : int

const MAX_HP_SCALING := 1.0
const TOTAL_MAX_SHIELD_SCALING := 1.0
const POTENCY_COEFFICIENT_SCALING := 0.5
const POTENCY_EXPONENT_SCALING := 2.0
const MASTERY_COEFFICIENT_SCALING := 0.5
const MASTERY_EXPONENT_SCALING := 2.0
const TOTAL_ATTRITION_EXPONENT_SCALING := 0.7
const ESCALATION_MULTIPLIER_BASE := 1.1

const DEATH_COUNTDOWN := 30

var turns_elapsed : int

func _init(p_target : Entity, p_stacks : int, p_base_damage : float) -> void:
	target = p_target
	damage_type = DamageAndDoT.DamageType.VOID
	stacks = p_stacks
	base_damage = p_base_damage
	duration = DEATH_COUNTDOWN
	turns_elapsed = 0

func tick_down() -> void:
	print("Will implement further Void logic later")	
	duration -= 1
	turns_elapsed += 1
	if duration <= 0:
		kill_target()

func kill_target() -> void:
	target.die()

func calculate_damage(caster_max_hp : int, caster_total_max_shield : int, potency : int, mastery: int, total_target_attrition : int) -> int:
	return ceili(
		(MAX_HP_SCALING * caster_max_hp + 
		TOTAL_MAX_SHIELD_SCALING * caster_total_max_shield +
		POTENCY_COEFFICIENT_SCALING * pow(potency, POTENCY_EXPONENT_SCALING) +
		MASTERY_COEFFICIENT_SCALING * pow(mastery, MASTERY_EXPONENT_SCALING) + 
		pow(total_target_attrition, TOTAL_ATTRITION_EXPONENT_SCALING)) * stacks * pow(ESCALATION_MULTIPLIER_BASE, turns_elapsed)
	)
