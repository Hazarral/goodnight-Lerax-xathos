class_name ScoringContext
extends RefCounted

var actor : Entity
var target : Entity
var target_count : int
var damage_types : Array[DamageAndDoT.DamageType]
var dot_instances : Array[DoTInstance]
var combat_field_state : CombatFieldState

func _init(
	p_actor : Entity,
	p_target : Entity,
	p_target_count : int,
	p_damage_types : Array[DamageAndDoT.DamageType],
	p_dot_instances : Array[DoTInstance],
	p_combat_field_state : CombatFieldState
) -> void:
	actor = p_actor
	target = p_target
	target_count = p_target_count
	damage_types = p_damage_types
	dot_instances = p_dot_instances
	combat_field_state = p_combat_field_state
