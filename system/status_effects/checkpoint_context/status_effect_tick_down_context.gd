class_name StatusEffectTickDownContext
extends CheckpointContext

var status_effect : StatusEffect
var remaining_duration : int

func _init(p_status_effect : StatusEffect, p_remaining_duration : int) -> void:
	status_effect = p_status_effect
	remaining_duration = p_remaining_duration
