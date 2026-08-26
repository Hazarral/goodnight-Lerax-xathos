extends Node

## Emitted by the action event itself to seek a single target
signal target_requested(
	action_event : ActionEvent, 
	target_faction : ActionEvent.TargetFaction, 
	target_state : ActionEvent.TargetState
)

## If the entity is null, it is the same as cancelling, or there is no target and this cannot be casted
signal target_resolved(entity : Entity)

## When a target die due to self-harm, typically
signal force_refresh_turn_ui()
