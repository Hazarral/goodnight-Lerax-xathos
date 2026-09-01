class_name DoTSegment
extends DescriptionSegment

@export var damage_over_time_type : DamageAndDoT.DoT
@export var stacks : int
@export var base_damage : float
@export var duration : int

const TEMPLATE := "[color=%s]%d Stacks[/color] of [color=%s]%s[/color] at [color=%s]%d Base Damage[/color] for [color=%s]%d Turns[/color]"

func to_text() -> String:
	var damage_color := DamageAndDoT.get_damage_color_hex(DamageAndDoT.get_damage_type(damage_over_time_type))
	
	return TEMPLATE % [
		DamageAndDoT.GENERIC_COLOR_HEX, stacks,
		damage_color, DamageAndDoT.get_damage_over_time_name(damage_over_time_type),
		damage_color, ceili(base_damage),
		DamageAndDoT.GENERIC_COLOR_HEX, duration
	]
