extends Node

var draechen_player : Entity
var player_on_field : Array[Entity]
var enemy_on_field: Array[Entity]
var enemy_reinforcement : Array[Entity]
var damage_event_queue : Array[DamageEvent]

var turn_order : Array[Entity]
var current_turn_index := 0
var turn_counter := 0
var current_actor : Entity = null

const MAX_ALIVE_ENEMY_ON_FIELD := 5

func reset() -> void:
	player_on_field.clear()
	enemy_on_field.clear()
	enemy_reinforcement.clear()
	damage_event_queue.clear()
	
	turn_order.clear()
	current_turn_index = 0
	turn_counter = 0

func initialize_combat(player_side_templates : Array[EntityTemplate], enemy_side_templates : Array[EntityTemplate]) -> void:
	## 1. Ensure clean data before anything
	reset()
	
	## 2. Create the entities in memory. We will ignore magnification for now
	## NOTE: Implement magnification later
	var player_side : Array[Entity] = []
	var enemy_side : Array[Entity] = []
	
	for template in player_side_templates:
		player_side.append(Entity.new(template))
	
	for template in enemy_side_templates:
		enemy_side.append(Entity.new(template))
	
	## 3. Now we initialize factions for proper storage
	initialize_factions(player_side, enemy_side)
	
	## 4. Turn order is finalized
	build_turn_order()

func initialize_encounter(player_party : Array[Entity], enemy_side_templates : Array[EntityTemplate]) -> void:
	## NOTE: Use this for the actual game, because player party is persistent
	reset()
	var enemy_side : Array[Entity] = []
	for template in enemy_side_templates:
		enemy_side.append(Entity.new(template))
	
	initialize_factions(player_party, enemy_side)
	build_turn_order()

func initialize_factions(player_side : Array[Entity], enemy_side : Array[Entity]) -> void:
	if player_side.is_empty() or enemy_side.is_empty():
		push_error("Cannot initialize faction without %s side!" % ("player" if player_side.is_empty() else "enemy"))
		return
	
	for entity in player_side:
		# NOTE: For now, player can have as many entities on the field as they want
		draechen_player = player_side.front()
		add_player_faction(entity)
	
	for entity in enemy_side:
		if get_alive_targets(enemy_on_field).size() < MAX_ALIVE_ENEMY_ON_FIELD:
			add_enemy_faction(entity)
		else:
			add_enemy_reinforcement(entity)

func build_turn_order() -> void:
	turn_order.append_array(player_on_field)
	turn_order.append_array(enemy_on_field)

func add_player_faction(entity : Entity) -> void:
	if not entity.is_player_faction():
		push_error("Entity %s is not player faction! Check the template list passed into initialize_combat() — this entity's template has is_player_faction=false but was routed to player_side." % entity.template.entity_name)
		return	
	
	player_on_field.append(entity)

func add_enemy_faction(entity : Entity) -> void:
	if entity.is_player_faction():
		push_error("Entity %s is not enemy faction! Check the template list passed into initialize_combat() — this entity's template has is_player_faction=true but was routed to enemy_side." % entity.template.entity_name)
		return	
	
	enemy_on_field.append(entity)

func add_enemy_reinforcement(entity : Entity) -> void:
	if entity.is_player_faction():
		push_error("Entity %s is not enemy faction! Cannot add to enemy reinforcement list." % entity.template.entity_name)
		return	
	
	enemy_reinforcement.append(entity)

func add_reinforcement_to_field() -> void:
	if not enemy_reinforcement.is_empty():
		var entity : Entity = enemy_reinforcement.pop_front()
		enemy_on_field.append(entity)
		turn_order.append(entity)

func backfill_reinforcements() -> void:
	while get_alive_targets(enemy_on_field).size() < MAX_ALIVE_ENEMY_ON_FIELD and not enemy_reinforcement.is_empty():
		add_reinforcement_to_field()

func get_next_actor() -> Entity:
	var attempts := 0
	while attempts < turn_order.size():
		var entity = turn_order[current_turn_index]
		current_turn_index = (current_turn_index + 1) % turn_order.size()
		
		if entity.current_state == Entity.State.ALIVE:
			turn_counter += 1
			return entity
		
		attempts += 1
	
	return null  # everyone in turn_order is dead — combat should have ended already

func get_turn_counter() -> int:
	return turn_counter

func advance_turn() -> void:
	## NOTE: This is the official way to advance turn and get next entity in the turn order
	if is_combat_over():
		end_combat()
		return
	
	current_actor = get_next_actor()
	if not current_actor:
		end_combat()
		return
	
	current_actor.begin_turn()

func on_turn_finished() -> void:
	## NOTE: This is meant to be called by entities to report having finished their turn
	advance_turn()

func get_current_actor() -> Entity:
	return current_actor

func end_current_actor_turn() -> void:
	current_actor.end_turn()

func is_combat_over() -> bool:
	if draechen_player.current_state == Entity.State.DEAD:
		return true
	if get_dead_targets(enemy_on_field).size() == enemy_on_field.size():
		return true
	
	return false

func end_combat() -> void:
	print("COMBAT ENDED!")
	reset()

func register_damage_event(damage_event : DamageEvent) -> void:
	damage_event_queue.append(damage_event)

func register_multi_damage_event(multi_damage_event : MultiDamageEvent) -> void:
	damage_event_queue.append_array(multi_damage_event.data)

func inject_damage_event(damage_event : DamageEvent) -> void:
	damage_event_queue.push_front(damage_event)

func process_damage_event_queue() -> void:
	while not damage_event_queue.is_empty():
		var current_event : DamageEvent = damage_event_queue.pop_front()
		
		# NOTE: This may inject during resolve() but that is none of this script's business\
		# current_event also gets ref = 0 when going out of scope
		current_event.resolve()

func get_on_field(is_player_faction : bool) -> Array[Entity]:
	return player_on_field if is_player_faction else enemy_on_field

func get_alive_targets(faction : Array[Entity]) -> Array[Entity]:
	return (faction.filter(func(entity): return entity.current_state == Entity.State.ALIVE))

func get_dead_targets(faction : Array[Entity]) -> Array[Entity]:
	return (faction.filter(func(entity): return entity.current_state == Entity.State.DEAD))

func get_enemy_reinforcement_count() -> int:
	return enemy_reinforcement.size()

func get_valid_targets(faction_filter : ActionEvent.TargetFaction, state_filter : ActionEvent.TargetState) -> Array[Entity]:
	var targets : Array[Entity] = []
	match faction_filter:
		ActionEvent.TargetFaction.PLAYER:
			targets.append_array(player_on_field)
		ActionEvent.TargetFaction.ENEMY:
			targets.append_array(enemy_on_field)
		ActionEvent.TargetFaction.ALL:
			targets.append_array(player_on_field)
			targets.append_array(enemy_on_field)
	
	match state_filter:
		ActionEvent.TargetState.ALIVE:
			return get_alive_targets(targets)
		ActionEvent.TargetState.DEAD:
			return get_dead_targets(targets)
		ActionEvent.TargetState.ALL:
			return targets
	
	## Guard that is unreachable anyway
	return targets
