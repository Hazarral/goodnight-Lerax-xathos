class_name StatusEffectDisplayInfo
extends RefCounted

var effect_name : String
var description : String
var duration : int
var is_permanent : bool

func _init(p_effect_name : String, p_description : String, p_duration : int, p_is_permanent : bool) -> void:
	effect_name = p_effect_name
	description = p_description
	duration = p_duration
	is_permanent = p_is_permanent
