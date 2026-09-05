class_name Action
extends Resource

## What world this came from
@export var origin : World.Origin

## Name of this action, e.g. "Fire Breath"
@export var action_name : String

## Cost to cast this action, in AP
@export var action_point_cost : int

## Cooldown, in turns
@export var cooldown : int

## Description: what it does
@export var description_segments : Array[DescriptionSegment]

## List of modular action this will perform in order, all ActionEvent have the same targeting specification as this Action
@export var action_events : Array[ActionEvent]

func cast(source : Entity) -> bool:	
	var last_targets : Array[Entity] = []
	for action_event in action_events:
		var dynamic_event : Variant = action_event
		var success : bool = await dynamic_event.resolve(source, last_targets)
		if not success:
			return false
		last_targets = action_event.get_last_resolved_targets()
	
	return true
