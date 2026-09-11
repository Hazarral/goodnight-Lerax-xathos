class_name PreStatusEffectTickDownContext
extends CheckpointContext

var status_effect : StatusEffect
var remaining_duration : int

func _init(p_entity : Entity, p_status_effect : StatusEffect, p_remaining_duration : int) -> void:
	super(p_entity)
	status_effect = p_status_effect
	remaining_duration = p_remaining_duration
