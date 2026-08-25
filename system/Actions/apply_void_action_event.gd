class_name ApplyVoidActionEvent
extends ActionEvent

@export var stacks : int

func resolve(source : Entity) -> void:
	var targets : Array[Entity] = await get_targets()
	
	for entity in targets:
		entity.apply_void(stacks, source.is_player_faction())
