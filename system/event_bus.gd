extends Node

## Emitted by the action event itself to seek a single target
signal target_requested(
	action_event : ActionEvent, 
	target_faction : ActionEvent.TargetFaction, 
	target_state : ActionEvent.TargetState
)

## And in response, the UI/AI will pick and emit this signal
signal target_chosen(entity : Entity)

## When a target die due to self-harm, typically
signal force_refresh_turn_ui()
