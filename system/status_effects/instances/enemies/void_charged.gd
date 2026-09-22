class_name VoidCharged
extends StatusEffect

var prechosen_target : Entity  # who eats the Void stack on expiry
var _interrupted := false

@export var void_stacks := 1
const DESCRIPTION := "On expiration, apply %d Void Stack%s to %s. If the owner's shield is broken or receives damage to Health, Void-Charged is cancelled and does not apply Void."

func _init() -> void:
	registered_checkpoints = [
		StatusEffectPriorityList.CheckpointType.POST_DAMAGE_TO_HP_TAKEN,
		StatusEffectPriorityList.CheckpointType.POST_SHIELD_BREAK,
		StatusEffectPriorityList.CheckpointType.PRE_STATUS_EFFECT_TICK_DOWN
	]

func register_hooks(manager : StatusEffectManager) -> void:
	manager.register_hook(
		registered_checkpoints[0],
		HookBinding.new(self, StatusEffectPriorityList.VOID_CHARGED_POST_DAMAGE_TO_HP_TAKEN, _interrupt)
	)
	
	manager.register_hook(
		registered_checkpoints[1],
		HookBinding.new(self, StatusEffectPriorityList.VOID_CHARGED_POST_SHIELD_BREAK, _interrupt)
	)
	
	manager.register_hook(
		registered_checkpoints[2],
		HookBinding.new(self, StatusEffectPriorityList.VOID_CHARGED_PRE_STATUS_EFFECT_TICK_DOWN, _apply_void)
	)

func get_description() -> String:
	return DESCRIPTION % [
		void_stacks,
		"s" if void_stacks != 1 else "",
		prechosen_target.get_entity_name_with_suffix() 
	]

func _interrupt(_context : CheckpointContext) -> void:
	if _interrupted:
		return
	
	_interrupted = true

func _apply_void(context : PreStatusEffectTickDownContext) -> void:
	if context.status_effect != self:
		return
	
	if context.remaining_duration > 1:
		return
	
	if _interrupted:
		return
	
	prechosen_target.apply_void(void_stacks)

# StatusEffect base
func on_applied(target : Entity, _caster : Entity) -> void:
	prechosen_target = target
	duration = default_duration

# A bit unintuitive, but it's how it works
func attaches_to_caster() -> bool:
	return true
