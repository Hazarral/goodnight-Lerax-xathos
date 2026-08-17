class_name Entity
extends RefCounted

var template : EntityTemplate
var magnification : float

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
func _init(base_template : EntityTemplate, p_magnification : float = 1.0) -> void:
	template = base_template
	magnification = p_magnification
	
	current_hp = get_max_hp()
	setup_shields()
	setup_active_dot_arrays()

func get_max_hp() -> int:
	return floori(template.max_hp * magnification)

func get_max_shield(i : int) -> int:
	return floori(template.max_shields[i] * magnification)

func setup_shields() -> void:
	current_shields.resize(DamageAndDoT.ELEMENT_COUNT)
	for i in range(DamageAndDoT.ELEMENT_COUNT):
		current_shields[i] = get_max_shield(i)

func setup_active_dot_arrays() -> void:
	active_dots.resize(DamageAndDoT.ELEMENT_COUNT)
	for i in range(DamageAndDoT.ELEMENT_COUNT):
		active_dots[i] = DoTInstanceArray.new()

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

func get_active_shield_indices() -> Array[int]:
	var arr : Array[int] = []
	for i in range(DamageAndDoT.ELEMENT_COUNT):
		if template.max_shields[i] > 0 and current_shields[i] > 0:
			arr.append(i)
	
	return arr

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
		# NOTE: DoT will still tick later on, but not compute the damage.
		return
		
	# 1. Void Special Case
	if damage_type == DamageAndDoT.DamageType.VOID:
		if is_any_shield_breached() or has_no_shields():
			reduce_hp(incoming_damage)
		else:
			shield_cascade(damage_type, incoming_damage)
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
	shield_cascade(damage_type, incoming_damage)

func shield_cascade(damage_type: DamageAndDoT.DamageType, incoming_damage: int) -> void:
	var multiplier_against_shield := (
		DamageAndDoT.VOID_MULTIPLIER_AGAINST_SHIELD 
		if damage_type == DamageAndDoT.DamageType.VOID 
		else DamageAndDoT.PENALIZED_MULTIPLIER_AGAINST_SHIELD
	)
	
	var remaining_damage : int = incoming_damage
	var active_shield_indices : Array[int] = get_active_shield_indices()
	
	while remaining_damage > 0 and not active_shield_indices.is_empty():
		## 1. Update X (active shield count) and M (minimum shield value) per iteration, need to recompute
		var active_shield_count := active_shield_indices.size()
		var minimum_shield_value := current_shields[active_shield_indices[0]]
		for i in range(1, active_shield_count):
			minimum_shield_value = mini(minimum_shield_value, current_shields[active_shield_indices[i]])
		
		# 2.0 penalized multiplier is guaranteed to be integer anyway
		var cost : int = int(active_shield_count * minimum_shield_value * multiplier_against_shield)
		
		## 2. Distribute damage equally before refunding
		for idx in active_shield_indices:
			current_shields[idx] -= minimum_shield_value
		
		## 3. Enough damage to pay, no refund
		if remaining_damage >= cost:
			remaining_damage -= cost
			active_shield_indices = get_active_shield_indices()
			continue
		
		## 4. Refund
		# Again, guaranteed to be integer
		var deficit_damage : int = cost - remaining_damage
		
		# Integer Ceil: If we are short even 1 damage point, we must refund the full shield point.
		# This perfectly mimics flooring the forward damage. The odd damage is absorbed and lost.
		var deficit_shield : int = int((deficit_damage + multiplier_against_shield - 1) / multiplier_against_shield)
		
		# Sort in descending order with elemental ordering as tiebreker for actual refunding
		active_shield_indices.sort_custom(func(a : int, b : int) -> bool:
			# Value first
			if current_shields[a] != current_shields[b]:
				return current_shields[a] > current_shields[b]
				
			# Then elemental enum index
			return a < b 
		)
		
		for idx in active_shield_indices:
			if deficit_shield <= 0:
				break
				
			var refund : int = mini(minimum_shield_value, deficit_shield)
			current_shields[idx] += refund
			deficit_shield -= refund
			
		# The damage was insufficient to wipe the layer. 
		# All remaining damage is fully absorbed by the shield, even if odd/inefficient.
		remaining_damage = 0
		break
	
	# What is left will go to HP, even if it is 0
	if remaining_damage > 0:
		reduce_hp(remaining_damage)

func reduce_hp(amount: int) -> void:
	if current_state == State.DEAD:
		return
	
	current_hp = maxi(0, current_hp - amount)
	if current_hp <= 0:
		die()

func die() -> void:
	current_state = State.DEAD
	current_hp = 0
	print("Entity %s died" % template.entity_name)

func take_turn() -> void:
	## TODO: Implement the pipeline here
	push_error("Entity.take_turn() is not implemented!")
