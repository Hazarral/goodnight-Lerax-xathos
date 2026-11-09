class_name UtilityAI
extends RefCounted

##TODO: decide where the weights should go, if they are pure attributes or a class
##TODO: implement the scoring functions here as well

const INVALID_SCORE := -INF
const ABSOLUTE_EPSILON := 1e-8
const RELATIVE_EPSILON := 1e-6

class Choice:
	var actor : Entity
	var action_index : int
	var score : float
	var target : Entity
	var consideration_terms : Array[ConsiderationTerm] = []
	var bias_terms : Array[AIProfile.BiasTerm] = []
	
	func _init(p_actor : Entity, p_action_index : int, p_score : float, p_target : Entity) -> void:
		actor = p_actor
		action_index = p_action_index
		score = p_score
		target = p_target
	
	func _to_string() -> String:
		var output := "\n[Index: %d, Action name: %s, Score: %.2f, Target: %s]" % [
			action_index,
			actor.get_action(action_index).action_name if action_index != Entity.END_TURN_INDEX else "End turn",
			score,
			target.get_entity_name_with_suffix() if target != null else "null"
		]
		
		output += "\n  Considerations:"
		
		for term in consideration_terms:
			if is_zero_approx(term.contribution):
				continue
			
			output += "\n    %s: %.2f * %.2f = %.2f" % [
				Utility.Consideration.keys()[term.consideration],
				term.weight,
				term.raw_score,
				term.contribution
			]
		
		output += "\n  Biases:"
		
		for term in bias_terms:
			output += "\n    %s: %.2f" % [
				term.name,
				term.value
			]
		
		return output
	
	func get_consideration_total() -> float:
		var total := 0.0
		
		for term in consideration_terms:
			total += term.contribution
		
		return total
	
	func get_bias_total() -> float:
		var total := 0.0
	
		for term in bias_terms:
			total += term.value
	
		return total
	
	class ConsiderationTerm:
		var consideration : Utility.Consideration
		var weight : float
		var raw_score : float
		var contribution : float
		
		func _init(
			p_consideration : Utility.Consideration,
			p_weight : float,
			p_raw_score : float
		) -> void:
			consideration = p_consideration
			weight = p_weight
			raw_score = p_raw_score
			contribution = weight * raw_score

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
			choices[i] = get_choice(actor, i, combat_field_state)
		
		## End turn action here
		choices[known_actions_size] = get_choice(actor, Entity.END_TURN_INDEX, combat_field_state)
		
		## Find the best one
		choices.sort_custom(func (a : Choice, b: Choice) -> bool: return a.score > b.score)
		print("%s's choices: %s" % [actor.get_entity_name_with_suffix(), choices])
		
		var chosen_choice : Choice = choices.front()
		
		if not is_finite(chosen_choice.score):
			## Inject to force it
			chosen_choice.action_index = Entity.END_TURN_INDEX
		
		print("Chosen index: %d" % chosen_choice.action_index)
		
		actor.cast_action(chosen_choice.action_index)
		
		# Get the target desired
		EventBus.target_resolved.emit(chosen_choice.target)
		
		## THIS IS NEVER GOING TO BE REACHED
		if chosen_choice.action_index == Entity.END_TURN_INDEX:
			print("[UtilityAI] %s ended their turn" % actor.get_entity_name_with_suffix())
			return
	
static func get_choice(actor : Entity, action_index : int, combat_field_state : CombatFieldState) -> Choice:
	# Plan:
	# Sometimes I forgot ## is for bigger comments, anyway
	# - Get its targets
	# - Compute Wx for each target, keep only the argmax
	# - Compute Wx_max + biases, return that as the score along with the actually chosen target
	
	if not actor.is_castable(action_index):
		return Choice.new(actor, action_index, INVALID_SCORE, null)
	
	if action_index == Entity.END_TURN_INDEX:
		## Special logic here to handle end turn scoring
		return Choice.new(actor, Entity.END_TURN_INDEX, INVALID_SCORE, null)
	
	# Stuff
	var first_targets := actor.get_action(action_index).get_first_targets()
	var considerations := actor.get_considerations(action_index)
	
	# Bias here
	var utility_entries := actor.get_action(action_index).utility.utility_entries
	var biases_breakdown : Array[AIProfile.BiasTerm] = actor.get_ai_profile().get_bias_breakdown(utility_entries)
	var biases := 0.0
	for term in biases_breakdown:
		biases += term.value
	
	var damage_types = actor.get_action(action_index).get_damage_types()
	var dot_types := actor.get_action(action_index).get_dot_types()
	
	if first_targets.is_empty():
		push_error("No valid target for action index %d of entity %s" % [action_index, actor.get_entity_name_with_suffix()])
		return Choice.new(actor, action_index, INVALID_SCORE, null)
	
	var best_target : Entity = null
	var best_score : float = INVALID_SCORE
	var best_consideration_terms : Array[Choice.ConsiderationTerm] = []
	
	for target in first_targets:
		var score := biases
		var consideration_terms : Array[Choice.ConsiderationTerm] = []
		
		for consideration in considerations:
			var weight := actor.get_ai_profile().get_weight(consideration)
			var raw_score := UtilityMath.get_raw_score(
				actor,
				target,
				damage_types,
				dot_types,
				consideration,
				combat_field_state
			)
			
			var term := Choice.ConsiderationTerm.new(
				consideration,
				weight,
				raw_score
			)
			
			consideration_terms.append(term)
			score += term.contribution # Already W * raw_score
		
		if score > best_score:
			best_target = target
			best_score = score
			best_consideration_terms = consideration_terms
	
	var choice := Choice.new(actor, action_index, best_score, best_target)
	choice.consideration_terms = best_consideration_terms
	choice.bias_terms = biases_breakdown
	
	return choice
	
