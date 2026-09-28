class_name BuffAndDebuffSummary
extends RefCounted

# Health
var health_additive : float = 0.0
var health_additive_multiplicative : float = 0.0
var health_true_multiplicative : float = 0.0

## Shields (one entry per shield slot)
var shields_additive : PackedFloat32Array = PackedFloat32Array()
var shields_additive_multiplicative : PackedFloat32Array = PackedFloat32Array()
var shields_true_multiplicative : PackedFloat32Array = PackedFloat32Array()

## Potency
var potency_additive : float = 0.0
var potency_additive_multiplicative : float = 0.0
var potency_true_multiplicative : float = 0.0

## Mastery
var mastery_additive : float = 0.0
var mastery_additive_multiplicative : float = 0.0
var mastery_true_multiplicative : float = 0.0

## Damage dealt and received
var final_damage_dealt_true_multiplicative : float = 0.0
var final_damage_received_true_multiplicative : float = 0.0

func _init(
	p_health_additive : float = 0.0,
	p_health_additive_multiplicative : float = 0.0,
	p_health_true_multiplicative : float = 0.0,
	p_shields_additive : PackedFloat32Array = PackedFloat32Array(),
	p_shields_additive_multiplicative : PackedFloat32Array = PackedFloat32Array(),
	p_shields_true_multiplicative : PackedFloat32Array = PackedFloat32Array(),
	p_potency_additive : float = 0.0,
	p_potency_additive_multiplicative : float = 0.0,
	p_potency_true_multiplicative : float = 0.0,
	p_mastery_additive : float = 0.0,
	p_mastery_additive_multiplicative : float = 0.0,
	p_mastery_true_multiplicative : float = 0.0,
	p_final_damage_dealt_true_multiplicative : float = 0.0,
	p_final_damage_received_true_multiplicative : float = 0.0
) -> void:
	health_additive = p_health_additive
	health_additive_multiplicative = p_health_additive_multiplicative
	health_true_multiplicative = p_health_true_multiplicative
	
	shields_additive = p_shields_additive.duplicate()
	shields_additive_multiplicative = p_shields_additive_multiplicative.duplicate()
	shields_true_multiplicative = p_shields_true_multiplicative.duplicate()
	
	potency_additive = p_potency_additive
	potency_additive_multiplicative = p_potency_additive_multiplicative
	potency_true_multiplicative = p_potency_true_multiplicative
	
	mastery_additive = p_mastery_additive
	mastery_additive_multiplicative = p_mastery_additive_multiplicative
	mastery_true_multiplicative = p_mastery_true_multiplicative
	
	final_damage_dealt_true_multiplicative = p_final_damage_dealt_true_multiplicative
	final_damage_received_true_multiplicative = p_final_damage_received_true_multiplicative
