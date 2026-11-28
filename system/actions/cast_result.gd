class_name CastResult
extends RefCounted

var success : bool
var ap_spent : int

func _init(p_success : bool, p_ap_spent : int) -> void:
	success = p_success
	ap_spent = p_ap_spent
