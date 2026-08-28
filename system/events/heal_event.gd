class_name HealEvent
extends CombatEvent

## And the actual computed, rounded up integer amount to deliver
var amount : int

func _init(p_source : Entity, p_target : Entity, p_amount : int) -> void:
	super(p_source, p_target)
	amount = p_amount

func resolve() -> void:
	target.heal(amount)
	print("Target %s healed for %d!" % [target.template.entity_name, amount])
