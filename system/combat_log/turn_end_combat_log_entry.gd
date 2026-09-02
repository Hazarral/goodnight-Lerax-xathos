class_name TurnEndCombatLogEntry
extends CombatLogEntry

const BASIC_TEMPLATE := "> %s's turn ended"

func render_basic() -> String:	
	return BASIC_TEMPLATE % actor.template.entity_name

func render_advanced() -> String:
	return render_basic()

func render_developer() -> String:
	var text := STAGE_TEMPLATE % [DamageAndDoT.GENERIC_COLOR_HEX, stage, turn_number] + "\n"
	text += render_basic()
	return text
