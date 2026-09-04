class_name DeathCombatLogEntry
extends CombatLogEntry

const BASIC_TEMPLATE := "> %s [color=%s]died[/color]. (Taken by [color=%s]Evernight.[/color])"

func render_basic() -> String:
	return BASIC_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.VOID_COLOR_HEX,
		DamageAndDoT.VOID_COLOR_HEX
	]

func render_advanced() -> String:
	return render_basic()

func render_developer() -> String:
	var text := _get_developer_stage_prefix()
	text += render_basic()
	return text
