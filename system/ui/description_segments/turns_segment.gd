class_name TurnsSegment
extends DescriptionSegment

@export var value : int

const TEMPLATE := "[color=%s]%d Turn%s[/color]"

func to_text(_detailed : bool = false) -> String:
	return TEMPLATE % [
		DamageAndDoT.GENERIC_COLOR_HEX,
		value,
		"s" if value != 1 else ""
	]
