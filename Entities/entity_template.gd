class_name EntityTemplate
extends Resource

#An entity has several attributes
@export var entity_name : String

## Either on player's side or not
@export var is_player_faction : bool

## Potency increases how strong damage is
@export var potency : int

## Mastery increases Attrition, which reduces Shield capacity
@export var mastery : int

@export var max_hp : int

## Please edit all 8 shields because all entitie must have all 8 reported, even at 0
@export var max_shields : PackedInt64Array

@export var max_action_point : int

@export var action_point_regen_per_turn : int
