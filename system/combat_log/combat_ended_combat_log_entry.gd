class_name CombatEndedCombatLogEntry
extends CombatLogEntry

const BASIC_TEMPLATE := "Combat Ended!"

func render_basic() -> String:
	return BASIC_TEMPLATE

func render_advanced() -> String:
	return render_basic()

func render_developer() -> String:
	return render_basic()
