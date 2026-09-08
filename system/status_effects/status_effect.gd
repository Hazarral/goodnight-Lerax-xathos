@abstract class_name StatusEffect
extends RefCounted

var target : Entity
var stacks : int
var is_permanent : bool

## Only used if is_permanent == false
var duration : int

## Hard-coded per subclass: which checkpoints this effect hooks.
## Set once in _init, never mutated
## at runtime by the hook manager or anything else.
var registered_checkpoints : Array[StatusEffectPriorityList.CheckpointType] = []

func _expire() -> void:
	EventBus.status_expired.emit(self)
