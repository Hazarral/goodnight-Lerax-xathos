class_name StatusEffectRemovedCombatLogEntry
extends CombatLogEntry

var status_effect : StatusEffect

const BASIC_TEMPLATE := "> %s no longer has [color=%s]%s[/color]"

func _init(
	p_turn_number : int,
	p_actor : Entity,
	p_stage : String,
	p_status_effect : StatusEffect
) -> void:
	super(p_turn_number, p_actor, p_stage)
	status_effect = p_status_effect

func render_basic() -> String:
	return BASIC_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.GENERIC_COLOR_HEX, status_effect.effect_name
	]

func render_advanced() -> String:
	return render_basic()

func render_developer() -> String:
	var text := _get_developer_stage_prefix()
	text += render_basic()
	return text
