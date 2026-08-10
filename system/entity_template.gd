class_name EntityTemplate
extends Resource

#An entity has several attributes
@export var entity_name : StringName = ""

## Potency increases how strong damage is
@export var potency : int = 0

## Mastery increases Attrition, which reduces Shield capacity
@export var mastery : int = 0

@export var max_hp : int = 0
@export var current_hp : int = 0

@export var max_shields : PackedInt32Array = [0, 0, 0, 0, 0, 0, 0, 0] 
@export var current_shields : PackedInt32Array = [0, 0, 0, 0, 0, 0, 0, 0]
