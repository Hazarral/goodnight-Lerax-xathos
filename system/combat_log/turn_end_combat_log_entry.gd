class_name TurnEndCombatLogEntry
extends CombatLogEntry

const BASIC_TEMPLATE := "%s's turn ended"

func render_basic() -> String:	
	return BASIC_TEMPLATE % actor.template.entity_name

func render_advanced() -> String:
	return render_basic()

func render_developer() -> String:
	var text := STAGE_TEMPLATE % stage + "\n"
	text += render_basic()
	return text
