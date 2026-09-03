class_name VoidEscalateCombatLogEntry
extends CombatLogEntry

const BASIC_TEMPLATE := "> [color=%s]The Primordial Void[/color]'s hunger grows..."

func render_basic() -> String:	
	return BASIC_TEMPLATE % DamageAndDoT.VOID_COLOR_HEX

func render_advanced() -> String:
	return render_basic()

func render_developer() -> String:
	var text := _get_developer_stage_prefix()
	text += render_basic()
	return text
