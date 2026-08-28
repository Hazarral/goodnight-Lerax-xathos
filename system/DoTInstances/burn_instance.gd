class_name BurnInstance
extends DoTInstance

var turns_elapsed : int

func _init(p_caster : Entity, p_target : Entity, p_damage_type : DamageAndDoT.DamageType, p_base_damage : float, p_stacks : int, p_duration : int) -> void:
	super(p_caster, p_target, p_damage_type, p_base_damage, p_stacks, p_duration)
	turns_elapsed = 0

func tick_down() -> void:
	print("Will implement further Burn logic later")
	duration -= 1
	turns_elapsed += 1
	if duration <= 0:
		expire()

func get_burn_multiplier() -> float:
	return minf(DamageAndDoT.MAX_FIRE_MULTIPLIER, 1.0 + DamageAndDoT.FIRE_MULTIPLIER_STEP * turns_elapsed)

func calculate_damage() -> float:
	return DamageAndDoT.calculate_dot_damage(
		DamageAndDoT.get_dot(damage_type),
		base_damage,
		get_current_potency(),
		get_current_mastery(),
		stacks,
		duration
	) * get_burn_multiplier()
