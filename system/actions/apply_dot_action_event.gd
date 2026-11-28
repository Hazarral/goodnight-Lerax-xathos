@tool
class_name ApplyDoTActionEvent
extends ActionEvent

@export var damage_type : DamageAndDoT.DamageType
@export var base_damage : float
@export var stacks : int
@export var duration : int

func resolve(source : Entity, inherited_targets : Array[Entity]) -> bool:
	if damage_type == DamageAndDoT.DamageType.VOID:
		push_error("ApplyDoTActionEvent cannot apply Void. Please use ApplyVoidActionEvent")
		return false
	
	var targets : Variant = await get_targets(source, inherited_targets)
	if targets == null:
		## Already cancelled!
		return false
	
	for entity : Entity in targets:
		var dot_instance : DoTInstance = null
		match damage_type:
			DamageAndDoT.DamageType.FIRE:
				dot_instance = BurnInstance.new(source, entity, damage_type, base_damage, stacks, duration)
			_:
				dot_instance = DoTInstance.new(source, entity, damage_type, base_damage, stacks, duration)
		
		entity.apply_dot(dot_instance)
	
	return true

func get_tags() -> Array[Utility.Tag]:
	var tag := Utility.Tag.APPLY_BURN
	match damage_type:
		DamageAndDoT.DamageType.FIRE:
			tag = Utility.Tag.APPLY_BURN
		DamageAndDoT.DamageType.WATER:
			tag = Utility.Tag.APPLY_CURRENT
		DamageAndDoT.DamageType.WIND:
			tag = Utility.Tag.APPLY_WIND_SHEAR
		DamageAndDoT.DamageType.POISON:
			tag = Utility.Tag.APPLY_POISON
		DamageAndDoT.DamageType.LIGHTNING:
			tag = Utility.Tag.APPLY_SHOCK
		DamageAndDoT.DamageType.PHYSICAL:
			tag = Utility.Tag.APPLY_BLEED
		DamageAndDoT.DamageType.EARTH:
			tag = Utility.Tag.APPLY_CRUMBLE
		DamageAndDoT.DamageType.ICE:
			tag = Utility.Tag.APPLY_FROSTBITE
		
	return super() + [tag]
