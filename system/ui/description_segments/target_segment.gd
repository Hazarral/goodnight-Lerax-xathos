class_name TargetSegment
extends DescriptionSegment

@export var target_count : ActionEvent.TargetCount
@export var target_state : ActionEvent.TargetState
@export var target_faction : ActionEvent.TargetFaction

const TEMPLATE := "to %s %s %s"

const TARGET_COUNT_SINGLE_TEMPLATE := "one"
const TARGET_COUNT_ALL_TEMPLATE := "all"

const TARGET_STATE_ALIVE_TEMPLATE := "alive"
const TARGET_STATE_DEAD_TEMPLATE := "dead"
const TARGET_STATE_ALL_TEMPLATE := "dead or alive"

const TARGET_FACTION_ENEMY_SINGULAR_TEMPLATE := "enemy"
const TARGET_FACTION_ENEMY_PLURAL_TEMPLATE := "enemies"
const TARGET_FACTION_ALL_SINGULAR_TEMPLATE := "entity"
const TARGET_FACTION_ALL_PLURAL_TEMPLATE := "entities"

func to_text(_detailed : bool = false) -> String:
	if target_faction == ActionEvent.TargetFaction.PLAYER:
		return _player_faction_text()
	
	var count := _count_text()
	var state := _state_text()
	var faction := _faction_text()
	
	return TEMPLATE % [count, state, faction]

func _count_text() -> String:
	match target_count:
		ActionEvent.TargetCount.SINGLE:
			return TARGET_COUNT_SINGLE_TEMPLATE
		ActionEvent.TargetCount.ALL:
			return TARGET_COUNT_ALL_TEMPLATE
	return ""

func _state_text() -> String:
	match target_state:
		ActionEvent.TargetState.ALIVE:
			return TARGET_STATE_ALIVE_TEMPLATE
		ActionEvent.TargetState.DEAD:
			return TARGET_STATE_DEAD_TEMPLATE
		ActionEvent.TargetState.ALL:
			return TARGET_STATE_ALL_TEMPLATE
	return ""

func _faction_text() -> String:
	var is_plural := target_count == ActionEvent.TargetCount.ALL
	match target_faction:
		ActionEvent.TargetFaction.ENEMY:
			return TARGET_FACTION_ENEMY_PLURAL_TEMPLATE if is_plural else TARGET_FACTION_ENEMY_SINGULAR_TEMPLATE
		ActionEvent.TargetFaction.ALL:
			return TARGET_FACTION_ALL_PLURAL_TEMPLATE if is_plural else TARGET_FACTION_ALL_SINGULAR_TEMPLATE
	return ""

func _player_faction_text() -> String:
	var is_plural := target_count == ActionEvent.TargetCount.ALL
	var state := _state_text()
	
	if is_plural:
		return "to all %s entities on Draechen's side, including Draechen himself" % state
	else:
		return "to one %s entity on Draechen's side, or Draechen himself" % state
