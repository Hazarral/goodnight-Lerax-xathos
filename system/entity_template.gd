class_name EntityTemplate
extends Resource

#An entity has several attributes
@export var entity_name : StringName

## Potency increases how strong damage is
@export var potency : int

## Mastery increases Attrition, which reduces Shield capacity
@export var mastery : int

@export var max_hp : int

@export var max_shields : PackedInt64Array
