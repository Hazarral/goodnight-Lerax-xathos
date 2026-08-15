class_name DamageEvent 
extends RefCounted

## Who caused this damage?
var source : Entity

## Who is the receiver?
var target : Entity

## What damage type? There are 9 damage types
var damage_type : DamageAndDoT.DamageType

## And the actual computed, rounded up integer amount to deliver
var amount : int

func _init(p_source : Entity, p_target : Entity, p_damage_type : DamageAndDoT.DamageType, p_amount : int) -> void:
	source = p_source
	target = p_target
	damage_type = p_damage_type
	amount = p_amount
