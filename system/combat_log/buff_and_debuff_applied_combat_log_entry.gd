class_name BuffAndDebuffAppliedCombatLogEntry
extends CombatLogEntry

var buff_and_debuff : BuffAndDebuff

const BASIC_TEMPLATE := "> %s receives [color=%s]%s[/color]"
const EXTRA_PERMANENT_TEMPLATE := " permanently"
const EXTRA_TURN_TEMPLATE := " for %d Turn%s"

func _init(
	p_turn_number : int,
	p_actor : Entity,
	p_stage : String,
	p_buff_and_debuff : BuffAndDebuff
) -> void:
	super(p_turn_number, p_actor, p_stage)
	buff_and_debuff = p_buff_and_debuff

func render_basic() -> String:
	var text := BASIC_TEMPLATE % [
		actor.get_entity_name_with_suffix(),
		DamageAndDoT.GENERIC_COLOR_HEX, buff_and_debuff.buff_and_debuff_name
	]
	
	if buff_and_debuff.is_permanent:
		text += EXTRA_PERMANENT_TEMPLATE
	else:
		text += EXTRA_TURN_TEMPLATE % [
			buff_and_debuff.duration,
			"s" if buff_and_debuff.duration != 1 else ""
		]
	
	return text

func render_advanced() -> String:
	return render_basic()

func render_developer() -> String:
	var text := _get_developer_stage_prefix()
	text += render_basic()
	return text
