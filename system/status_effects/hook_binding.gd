class_name HookBinding
extends RefCounted

var source_effect : StatusEffect
var priority : int
var execute : Callable

func _init(p_source_effect : StatusEffect, p_priority : int, p_execute : Callable) -> void:
	source_effect = p_source_effect
	priority = p_priority
	execute = p_execute
