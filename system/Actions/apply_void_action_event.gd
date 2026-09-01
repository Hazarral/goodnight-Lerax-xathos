class_name ApplyVoidActionEvent
extends ActionEvent

@export var stacks : int

func resolve(source : Entity, inherited_targets : Array[Entity]) -> bool:
	var targets : Variant = await get_targets(source, inherited_targets)
	if targets == null:
		## Already cancelled!
		return false
	
	for entity in targets:
		entity.apply_void(stacks)
	
	return true
