class_name ShieldBreakContext
extends CheckpointContext

var damage_type : DamageAndDoT.DamageType

func _init(p_entity : Entity, p_damage_type : DamageAndDoT.DamageType) -> void:
	super(p_entity)
	damage_type = p_damage_type
