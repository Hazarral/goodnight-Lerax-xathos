class_name MultiCombatEvent
extends RefCounted

var source : Entity
var data : Array[CombatEvent]

func _init(p_source : Entity, combat_event : CombatEvent = null) -> void:
	source = p_source
	if combat_event:
		add_event(combat_event)

func add_event(combat_event : CombatEvent) -> void:
	if source and combat_event.source != source:
		push_error("Cannot add a different source to a MultiCombatEvent")
		return
		
	data.append(combat_event)

func clear() -> void:
	data.clear()
