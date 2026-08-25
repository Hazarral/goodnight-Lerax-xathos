class_name ApplyDoTActionEvent
extends ActionEvent

@export var damage_type : DamageAndDoT.DamageType
@export var base_damage : float
@export var stacks : int
@export var duration : int

func resolve(source : Entity) -> void:
	if damage_type == DamageAndDoT.DamageType.VOID:
		push_error("ApplyDoTActionEvent cannot apply Void. Please use ApplyVoidActionEvent")
		return
	
	var targets : Array[Entity] = await get_targets()
	
	for entity in targets:
		var dot_instance : DoTInstance = null
		match damage_type:
			DamageAndDoT.DamageType.FIRE:
				dot_instance = BurnInstance.new(source, entity, damage_type, base_damage, stacks, duration)
			_:
				dot_instance = DoTInstance.new(source, entity, damage_type, base_damage, stacks, duration)
		
		entity.apply_dot(dot_instance)
