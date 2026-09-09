class_name VoidCharged
extends StatusEffect

var prechosen_target : Entity  # who eats the Void stack on expiry
var _interrupted := false

const DEFAULT_DURATION := 2

const VOID_STACKS := 1
const DESCRIPTION := "On expiration, apply %d Void Stack%s to %s. If the owner's shield is broken or receives damage to Health, Void-Charged is cancelled and does not apply Void."
const NAME := "Void-Charged"

func _init(p_duration : int = DEFAULT_DURATION) -> void:
	registered_checkpoints = [
		StatusEffectPriorityList.CheckpointType.POST_DAMAGE_TO_HP_TAKEN,
		StatusEffectPriorityList.CheckpointType.POST_SHIELD_BREAK,
		StatusEffectPriorityList.CheckpointType.STATUS_EFFECT_TICK_DOWN
	]
	
	duration = p_duration

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
		HookBinding.new(self, StatusEffectPriorityList.VOID_CHARGED_STATUS_EFFECT_TICK_DOWN, _apply_void)
	)

func get_description() -> String:
	return DESCRIPTION % [
		VOID_STACKS,
		"s" if VOID_STACKS > 1 else "",
		prechosen_target.get_entity_name_with_suffix() 
	]

func get_effect_name() -> String:
	return NAME

func _interrupt(_context : DamageToHPContext) -> void:
	_interrupted = true

func _apply_void(context : StatusEffectTickDownContext) -> void:
	if context.status_effect != self:
		return
	
	if _interrupted:
		return
	
	prechosen_target.apply_void(VOID_STACKS)
