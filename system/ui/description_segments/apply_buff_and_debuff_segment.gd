class_name ApplyBuffAndDebuffSegment
extends DescriptionSegment

@export var buff_and_debuff : BuffAndDebuff

const TEMPLATE := "[color=%s]%s[/color] Modifier"
const EXTRA_TURN_TEMPLATE := " for [color=%s]%d Turn%s[/color]"
const EXTRA_PERMANENT_TEMPLATE := " permanently"

func to_text(_detailed : bool = false) -> String:	
	var text := TEMPLATE % [
		DamageAndDoT.GENERIC_COLOR_HEX, buff_and_debuff.buff_and_debuff_name
	]
	
	if buff_and_debuff.is_permanent:
		text += EXTRA_PERMANENT_TEMPLATE
	else:
		text += EXTRA_TURN_TEMPLATE % [
			DamageAndDoT.GENERIC_COLOR_HEX, buff_and_debuff.duration,
			DisplayUtility.plural_ending(buff_and_debuff.duration)
		]
	
	return text
