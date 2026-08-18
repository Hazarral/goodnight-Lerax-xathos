class_name DamageActionEvent
extends ActionEvent

@export var damage_type : DamageAndDoT.DamageType
@export var ignore_shield : bool
@export var amount : int
@export var potency_scaling : float
@export var mastery_scaling : float

func resolve() -> void:
	var targets : Array[Entity] = CombatSystem.get_valid_targets(target_faction, target_state)
	
	if target_count == TargetCount.SINGLE:
		print("Single target damage action not implemented!")
		return
	
	var multi_damage_event := MultiDamageEvent.new(source)
	var final_amount = amount + potency_scaling * source.get_potency() + mastery_scaling * source.get_mastery()
	for entity in targets:
		var damage_event := DamageEvent.new(source, entity, damage_type, final_amount, ignore_shield)
		multi_damage_event.add_event(damage_event)
	
	CombatSystem.register_multi_damage_event(multi_damage_event)
	CombatSystem.process_damage_event_queue()
