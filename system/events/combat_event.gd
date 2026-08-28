@abstract class_name CombatEvent
extends RefCounted

## Who caused this damage?
var source : Entity

## Who is the receiver?
var target : Entity

func _init(p_source : Entity, p_target : Entity) -> void:
	source = p_source
	target = p_target

@abstract func resolve() -> void
