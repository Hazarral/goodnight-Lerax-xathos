extends Node

var draechen_player : Draechen
const DRAECHEN_TEMPLATE := preload("res://system/entities/templates/player_side/player_the_draechen.tres")

var ally_on_field : Array[Entity]
var enemy_on_field: Array[Entity]
var enemy_reinforcement : Array[Entity]
var _combat_event_queue : Array[CombatEvent]

var turn_order : Array[Entity]
var current_turn_index := 0
var turn_counter := 0
var round_counter := 0
var current_actor : Entity = null

var is_processing_combat_event_queue : bool = false

const MAX_ALIVE_ENEMY_ON_FIELD := 5

var _entity_name_counter : Dictionary[String, int] = {}
const _ROMAN_VALUES : Array[int] = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1]
const _ROMAN_SYMBOLS : Array[String] = ["M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"]

func reset() -> void:
	ally_on_field.clear()
	enemy_on_field.clear()
	enemy_reinforcement.clear()
	_combat_event_queue.clear()
	
	turn_order.clear()
	current_turn_index = 0
	turn_counter = 0
	
	_entity_name_counter.clear()
	
	is_processing_combat_event_queue = false

func _register_or_increment_entity_name(entity_name : String) -> void:
	if _entity_name_counter.has(entity_name):
		_entity_name_counter[entity_name] += 1
	else:
		_entity_name_counter[entity_name] = 1

func _to_roman_numeral(number : int) -> String:
	if number <= 0:
		push_error("Cannot convert non-positive number %d to roman numeral!" % number)
		return str(number)
	
	var result := ""
	var remaining := number
	
	for i in _ROMAN_VALUES.size():
		while remaining >= _ROMAN_VALUES[i]:
			remaining -= _ROMAN_VALUES[i]
			result += _ROMAN_SYMBOLS[i]
	
	return result

func get_entity_name_suffix(entity : Entity) -> String:
	if entity.display_suffix == -1:
		return ""
	
	return " (%s)" % _to_roman_numeral(entity.display_suffix)

func initialize_combat(player_side_templates : Array[EntityTemplate], enemy_side_templates : Array[EntityTemplate]) -> void:
	## 1. Ensure clean data before anything
	reset()
	
	## 2. Create the entities in memory. We will ignore magnification for now
	## NOTE: Implement magnification later
	var player_side : Array[Entity] = []
	var enemy_side : Array[Entity] = []
	
	for template in player_side_templates:
		if template == DRAECHEN_TEMPLATE and template is DraechenTemplate:
			draechen_player = Draechen.new(template)
			player_side.append(draechen_player)
		else:
			player_side.append(Entity.new(template))
	
	for template in enemy_side_templates:
		enemy_side.append(Entity.new(template))
	
	## 3. Now we initialize factions for proper storage
	initialize_factions(player_side, enemy_side)
	
	## 4. Turn order is finalized
	build_turn_order()
	EventBus.combat_initialization_finished.emit()

func initialize_encounter(player_party : Array[Entity], enemy_side_templates : Array[EntityTemplate]) -> void:
	## NOTE: Use this for the actual game, because player party is persistent
	reset()
	var enemy_side : Array[Entity] = []
	for template in enemy_side_templates:
		enemy_side.append(Entity.new(template))
	
	initialize_factions(player_party, enemy_side)
	build_turn_order()
	EventBus.combat_initialization_finished.emit()

func initialize_factions(player_side : Array[Entity], enemy_side : Array[Entity]) -> void:
	if player_side.is_empty() or enemy_side.is_empty():
		push_error("Cannot initialize faction without %s side!" % ("player" if player_side.is_empty() else "enemy"))
		return
	
	for entity in player_side:
		# NOTE: For now, player can have as many entities on the field as they want
		draechen_player = player_side.front() as Draechen
		add_player_faction(entity)
	
	for entity in enemy_side:
		if get_alive_targets(enemy_on_field).size() < MAX_ALIVE_ENEMY_ON_FIELD:
			add_enemy_faction(entity)
		else:
			add_enemy_reinforcement(entity)

func build_turn_order() -> void:
	turn_order.append_array(ally_on_field)
	turn_order.append_array(enemy_on_field)

func add_player_faction(entity : Entity) -> void:
	if not entity.is_player_faction():
		push_error("Entity %s is not player faction! Check the template list passed into initialize_combat() — this entity's template has is_player_faction=false but was routed to player_side." % entity.template.entity_name)
		return	
	
	ally_on_field.append(entity)

func add_enemy_faction(entity : Entity) -> void:
	if entity.is_player_faction():
		push_error("Entity %s is not enemy faction! Check the template list passed into initialize_combat() — this entity's template has is_player_faction=true but was routed to enemy_side." % entity.template.entity_name)
		return	
	
	enemy_on_field.append(entity)
	_register_or_increment_entity_name(entity.template.entity_name)
	entity.display_suffix = _entity_name_counter[entity.template.entity_name]

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
		_register_or_increment_entity_name(entity.template.entity_name)
		entity.display_suffix = _entity_name_counter[entity.template.entity_name]

func backfill_reinforcements() -> void:
	while get_alive_targets(enemy_on_field).size() < MAX_ALIVE_ENEMY_ON_FIELD and not enemy_reinforcement.is_empty():
		add_reinforcement_to_field()

func get_next_actor() -> Entity:
	var entity = turn_order[current_turn_index]
	
	turn_counter += 1
	if current_turn_index == 0:
		round_counter += 1
		var combat_log_entry := RoundCombatLogEntry.new(
			get_turn_counter(),
			null,
			"Round Start"
		)
		CombatLog.register(combat_log_entry)
	
	current_turn_index = (current_turn_index + 1) % turn_order.size()
	
	return entity

func get_turn_counter() -> int:
	return turn_counter

func get_round_counter() -> int:
	return round_counter

func advance_turn() -> void:
	## NOTE: This is the official way to advance turn and get next entity in the turn order
	if is_combat_over():
		end_combat()
		return
	
	current_actor = get_next_actor()
	if current_actor == null:
		end_combat()
		return
	
	current_actor.begin_turn()

func on_turn_finished() -> void:
	## NOTE: This is meant to be called by entities to report having finished their turn
	advance_turn()

func get_the_draechen() -> Draechen:
	return draechen_player

func get_current_actor() -> Entity:
	return current_actor

func is_current_actor(entity : Entity) -> bool:
	return entity == current_actor

func end_current_actor_turn() -> void:
	if is_combat_over():
		return
	
	current_actor.end_turn()
	EventBus.force_refresh_turn_ui.emit()

func is_combat_over() -> bool:
	if draechen_player != null and draechen_player.current_state == Entity.State.DEAD:
		return true
	if get_dead_targets(enemy_on_field).size() == enemy_on_field.size():
		return true
	
	return false

func end_combat() -> void:
	var current_turn_counter := turn_counter
	reset()
	var combat_log_entry := CombatEndedCombatLogEntry.new(
		current_turn_counter,
		null,
		"Combat Ended"
	)
	CombatLog.register(combat_log_entry)

func register_combat_event(combat_event : CombatEvent) -> void:
	_combat_event_queue.append(combat_event)

func register_multi_combat_event(multi_combat_event : MultiCombatEvent) -> void:
	_combat_event_queue.append_array(multi_combat_event.data)

func inject_combat_event(damage_event : CombatEvent) -> void:
	_combat_event_queue.push_front(damage_event)
	
	## Always force call, protected by lock so this is safe
	process_combat_event_queue()

func process_combat_event_queue() -> void:
	if is_processing_combat_event_queue:
		return
	
	is_processing_combat_event_queue = true
	
	while not _combat_event_queue.is_empty() and not is_combat_over():
		var current_event : CombatEvent = _combat_event_queue.pop_front()
		
		# NOTE: This may inject during resolve() but that is none of this script's business\
		# current_event also gets ref = 0 when going out of scope
		current_event.resolve()
	
	is_processing_combat_event_queue = false
	EventBus.combat_event_queue_processing_finished.emit()

func get_on_field(is_player_faction : bool) -> Array[Entity]:
	return ally_on_field if is_player_faction else enemy_on_field

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
			targets.append_array(ally_on_field)
		ActionEvent.TargetFaction.ENEMY:
			targets.append_array(enemy_on_field)
		ActionEvent.TargetFaction.ALL:
			targets.append_array(ally_on_field)
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

func get_highest_enemy_potency_and_mastery() -> EncounterPotencyAndMastery:
	var enemies := enemy_on_field + enemy_reinforcement
	var highest_potency := 0
	var highest_mastery := 0
	for enemy in enemies:
		highest_potency = maxi(highest_potency, enemy.get_potency())
		highest_mastery = maxi(highest_mastery, enemy.get_mastery())
	
	return EncounterPotencyAndMastery.new(highest_potency, highest_mastery)
