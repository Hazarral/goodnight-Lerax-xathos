class_name StatusEffectAppliedCombatLogEntry
extends CombatLogEntry

var status_effect : StatusEffect

const BASIC_TEMPLATE := "> %s receives [color=%s]%s[/color]"
const EXTRA_PERMANENT_TEMPLATE := " permanently"
const EXTRA_TURN_TEMPLATE := " for %d Turn%s"

func _init(
	p_turn_number : int,
	p_actor : Entity,
	p_stage : String,
	p_status_effect : StatusEffect
) -> void:
	super(p_turn_number, p_actor, p_stage)
	status_effect = p_status_effect

func render_basic() -> String:
	var text := BASIC_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.GENERIC_COLOR_HEX, status_effect.effect_name
	]
	
	if status_effect.is_permanent:
		text += EXTRA_PERMANENT_TEMPLATE
	else:
		text += EXTRA_TURN_TEMPLATE % [
			status_effect.duration,
			"s" if status_effect.duration != 1 else ""
		]
	
	return text

func render_advanced() -> String:
	return render_basic()

func render_developer() -> String:
	var text := _get_developer_stage_prefix()
	text += render_basic()
	return text
