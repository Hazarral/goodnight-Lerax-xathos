class_name Entity
extends RefCounted

var template : EntityTemplate

var current_hp : int
var current_shields : PackedInt64Array
var current_potency : int
var current_mastery : int

enum State {
	ALIVE,
	DEAD
}

## Used for targeting
var current_state := State.ALIVE

## This is for looting the corpse via consumption
var is_looted := false

## Either on player's side or not
var is_player_faction := false

var active_dots : Array[DoTInstanceArray] = []
var void_instance : VoidInstance = null
const STACKS_KEY := &"Stacks"
const BASE_DAMAGE_KEY := &"Base damage"
const TURNS_ELAPSED_KEY := &"Turns elapsed"

## Template will be duplicated
func _init(base_template : EntityTemplate, magnification : float = 1.0) -> void:
	template = base_template.duplicate(true)
	current_hp = floori(template.max_hp * magnification)
	
	setup_shields(magnification)
	setup_active_dot_arrays()

func setup_shields(magnification : float) -> void:
	current_shields.resize(DamageAndDoT.ELEMENT_COUNT)
	for i in range(DamageAndDoT.ELEMENT_COUNT):
		current_shields[i] = floori(template.max_shields[i] * magnification)

func setup_active_dot_arrays() -> void:
	for type in DamageAndDoT.DamageType.values():
		active_dots[type] = DoTInstanceArray.new()
	
	# NOTE: VoidInstance will handle it!
	active_dots.remove_at(DamageAndDoT.DamageType.VOID)

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

func has_dot(damage_type : DamageAndDoT.DoT) -> bool:
	return active_dots[damage_type].has_dot()

func has_void() -> bool:
	return void_instance != null

func apply_dot(dot_instance : DoTInstance) -> void:
	active_dots[dot_instance.damage_type].add_dot_instance(dot_instance)

func apply_void(stacks : int, p_is_player_faction : bool) -> void:
	## NOTE: Technically is_plahyer_faction can never change, and must be opposite to this entity
	if is_player_faction == p_is_player_faction:
		push_error("Cannot apply Void to the same faction as caster!")
		return
	
	if not has_void():
		void_instance = VoidInstance.new(self, stacks, is_player_faction)
	else:
		void_instance.apply_stacks(stacks)

func take_damage(damage_type: DamageAndDoT.DamageType, incoming_damage: int) -> void:
	if current_state == State.DEAD:
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
		die()

func die() -> void:
	current_state = State.DEAD
	current_hp = 0
	print("Entity %s died" % template.entity_name)
