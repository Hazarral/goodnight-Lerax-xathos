class_name ScoringContext
extends RefCounted

var actor : Entity
var target : Entity
var ap_cost : int
var cooldown : int
var valid_target_count : int
var is_single_target : bool
var damage_types : Array[DamageAndDoT.DamageType]
var dot_instances : Array[DoTInstance]
var buff_and_debuffs : Array[BuffAndDebuff]
var combat_field_state : CombatFieldState

func _init(
	p_actor : Entity,
	p_target : Entity,
	p_ap_cost : int,
	p_cooldown : int,
	p_valid_target_count : int,
	p_is_single_target : bool,
	p_damage_types : Array[DamageAndDoT.DamageType],
	p_dot_instances : Array[DoTInstance],
	p_buff_and_debuffs : Array[BuffAndDebuff],
	p_combat_field_state : CombatFieldState
) -> void:
	actor = p_actor
	target = p_target
	ap_cost = p_ap_cost
	cooldown = p_cooldown
	valid_target_count = p_valid_target_count
	is_single_target = p_is_single_target
	damage_types = p_damage_types
	dot_instances = p_dot_instances
	buff_and_debuffs = p_buff_and_debuffs
	combat_field_state = p_combat_field_state
