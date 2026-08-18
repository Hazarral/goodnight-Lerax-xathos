class_name ActionEvent
extends Resource

enum TargetFaction {
	PLAYER,
	ENEMY,
	ALL
}

enum TargetState {
	ALIVE,
	DEAD,
	ALL
}

enum TargetCount {
	SINGLE,
	ALL
}

var source : Entity
@export var target_state : TargetState
@export var target_faction : TargetFaction
@export var target_count : TargetCount

func resolve() -> void:
	print("This exists for base class of ActionEvent as a reminder only, remember to overwrite it!")
