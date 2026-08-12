class_name DoTInstanceArray
extends RefCounted

var data : Array[DoTInstance]

func _init(dot_instance : DoTInstance = null) -> void:
	if dot_instance:
		add_dot_instance(dot_instance)

func has_dot() -> bool:
	return not data.is_empty()

func add_dot_instance(dot_instance : DoTInstance) -> void:
	if not dot_instance:
		push_error("Cannot add null DoTInstance to DoTInstanceArray")
		return
	
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

func calculate_total_damage(potency : int, mastery : int) -> int:
	var total_damage : float = 0.0
	for dot_instance in data:
		total_damage += dot_instance.calculate_damage(potency, mastery)
	
	return ceili(total_damage)

func calculate_total_attrition(potency : int, mastery : int) -> int:
	var total_attrition : float = 0.0
	for dot_instance in data:
		total_attrition += dot_instance.calculate_attrition(potency, mastery)
	
	return ceili(total_attrition)
