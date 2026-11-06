class_name UtilityAI
extends RefCounted

##TODO: decide where the weights should go, if they are pure attributes or a class
##TODO: implement the scoring functions here as well

const INVALID_SCORE := -INF

class Choice:
	var action_index : int
	var score : float
	var target : Entity
	
	func _init(p_action_index : int, p_score : float, p_target : Entity) -> void:
		action_index = p_action_index
		score = p_score
		target = p_target

static func start_turn(actor : Entity) -> void:
	## This is nothing but a big wx + b function
	## Normal action will use Entity.cast_action(index : int), but end_turn will call with index = -1
	##1. Evaluate the actions
	##2. Score them, rank them
	##3. Pick action, repeat till "End Turn" is chosen
	## All of these call actor.cast_action(index)
	
	var known_actions_size := actor.get_known_actions_size()
	
	while true:
		# Compute for every action
		# Pick whatever is highest later, with some randomizing
		# End turn just quits
		var combat_field_state := CombatFieldState.new()
		var choices : Array[Choice] = []
		choices.resize(known_actions_size + 1)
		for i in known_actions_size:
			choices[i] = await get_choice(actor, i, combat_field_state)
		
		## End turn action here
		choices[known_actions_size] = await get_choice(actor, Entity.END_TURN_INDEX, combat_field_state)
		
		## Find the best one
		choices.sort_custom(func (a : Choice, b: Choice) -> bool: return a.score > b.score)
		var chosen_index : int = choices.front().index
		
		actor.cast(chosen_index)
		
		if chosen_index == Entity.END_TURN_INDEX:
			print("[UtilityAI] %s ended their turn" % actor.get_entity_name_with_suffix())
			return
	
static func get_choice(actor : Entity, action_index : int, combat_field_state : CombatFieldState) -> Choice:
	# Plan:
	# Sometimes I forgot ## is for bigger comments, anyway
	# - Get its targets
	# - Compute Wx for each target, keep only the argmax
	# - Compute Wx_max + biases, return that as the score along with the actually chosen target
	
	if action_index == Entity.END_TURN_INDEX:
		## Special logic here to handle end turn scoring
		return Choice.new(Entity.END_TURN_INDEX, INVALID_SCORE, null)
	
	# Stuff
	var first_targets := await actor.get_action(action_index).get_first_targets(actor)
	var considerations := actor.get_considerations(action_index)
	var biases := actor.get_total_bias(action_index)
	
	if first_targets.is_empty():
		push_error("No valid target for action index %d of entity %s" % [action_index, actor.get_entity_name_with_suffix()])
		return Choice.new(action_index, INVALID_SCORE, null)
	
	var best_target : Entity = null
	var best_score : float = INVALID_SCORE
	
	for target in first_targets:
		var score := biases
		for consideration in considerations:
			var raw_score := UtilityMath.get_raw_score(actor, target, consideration, combat_field_state)
			score += actor.ai_profile.get_weight(consideration) * raw_score
		
		if score > best_score:
			best_target = target
			best_score = score
	
	return Choice.new(action_index, best_score, best_target)
	
