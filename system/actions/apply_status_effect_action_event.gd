class_name ApplyStatusEffectActionEvent
extends ActionEvent

## Effects will not stack, but can refresh
@export var status_effects : Array[StatusEffect] = []

func resolve(source : Entity, inherited_targets : Array[Entity]) -> bool:
	var targets : Variant = await get_targets(source, inherited_targets)
	if targets == null:
		## Already cancelled!
		return false
	
	for entity : Entity in targets:
		for effect in status_effects:
			entity.apply_status_effect(effect, source)
	
	return true
