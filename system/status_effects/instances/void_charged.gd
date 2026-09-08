class_name VoidCharged
extends StatusEffect

func _init() -> void:
	registered_checkpoints = [
		StatusEffectPriorityList.CheckpointType.POST_DAMAGE_TO_HP_TAKEN,
		StatusEffectPriorityList.CheckpointType.TURN_END
	]
