class_name DamageSegment
extends DescriptionSegment

@export var damage_type : DamageAndDoT.DamageType
@export var base_damage : float
@export var potency_scaling : float
@export var mastery_scaling : float

const TEMPLATE := "[color=%s]%d %s Damage[/color]"

var source : Entity

func set_source(p_source : Entity) -> void:
	source = p_source

func to_text() -> String:
	var total_damage := ceili(
		base_damage + 
		potency_scaling * source.get_potency() + 
		mastery_scaling * source.get_mastery()
	)
	
	return TEMPLATE % [
		DamageAndDoT.get_damage_color_hex(damage_type),
		total_damage,
		DamageAndDoT.get_damage_type_name(damage_type)
	]
