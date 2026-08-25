@abstract class_name ActionEvent
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

@export var target_state : TargetState
@export var target_faction : TargetFaction
@export var target_count : TargetCount

func get_targets() -> Array[Entity]:
	var targets : Array[Entity] = []
	
	if target_count == TargetCount.SINGLE:
		EventBus.emit_signal("target_requested", self, target_faction, target_state)
		
		## This signal will be emitted by UI on player side and by AI on enemy side
		var picked : Entity = await EventBus.target_chosen
		targets = [picked]
	else:
		targets = CombatSystem.get_valid_targets(target_faction, target_state)

	return targets

@abstract func resolve(source : Entity) -> void
