@abstract class_name StatusEffect
extends RefCounted

var owner : Entity
var stacks : int
var is_permanent : bool

## Only used if is_permanent == false
var duration : int

## Hard-coded per subclass: which checkpoints this effect hooks.
## Set once in _init, never mutated
## at runtime by the hook manager or anything else.
var registered_checkpoints : Array[StatusEffectPriorityList.CheckpointType] = []

@abstract func register_hooks(manager : StatusEffectHookManager) -> void

func tick_down() -> void:
	if is_permanent:
		return
	
	duration -= 1
	if duration <= 0:
		_expire()

func _expire() -> void:
	EventBus.status_expired.emit(self)

func _purged() -> void:
	EventBus.status_purged.emit(self)
