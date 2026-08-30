class_name VoidSegment
extends DescriptionSegment

@export var stacks : int
const TEMPLATE := "[color=%s]%d Void Stack%s[/color]"

func to_text() -> String:
	return TEMPLATE % [
		DamageAndDoT.VOID_COLOR_HEX,
		stacks,
		"s" if stacks > 1 else ""
	]
