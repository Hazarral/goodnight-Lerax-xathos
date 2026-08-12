class_name DoTInstance
extends RefCounted

var target : Entity
var damage_type : DamageAndDoT.DamageType
var stacks : int
var base_damage : float
var duration : int

signal expired(dot_instance : DoTInstance)

func _init(p_target : Entity, p_damage_type : DamageAndDoT.DamageType, p_stacks : int, p_base_damage : float, p_duration : int) -> void:
	target = p_target
	damage_type = p_damage_type
	stacks = p_stacks
	base_damage = p_base_damage
	duration = p_duration

func tick_down() -> void:
	print("Will implement further logic later")
	duration -= 1
	if duration <= 0:
		expire()

func expire() -> void:
	emit_signal("expired", self)

func calculate_damage(potency : int, mastery : int) -> int:
	return ceili(
		DamageAndDoT.calculate_dot_damage(
			DamageAndDoT.get_dot(damage_type),
			base_damage,
			potency,
			mastery,
			stacks
		)
	)
