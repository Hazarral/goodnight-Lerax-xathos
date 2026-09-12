extends Node

## Emitted when a DoT instance expires
@warning_ignore("unused_signal")
signal dot_instance_expired(dot_instance : DoTInstance)

## Emitted by the action event itself to seek a single target
@warning_ignore("unused_signal")
signal target_requested(
	action_event : ActionEvent, 
	target_faction : ActionEvent.TargetFaction, 
	target_state : ActionEvent.TargetState
)

## If the entity is null, it is the same as cancelling, or there is no target and this cannot be casted
@warning_ignore("unused_signal")
signal target_resolved(entity : Entity)

## When a target die due to self-harm, typically
@warning_ignore("unused_signal")
signal force_refresh_turn_ui()

## When the combat system inished initializing
@warning_ignore("unused_signal")
signal combat_initialization_finished()

## When the CombatSystem finishes processing its queue and has released the lock
@warning_ignore("unused_signal")
signal combat_event_queue_processing_finished()

## When a status effect expires
@warning_ignore("unused_signal")
signal status_expired(status_effect : StatusEffect)

## When a status effect is removed forcibly or cleansed
@warning_ignore("unused_signal")
signal status_purged(status_effect : StatusEffect)

## When a "buff and debuff" effect expires
@warning_ignore("unused_signal")
signal buff_and_debuff_expired(buff_and_debuff : BuffAndDebuff)
