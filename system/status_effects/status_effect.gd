@abstract class_name StatusEffect
extends Resource

var owner : Entity       # who the effect lives on — ticks, gets cleansed, shows in their status bar
var source : Entity      # who caused/casts it — Potency/Mastery source, authority for resolution
var stacks : int
var is_permanent : bool
var _is_expired := false

## Only used if is_permanent == false
var duration : int

## Hard-coded per subclass: which checkpoints this effect hooks.
## Set once in _init, never mutated
## at runtime by the hook manager or anything else.
var registered_checkpoints : Array[StatusEffectPriorityList.CheckpointType] = []

@abstract func register_hooks(manager : StatusEffectManager) -> void
@abstract func get_description() -> String
@abstract func get_effect_name() -> String
@abstract func get_default_duration() -> int

func tick_down() -> void:
	if is_permanent or _is_expired:
		return
	
	duration -= 1
	if duration <= 0:
		_is_expired = true
		_expire()

func _expire() -> void:
	EventBus.status_expired.emit(self)

func _purged() -> void:
	EventBus.status_purged.emit(self)

# StatusEffect base
func on_applied(target : Entity, caster : Entity) -> void:
	pass

# StatusEffect base
func attaches_to_caster() -> bool:
	return false
