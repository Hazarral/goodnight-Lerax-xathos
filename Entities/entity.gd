class_name Entity
extends RefCounted

var template : EntityTemplate
var magnification : float

var current_hp : int
var max_shields : PackedInt64Array
var current_shields : PackedInt64Array
var current_potency : int
var current_mastery : int
var current_action_point : int

enum State {
	ALIVE,
	DEAD
}

## Used for targeting
var current_state := State.ALIVE

## This is for looting the corpse via consumption
var is_looted := false

var active_dots : Array[DoTInstanceArray] = []
var void_instance : VoidInstance = null

var known_actions : Array[KnownAction]

const STACKS_KEY := &"Stacks"
const BASE_DAMAGE_KEY := &"Base damage"
const TURNS_ELAPSED_KEY := &"Turns elapsed"

## Template will be duplicated
func _init(base_template : EntityTemplate, p_magnification : float = 1.0) -> void:
	template = base_template
	magnification = p_magnification
	
	current_hp = get_max_hp()
	current_potency = get_potency()
	current_mastery = get_mastery()
	setup_shields()
	setup_active_dot_arrays()
	setup_action_points()
	setup_innate_actions()
	
	current_state = State.ALIVE

func get_max_hp() -> int:
	return floori(template.max_hp * magnification)

func get_max_shield(i : int) -> int:
	return floori(max_shields[i] * magnification)

func get_potency() -> int:
	return floori(template.potency * magnification)

func get_mastery() -> int:
	return floori(template.mastery * magnification)

func setup_shields() -> void:
	max_shields = template.get_packed_shields()
	current_shields.resize(DamageAndDoT.ELEMENT_COUNT)
	for i in range(DamageAndDoT.ELEMENT_COUNT):
		current_shields[i] = get_max_shield(i)

func setup_active_dot_arrays() -> void:
	active_dots.resize(DamageAndDoT.ELEMENT_COUNT)
	for i in range(DamageAndDoT.ELEMENT_COUNT):
		active_dots[i] = DoTInstanceArray.new()

func setup_action_points() -> void:
	current_action_point = template.starting_action_point

func setup_innate_actions() -> void:
	for action in template.innate_actions:
		learn_action(action)

func get_max_action_point() -> int:
	return template.max_action_point

func get_action_point_regen_per_turn() -> int:
	return template.action_point_regen_per_turn

func recover_action_point() -> void:
	current_action_point = mini(current_action_point + template.action_point_regen_per_turn, template.max_action_point)

func has_shield(damage_type : DamageAndDoT.DamageType) -> bool:
	if damage_type == DamageAndDoT.DamageType.VOID:
		return false
	
	return max_shields[damage_type] > 0

func is_any_shield_breached() -> bool:
	for i in range(DamageAndDoT.ELEMENT_COUNT):
		if max_shields[i] > 0 and current_shields[i] <= 0:
			return true
	return false

func are_all_shields_breached() -> bool:
	for i in range(DamageAndDoT.ELEMENT_COUNT):
		if max_shields[i] > 0 and current_shields[i] > 0:
			return false
	
	return true

func has_no_shields() -> bool:
	for i in range(DamageAndDoT.ELEMENT_COUNT):
		if max_shields[i] > 0:
			return false
	return true

func get_active_shield_indices() -> Array[int]:
	var arr : Array[int] = []
	for i in range(DamageAndDoT.ELEMENT_COUNT):
		if max_shields[i] > 0 and current_shields[i] > 0:
			arr.append(i)
	
	return arr

func has_dot(dot_type : DamageAndDoT.DoT) -> bool:
	return active_dots[dot_type].has_dot()

func has_void() -> bool:
	return void_instance != null

func is_player_faction() -> bool:
	return template.is_player_faction

func apply_dot(dot_instance : DoTInstance) -> void:
	active_dots[dot_instance.damage_type].add_dot_instance(dot_instance)

func apply_void(stacks : int, is_void_on_player_faction : bool) -> void:
	## NOTE: Technically is_plahyer_faction can never change, and must be opposite to this entity
	if is_player_faction() == is_void_on_player_faction:
		push_error("Cannot apply Void to the same faction as caster!")
		return
	
	if not has_void():
		void_instance = VoidInstance.new(self, stacks, is_void_on_player_faction)
	else:
		void_instance.apply_stacks(stacks)

func get_attrition(damage_type : DamageAndDoT.DamageType) -> float:
	if not (has_shield(damage_type) and active_dots[damage_type].has_dot()):
		return 0
	
	return active_dots[damage_type].calculate_total_attrition()

func get_damage_per_turn(damage_over_time : DamageAndDoT.DoT) -> float:
	return active_dots[damage_over_time].calculate_total_damage()

func get_void_stacks() -> int:
	return void_instance.stacks

func take_damage(damage_type : DamageAndDoT.DamageType, incoming_damage : int) -> void:
	if current_state == State.DEAD:
		# NOTE: DoT will still tick later on, but not compute the damage.
		return
		
	# 1. Void Special Case
	if damage_type == DamageAndDoT.DamageType.VOID:
		if is_any_shield_breached() or has_no_shields():
			reduce_hp(damage_type, incoming_damage)
		else:
			shield_cascade(damage_type, incoming_damage)
		return
		
	# 2. Resonance (Direct Match) Case
	if max_shields[damage_type] > 0:
		var shield_hp = current_shields[damage_type]
		if shield_hp > 0:
			var damage_to_shield = mini(shield_hp, incoming_damage)
			current_shields[damage_type] -= damage_to_shield
			
			print("> Resonance! %s's %s shield received %d %s damage!" % [
				template.entity_name,
				DamageAndDoT.get_damage_type_name(damage_type), 
				damage_to_shield,
				DamageAndDoT.get_damage_type_name(damage_type)
				]
			)
			var surplus = incoming_damage - damage_to_shield
			if surplus > 0:
				reduce_hp(damage_type, surplus)
			
			return
		
		# Shield is broken, matching damage goes straight to HP
		reduce_hp(damage_type, incoming_damage)
		return
			
	# 3. Wrong Element Case (50% Penalty, hits weakest shield)
	shield_cascade(damage_type, incoming_damage)

func shield_cascade(damage_type : DamageAndDoT.DamageType, incoming_damage : int) -> void:
	var multiplier_against_shield := (
		DamageAndDoT.VOID_MULTIPLIER_AGAINST_SHIELD 
		if damage_type == DamageAndDoT.DamageType.VOID 
		else DamageAndDoT.PENALIZED_MULTIPLIER_AGAINST_SHIELD
	)
	
	var shields_before : PackedInt64Array = current_shields.duplicate()
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
	
	var shield_damage_dealt : Dictionary[int, int] = {}
	var total_shield_damage := 0
	for idx in range(current_shields.size()):
		var delta : int = shields_before[idx] - current_shields[idx]
		if delta > 0:
			shield_damage_dealt[idx] = delta
			total_shield_damage += delta
	
	_print_sca_damage_to_shield(damage_type, shield_damage_dealt, total_shield_damage)
	# What is left will go to HP, even if it is 0
	if remaining_damage > 0:
		reduce_hp(damage_type, remaining_damage)

func reduce_hp(damage_type : DamageAndDoT.DamageType, amount : int) -> void:
	if current_state == State.DEAD:
		return
	
	print("> %s received %d %s damage to HP!" % [
		template.entity_name,
		amount,
		DamageAndDoT.get_damage_type_name(damage_type)
		]
	)
	current_hp = maxi(0, current_hp - amount)
	
	if current_hp <= 0:
		die()

func _print_sca_damage_to_shield(incoming_damage_type : DamageAndDoT.DamageType, shield_damage : Dictionary[int, int], total_shield_damage : int) -> void:
	print("> %s received a total of %d %s damage to shield" % [
		template.entity_name, 
		total_shield_damage,
		DamageAndDoT.get_damage_type_name(incoming_damage_type)
		]
	)
	
	for i in shield_damage:
		var damage_type := i as DamageAndDoT.DamageType
		print(">> %s shield received %d %s damage" % [
			DamageAndDoT.get_damage_type_name(damage_type), 
			shield_damage[damage_type],
			DamageAndDoT.get_damage_type_name(incoming_damage_type)
			]
		)

func heal(amount : int) -> void:
	if current_state == State.DEAD:
		print("You cannot bring back the dead by healing them, my dear")
		return
	
	## Normal healing short-circuit
	if not has_dot(DamageAndDoT.DoT.BLEED):
		current_hp = mini(get_max_hp(), current_hp + amount)
		print("HP: %d/%d" % [current_hp, get_max_hp()])
		return
	
	## THe real elaborate healing
	var highest_mastery := active_dots[DamageAndDoT.DoT.BLEED].get_highest_mastery()
	var highest_potency := active_dots[DamageAndDoT.DoT.BLEED].get_highest_potency()
	var stacks_count := active_dots[DamageAndDoT.DoT.BLEED].get_all_stacks_count()
	var healing_reduction := DamageAndDoT.get_bleed_healing_reduction(highest_mastery)
	var real_amount := maxi(0, ceili(amount * (1 - healing_reduction)))
	
	# NOTE: Heal first, before damage
	current_hp = mini(get_max_hp(), current_hp + real_amount)
	
	var anti_heal_damage := ceili(DamageAndDoT.get_bleed_anti_heal_damage(amount, highest_mastery, highest_potency, stacks_count))
	var damage_event := DamageEvent.new(
		self,
		self,
		DamageAndDoT.DamageType.PHYSICAL,
		anti_heal_damage,
		true
	)
	
	# NOTE: If injected, never call process_combat_event_queue further
	CombatSystem.inject_combat_event(damage_event)

func die() -> void:
	current_state = State.DEAD
	current_hp = 0
	print("Entity %s died" % template.entity_name)
	
	if not is_player_faction():
		CombatSystem.backfill_reinforcements()
	
	end_turn()

func begin_turn() -> void:
	## TODO: Implement the pipeline here
	print("%s is beginning their turn!" % template.entity_name)
	if current_state == State.DEAD:
		print("This target is dead! DoT will still tick down")
		_resolve_dot_tick_down()
		end_turn()
		return
	
	## Stage A: Shield regen + Attrition
	_regen_shields()
	
	## Stage B: Resolve Crumble splash effect 
	if has_dot(DamageAndDoT.DoT.CRUMBLE):
		_resolve_crumble_splash_effect()
	
	## Stage C: Resolve DoT (only the damage part)
	_resolve_dot_damage()
	
	## Stage D: Wind Shear blast effect
	if has_dot(DamageAndDoT.DoT.WIND_SHEAR):
		_resolve_wind_shear_spread_effect()
		_resolve_wind_shear_blast_effect()
	
	## Stage E: Void
	## TODO: implement Void damage and escalation here
	
	## Stage F: Tick down on all DoT
	_resolve_dot_tick_down()
	
	## Stage F: Actions
	start_action_phase()

func start_action_phase() -> void:
	print("%s is starting action phase..." % template.entity_name)

func end_turn() -> void:
	print("%s's turn ended!" % template.entity_name)
	recover_action_point()
	tick_cooldowns()
	CombatSystem.on_turn_finished()
	EventBus.force_refresh_turn_ui.emit()

func learn_action(action : Action) -> void:
	known_actions.append(KnownAction.new(action, self))

func get_known_actions() -> Array[KnownAction]:
	return known_actions

func tick_cooldowns() -> void:
	for known_action in known_actions:
		known_action.tick_cooldown()

func cast_action(index : int) -> void:
	var is_cast_success := await known_actions[index].cast()
	
	if not is_cast_success:
		push_error("Cannot cast %s due to cooldown or AP cost!" % known_actions[index].action.action_name)

##Combat turn stages below

func _regen_shields() -> void:
	for i in range(DamageAndDoT.ELEMENT_COUNT):
		if max_shields[i] > 0:
			var attrition := ceili(get_attrition(i as DamageAndDoT.DamageType))
			current_shields[i] = maxi(0, max_shields[i] - attrition)

func _resolve_crumble_splash_effect() -> void:
	var total_damage := active_dots[DamageAndDoT.DoT.CRUMBLE].calculate_total_damage()
	var non_earth_shield_damage := ceili(
		DamageAndDoT.get_crumble_splash_damage(
			total_damage, 
			active_dots[DamageAndDoT.DoT.CRUMBLE].get_highest_potency()
		)
	)
	var multi_damage_event := MultiCombatEvent.new(self)
	var active_shield_indices := get_active_shield_indices()
	
	for idx in active_shield_indices:
		if idx as DamageAndDoT.DamageType == DamageAndDoT.DamageType.EARTH:
			continue
		
		var real_amount := mini(current_shields[idx], non_earth_shield_damage)
		var damage_event := DamageEvent.new(self, self, idx as DamageAndDoT.DamageType, real_amount)
		multi_damage_event.add_event(damage_event)
	
	CombatSystem.register_multi_combat_event(multi_damage_event)
	CombatSystem.process_combat_event_queue()

func _resolve_dot_damage() -> void:
	var has_current := has_dot(DamageAndDoT.DoT.CURRENT)
	for damage_over_time in DamageAndDoT.ELEMENT_COUNT:
		if has_dot(damage_over_time as DamageAndDoT.DoT):
			active_dots[damage_over_time].resolve_damage(self, has_current)

func _resolve_dot_tick_down() -> void:
	## NOTE: This is for decreasing duration afterward.
	for damage_over_time in DamageAndDoT.ELEMENT_COUNT:
		if has_dot(damage_over_time as DamageAndDoT.DoT):
			active_dots[damage_over_time].tick_down()

func _resolve_wind_shear_spread_effect() -> void:
	## NOTE: Damage Duplication is still sourced from the original sources
	var valid_targets = DamageAndDoT.get_wind_shear_special_effect_targets(self, is_player_faction())
	
	for dot_instance_array in active_dots:
		if not dot_instance_array.has_dot():
			continue
		
		if dot_instance_array.get_dot_type() == DamageAndDoT.DoT.WIND_SHEAR:
			continue
		
		for instance in dot_instance_array.data:
			for target in valid_targets:
				var damage_event := DamageEvent.new(
					instance.source, 
					target, 
					instance.damage_type, 
					ceili(
						DamageAndDoT.get_wind_shear_spread_damage(
							instance.calculate_damage(), 
							instance.get_current_mastery()
						)
					)
				)
				
				CombatSystem.register_combat_event(damage_event)
	
	CombatSystem.process_combat_event_queue()

func _resolve_wind_shear_blast_effect() -> void:
	## NOTE: The blast is sourced from the emitter, aka this entity
	var valid_targets = DamageAndDoT.get_wind_shear_special_effect_targets(self, is_player_faction())
	
	var total_wind_shear_damage := active_dots[DamageAndDoT.DoT.WIND_SHEAR].calculate_total_damage()
	var highest_potency := active_dots[DamageAndDoT.DoT.WIND_SHEAR].get_highest_potency()
	
	## +1 due to "self" being filtered
	var afflicted_count := valid_targets.size() + 1
	
	var entity_names := valid_targets.map(func(entity : Entity) -> String: return entity.template.entity_name)
	print("Wind Shear Blast Targets: ", entity_names)
	for target in valid_targets:
		var damage_event := DamageEvent.new(
			self,
			target,
			DamageAndDoT.DamageType.WIND,
			ceili(
				DamageAndDoT.get_wind_shear_blast_damage(
					total_wind_shear_damage,
					highest_potency,
					afflicted_count
				)
			)
		)
		
		CombatSystem.register_combat_event(damage_event)
	
	CombatSystem.process_combat_event_queue()
