class_name ApplyStatusSegment
extends DescriptionSegment

@export var status : StatusEffect

const TEMPLATE := "[color=%s]%s[/color] Status"
const EXTRA_TURN_TEMPLATE := " for [color=%s]%d Turn%s[/color]"
const EXTRA_PERMANENT_TEMPLATE := " permanently"

func to_text(_detailed : bool = false) -> String:	
	var text := TEMPLATE % [
		DamageAndDoT.GENERIC_COLOR_HEX, status.effect_name
	]
	
	if status.is_permanent:
		text += EXTRA_PERMANENT_TEMPLATE
	else:
		text += EXTRA_TURN_TEMPLATE % [
			DamageAndDoT.GENERIC_COLOR_HEX, status.default_duration,
			DisplayUtility.plural_ending(status.default_duration)
		]
	
	return text
