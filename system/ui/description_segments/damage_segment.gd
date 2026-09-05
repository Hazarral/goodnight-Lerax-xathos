class_name DamageSegment
extends DescriptionSegment

@export var damage_type : DamageAndDoT.DamageType
@export var base_damage : float
@export var potency_scaling : float
@export var mastery_scaling : float

const SIMPLE_TEMPLATE := "[color=%s]%d %s Damage[/color]"
const DETAILED_TEMPLATE := "[color=%s]%d[/color] [color=%s][%.2f + %.2f(%.2fP) + %.2f(%.2fM)][/color] [color=%s]%s Damage[/color]"

var source : Entity

func set_source(p_source : Entity) -> void:
	source = p_source

func to_text(detailed : bool = false) -> String:
	var potency := source.get_potency()
	var mastery := source.get_mastery()
	
	var total_damage := ceili(
		base_damage + 
		potency_scaling * potency + 
		mastery_scaling * mastery
	)
	
	if detailed:
		return DETAILED_TEMPLATE % [
			DamageAndDoT.get_damage_color_hex(damage_type), total_damage,
			DamageAndDoT.GENERIC_COLOR_HEX, 
			base_damage,
			potency * potency_scaling,
			potency_scaling,
			mastery * mastery_scaling,
			mastery_scaling,
			DamageAndDoT.get_damage_color_hex(damage_type),
			DamageAndDoT.get_damage_type_name(damage_type)
		]
	
	return SIMPLE_TEMPLATE % [
		DamageAndDoT.get_damage_color_hex(damage_type),
		total_damage,
		DamageAndDoT.get_damage_type_name(damage_type)
	]
