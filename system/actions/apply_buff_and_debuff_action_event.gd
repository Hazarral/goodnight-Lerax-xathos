class_name ApplyBuffAndDebuffActionEvent
extends ActionEvent

@export var buff_and_debuff : BuffAndDebuff

func resolve(source : Entity, inherited_targets : Array[Entity]) -> bool:
	var targets : Variant = await get_targets(source, inherited_targets)
	if targets == null:
		## Already cancelled!
		return false
	
	for entity : Entity in targets:
		entity.apply_buff_and_debuff(buff_and_debuff.duplicate_deep(Resource.DEEP_DUPLICATE_ALL))
	
	return true
