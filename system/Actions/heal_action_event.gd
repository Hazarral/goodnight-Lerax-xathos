class_name HealActionEvent
extends ActionEvent

@export var amount : int
@export var potency_scaling : float
@export var mastery_scaling : float

func resolve(source : Entity) -> bool:
	var targets : Variant = await get_targets()
	if targets == null:
		return false
	
	var final_amount = amount + potency_scaling * source.get_potency() + mastery_scaling * source.get_mastery()
	for entity in targets:
		entity.heal(final_amount)
	
	return true
