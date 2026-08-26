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

func cast(source : Entity) -> bool:	
	var counter : int = 0
	
	for action_event in action_events:
		var dynamic_event: Variant = action_event
		var success : bool = await dynamic_event.resolve(source)
		print("ActionEvent index %d success status: %s" % [counter, success])
		if not success:
			return false
		
		print("%s: ActionEvent index %d succeeded" % [action_name, counter])
		counter += 1
	
	return true
