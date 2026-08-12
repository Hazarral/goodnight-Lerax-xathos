class_name VoidInstance
extends DoTInstance

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

func _init(p_target : Entity, p_damage_type : DamageAndDoT.DamageType, p_stacks : int, p_base_damage : float) -> void:
	super(p_target, p_damage_type, p_stacks, p_base_damage, DEATH_COUNTDOWN)
	turns_elapsed = 0

func tick_down() -> void:
	print("Will implement further Void logic later")
	duration -= 1
	turns_elapsed += 1
	if duration <= 0:
		kill_target()

func kill_target() -> void:
	target.die()

func get_void_damage(max_hp : int, total_max_shield : int, potency : int, mastery: int, total_attrition : int) -> int:
	return ceili(
		(MAX_HP_SCALING * max_hp + 
		TOTAL_MAX_SHIELD_SCALING * total_max_shield +
		POTENCY_COEFFICIENT_SCALING * pow(potency, POTENCY_EXPONENT_SCALING) +
		MASTERY_COEFFICIENT_SCALING * pow(mastery, MASTERY_EXPONENT_SCALING) + 
		pow(total_attrition, TOTAL_ATTRITION_EXPONENT_SCALING)) * stacks * pow(ESCALATION_MULTIPLIER_BASE, turns_elapsed)
	)
