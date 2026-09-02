class_name TurnStartCombatLogEntry
extends CombatLogEntry

var actor_state : Entity.State

const TURN_START := "[color=%s]- Turn %d -[/color]"

const BASIC_ALIVE_TEMPLATE := "> %s's turn started"
const BASIC_DEAD_TEMPLATE := "> %s is [color=%s]dead[/color]"

func _init(p_turn_number : int, p_actor : Entity, p_stage : String, p_actor_state : Entity.State) -> void:
	super(p_turn_number, p_actor, p_stage)
	actor_state = p_actor_state

func render_basic() -> String:
	var text := TURN_START % [DamageAndDoT.TURN_LABEL_COLOR_HEX, turn_number] + "\n"
	
	if actor_state == Entity.State.ALIVE:
		text += BASIC_ALIVE_TEMPLATE % actor.template.entity_name
	else:
		text += BASIC_DEAD_TEMPLATE % [actor.template.entity_name, DamageAndDoT.VOID_COLOR_HEX]
	
	return text

func render_advanced() -> String:
	return render_basic()

func render_developer() -> String:
	var text := STAGE_TEMPLATE % [DamageAndDoT.GENERIC_COLOR_HEX, stage, turn_number] + "\n"
	text += render_basic()
	return text
