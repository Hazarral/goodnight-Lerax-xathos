class_name VoidInstance
extends RefCounted

var target : Entity
const damage_type := DamageAndDoT.DamageType.VOID
var stacks : int
var is_player_faction : bool

## Player scaling
const MAX_HP_SCALING := 0.05
const TOTAL_MAX_SHIELD_SCALING := 0.05
const POTENCY_COEFFICIENT_SCALING := 0.5
const POTENCY_EXPONENT_SCALING := 1.5
const MASTERY_COEFFICIENT_SCALING := 0.5
const MASTERY_EXPONENT_SCALING := 1.5
const TOTAL_ATTRITION_EXPONENT_SCALING := 0.7
const ESCALATION_MULTIPLIER_BASE := 1.25

## Enemy scaling
const ENEMY_BASE_DAMAGE := 10
const ENEMY_POTENCY_COEFFICIENT_SCALING := 10.0
const ENEMY_MASTERY_COEFFICIENT_SCALING := 10.0

var turns_elapsed : int

func _init(p_target : Entity, p_stacks : int, p_is_player_faction : bool) -> void:
	target = p_target
	stacks = p_stacks
	is_player_faction = p_is_player_faction
	turns_elapsed = 0

func tick_down() -> void:
	turns_elapsed += 1

func apply_stacks(incoming_stacks : int) -> void:
	stacks += incoming_stacks

func calculate_player_void_damage(dragon_max_hp : int, dragon_total_max_shield : int, potency : int, mastery: int, total_target_attrition : int) -> int:	
	return ceili(
		(MAX_HP_SCALING * dragon_max_hp + 
		TOTAL_MAX_SHIELD_SCALING * dragon_total_max_shield +
		POTENCY_COEFFICIENT_SCALING * pow(potency, POTENCY_EXPONENT_SCALING) +
		MASTERY_COEFFICIENT_SCALING * pow(mastery, MASTERY_EXPONENT_SCALING) + 
		pow(total_target_attrition, TOTAL_ATTRITION_EXPONENT_SCALING)) * stacks * pow(ESCALATION_MULTIPLIER_BASE, turns_elapsed)
	)

func calculate_enemy_void_damage(highest_enemy_potency : int, highest_enemy_mastery : int, total_target_attrition : int) -> int:
	return ceili(
		(ENEMY_BASE_DAMAGE +
		ENEMY_POTENCY_COEFFICIENT_SCALING * log(highest_enemy_potency + 1) +
		ENEMY_MASTERY_COEFFICIENT_SCALING * log(highest_enemy_mastery + 1) +
		pow(total_target_attrition, TOTAL_ATTRITION_EXPONENT_SCALING)) * stacks * pow(ESCALATION_MULTIPLIER_BASE, turns_elapsed)
	)
