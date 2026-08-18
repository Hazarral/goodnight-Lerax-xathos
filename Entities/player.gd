class_name Player
extends Entity

var actions : Array[Action]

func learn_action(action : Action) -> void:
	actions.append(action)

func get_actions() -> Array[Action]:
	return actions
