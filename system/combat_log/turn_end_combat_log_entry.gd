class_name TurnEndCombatLogEntry
extends CombatLogEntry

const BASIC_TEMPLATE := "> %s's turn ended"

func render_basic() -> String:	
	return BASIC_TEMPLATE % actor.get_entity_name_with_suffix()

func render_advanced() -> String:
	return render_basic()

func render_developer() -> String:
	var text := _get_developer_stage_prefix()
	text += render_basic()
	return text

func execute_visuals() -> void:
	if CombatLog.entity_info_card_registry.has(actor):
		var card := CombatLog.entity_info_card_registry[actor]
		card.sync_action_point()
