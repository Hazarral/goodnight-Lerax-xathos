class_name HealSegment
extends DescriptionSegment

@export var base_healing : float
@export var potency_scaling : float
@export var mastery_scaling : float

const SIMPLE_TEMPLATE := "[color=%s]%d Health[/color]"
const DETAILED_TEMPLATE := "[color=%s]%d[/color] [color=%s][%.2f + %.2f(%.2fP) + %.2f(%.2fM)][/color] [color=%s]Health[/color]"

var source : Entity

func set_source(p_source : Entity) -> void:
	source = p_source

func to_text(detailed : bool = false) -> String:	
	var potency := source.get_potency()
	var mastery := source.get_mastery()
	
	var total_healing := ceili(
		base_healing + 
		potency_scaling * potency + 
		mastery_scaling * mastery
	)
	
	if detailed:
		return DETAILED_TEMPLATE % [
			DamageAndDoT.HEALING_COLOR_HEX, total_healing,
			DamageAndDoT.GENERIC_COLOR_HEX,
			base_healing,
			potency * potency_scaling,
			potency_scaling,
			mastery * mastery_scaling,
			mastery_scaling,
			DamageAndDoT.HEALING_COLOR_HEX
		]
	
	return SIMPLE_TEMPLATE% [
		DamageAndDoT.HEALING_COLOR_HEX,
		total_healing,
	]
