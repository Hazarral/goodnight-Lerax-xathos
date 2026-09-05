class_name TurnStartCombatLogEntry
extends CombatLogEntry

var actor_state : Entity.State

const TURN_START := "\n[color=%s]- Turn %d -[/color]\n"

const BASIC_ALIVE_TEMPLATE := "> %s's turn started"
const BASIC_DEAD_TEMPLATE := "> %s is [color=%s]dead[/color]"

func _init(p_turn_number : int, p_actor : Entity, p_stage : String, p_actor_state : Entity.State) -> void:
	super(p_turn_number, p_actor, p_stage)
	actor_state = p_actor_state

func render_basic() -> String:
	var text := TURN_START % [DamageAndDoT.TURN_LABEL_COLOR_HEX, turn_number] + "\n"
	
	if actor_state == Entity.State.ALIVE:
		text += BASIC_ALIVE_TEMPLATE % actor.get_entity_name_with_suffix()
	else:
		text += BASIC_DEAD_TEMPLATE % [actor.get_entity_name_with_suffix(), DamageAndDoT.VOID_COLOR_HEX]
	
	return text

func render_advanced() -> String:
	return render_basic()

func render_developer() -> String:
	var text := _get_developer_stage_prefix()
	text += render_basic()
	return text
