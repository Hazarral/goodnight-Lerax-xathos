class_name HealSegment
extends DescriptionSegment

@export var base_healing : float
@export var potency_scaling : float
@export var mastery_scaling : float

const TEMPLATE := "[color=%s]%d Health[/color]"

var source : Entity

func set_source(p_source : Entity) -> void:
	source = p_source
	

func to_text() -> String:
	var total_healing := ceili(
		base_healing + 
		potency_scaling * source.get_potency() + 
		mastery_scaling * source.get_mastery()
	)
	
	return TEMPLATE % [
		DamageAndDoT.HEALING_COLOR_HEX,
		total_healing
	]
