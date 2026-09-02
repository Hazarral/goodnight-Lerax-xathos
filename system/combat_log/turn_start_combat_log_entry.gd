class_name TurnStartCombatLogEntry
extends CombatLogEntry

var actor_state : Entity.State

const TURN_START := "- Turn %d -"

const BASIC_ALIVE_TEMPLATE := "%s's turn started"
const BASIC_DEAD_TEMPLATE := "%s is dead"

func _init(p_turn_number : int, p_actor : Entity, p_stage : String, p_actor_state : Entity.State) -> void:
	super(p_turn_number, p_actor, p_stage)
	actor_state = p_actor_state

func render_basic() -> String:
	var text := TURN_START % turn_number + "\n"
	
	if actor_state == Entity.State.ALIVE:
		text += BASIC_ALIVE_TEMPLATE % actor.template.entity_name
	else:
		text += BASIC_DEAD_TEMPLATE % actor.template.entity_name
	
	return text

func render_advanced() -> String:
	return render_basic()

func render_developer() -> String:
	return render_basic()
