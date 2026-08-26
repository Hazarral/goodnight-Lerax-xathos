class_name ApplyVoidActionEvent
extends ActionEvent

@export var stacks : int

func resolve(source : Entity) -> bool:
	var targets : Variant = await get_targets()
	if targets == null:
		## Already cancelled!
		return false
	
	for entity in targets:
		entity.apply_void(stacks, source.is_player_faction())
	
	return true
