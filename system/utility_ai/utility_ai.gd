class_name UtilityAI
extends RefCounted

##TODO: decide where the weights should go, if they are pure attributes or a class
##TODO: implement the scoring functions here as well

const INVALID_SCORE := -INF
const ABSOLUTE_EPSILON := 1e-8
const RELATIVE_EPSILON := 1e-6

const AI_DECISION_DELAY := 0.5

const END_TURN_DISCOUNT : float = 0.8

static var _tree : SceneTree

class Choice:
	var actor : Entity
	var action_index : int
	var score : float
	var target : Entity
	var consideration_terms : Array[ConsiderationTerm] = []
	var bias_terms : Array[AIProfile.BiasTerm] = []
	var future_choices : Array[Choice] = []
	
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
		
		if consideration_terms:
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
		
		if action_index == Entity.END_TURN_INDEX:
			output += "\n  Future opportunities:"
			
			if future_choices.is_empty():
				output += "\n    None"
			else:
				var total := 0.0
			
				for i in range(future_choices.size()):
					var choice := future_choices[i]
					var contribution := choice.score / (i + 1)
					
					total += contribution
					
					output += "\n    %s: %.2f / %d = %.2f" % [
						actor.get_action(choice.action_index).action_name,
						choice.score,
						i + 1,
						contribution
					]
				
				output += "\n  Opportunity total: %.2f" % total
				output += "\n  Discount: %.2f" % END_TURN_DISCOUNT
				output += "\n  Discounted total: %.2f" % (
					total * END_TURN_DISCOUNT
				)
		
		if bias_terms:
			output += "\n  Biases:"
			
			for term in bias_terms:
				if is_zero_approx(term.value):
					continue
				
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

static func _get_tree() -> SceneTree:
	if _tree == null:
		_tree = Engine.get_main_loop() as SceneTree
	return _tree

static func _decision_delay() -> void:
	if AI_DECISION_DELAY > 0.0:
		await _get_tree().create_timer(AI_DECISION_DELAY).timeout

static func _score_cmp(a : Choice, b : Choice) -> bool:
	return a.score > b.score 

## Archived
#static func start_turn(actor : Entity) -> void:
	### This is nothing but a big wx + b function
	### Normal action will use Entity.cast_action(index : int), but end_turn will call with index = -1
	###1. Evaluate the actions
	###2. Score them, rank them
	###3. Pick action, repeat till "End Turn" is chosen
	### All of these call actor.cast_action(index)
	#
	#var entity_name := actor.get_entity_name_with_suffix()
	#var known_actions_size := actor.get_known_actions_size()
	#
	#await _decision_delay()
	#
	#while true:
		## Wait out anything still draining before reading the board
		#while CombatSystem.is_processing_combat_event_queue:
			#await EventBus.combat_event_queue_processing_finished
		#
		#if actor.current_state == Entity.State.DEAD:
			#print("[UtilityAI] %s died mid AI loop" % entity_name)
			#return
		#
		## Compute for every action
		## Pick whatever is highest later, with some randomizing
		## End turn just quits
		#print("[%s] %s deciding" % [Time.get_ticks_msec(), entity_name])
		#var combat_field_state := CombatFieldState.new()
		#var choices : Array[Choice] = []
		#choices.resize(known_actions_size + 1)
		#for i in known_actions_size:
			#choices[i] = get_choice(actor, i, combat_field_state)
		#
		### End turn action here
		#choices[known_actions_size] = get_choice(actor, Entity.END_TURN_INDEX, combat_field_state)
		#
		### Find the best one
		#choices.sort_custom(_score_cmp)
		#print("%s's choices: %s" % [entity_name, choices])
		#
		#var chosen_choice : Choice = choices.front()
		#
		#if not is_finite(chosen_choice.score):
			### Inject to force it
			#chosen_choice.action_index = Entity.END_TURN_INDEX
		#
		#print("Chosen index: %d" % chosen_choice.action_index)
		#
		#await actor.cast_action(chosen_choice.action_index, chosen_choice.target)
		#EventBus.force_refresh_turn_ui.emit()
		#
		#if chosen_choice.action_index == Entity.END_TURN_INDEX:
			#print("[UtilityAI] %s ended their turn" % entity_name)
			#return
		#
		#await _decision_delay()
	
static func start_turn(actor : Entity) -> void:
	var entity_name := actor.get_entity_name_with_suffix()
		
	await _decision_delay()
		
	while true:
		while CombatSystem.is_processing_combat_event_queue:
			await EventBus.combat_event_queue_processing_finished
		
		if actor.current_state == Entity.State.DEAD:
			print("[UtilityAI] %s died mid AI loop" % entity_name)
			return
		
		print("[%s] %s deciding" % [
			Time.get_ticks_msec(), entity_name
		])
		
		var combat_field_state := CombatFieldState.new()
		var choices : Array[Choice] = []
		var invalid_indices : Array[int] = []
		
		for i in actor.get_known_actions_size():
			var choice := get_choice(actor, i, combat_field_state)
			if is_finite(choice.score):
				choices.append(choice)
			else:
				invalid_indices.append(i)
		
		# End Turn evaluates unavailable opportunities.
		choices.append(
			_get_end_turn_choice(
				actor,
				invalid_indices,
				combat_field_state
			)
		)
		
		choices.sort_custom(_score_cmp)
		
		print("%s's choices: %s" % [entity_name, choices])
		
		var chosen_choice : Choice = choices.front()
		
		print("Chosen index: %d" % chosen_choice.action_index)
		
		await actor.cast_action(
			chosen_choice.action_index,
			chosen_choice.target
		)
		
		EventBus.force_refresh_turn_ui.emit()
		
		if chosen_choice.action_index == Entity.END_TURN_INDEX:
			print("[UtilityAI] %s ended their turn" % entity_name)
			return
		
		await _decision_delay()

## Archived
#static func get_choice(actor : Entity, action_index : int, combat_field_state : CombatFieldState) -> Choice:
	## Plan:
	## Sometimes I forgot ## is for bigger comments, anyway
	## - Get its targets
	## - Compute Wx for each target, keep only the argmax
	## - Compute Wx_max + biases, return that as the score along with the actually chosen target
	#
	#if not actor.is_castable(action_index):
		#return Choice.new(actor, action_index, INVALID_SCORE, null)
	#
	#if action_index == Entity.END_TURN_INDEX:
		### Special logic here to handle end turn scoring
		#return Choice.new(actor, Entity.END_TURN_INDEX, INVALID_SCORE, null)
	#
	## Stuff
	#var action := actor.get_action(action_index)
	#var first_valid_targets := action.get_first_targets()
	#var is_single_target := action.is_single_target()
	#var considerations := actor.get_considerations(action_index)
	#
	## Bias here
	#var utility_entries := action.utility.utility_entries
	#var biases_breakdown : Array[AIProfile.BiasTerm] = actor.get_ai_profile().get_bias_breakdown(utility_entries)
	#var biases := 0.0
	#for term in biases_breakdown:
		#biases += term.value
	#
	#var damage_types := action.get_damage_types()
	#var dot_instances := action.get_dot_instances()
	#
	#if first_valid_targets.is_empty():
		#push_error("No valid target for action index %d of entity %s" % [action_index, actor.get_entity_name_with_suffix() if actor != null else "null"])
		#return Choice.new(actor, action_index, INVALID_SCORE, null)
	#
	##var best_target : Entity = null
	##var best_score : float = INVALID_SCORE
	##var best_consideration_terms : Array[Choice.ConsiderationTerm] = []
	#
	#var target_scores : Array[float] = []
	#var target_consideration_terms : Array[Array] = []
	#
	#for target in first_valid_targets:
		#var score := 0.0
		#var consideration_terms : Array[Choice.ConsiderationTerm] = []
		#
		#var scoring_context := ScoringContext.new(
			#actor,
			#target,
			#first_valid_targets.size(),
			#is_single_target,
			#damage_types,
			#dot_instances,
			#combat_field_state
		#)
		#
		#for consideration in considerations:
			#var weight := actor.get_ai_profile().get_weight(consideration)
			#var raw_score := UtilityMath.get_raw_score(scoring_context, consideration)
			#
			#var term := Choice.ConsiderationTerm.new(
				#consideration,
				#weight,
				#raw_score
			#)
			#
			#consideration_terms.append(term)
			#score += term.contribution # Already W * raw_score
		#
		#target_scores.append(score)
		#target_consideration_terms.append(consideration_terms)
	#
	#var best_target : Entity = null
	#var best_score := INVALID_SCORE
	#var best_consideration_terms : Array[Choice.ConsiderationTerm] = []
	#
	#if is_single_target:
		#var best_index := 0
		#
		#for i in range(target_scores.size()):
			#if target_scores[i] > best_score:
				#best_score = target_scores[i]
				#best_index = i
		#
		#best_target = first_valid_targets[best_index]
		#best_consideration_terms = target_consideration_terms[best_index]
		#best_score += biases # Add bias exactly once here
		#
	#else:
		#var sorted_indices := range(target_scores.size())
		#sorted_indices.sort_custom(
			#func(a : int, b : int) -> bool:
				#return target_scores[a] > target_scores[b]
		#)
		#
		#var total := 0.0
		#for i in range(sorted_indices.size()):
			#total += target_scores[sorted_indices[i]] / (i + 1)
		#
		#best_score = total + biases # Add bias exactly once here
		#
		## Representative target and breakdown: highest-scoring target
		#var best_index : int = sorted_indices[0]
		#best_target = first_valid_targets[best_index]
		#best_consideration_terms = target_consideration_terms[best_index]
	#
	#var choice := Choice.new(actor, action_index, best_score, best_target)
	#choice.consideration_terms = best_consideration_terms
	#choice.bias_terms = biases_breakdown
	#
	#return choice
	
static func get_choice(actor : Entity, action_index : int, combat_field_state : CombatFieldState) -> Choice:
	if not actor.is_castable(action_index):
		return Choice.new(
			actor, action_index, INVALID_SCORE, null
		)

	return _evaluate_action(
		actor, action_index, combat_field_state
	)

static func _evaluate_action(actor : Entity, action_index : int, combat_field_state : CombatFieldState) -> Choice:
	# Plan:
	# Sometimes I forgot ## is for bigger comments, anyway
	# - Get its targets
	# - Compute Wx for each target, keep only the argmax
	# - Compute Wx_max + biases, return that as the score along with the actually chosen target
	
	# Stuff
	var action := actor.get_action(action_index)
	var first_valid_targets := action.get_first_targets()
	var is_single_target := action.is_single_target()
	var considerations := actor.get_considerations(action_index)
	
	# Bias here
	var utility_entries := action.utility.utility_entries
	var biases_breakdown : Array[AIProfile.BiasTerm] = actor.get_ai_profile().get_bias_breakdown(utility_entries)
	var biases := 0.0
	for term in biases_breakdown:
		biases += term.value
	
	var damage_types := action.get_damage_types()
	var dot_instances := action.get_dot_instances()
	var buff_and_debuffs := action.get_buff_and_debuffs()
	
	if first_valid_targets.is_empty():
		push_error("No valid target for action index %d of entity %s" % [action_index, actor.get_entity_name_with_suffix() if actor != null else "null"])
		return Choice.new(actor, action_index, INVALID_SCORE, null)
	
	#var best_target : Entity = null
	#var best_score : float = INVALID_SCORE
	#var best_consideration_terms : Array[Choice.ConsiderationTerm] = []
	
	var target_scores : Array[float] = []
	var target_consideration_terms : Array[Array] = []
	
	for target in first_valid_targets:
		var score := 0.0
		var consideration_terms : Array[Choice.ConsiderationTerm] = []
		
		var scoring_context := ScoringContext.new(
			actor,
			target,
			actor.get_action_ap_cost(action_index),
			actor.get_action_base_cooldown(),
			first_valid_targets.size(),
			is_single_target,
			damage_types,
			dot_instances,
			buff_and_debuffs,
			combat_field_state
		)
		
		for consideration in considerations:
			var weight := actor.get_ai_profile().get_weight(consideration)
			var raw_score := UtilityMath.get_raw_score(scoring_context, consideration)
			
			var term := Choice.ConsiderationTerm.new(
				consideration,
				weight,
				raw_score
			)
			
			consideration_terms.append(term)
			score += term.contribution # Already W * raw_score
		
		target_scores.append(score)
		target_consideration_terms.append(consideration_terms)
	
	var best_target : Entity = null
	var best_score := INVALID_SCORE
	var best_consideration_terms : Array[Choice.ConsiderationTerm] = []
	
	if is_single_target:
		var best_index := 0
		
		for i in range(target_scores.size()):
			if target_scores[i] > best_score:
				best_score = target_scores[i]
				best_index = i
		
		best_target = first_valid_targets[best_index]
		best_consideration_terms = target_consideration_terms[best_index]
		best_score += biases # Add bias exactly once here
		
	else:
		var sorted_indices := range(target_scores.size())
		sorted_indices.sort_custom(
			func(a : int, b : int) -> bool:
				return target_scores[a] > target_scores[b]
		)
		
		var total := 0.0
		for i in range(sorted_indices.size()):
			total += target_scores[sorted_indices[i]] / (i + 1)
		
		best_score = total + biases # Add bias exactly once here
		
		# Representative target and breakdown: highest-scoring target
		var best_index : int = sorted_indices[0]
		best_target = first_valid_targets[best_index]
		best_consideration_terms = target_consideration_terms[best_index]
	
	var choice := Choice.new(actor, action_index, best_score, best_target)
	choice.consideration_terms = best_consideration_terms
	choice.bias_terms = biases_breakdown
	
	return choice

static func _is_castable_next_turn(
	actor : Entity,
	action_index : int
) -> bool:
	var cooldown := actor.get_action_cooldown_remaining(action_index)

	if cooldown > 1:
		return false

	var ap_cost := actor.get_action_ap_cost(action_index)
	var next_ap := mini(
		actor.get_current_action_point() + actor.get_action_point_regen_per_turn(),
		actor.get_max_action_point()
	)

	return ap_cost <= next_ap

static func _get_bias_breakdown(actor : Entity, action_index : int) -> Array[AIProfile.BiasTerm]:
	var action := actor.get_action(action_index)
	var utility_entries := action.utility.utility_entries

	return actor.get_ai_profile().get_bias_breakdown(utility_entries)

static func _get_end_turn_choice(actor : Entity, invalid_indices : Array[int], combat_field_state : CombatFieldState) -> Choice:
	## invalid_indices is guaranteed to not include -1, which is the end turn's index
	
	# Collect everything into a list to sort later
	var valid_next_turn_choices : Array[Choice] = []
	
	for action_index in invalid_indices:		
		if not _is_castable_next_turn(actor, action_index):
			continue
	
		var future_choice := _evaluate_action(
			actor,
			action_index,
			combat_field_state
		)
	
		# The score <= 0.0 skip is technically ReLU after sorting in descending order
		if not is_finite(future_choice.score) or future_choice.score <= 0.0:
			continue
	
		valid_next_turn_choices.append(future_choice)
	
	## Compute bias 
	var biases_breakdown := _get_bias_breakdown(actor, Entity.END_TURN_INDEX)
	
	var biases := 0.0
	for term in biases_breakdown:
		biases += term.value
	
	## Compute harmonic-weighted score
	var total := 0.0
	valid_next_turn_choices.sort_custom(_score_cmp)
	for i in range(valid_next_turn_choices.size()):
		total += valid_next_turn_choices[i].score / (i + 1)
	
	var score := total * END_TURN_DISCOUNT + biases
	
	var end_turn_choice := Choice.new(
		actor,
		Entity.END_TURN_INDEX,
		score,
		null
	)
	
	end_turn_choice.bias_terms = biases_breakdown
	end_turn_choice.future_choices = valid_next_turn_choices

	return end_turn_choice
