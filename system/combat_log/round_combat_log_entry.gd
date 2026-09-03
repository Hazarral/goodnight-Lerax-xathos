class_name RoundCombatLogEntry
extends CombatLogEntry

const BASIC_TEMPLATE := "[color=%s] === ROUND %d ===[/color]"

func render_basic() -> String:	
	return BASIC_TEMPLATE % [
		DamageAndDoT.GENERIC_COLOR_HEX,
		CombatSystem.get_round_counter()
	]

func render_advanced() -> String:
	return render_basic()

func render_developer() -> String:
	var text := _get_developer_stage_prefix()
	text += render_basic()
	return text
