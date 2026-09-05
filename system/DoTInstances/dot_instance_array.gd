class_name DoTInstanceArray
extends RefCounted

var data : Array[DoTInstance]

func _init(dot_instance : DoTInstance = null) -> void:
	if dot_instance:
		add_dot_instance(dot_instance)

func has_dot() -> bool:
	return not data.is_empty()

func get_dot_type() -> DamageAndDoT.DoT:
	## NOTE: Will crash if used on empty data
	return data.front().damage_type

func add_dot_instance(dot_instance : DoTInstance) -> void:	
	if dot_instance.damage_type == DamageAndDoT.DamageType.VOID:
		push_error("Void is not a valid DoTInstance, use VoidInstance instead")
		return
	
	if not data.is_empty() and get_dot_type() != dot_instance.damage_type:
		push_error("Cannot add DoTInstance of a different type to this DoTInstanceArray")
		return
		
	data.append(dot_instance)
	dot_instance.expired.connect(remove_dot_instance)

func remove_dot_instance(dot_instance : DoTInstance) -> void:
	data.erase(dot_instance)

func clear_all_instances() -> void:
	data.clear()

func get_highest_duration() -> int:
	var result : int = data.front().duration
	for i in range(1, data.size()):
		result = maxi(result, data[i].duration)
	
	return result

func get_all_stacks_count() -> int:
	var result : int = 0
	for dot_instance in data:
		result += dot_instance.stacks
	
	return result

func get_highest_potency() -> int:
	var max_potency : int = 0
	for dot_instance in data:
		max_potency = maxi(max_potency, dot_instance.get_current_potency())
	return max_potency

func get_highest_mastery() -> int:
	var max_mastery : int = 0
	for dot_instance in data:
		max_mastery = maxi(max_mastery, dot_instance.get_current_mastery())
	return max_mastery

func tick_down() -> void:
	for dot_instance in data:
		dot_instance.tick_down()

func resolve_damage(target : Entity, has_current : bool) -> void:
	var is_current := get_dot_type() == DamageAndDoT.DoT.CURRENT
	
	for dot_instance in data:
		var total_amount := ceili(dot_instance.calculate_damage())
		
		var damage_event := DamageEvent.new(
			dot_instance.source, 
			target, 
			dot_instance.damage_type, 
			total_amount
		)
		
		var dot_tick_log_entry := DoTTickCombatLogEntry.new(
			CombatSystem.get_turn_counter(),
			target,
			"C: Natural DoT Tick",
			dot_instance.duplicate(),
		)
		CombatLog.register(dot_tick_log_entry)
		
		CombatSystem.register_combat_event(damage_event)
		CombatSystem.process_combat_event_queue()	
		
		if not has_current or is_current:
			continue
		
		var echo_damage := ceili(DamageAndDoT.get_current_echo_damage(total_amount, get_highest_mastery()))
		var echo_damage_event := DamageEvent.new(
			dot_instance.source,
			target,
			dot_instance.damage_type,
			echo_damage
		)
		
		var dot_echo_log_entry := EchoDoTTickCombatLogEntry.new(
			CombatSystem.get_turn_counter(),
			target,
			"C: Current DoT Echo",
			dot_instance.duplicate(),
			DamageAndDoT.get_current_echo_effectiveness(get_highest_mastery()),
			echo_damage
		)
		CombatLog.register(dot_echo_log_entry)
		
		CombatSystem.register_combat_event(echo_damage_event)
		CombatSystem.process_combat_event_queue()

func calculate_total_damage() -> float:
	var total_damage : float = 0.0
	
	for dot_instance in data:
		total_damage += dot_instance.calculate_damage()
	
	return total_damage

func calculate_total_attrition() -> float:
	var total_attrition : float = 0.0
	
	for dot_instance in data:
		total_attrition += dot_instance.calculate_attrition()
	
	return total_attrition
