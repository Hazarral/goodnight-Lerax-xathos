class_name Entity
extends RefCounted

var template : EntityTemplate

var current_hp : int
var current_shields : PackedInt64Array

## Template will be duplicated

func _init(base_template : EntityTemplate, magnification : float = 1.0) -> void:
	template = base_template.duplicate(true)
	
	current_hp = floori(template.max_hp * magnification)
	
	current_shields.resize(DamageAndDoT.ELEMENT_COUNT)
	for i in range(DamageAndDoT.ELEMENT_COUNT):
		current_shields[i] = floori(template.max_shields[i] * magnification)
