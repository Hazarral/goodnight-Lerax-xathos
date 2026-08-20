class_name DoTInstanceArray
extends RefCounted

var data : Array[DoTInstance]

func _init(dot_instance : DoTInstance = null) -> void:
	if dot_instance:
		add_dot_instance(dot_instance)

func has_dot() -> bool:
	return not data.is_empty()

func add_dot_instance(dot_instance : DoTInstance) -> void:	
	if dot_instance.damage_type == DamageAndDoT.DamageType.VOID:
		push_error("Void is not a valid DoTInstance, use VoidInstance instead")
		return
	
	if not data.is_empty() and data.front().damage_type != dot_instance.damage_type:
		push_error("Cannot add DoTInstance of a different type to this DoTInstanceArray")
		return
		
	data.append(dot_instance)
	dot_instance.expired.connect(remove_dot_instance)

func remove_dot_instance(dot_instance : DoTInstance) -> void:
	data.erase(dot_instance)

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

func calculate_total_damage() -> int:
	var total_damage : float = 0.0
	var highest_potency : int = get_highest_potency()
	var highest_mastery : int = get_highest_mastery()
	
	for dot_instance in data:
		total_damage += dot_instance.calculate_damage(highest_potency, highest_mastery)
	
	return ceili(total_damage)

func calculate_total_attrition() -> int:
	var total_attrition : float = 0.0
	var highest_potency : int = get_highest_potency()
	var highest_mastery : int = get_highest_mastery()
	
	for dot_instance in data:
		total_attrition += dot_instance.calculate_attrition(highest_potency, highest_mastery)
	
	return ceili(total_attrition)
