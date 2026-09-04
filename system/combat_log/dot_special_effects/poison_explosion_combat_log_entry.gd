class_name PoisonExplosionCombatLogEntry
extends CombatLogEntry

const BASIC_TEMPLATE := "> %s's corpse exploded into a burst of [color=%s]miasma[/color]!"

func render_basic() -> String:
	return BASIC_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.POISON_COLOR_HEX
	]

func render_advanced() -> String:
	return render_basic()

func render_developer() -> String:
	var text := _get_developer_stage_prefix()
	text += render_basic()
	return text
