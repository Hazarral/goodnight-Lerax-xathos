class_name UtilityAI
extends RefCounted

##TODO: decide where the weights should go, if they are pure attributes or a class
##TODO: implement the scoring functions here as well

class Choice:
	var action_index : int
	var score : float
	var target : Entity
	
	func _init(p_action_index : int, p_score : float, p_target : Entity) -> void:
		action_index = p_action_index
		score = p_score
		target = p_target

#static func get_all_action_index(actor : Entity) -> Array[Choice]:
	#var count := actor.get_known_actions_size()
	#var choices : Array[Choice] = []
	#choices.resize(count + 1)
	#for i in count:
		#choices[i] = Choice.new(i, 0.0, null)
	#
	#choices[count] = Choice.new(Entity.END_TURN_INDEX, 0.0, null)
	#return choices

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
		var choices : Array[Choice] = []
		choices.resize(known_actions_size + 1)
		for i in known_actions_size:
			choices[i] = get_choice(actor, i)
		
		## End turn action here
		choices[known_actions_size] = get_choice(actor, Entity.END_TURN_INDEX)
		
		## Find the best one
		choices.sort_custom(func (a : Choice, b: Choice) -> bool: return a.score > b.score)
		var chosen_index : int = choices.front().index
		
		actor.cast(chosen_index)
		
		if chosen_index == Entity.END_TURN_INDEX:
			print("[UtilityAI] %s ended their turn" % actor.get_entity_name_with_suffix())
			return
	
static func get_choice(actor : Entity, action_index : int) -> Choice:
	# Plan:
	# Sometimes I forgot ## is for bigger comments, anyway
	# - Get its targets
	# - Compute Wx for each target, keep only the argmax
	# - Compute Wx_max + biases, return that as the score along with the actually chosen target
	
	# Stuff
	var considerations : Array[Utility.Consideration] = actor.get_considerations(action_index)
	var biases = actor.get_total_bias(action_index)
	return Choice.new(Entity.END_TURN_INDEX, 0.0, null)
	
