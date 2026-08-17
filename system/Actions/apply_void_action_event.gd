class_name ApplyVoidActionEvent
extends ActionEvent

@export var stacks : int

func resolve() -> void:
	var targets : Array[Entity] = CombatSystem.get_valid_targets(target_faction, target_state)
	
	if target_count == TargetCount.SINGLE:
		print("Single target apply Void action not implemented!")
		return
	
	for entity in targets:
		entity.apply_void(stacks, source.is_player_faction)
