class_name ScoringContext
extends RefCounted

var actor : Entity
var target : Entity
var valid_target_count : int
var is_single_target : bool
var damage_types : Array[DamageAndDoT.DamageType]
var dot_instances : Array[DoTInstance]
var combat_field_state : CombatFieldState

func _init(
	p_actor : Entity,
	p_target : Entity,
	p_valid_target_count : int,
	p_is_single_target : bool,
	p_damage_types : Array[DamageAndDoT.DamageType],
	p_dot_instances : Array[DoTInstance],
	p_combat_field_state : CombatFieldState
) -> void:
	actor = p_actor
	target = p_target
	valid_target_count = p_valid_target_count
	is_single_target = p_is_single_target
	damage_types = p_damage_types
	dot_instances = p_dot_instances
	combat_field_state = p_combat_field_state
