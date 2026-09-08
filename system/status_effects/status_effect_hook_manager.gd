class_name StatusEffectHookManager
extends RefCounted

## Array is actually Array[HookBinding]
var _hooks : Dictionary[StatusEffectPriorityList.CheckpointType, Array] = {}

func _init() -> void:
	for checkpoint in StatusEffectPriorityList.CheckpointType.values():
		_hooks[checkpoint] = [] as Array[HookBinding]

func register_hook(type: StatusEffectPriorityList.CheckpointType, binding: HookBinding) -> void:
	_hooks[type].append(binding)

func remove_effect_hooks(effect: StatusEffect) -> void:
	for checkpoint in effect.registered_checkpoints:
		var arr : Array = _hooks[checkpoint]
		for i in range(arr.size() - 1, -1, -1):
			if arr[i].source_effect == effect:
				arr.remove_at(i)
