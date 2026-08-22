class_name Action
extends Resource

## Name of this action, e.g. "Fire Breath"
@export var action_name : String

## Cost to cast this action, in AP
@export var action_point_cost : int

## Cooldown, in turns
@export var cooldown : int

## Description: what it does
@export_multiline var description : String 

## List of modular action this will perform in order, all ActionEvent have the same targeting specification as this Action
@export var action_events : Array[ActionEvent]

func cast(source : Entity) -> void:	
	for action_event in action_events:
		action_event.source = source
		action_event.resolve()
