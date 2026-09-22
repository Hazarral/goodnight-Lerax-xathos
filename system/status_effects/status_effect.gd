@abstract class_name StatusEffect
extends Resource

@export var effect_name : String
@export var default_duration : int = -1
@export_multiline var description : String

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
signal status_expired(status_effect : StatusEffect)
signal status_purged(status_effect : StatusEffect)

@abstract func register_hooks(manager : StatusEffectManager) -> void

func get_description() -> String:
	return description

func tick_down() -> void:
	if is_permanent or _is_expired:
		return
	
	duration -= 1
	if duration <= 0:
		_is_expired = true
		_expire()

func _expire() -> void:
	status_expired.emit(self)

func _purged() -> void:
	status_purged.emit(self)

# StatusEffect base
func on_applied(_target : Entity, _caster : Entity) -> void:
	pass

# StatusEffect base
func attaches_to_caster() -> bool:
	return false
