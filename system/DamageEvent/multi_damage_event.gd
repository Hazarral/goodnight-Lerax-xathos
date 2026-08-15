class_name MultiDamageEvent
extends RefCounted

var source : Entity
var data : Array[DamageEvent]

func _init(p_source : Entity, damage_event : DamageEvent = null) -> void:
	source = p_source
	if damage_event:
		add_event(damage_event)

func add_event(damage_event : DamageEvent) -> void:
	if source and damage_event.source != source:
		push_error("Cannot add a different source to a MultiDamageEvent")
		return
		
	data.append(damage_event)

func clear() -> void:
	data.clear()
