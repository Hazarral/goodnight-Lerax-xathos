class_name StatusEffectManager
extends RefCounted

var effects : Array[StatusEffect] = []
var _pending_removals : Array[StatusEffect] = []

## Array is actually Array[HookBinding]
var _hooks : Dictionary[StatusEffectPriorityList.CheckpointType, Array] = {}

func _init() -> void:
	for checkpoint in StatusEffectPriorityList.CheckpointType.values():
		_hooks[checkpoint] = [] as Array[HookBinding]

func get_status_effects() -> Array[StatusEffect]:
	return effects

func register_hook(type: StatusEffectPriorityList.CheckpointType, binding: HookBinding) -> void:
	_hooks[type].append(binding)
	_hooks[type].sort_custom(StatusEffectPriorityList.compare_priority)

func remove_effect_hooks(effect: StatusEffect) -> void:
	for checkpoint in effect.registered_checkpoints:
		var arr : Array = _hooks[checkpoint]
		for i in range(arr.size() - 1, -1, -1):
			if arr[i].source_effect == effect:
				arr.remove_at(i)

func execute_effect_hooks(type: StatusEffectPriorityList.CheckpointType, context : CheckpointContext) -> void:
	for hook : HookBinding in _hooks[type]:
		hook.execute.call(context)

func apply_status_effect(effect : StatusEffect) -> void:
	var existing := _find_matching_effect(effect)
	if existing:
		if not existing.is_permanent:
			existing.duration = existing.default_duration
		return
	
	effects.append(effect)
	effect.register_hooks(self)
	effect.status_expired.connect(remove_status_effect)
	effect.status_purged.connect(remove_status_effect)

func tick_down(entity : Entity) -> void:
	for effect in effects:
		var status_effect_tick_down_context := PreStatusEffectTickDownContext.new(entity, effect, effect.duration)
		execute_effect_hooks(StatusEffectPriorityList.CheckpointType.PRE_STATUS_EFFECT_TICK_DOWN, status_effect_tick_down_context)
		
		effect.tick_down()
	
	if _pending_removals.is_empty():
		return
	
	for effect in _pending_removals:
		effects.erase(effect)
	
	_pending_removals.clear()

func _find_matching_effect(effect : StatusEffect) -> StatusEffect:
	for e in effects:
		if e.owner == effect.owner and e.get_script() == effect.get_script():
			return e
	return null

func remove_status_effect(effect : StatusEffect) -> void:
	remove_effect_hooks(effect)
	_pending_removals.append(effect)
	
	var combat_log_entry := StatusEffectRemovedCombatLogEntry.new(
		CombatSystem.get_turn_counter(),
		effect.owner,
		"Status Effect removed",
		effect
	)
	CombatLog.register(combat_log_entry)
