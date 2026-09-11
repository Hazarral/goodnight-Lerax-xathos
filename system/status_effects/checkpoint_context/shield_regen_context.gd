class_name ShieldRegenContext
extends CheckpointContext

var max_shields : PackedInt64Array
var attrition : PackedInt64Array
var shield_before_regen : PackedInt64Array
var shield_after_regen : PackedInt64Array

func _init(
	p_entity : Entity,
	p_max_shields : PackedInt64Array, 
	p_attrition : PackedInt64Array, 
	p_shield_before_regen : PackedInt64Array, 
	p_shield_after_regen : PackedInt64Array
) -> void:
	super(p_entity)
	max_shields = p_max_shields
	attrition = p_attrition
	shield_before_regen = p_shield_before_regen
	shield_after_regen = p_shield_after_regen
