class_name StacksSegment
extends DescriptionSegment

@export var value : int

const TEMPlATE := "[color=%s]%d Stack%s[/color] of"

func to_text(_detailed : bool = false) -> String:
	return TEMPlATE % [
		DamageAndDoT.GENERIC_COLOR_HEX,
		value,
		"s" if value != 1 else ""
	]
