class_name DamageActionEvent
extends ActionEvent

@export var damage_type : DamageAndDoT.DamageType
@export var ignore_shield : bool
@export var amount : int
@export var potency_scaling : float
@export var mastery_scaling : float

func resolve(source : Entity, inherited_targets : Array[Entity]) -> bool:
	var targets : Variant = await get_targets(source, inherited_targets)
	if targets == null:
		## Already cancelled!
		print("DamageActionEvent had null targets! Cancelling...")
		return false
	
	var multi_damage_event := MultiCombatEvent.new(source)
	var final_amount := ceili(amount + potency_scaling * source.get_potency() + mastery_scaling * source.get_mastery())
	for entity : Entity in targets:
		var damage_event := DamageEvent.new(source, entity, damage_type, final_amount, ignore_shield)
		multi_damage_event.add_event(damage_event)
	
	CombatSystem.register_multi_combat_event(multi_damage_event)
	CombatSystem.process_combat_event_queue()
	return true
