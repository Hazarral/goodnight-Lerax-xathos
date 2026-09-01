class_name ApplyRandomDoT
extends ActionEvent

@export var base_damage : float
@export var stacks : int
@export var duration : int

func resolve(source : Entity, inherited_targets : Array[Entity]) -> bool:
	var targets : Variant = await get_targets(source, inherited_targets)
	if targets == null:
		## Already cancelled!
		return false
	
	for entity in targets:
		var random_damage_type := randi_range(0, DamageAndDoT.ELEMENT_COUNT - 1) as DamageAndDoT.DamageType
		var dot_instance : DoTInstance = null
		match random_damage_type:
			DamageAndDoT.DamageType.FIRE:
				dot_instance = BurnInstance.new(source, entity, random_damage_type, base_damage, stacks, duration)
			_:
				dot_instance = DoTInstance.new(source, entity, random_damage_type, base_damage, stacks, duration)
		
		entity.apply_dot(dot_instance)
	
	return true
