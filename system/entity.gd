class_name Entity
extends RefCounted

var template : EntityTemplate

var current_hp : int
var current_shields : PackedInt64Array

var is_dead := false

var active_dots: Dictionary[DamageAndDoT.DoT, Dictionary] = {}
const STACKS_KEY := &"Stacks"
const BASE_DAMAGE_KEY := &"Base damage"
const TURNS_ELAPSED_KEY := &"Turns elapsed"

## Template will be duplicated
func _init(base_template : EntityTemplate, magnification : float = 1.0) -> void:
	template = base_template.duplicate(true)
	
	current_hp = floori(template.max_hp * magnification)
	
	current_shields.resize(DamageAndDoT.ELEMENT_COUNT)
	for i in range(DamageAndDoT.ELEMENT_COUNT):
		current_shields[i] = floori(template.max_shields[i] * magnification)
	
	setup_dot_dictionary()

func setup_dot_dictionary() -> void:
	for dot_type in DamageAndDoT.DoT.values():
		var dot_data : Dictionary = {}
		
		match dot_type:
			DamageAndDoT.DoT.BURN:
				# 50-sized arrays (10 durations * 5 ramping stages)
				var stacks := PackedInt64Array()
				stacks.resize(DamageAndDoT.MAX_DURATION * DamageAndDoT.MAX_BURN_TIERS)
				var base_dmg := PackedFloat64Array()
				base_dmg.resize(DamageAndDoT.MAX_DURATION * DamageAndDoT.MAX_BURN_TIERS)
				
				dot_data[STACKS_KEY] = stacks
				dot_data[BASE_DAMAGE_KEY] = base_dmg
				
			DamageAndDoT.DoT.VOID:
				# Void doesn't use duration arrays. It just needs two values.
				dot_data[STACKS_KEY] = 0
				dot_data[TURNS_ELAPSED_KEY] = 0
				
			_:
				# All other elements use 10-sized arrays (max duration = 10)
				var stacks := PackedInt64Array()
				stacks.resize(DamageAndDoT.MAX_DURATION)
				var base_dmg := PackedFloat64Array()
				base_dmg.resize(DamageAndDoT.MAX_DURATION)
				
				dot_data[STACKS_KEY] = stacks
				dot_data[BASE_DAMAGE_KEY] = base_dmg
		
		active_dots[dot_type] = dot_data

func is_any_shield_breached() -> bool:
	for i in range(DamageAndDoT.ELEMENT_COUNT):
		if template.max_shields[i] > 0 and current_shields[i] <= 0:
			return true
	return false

func has_no_shields() -> bool:
	for i in range(DamageAndDoT.ELEMENT_COUNT):
		if template.max_shields[i] > 0:
			return false
	return true

func take_damage(damage_type: DamageAndDoT.DamageType, incoming_damage: int) -> void:
	if is_dead:
		return
		
	# 1. Void Special Case
	if damage_type == DamageAndDoT.DamageType.VOID:
		if is_any_shield_breached() or has_no_shields():
			reduce_hp(incoming_damage)
		else:
			# TODO: Implement your loop here to find the lowest active shield
			print("Void no breach logic not yet implemented.")
			
		return
		
	# 2. Resonance (Direct Match) Case
	if template.max_shields[damage_type] > 0:
		var shield_hp = current_shields[damage_type]
		if shield_hp > 0:
			var damage_to_shield = mini(shield_hp, incoming_damage)
			current_shields[damage_type] -= damage_to_shield
			
			var surplus = incoming_damage - damage_to_shield
			if surplus > 0:
				reduce_hp(surplus)
			return
		
		# Shield is broken, matching damage goes straight to HP
		reduce_hp(incoming_damage)
		return
			
	# 3. Wrong Element Case (50% Penalty, hits weakest shield)
	# TODO: Implement your loop here to find the lowest active shield
	# and apply floori(incoming_damage * 0.5) to it.
	print("Wrong element logic not yet implemented.")

func reduce_hp(amount: int) -> void:
	current_hp = maxi(0, current_hp - amount)
	if current_hp <= 0:
		is_dead = true
