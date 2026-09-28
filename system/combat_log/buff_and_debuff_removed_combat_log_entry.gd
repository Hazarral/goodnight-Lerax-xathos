class_name BuffAndDebuffRemovedCombatLogEntry
extends CombatLogEntry

var buff_and_debuff : BuffAndDebuff

const BASIC_TEMPLATE := "> %s no longer has [color=%s]%s[/color]"

func _init(
	p_turn_number : int,
	p_actor : Entity,
	p_stage : String,
	p_buff_and_debuff : BuffAndDebuff
) -> void:
	super(p_turn_number, p_actor, p_stage)
	buff_and_debuff = p_buff_and_debuff

func render_basic() -> String:
	return BASIC_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.GENERIC_COLOR_HEX, buff_and_debuff.buff_and_debuff_name
	]

func render_advanced() -> String:
	return render_basic()

func render_developer() -> String:
	var text := _get_developer_stage_prefix()
	text += render_basic()
	return text
