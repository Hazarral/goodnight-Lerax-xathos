class_name AshenFlame
extends StatusEffect

const BURN_BASE_DAMAGE := 100.0
const BURN_STACKS := 1
const BURN_DURATION := 5

const DESCRIPTION := "The Ashen Flame of the God of Fire and Ash. After any entity's turn ends, inflicts Burn on all enemies."
const NAME := "Ashen Flame"

func _init() -> void:
	registered_checkpoints = [
		StatusEffectPriorityList.CheckpointType.TURN_END
	]
	
	is_permanent = true

## This is Roslum's Tier 3 passive
func register_hooks(manager : StatusEffectManager) -> void:
	manager.register_hook(
		registered_checkpoints[0],
		HookBinding.new(self, StatusEffectPriorityList.ASHEN_FLAME_TURN_END, _apply_burn)
	)

func get_description() -> String:
	return DESCRIPTION

func get_effect_name() -> String:
	return NAME

func get_default_duration() -> int:
	return -1

func _apply_burn(_context : TurnEndContext) -> void:
	var targets := CombatSystem.get_valid_targets(ActionEvent.TargetFaction.ENEMY, ActionEvent.TargetState.ALL)
	for target in targets:
		var burn_instance := BurnInstance.new(source, target, DamageAndDoT.DamageType.FIRE, BURN_BASE_DAMAGE, BURN_STACKS, BURN_DURATION)
		target.apply_dot(burn_instance)
