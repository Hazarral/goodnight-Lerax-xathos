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

## This is for distinguishing entities with the exact same name based on field position
var display_suffix : int = -1

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

func get_entity_name_with_suffix() -> String:
	return template.entity_name + CombatSystem.get_entity_name_suffix(self)

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

func get_total_max_shield() -> int:
	var result := 0
	for shield in max_shields:
		result += shield
	
	return result

func has_dot(dot_type : DamageAndDoT.DoT) -> bool:
	return active_dots[dot_type].has_dot()

func has_void() -> bool:
	return void_instance != null

func get_void_stacks() -> int:
	if not has_void():
		return 0
	
	return void_instance.stacks

func get_void_elapsed_turns() -> int:
	if not has_void():
		return 0
	
	return void_instance.turns_elapsed

func get_current_void_damage() -> int:
	if not has_void():
		return 0
	
	return void_instance.get_current_damage(CombatSystem.get_the_draechen())

func get_total_attrition() -> int:
	var result := 0.0
	for dot_instance_array in active_dots:
		if not dot_instance_array.has_dot():
			continue
		
		result += dot_instance_array.calculate_total_attrition()
	
	return ceili(result)

func is_player_faction() -> bool:
	return template.is_player_faction

func apply_dot(dot_instance : DoTInstance) -> void:
	active_dots[dot_instance.damage_type].add_dot_instance(dot_instance)
	var combat_log_entry := DoTAfflictionCombatLogEntry.new(
		CombatSystem.get_turn_counter(),
		self,
		"DoT Affliction",
		dot_instance
	)
	CombatLog.register(combat_log_entry)

func apply_void(stacks : int) -> void:
	## NOTE: Technically is_plahyer_faction can never change, and must be opposite to this entity	
	if not has_void():
		void_instance = VoidInstance.new(self, stacks, is_player_faction())
	else:
		void_instance.apply_stacks(stacks)
	
	var combat_log_entry := VoidAfflictionCombatLogEntry.new(
		CombatSystem.get_turn_counter(),
		self,
		"Void Affliction",
		stacks
	)
	CombatLog.register(combat_log_entry)

func get_attrition(damage_type : DamageAndDoT.DamageType) -> float:
	if not (has_shield(damage_type) and active_dots[damage_type].has_dot()):
		return 0
	
	return active_dots[damage_type].calculate_total_attrition()

func get_damage_per_turn(damage_over_time : DamageAndDoT.DoT) -> float:
	return active_dots[damage_over_time].calculate_total_damage()

func take_damage(damage_type : DamageAndDoT.DamageType, incoming_damage : int, ignore_shield : bool = false) -> void:
	if current_state == State.DEAD:
		# NOTE: DoT will still tick later on, but not compute the damage.
		return
	
	if ignore_shield:
		print("This damage ignores shield...")
		reduce_hp(damage_type, incoming_damage, ignore_shield)
		return
	
	# 1. Void Special Case
	if damage_type == DamageAndDoT.DamageType.VOID:
		if is_any_shield_breached() or has_no_shields():
			reduce_hp(damage_type, incoming_damage, ignore_shield)
		else:
			shield_cascade(damage_type, incoming_damage)
		return
		
	# 2. Resonance (Direct Match) Case
	if max_shields[damage_type] > 0:
		var shield_hp = current_shields[damage_type]
		if shield_hp > 0:
			var damage_to_shield = mini(shield_hp, incoming_damage)
			current_shields[damage_type] -= damage_to_shield
			
			var combat_log_entry := ResonanceDamageToShieldCombatLogEntry.new(
				CombatSystem.get_turn_counter(),
				self,
				"Resonance Element hit",
				damage_type,
				damage_to_shield
			)
			CombatLog.register(combat_log_entry)
			
			var surplus = incoming_damage - damage_to_shield
			if surplus > 0:
				reduce_hp(damage_type, surplus, ignore_shield)
			
			return
		
		# Shield is broken, matching damage goes straight to HP
		reduce_hp(damage_type, incoming_damage, ignore_shield)
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
	
	var damage_to_shield := PackedInt64Array()
	damage_to_shield.resize(DamageAndDoT.ELEMENT_COUNT)
	var newly_broken_indices : Array[int] = []
	var total_shield_damage := 0
	for idx in range(current_shields.size()):
		var delta : int = shields_before[idx] - current_shields[idx]
		damage_to_shield[idx] = delta
		
		if delta > 0:
			total_shield_damage += delta
		if shields_before[idx] > 0 and current_shields[idx] == 0:
			newly_broken_indices.append(idx)
	
	var combat_log_entry := CascadeDamageToShieldCombatLogEntry.new(
		CombatSystem.get_turn_counter(),
		self,
		"Shield Cascade Algorithm (SCA)",
		damage_type,
		total_shield_damage,
		damage_to_shield
	)
	CombatLog.register(combat_log_entry)
	# What is left will go to HP, even if it is 0
	
	if has_dot(DamageAndDoT.DoT.FROSTBITE) and not newly_broken_indices.is_empty():
		_trigger_frostbite_on_break(newly_broken_indices)
	
	if remaining_damage > 0:
		reduce_hp(damage_type, remaining_damage)

func reduce_hp(damage_type : DamageAndDoT.DamageType, amount : int, ignore_shield : bool = false) -> void:
	if current_state == State.DEAD:
		return
	
	current_hp = maxi(0, current_hp - amount)
	
	var damage_to_hp_log := DamageToHPCombatLogEntry.new(
		CombatSystem.get_turn_counter(),
		self,
		"reduce_hp(...)",
		damage_type,
		amount,
		ignore_shield
	)
	CombatLog.register(damage_to_hp_log)
	
	if current_hp <= 0:
		die()

func heal(amount : int) -> void:
	if current_state == State.DEAD:
		print("You cannot bring back the dead by healing them, my dear")
		return
	
	var real_amount := amount
	var hp_before_heal := current_hp
	
	if has_dot(DamageAndDoT.DoT.BLEED):
		real_amount = _get_bleed_healing_reduction_amount(amount)
	
	# NOTE: Heal first, before rupture damage
	current_hp = mini(get_max_hp(), current_hp + real_amount)
	var hp_after_heal := current_hp
	
	if has_dot(DamageAndDoT.DoT.BLEED):
		_trigger_bleed_rupture_damage(amount)
	
	var combat_log_entry := HealCombatLogEntry.new(
		CombatSystem.get_turn_counter(),
		self,
		"Healing",
		amount,
		real_amount,
		hp_before_heal,
		hp_after_heal
	)
	CombatLog.register(combat_log_entry)

func die() -> void:
	if current_state == State.DEAD:
		print("The dead is no more, but more can be lost.")
		return
	
	current_state = State.DEAD
	current_hp = 0
	
	var combat_log_entry := DeathCombatLogEntry.new(
		CombatSystem.get_turn_counter(),
		self,
		"Death"
	)
	CombatLog.register(combat_log_entry)
	
	## Resolve poison effect here
	if has_dot(DamageAndDoT.DoT.POISON):
		_trigger_poison_explosion_on_death()
	
	if not is_player_faction():
		CombatSystem.backfill_reinforcements()
	
	if CombatSystem.is_current_actor(self):
		end_turn()
	
func begin_turn() -> void:
	var combat_log_entry := TurnStartCombatLogEntry.new(
		CombatSystem.get_turn_counter(),
		self,
		"Begin Turn",
		current_state
	)
	CombatLog.register(combat_log_entry)
	
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
	_resolve_void()
	
	## Stage F: Tick down on all DoT
	_resolve_dot_tick_down()
	
	## Stage F: Actions
	start_action_phase()

func start_action_phase() -> void:
	print("%s is starting action phase..." % template.entity_name)
	if is_player_faction():
		## NOTE: The player will control, nothing special here
		return
	
	## TODO: AI goes here

func end_turn() -> void:
	recover_action_point()
	tick_cooldowns()
	var combat_log_entry := TurnEndCombatLogEntry.new(
		CombatSystem.get_turn_counter(),
		self,
		"Final: Turn Ended"
	)
	CombatLog.register(combat_log_entry)
	
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
	var action_wrapper := known_actions[index]
	
	if not action_wrapper.is_castable():
		push_error("Cannot cast %s due to cooldown or AP cost!" % action_wrapper.get_action_name())
		return
	
	var pending_slot := CombatLog.reserve_slot()
	var cast_result := await action_wrapper.cast()
	
	if not cast_result.success:
		CombatLog.cancel_reserved_slot(pending_slot)
		print("Cast cancelled by target selection.")
		return
	
	var combat_log_entry := CastActionCombatLogEntry.new(
		CombatSystem.get_turn_counter(),
		self,
		"Cast Success",
		known_actions[index].get_action_name(),
		known_actions[index].get_action_point_cost(),
		known_actions[index].get_cooldown()
	)
	CombatLog.fill_reserved_slot(pending_slot, combat_log_entry)
	
	if has_dot(DamageAndDoT.DoT.SHOCK):
		print("Triggering shock damage...")
		_trigger_shock_damage_on_action(cast_result.ap_spent)

##Combat turn stages below

func _regen_shields() -> void:
	var shield_before_regen := current_shields.duplicate()
	var attrition_list := PackedInt64Array()
	attrition_list.resize(DamageAndDoT.ELEMENT_COUNT)
	
	for i in range(DamageAndDoT.ELEMENT_COUNT):
		if max_shields[i] > 0:
			var attrition := ceili(get_attrition(i as DamageAndDoT.DamageType))
			current_shields[i] = maxi(0, max_shields[i] - attrition)
			attrition_list[i] = attrition
		else:
			attrition_list[i] = 0
	
	var shield_after_regen := current_shields.duplicate()
	var combat_log_entry := ShieldRegenCombatLogEntry.new(
		CombatSystem.get_turn_counter(),
		self,
		"A: Shield Regen",
		max_shields,
		attrition_list,
		shield_before_regen,
		shield_after_regen
	)
	
	CombatLog.register(combat_log_entry)

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
	var damage_types : Array[DamageAndDoT.DamageType] = []
	
	for dot_instance_array in active_dots:
		if not dot_instance_array.has_dot():
			continue
		
		if dot_instance_array.get_dot_type() == DamageAndDoT.DoT.WIND_SHEAR:
			continue
		
		damage_types.append(dot_instance_array.get_dot_type())
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
	
	if not damage_types.is_empty():
		var combat_log_entry := WindShearSpreadCombatLogEntry.new(
			CombatSystem.get_turn_counter(),
			self,
			"Wind Shear Spread",
			damage_types,
			valid_targets
		)
		CombatLog.register(combat_log_entry)
	
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

func _trigger_frostbite_on_break(newly_broken_indices : Array[int]) -> void:
	for idx in newly_broken_indices:
		var multiplier : float = DamageAndDoT.FROSTBITE_ICE_SHIELD_BREAK_COEFFICIENT if ((idx as DamageAndDoT.DamageType) == DamageAndDoT.DamageType.ICE) else DamageAndDoT.FROSTBITE_NON_ICE_SHIELD_BREAK_COEFFICIENT
		var damage_event := DamageEvent.new(
			self,
			self,
			DamageAndDoT.DamageType.ICE,
			ceili(multiplier * max_shields[idx]),
			true
		)
		
		CombatSystem.inject_combat_event(damage_event)

func _get_bleed_healing_reduction_amount(heal_amount : int) -> int:
	var highest_mastery := active_dots[DamageAndDoT.DoT.BLEED].get_highest_mastery()
	var healing_reduction := DamageAndDoT.get_bleed_healing_reduction(highest_mastery)
	return maxi(0, ceili(heal_amount * (1 - healing_reduction)))

func _trigger_bleed_rupture_damage(heal_amount : int) -> void:
	var highest_mastery := active_dots[DamageAndDoT.DoT.BLEED].get_highest_mastery()
	var highest_potency := active_dots[DamageAndDoT.DoT.BLEED].get_highest_potency()
	var stacks_count := active_dots[DamageAndDoT.DoT.BLEED].get_all_stacks_count()
	var total_bleed_damage := active_dots[DamageAndDoT.DoT.BLEED].calculate_total_damage()
	
	var anti_heal_damage := ceili(DamageAndDoT.get_bleed_anti_heal_damage(total_bleed_damage, heal_amount, highest_mastery, highest_potency, stacks_count))
	var damage_event := DamageEvent.new(
		self,
		self,
		DamageAndDoT.DamageType.PHYSICAL,
		anti_heal_damage,
		true
	)
	
	CombatSystem.inject_combat_event(damage_event)

func _trigger_poison_explosion_on_death() -> void:
	var valid_targets := DamageAndDoT.get_poison_special_effect_targets(self, is_player_faction())
	var highest_mastery := active_dots[DamageAndDoT.DoT.POISON].get_highest_mastery()
	var explosion_damage := ceili(DamageAndDoT.get_poison_attrition_explosion_damage(get_total_attrition(), highest_mastery))
	
	for entity in valid_targets:
		var damage_event := DamageEvent.new(
			self,
			entity,
			DamageAndDoT.DamageType.POISON,
			explosion_damage
		)
		
		CombatSystem.inject_combat_event(damage_event)
	
	await EventBus.combat_event_queue_processing_finished
	
	var highest_hp_target : Entity = null
	for entity in valid_targets:
		if entity.current_state != Entity.State.ALIVE:
			continue
		
		if highest_hp_target == null or entity.current_hp > highest_hp_target.current_hp:
			highest_hp_target = entity
	
	if highest_hp_target != null:
		DamageAndDoT.transfer_poison_damage_over_time(self, highest_hp_target)

func _trigger_shock_damage_on_action(ap_spent : int) -> void:
	var total_shock_damage := active_dots[DamageAndDoT.DoT.SHOCK].calculate_total_damage()
	var highest_potency := active_dots[DamageAndDoT.DoT.SHOCK].get_highest_potency()
	var shock_damage_on_action := ceili(DamageAndDoT.get_shock_damage_on_action(total_shock_damage, highest_potency, ap_spent))
	var damage_event := DamageEvent.new(
		self,
		self,
		DamageAndDoT.DamageType.LIGHTNING,
		shock_damage_on_action,
		true
	)
	
	CombatSystem.inject_combat_event(damage_event)

func _resolve_void() -> void:
	if void_instance == null:
		## No Void for now
		return
	
	var pending_slot := CombatLog.reserve_slot()
	
	void_instance.deal_damage(CombatSystem.get_the_draechen())
	
	var the_draechen := CombatSystem.get_the_draechen()
	var encounter_potency_and_mastery := CombatSystem.get_highest_enemy_potency_and_mastery()
	var void_tick_log_entry := VoidTickCombatLogEntry.new(
		CombatSystem.get_turn_counter(),
		self,
		"Void Tick",
		get_current_void_damage(),
		void_instance.stacks,
		void_instance.turns_elapsed,
		get_total_attrition(),
		the_draechen.get_max_hp(), 
		the_draechen.get_total_max_shield(),
		the_draechen.get_potency(),
		the_draechen.get_mastery(),
		encounter_potency_and_mastery.potency,
		encounter_potency_and_mastery.mastery
	)
	CombatLog.fill_reserved_slot(pending_slot, void_tick_log_entry)
	
	void_instance.escalate()
	
	var void_escalate_log_entry := VoidEscalateCombatLogEntry.new(
		CombatSystem.get_turn_counter(),
		self,
		"Void Tick"
	)
	CombatLog.register(void_escalate_log_entry)
