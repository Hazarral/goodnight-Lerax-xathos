class_name VoidCharged
extends StatusEffect

var target : Entity

const VOID_STACKS := 1

func _init() -> void:
	registered_checkpoints = [
		StatusEffectPriorityList.CheckpointType.POST_DAMAGE_TO_HP_TAKEN,
		StatusEffectPriorityList.CheckpointType.STATUS_EFFECT_TICK_DOWN
	]

func register_hooks(manager : StatusEffectHookManager) -> void:
	manager.register_hook(
		registered_checkpoints[0],
		HookBinding.new(self, StatusEffectPriorityList.VOID_CHARGED_POST_DAMAGE_TO_HP_TAKEN, _interrupt)
	)
	
	manager.register_hook(
		registered_checkpoints[1],
		HookBinding.new(self, StatusEffectPriorityList.VOID_CHARGED_TURN_END, _apply_void)
	)

func _interrupt(context : DamageToHPContext) -> void:
	## TODO: Cancel and not apply anything
	pass

func _apply_void(context : StatusEffectTickDownContext) -> void:
	if context.status_effect != self:
		return
	
	target.apply_void(VOID_STACKS)
