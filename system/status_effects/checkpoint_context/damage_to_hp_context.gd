class_name DamageToHPContext
extends CheckpointContext

var amount : int
var ignore_shield : bool

func _init(p_amount : int, p_ignore_shield : bool) -> void:
	amount = p_amount
	ignore_shield = p_ignore_shield
