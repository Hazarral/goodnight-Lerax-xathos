class_name DoTInstance
extends RefCounted

var target : Entity
var damage_type : DamageAndDoT.DamageType
var stacks : int
var base_damage : float
var duration : int

var source : Entity
var cached_potency : int
var cached_mastery : int

signal expired(dot_instance : DoTInstance)

func _init(p_source : Entity, p_target : Entity, p_damage_type : DamageAndDoT.DamageType, p_stacks : int, p_base_damage : float, p_duration : int) -> void:
	if p_damage_type == DamageAndDoT.DamageType.VOID:
		push_error("Void is not a valid DoTInstance, use VoidInstance instead")
		return
	
	source = p_source
	target = p_target
	damage_type = p_damage_type
	stacks = p_stacks
	base_damage = p_base_damage
	duration = p_duration
	
	update_cache()

func update_cache() -> void:
	if is_instance_valid(source) and not source.is_dead:
		cached_potency = source.current_potency
		cached_mastery = source.current_mastery

func get_current_potency() -> int:
	update_cache()
	return cached_potency

func get_current_mastery() -> int:
	update_cache()
	return cached_mastery

func tick_down() -> void:
	print("Will implement further logic later")
	duration -= 1
	if duration <= 0:
		expire()

func expire() -> void:
	emit_signal("expired", self)

func calculate_damage(potency : int, mastery : int) -> float:
	return DamageAndDoT.calculate_dot_damage(
		DamageAndDoT.get_dot(damage_type),
		base_damage,
		potency,
		mastery,
		stacks
	)

func calculate_attition(potency : int, mastery : int) -> float:
	return DamageAndDoT.calculate_dot_attrition(
		DamageAndDoT.get_dot(damage_type),
		base_damage,
		potency,
		mastery,
		stacks,
		duration
	)
