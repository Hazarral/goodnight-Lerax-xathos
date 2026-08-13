class_name BurnInstance
extends DoTInstance

const MAX_MULTIPLIER := 3.0
const MULTIPLIER_STEP := 0.5

var turns_elapsed : int

func _init(p_caster : Entity, p_target : Entity, p_damage_type : DamageAndDoT.DamageType, p_stacks : int, p_base_damage : float, p_duration : int) -> void:
	super(p_caster, p_target, p_damage_type, p_stacks, p_base_damage, p_duration)
	turns_elapsed = 0

func tick_down() -> void:
	print("Will implement further Burn logic later")
	duration -= 1
	turns_elapsed += 1
	if duration <= 0:
		expire()

func get_burn_multiplier() -> float:
	return minf(MAX_MULTIPLIER, 1.0 + MULTIPLIER_STEP * turns_elapsed)

func calculate_damage(potency : int, mastery : int) -> float:
	return DamageAndDoT.calculate_dot_damage(
		DamageAndDoT.get_dot(damage_type),
		base_damage,
		potency,
		mastery,
		stacks
	) * get_burn_multiplier()
