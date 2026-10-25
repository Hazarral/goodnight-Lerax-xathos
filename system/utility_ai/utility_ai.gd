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

static func start_turn(actor : Entity, profile : AIProfile) -> void:
	## This is nothing but a big wx + b function
	## Normal action will use Entity.cast_action(index : int), but end_turn will call with index = -1
	##1. Evaluate the actions
	##2. Score them, rank them
	##3. Pick action, repeat till "End Turn" is chosen
	## All of these call actor.cast_action(index)
	
	while actor.current_state == Entity.State.ALIVE:
		## 1. One battlefield snapshot per iteration
		var field := CombatFieldState.new()
		
		## 2. Evaluate and score every option
		var choices : Array[Choice] = get_all_action_index(actor)
		for choice in choices:
			choice.score = score_choice(choice, actor, field, profile)
		
		## 3. Rank and pick argmax
		var best : Choice = choices[0]
		for choice in choices:
			if choice.score > best.score:
				best = choice
		
		## 4. Cast and repeat
		await actor.cast_action(best.index)
		
		## If end turn was chosen, exit cleanly
		if best.index == Entity.END_TURN_INDEX:
			return
		CombatSystem.process_damage_event_queue()
