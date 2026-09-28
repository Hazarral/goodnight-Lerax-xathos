class_name HealActionEvent
extends ActionEvent

@export var amount : int
@export var potency_scaling : float
@export var mastery_scaling : float

func resolve(source : Entity, inherited_targets : Array[Entity]) -> bool:
	var targets : Variant = await get_targets(source, inherited_targets)
	if targets == null:
		return false
	
	var multi_heal_event := MultiCombatEvent.new(source)
	var final_amount = amount + potency_scaling * source.get_potency() + mastery_scaling * source.get_mastery()
	for entity : Entity in targets:
		var heal_event := HealEvent.new(source, entity, final_amount)
		multi_heal_event.add_event(heal_event)
	
	CombatSystem.register_multi_combat_event(multi_heal_event)
	CombatSystem.process_combat_event_queue()
	
	return true
