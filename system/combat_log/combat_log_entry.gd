@abstract class_name CombatLogEntry
extends RefCounted

## Turn number is mostly for organization, the CombatLog class will handle printing it out properly
var turn_number : int
var actor : Entity

## Developer only!
var stage : String

const STAGE_TEMPLATE := "[color=%s][Stage %s, Turn %d][/color]"

func _init(p_turn_number : int, p_actor : Entity, p_stage : String) -> void:
	turn_number = p_turn_number
	actor = p_actor
	stage = p_stage

@abstract func render_basic() -> String
@abstract func render_advanced() -> String
@abstract func render_developer() -> String
