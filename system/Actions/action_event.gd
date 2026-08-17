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
var target_state : TargetState
var target_faction : TargetFaction
var target_count : TargetCount

func resolve() -> void:
	print("This exists for base class of ActionEvent as a reminder only, remember to overwrite it!")
