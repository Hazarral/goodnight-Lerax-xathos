class_name UtilityAI
extends RefCounted

##TODO: decide where the weights should go, if they are pure attributes or a class
##TODO: implement the scoring functions here as well

class Choice:
	var index : int
	var score : float
	
	func _init(p_index : int, p_score : float) -> void:
		index = p_index
		score = p_score

static func get_all_action_index(actor : Entity) -> Array[Choice]:
	var count := actor.get_known_actions_size()
	var choices : Array[Choice] = []
	choices.resize(count + 1)
	for i in count:
		choices[i] = Choice.new(i, 0.0)
	
	choices[count] = Choice.new(Entity.END_TURN_INDEX, 0.0)
	return choices

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
			var biases = actor.get_total_bias(i)
			choices[i] = Choice.new(i, biases + get_raw_score(i, actor.get_considerations(i)))
		
		## End turn action here
		var end_turn_raw_score := get_raw_score(Entity.END_TURN_INDEX, actor.get_considerations(Entity.END_TURN_INDEX))
		choices[known_actions_size] = Choice.new(Entity.END_TURN_INDEX, end_turn_raw_score)
		
		## Find the best one
		choices.sort_custom(func (a : Choice, b: Choice) -> bool: return a.score > b.score)
		var chosen_index : int = choices.front().index
		
		actor.cast(chosen_index)
		
		if chosen_index == Entity.END_TURN_INDEX:
			print("[UtilityAI] %s ended their turn" % actor.get_entity_name_with_suffix())
			return
	
static func get_raw_score(action_index : int, considerations : Array[Utility.Consideration]) -> float:
	return 0.0
	
