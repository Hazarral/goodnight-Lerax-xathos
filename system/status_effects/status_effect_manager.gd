class_name StatusEffectManager
extends RefCounted

var effects : Array[StatusEffect] = []
var _pending_removals : Array[DoTInstance] = []

## Array is actually Array[HookBinding]
var _hooks : Dictionary[StatusEffectPriorityList.CheckpointType, Array] = {}

func _init() -> void:
	for checkpoint in StatusEffectPriorityList.CheckpointType.values():
		_hooks[checkpoint] = [] as Array[HookBinding]
	
	EventBus.status_expired.connect(remove_effect_hooks)

func get_status_effects_display_info() -> Array[StatusEffectDisplayInfo]:
	var arr : Array[StatusEffectDisplayInfo] = []
	for effect in effects:
		arr.append(
			StatusEffectDisplayInfo.new(
				effect.get_effect_name(), 
				effect.get_description(), 
				effect.duration, 
				effect.is_permanent
			)
		)
	
	return arr

func register_hook(type: StatusEffectPriorityList.CheckpointType, binding: HookBinding) -> void:
	_hooks[type].append(binding)

func remove_effect_hooks(effect: StatusEffect) -> void:
	for checkpoint in effect.registered_checkpoints:
		var arr : Array = _hooks[checkpoint]
		for i in range(arr.size() - 1, -1, -1):
			if arr[i].source_effect == effect:
				arr.remove_at(i)

func _execute_effect_hooks(type: StatusEffectPriorityList.CheckpointType, context : CheckpointContext) -> void:
	for hook : HookBinding in _hooks[type]:
		hook.execute.call(context)

func apply_status_effect(effect : StatusEffect) -> void:
	if not effects.has(effect):
		effects.append(effect)
		effect.register_hooks(self)
		return
	
	if not effect.is_permanent:
		## Refresh
		effect.duration = effect.DEFAULT_DURATION

func tick_down() -> void:
	for effect in effects:
		effect.tick_down()
	
	if _pending_removals.is_empty():
		return
	
	for effect in _pending_removals:
		effects.erase(effect)
	
	_pending_removals.clear()

func remove_status_effect(effect : StatusEffect) -> void:
	remove_effect_hooks(effect)
	_pending_removals.append(effect)
