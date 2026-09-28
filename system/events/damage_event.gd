class_name DamageEvent 
extends CombatEvent

## What damage type? There are 9 damage types
var damage_type : DamageAndDoT.DamageType

## And the actual computed, rounded up integer amount to deliver
var amount : int

## If true, this will deal damage to HP no matter what
var ignore_shield : bool

func _init(p_source : Entity, p_target : Entity, p_damage_type : DamageAndDoT.DamageType, p_amount : int, p_ignore_shield : bool = false) -> void:
	super(p_source, p_target)
	damage_type = p_damage_type
	amount = p_amount
	ignore_shield = p_ignore_shield

func resolve() -> void:
	var multiplier := 1.0 if source == null else source.get_final_damage_dealt_true_multiplicative()	
	target.take_damage(damage_type, ceili(amount * multiplier), ignore_shield)
