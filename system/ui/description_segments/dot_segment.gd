class_name DoTSegment
extends DescriptionSegment

@export var damage_over_time_type : DamageAndDoT.DoT
@export var stacks : int
@export var base_damage : float
@export var duration : int

const SIMPLE_TEMPLATE := "[color=%s]%d Stack%s[/color] of [color=%s]%s[/color] at [color=%s]%d Base Damage[/color] for [color=%s]%d Turns[/color]"
const DETAILED_TEMPLATE := "[color=%s]%d Stack%s[/color] of [color=%s]%s[/color] at [color=%s]%.2f Base Damage[/color] for [color=%s]%d Turns[/color]"

func to_text(detailed : bool = false) -> String:
	var damage_color := DamageAndDoT.get_damage_color_hex(DamageAndDoT.get_damage_type(damage_over_time_type))
	
	if detailed:
		return DETAILED_TEMPLATE % [
			DamageAndDoT.GENERIC_COLOR_HEX, stacks, "s" if stacks != 1 else "",
			damage_color, DamageAndDoT.get_damage_over_time_name(damage_over_time_type),
			damage_color, ceili(base_damage),
			DamageAndDoT.GENERIC_COLOR_HEX, duration
		]
	
	return SIMPLE_TEMPLATE % [
		DamageAndDoT.GENERIC_COLOR_HEX, stacks, "s" if stacks != 1 else "",
		damage_color, DamageAndDoT.get_damage_over_time_name(damage_over_time_type),
		damage_color, base_damage,
		DamageAndDoT.GENERIC_COLOR_HEX, duration
	]
