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

enum TargetMode { 
	INDEPENDENT_FILTER, 	## Use its own target faction, state and count filter. Ask for confirmation and manual targeting if single target, else it will auto target valid entities when target count = all
	SELF,					## Always target caster
	INHERIT_FILTERED,		## Inherit the previous action event targets while respecting the filtering of the target faction, state and count
	INHERIT					## Inherit the previous action event targets, ignore any and all target faction, state and count filtering
}

@export var target_state : TargetState
@export var target_faction : TargetFaction
@export var target_count : TargetCount
@export var target_mode : TargetMode = TargetMode.INDEPENDENT_FILTER

var _last_resolved_targets : Array[Entity] = []

func get_last_resolved_targets() -> Array[Entity]:
	return _last_resolved_targets

func get_targets(caster : Entity, inherited_targets : Array[Entity]) -> Variant:
	## Either Array[Entity] or null, different from an empty Array[Entity]
	var targets : Array[Entity] = []
	
	match target_mode:
		TargetMode.SELF:
			targets = [caster]
		TargetMode.INHERIT:
			targets = inherited_targets
		TargetMode.INHERIT_FILTERED:
			targets = _filter_targets(inherited_targets)
		TargetMode.INDEPENDENT_FILTER:
			if target_count == TargetCount.SINGLE:
				EventBus.target_requested.emit(self, target_faction, target_state)
				var picked : Entity = await EventBus.target_resolved
				if picked == null:
					print("Picked null! Cancelling...")
					return null
				targets = [picked]
			else:
				targets = CombatSystem.get_valid_targets(target_faction, target_state)
	
	_last_resolved_targets = targets
	return targets

func _filter_targets(pool : Array[Entity]) -> Array[Entity]:
	return pool.filter(func(entity : Entity) -> bool:
		var faction_ok := (
			target_faction == TargetFaction.ALL or
			(target_faction == TargetFaction.PLAYER and entity.is_player_faction()) or
			(target_faction == TargetFaction.ENEMY and not entity.is_player_faction())
		)
		var state_ok := (
			target_state == TargetState.ALL or
			(target_state == TargetState.ALIVE and entity.current_state == Entity.State.ALIVE) or
			(target_state == TargetState.DEAD and entity.current_state == Entity.State.DEAD)
		)
		return faction_ok and state_ok
	)

@abstract func resolve(source : Entity, inherited_targets : Array[Entity]) -> bool
