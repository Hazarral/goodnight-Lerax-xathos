class_name UtilityMath
extends Object

const MIN_VAL : float = -1.0
const MAX_VAL : float = 1.0
const NEUTRAL_VAL : float = 0.0
const RANGE : float = MAX_VAL - MIN_VAL

const LOGISTICS_EXPONENT_COEFFICIENT : float = 10.0
const LOGISTICS_EXPONENT_MIDPOINT : float = 0.5

const EXPONENTIAL_DECAY_COEFFICIENT : float = 0.1

const LOGARITHMIC_MAX_COUNT : int = CombatSystem.MAX_ALIVE_ENEMY_ON_FIELD

const LINEAR_EXTRAPOLATION_MAX_COUNT : int = DamageAndDoT.ELEMENT_COUNT

const FROSTBITE_BOUNTY_BASE : float = 0.2
const FROSTBITE_BOUNTY_BASE_MAX : float = 0.6
const FROSTBITE_BOUNTY_BASE_MAX_ICE : float = 1.4

const BOOLEAN_TRUE := MAX_VAL
const BOOLEAN_FALSE := MIN_VAL

## Specific considerations
const FROSTBITE_BOUNTY_HALF_VALUE_COST  := 100.0
const FROSTBITE_ICE_BOUNTY_MULTIPLIER := 2.0

const EARLY_COMBAT_TURN_COUNTER_WEIGHT := 0.5
const HIGH_MAX_SHIELD_RATIO_CAP := 0.5

const LOW_HP_TARGET_MIN_VAL := -0.5
const HIGH_HP_TARGET_MIN_VAL = -0.2

const HIGH_DOT_COUNT_COEFFICIENT := 0.5

const HIGH_TOTAL_DOT_RATIO_CAP := 0.6
const HIGH_TOTAL_DOT_DISCOUNT_COEFFICIENT := 0.1 # Lower means more preference for sustained damage

const HIGH_DOT_DAMAGE_RATIO_CAP := 0.5

static func _logistic(value : float, is_decreasing : bool = false) -> float:
	## Typically used in HighHPTarget and LowHPTarget
	var sgn := 1 if is_decreasing else -1
	var power : float = sgn * LOGISTICS_EXPONENT_COEFFICIENT * (value - LOGISTICS_EXPONENT_MIDPOINT)
	
	# Applies a linear scaling, vertically stretching it so it meets the actual endpoints
	var raw := 1.0 / (1.0 + exp(power))
	
	var min_power := -LOGISTICS_EXPONENT_COEFFICIENT * LOGISTICS_EXPONENT_MIDPOINT
	var max_power := LOGISTICS_EXPONENT_COEFFICIENT * (1.0 - LOGISTICS_EXPONENT_MIDPOINT)
	
	var min_raw := 1.0 / (1.0 + exp(-min_power))
	var max_raw := 1.0 / (1.0 + exp(-max_power))
	
	var normalized := (raw - min_raw) / (max_raw - min_raw)
	
	return MIN_VAL + RANGE * normalized

static func _exponential_decay(value : float) -> float:
	return MIN_VAL + RANGE * exp(-EXPONENTIAL_DECAY_COEFFICIENT * maxf(value, 0.0))

static func _logarithmic(value : int) -> float:
	## Typically used in HighTargetCount
	var v := clampi(value, 0, LOGARITHMIC_MAX_COUNT)
	return MIN_VAL + RANGE * log(v + 1) / log(LOGARITHMIC_MAX_COUNT + 1)

static func _lerp(value : int, max_value : int = LINEAR_EXTRAPOLATION_MAX_COUNT) -> float:
	## Typically used with HighShieldCount
	var v := clampi(value, 0, max_value)
	return MIN_VAL + RANGE * v / max_value

static func _lerp_float(value : float, max_value : float) -> float:
	## Typically used with HighMaxShieldValue, where value is a ratio
	var t := clampf(value / max_value, 0.0, 1.0)
	return MIN_VAL + RANGE * t

static func _boolean(value : bool) -> float:
	return BOOLEAN_TRUE if value else BOOLEAN_FALSE

static func get_raw_score(scoring_context : ScoringContext, consideration : Utility.Consideration) -> float:
	var actor := scoring_context.actor
	var target := scoring_context.target
	var ap_cost := scoring_context.ap_cost
	var cooldown := scoring_context.cooldown
	var valid_target_count := scoring_context.valid_target_count
	var is_single_target := scoring_context.is_single_target
	var damage_types := scoring_context.damage_types
	var dot_instances := scoring_context.dot_instances
	var buff_and_debuffs := scoring_context.buff_and_debuffs
	var combat_field_state := scoring_context.combat_field_state
	
	match consideration:
		Utility.Consideration.MATCHING_SHIELD:
			return _matching_shield_score(damage_types, dot_instances, target)
		Utility.Consideration.FROSTBITE_BOUNTY:
			return _frostbite_bounty_score(target, damage_types)
		Utility.Consideration.EARLY_COMBAT:
			return _early_combat_score(combat_field_state)
		Utility.Consideration.HIGH_HP_TARGET:
			return _high_hp_target_score(target)
		Utility.Consideration.LOW_HP_TARGET:
			return _low_hp_target_score(target)
		Utility.Consideration.LOW_HP_ALLY:
			# Yes, an ally is a target too
			# This will not check if the target is the same faction as actor 
			return _low_hp_target_score(target)
		Utility.Consideration.LOW_HP_SELF:
			return _low_hp_target_score(actor)
		Utility.Consideration.HIGH_TARGET_COUNT:
			return _high_target_count_score(valid_target_count, is_single_target)
		Utility.Consideration.HIGH_WIND_SHEARED_COUNT:
			return _high_wind_sheared_count_score(target)
		Utility.Consideration.HIGH_ACTIVE_SHIELD_COUNT:
			return _high_active_shield_count_score(target)
		Utility.Consideration.HIGH_MAX_SHIELD_VALUE:
			return _high_max_shield_value_score(target)
		Utility.Consideration.TOTAL_DOT_DEALT:
			return _total_dot_dealt_score(actor, target, dot_instances)
		Utility.Consideration.HIGH_DOT_COUNT:
			return _high_dot_count_score(target)
		Utility.Consideration.HIGH_DOT_DAMAGE:
			return _high_dot_damage_score(target)
		Utility.Consideration.DOT_EXIST:
			return _has_dot_score(target)
		Utility.Consideration.COOLDOWN:
			return _cooldown_score(cooldown)
		Utility.Consideration.AP_COST:
			return _ap_cost_score(actor, ap_cost)
		Utility.Consideration.MISSING_SELF_BUFF:
			return _missing_buff_and_debuff_score(actor, buff_and_debuffs)
		Utility.Consideration.MISSING_TARGET_DEBUFF:
			return _missing_buff_and_debuff_score(target, buff_and_debuffs)
		Utility.Consideration.EXCESS_AP:
			return _excess_ap_score(actor)
		Utility.Consideration.PREVENT_AP_OVERCAP:
			return _prevent_ap_overcap_score(actor, ap_cost)
	
	## Guard for any enum value added later without a case
	push_error("Unhandled consideration: %s" % Utility.Consideration.keys()[consideration])
	return 0.0

static func _matching_shield_score(damage_types : Array[DamageAndDoT.DamageType], dot_instances : Array[DoTInstance], target : Entity) -> float:
	## damage_types and dot_types are guaranteed to have no duplicate
	var total := damage_types.size() + dot_instances.size()
	if total == 0:
		return MIN_VAL
	
	var match_count := 0
	for damage_type in damage_types:
		if target.has_shield(damage_type):
			match_count += 1
	
	for dot_instance in dot_instances:
		if target.has_shield(dot_instance.damage_type):
			match_count += 1
	
	# Fraction will try to fill up from min to max
	return _lerp(match_count, total)

static func _frostbite_bounty_score(target : Entity, damage_types : Array[DamageAndDoT.DamageType]) -> float:
	## Find the best opportunity to break a shield, this is heuristics
	if not target.has_dot(DamageAndDoT.DoT.FROSTBITE):
		return NEUTRAL_VAL

	if damage_types.is_empty():
		return NEUTRAL_VAL

	var active_indices := target.get_active_shield_indices()

	if active_indices.is_empty():
		return NEUTRAL_VAL

	## Find the weakest shield for cascade.
	## Higher elemental index breaks first when tied.
	var weakest_index : int = active_indices[0]
	
	for idx in active_indices:
		var current := target.get_current_shield(idx)
		var weakest := target.get_current_shield(weakest_index)
	
		if current < weakest or (current == weakest and idx > weakest_index):
			weakest_index = idx
	
	## Store the best bounty per unique shield.
	var bounties : Dictionary[int, float] = {}
	
	for damage_type in damage_types:
		var shield_index : int = -1
		var multiplier : float = 1.0
		
		if damage_type == DamageAndDoT.DamageType.VOID:
			if target.is_any_shield_breached():
				## No value in breaking, it will eat into HP
				continue
		
			shield_index = weakest_index
			multiplier = DamageAndDoT.VOID_MULTIPLIER_AGAINST_SHIELD
		elif target.has_shield(damage_type):
			if target.get_current_shield(damage_type) <= 0:
				## No value in breaking, it will eat into HP
				continue
		
			shield_index = damage_type
		else:
			shield_index = weakest_index
			multiplier = DamageAndDoT.PENALIZED_MULTIPLIER_AGAINST_SHIELD
	
		## Asymptotic raw score
		var break_cost := target.get_current_shield(shield_index) * multiplier
		var bounty := 1.0 / (1.0 + break_cost / FROSTBITE_BOUNTY_HALF_VALUE_COST )
		
		## Doubled for ice, as usual
		if shield_index == DamageAndDoT.DamageType.ICE:
			bounty *= FROSTBITE_ICE_BOUNTY_MULTIPLIER
	
		bounties[shield_index] = maxf(
			bounties.get(shield_index, 0.0),
			bounty
		)
	
	## Harmonic aggregation of unique shield opportunities.
	var sorted_bounties := bounties.values()
	sorted_bounties.sort()
	sorted_bounties.reverse()
	
	var total := 0.0
	
	for i in range(sorted_bounties.size()):
		total += sorted_bounties[i] / (i + 1)
	
	return MAX_VAL * clampf(
		total / FROSTBITE_ICE_BOUNTY_MULTIPLIER,
		0.0,
		1.0
	)

static func _early_combat_score(combat_field_state : CombatFieldState) -> float:
	var round_counter := combat_field_state.round_counter
	var turn_counter := combat_field_state.turn_counter
	
	var progression := (
		round_counter + 
		EARLY_COMBAT_TURN_COUNTER_WEIGHT * log(turn_counter + 1)
	) 
	
	return _exponential_decay(progression)

static func _high_hp_target_score(target : Entity) -> float:
	return clampf(_logistic(float(target.current_hp) / target.get_max_hp(), false), HIGH_HP_TARGET_MIN_VAL, MAX_VAL)

static func _low_hp_target_score(target : Entity) -> float:
	return clampf(_logistic(float(target.current_hp) / target.get_max_hp(), true), LOW_HP_TARGET_MIN_VAL, MAX_VAL)

static func _high_target_count_score(valid_target_count : int, is_single_target : bool) -> float:
	if is_single_target:
		return NEUTRAL_VAL
	
	return _logarithmic(valid_target_count)

static func _high_wind_sheared_count_score(target : Entity) -> float:
	var target_count := DamageAndDoT.get_wind_shear_special_effect_targets(null, target.is_player_faction()).size()
	return _logarithmic(target_count)

static func _high_active_shield_count_score(target : Entity) -> float:
	return _lerp(target.get_active_shield_count())

static func _high_max_shield_value_score(target : Entity) -> float:
	var ratio := target.get_total_max_shield() / maxf(target.max_hp, 1.0)
	return _lerp_float(ratio, HIGH_MAX_SHIELD_RATIO_CAP)

## This is archived as it computes the entire lifetime damage without discount, which is the same as setting HIGH_TOTAL_DOT_DISCOUNT_COEFFICIENT = 0
#static func _calculate_total_dot_damage(dot_instance : DoTInstance, potency : int, mastery : int) -> float:
	#var dot_type : DamageAndDoT.DoT = DamageAndDoT.get_dot(dot_instance.damage_type)
	#var duration : int = dot_instance.duration  # use your actual field name
	#
	#if dot_type == DamageAndDoT.DoT.VOID:
		#push_error("Void has special damage! Please use VoidInstance.get_void_damage(...)")
		#return 0.0
	#
	#var coefs : PackedFloat32Array = DamageAndDoT.DOT_COEFFICIENTS.get(dot_type)
	#var potency_coef : float = coefs[DamageAndDoT.Coefficient.DAMAGE_POTENCY]
	#var mastery_coef : float = coefs[DamageAndDoT.Coefficient.DAMAGE_MASTERY]
#
	#var constant_base := dot_instance.base_damage + potency_coef * potency + mastery_coef * mastery
	#var total := 0.0
#
	#if dot_instance is BurnInstance:
		## Burn has instance-specific per-tick multipliers.
		## Retain the original simulation for this case.
		## The summation below is O(1), done by splitting the ramping sum from the constant max ramp sum
		#var max_ramp_duration := DamageAndDoT.MAX_BURN_TIERS - 1
		#var ramp_duration := mini(duration, max_ramp_duration)
		#var ramp_float := float(ramp_duration)
		#var base_tick := constant_base + duration
		#
		#var sum_indices := ramp_float * (ramp_float - 1.0) / 2.0
		#var sum_squared_indices := ramp_float * (ramp_float - 1.0) * (2.0 * ramp_float - 1.0) / 6.0
		#
		#total = dot_instance.stacks * (
			#ramp_float * base_tick
			#- sum_indices
			#+ 0.5 * (base_tick * sum_indices - sum_squared_indices)
		#)
		#
		#if duration > max_ramp_duration:
			#var remaining_duration := float(duration - max_ramp_duration)
			#var remaining_damage := remaining_duration * base_tick - (float(duration - 1) * duration / 2.0 - 6.0)
			#total += dot_instance.stacks * 3.0 * remaining_damage
	#else:
		#total = dot_instance.stacks * (
			#duration * constant_base + duration * (duration + 1) / 2.0
		#)
#
	#return total

static func _calculate_discounted_dot_damage(dot_instance : DoTInstance, potency : int, mastery : int) -> float:
	var dot_type := DamageAndDoT.get_dot(dot_instance.damage_type)
	
	if dot_type == DamageAndDoT.DoT.VOID:
		push_error("Void requires special damage calculation!")
		return 0.0
	
	var total := 0.0
	
	for i in range(dot_instance.duration):
		var remaining_duration := dot_instance.duration - i
		
		var damage := DamageAndDoT.calculate_dot_damage(
			dot_type,
			dot_instance.base_damage,
			potency,
			mastery,
			dot_instance.stacks,
			remaining_duration
		)
		
		if dot_instance is BurnInstance:
			damage *= BurnInstance.get_burn_theoretical_multiplier(i)
		
		## Harmonic in the form 1 / (1 + k * turns_elapsed)
		var discount := 1.0 / (1.0 + HIGH_TOTAL_DOT_DISCOUNT_COEFFICIENT * i)
		
		total += damage * discount

	return total

static func _get_effective_pool(target : Entity, damage_type : DamageAndDoT.DamageType) -> int:
	if target.has_shield(damage_type):
		return target.current_hp + target.current_shields[damage_type]  # 0 if breached
	return target.current_hp + DamageAndDoT.PENALIZED_MULTIPLIER_AGAINST_SHIELD * target.get_total_current_shield()

static func _total_dot_dealt_score(actor : Entity, target : Entity, dot_instances : Array[DoTInstance]) -> float:
	if dot_instances.is_empty():
		return MIN_VAL
	
	var potency := actor.get_potency()
	var mastery := actor.get_mastery()
	var ratio := 0.0
	for dot_instance in dot_instances:
		var damage := _calculate_discounted_dot_damage(dot_instance, potency, mastery)
		ratio += damage / maxi(_get_effective_pool(target, dot_instance.damage_type), 1)
	
	return MIN_VAL + RANGE * clampf(ratio / HIGH_TOTAL_DOT_RATIO_CAP, 0.0, 1.0)

static func _high_dot_count_score(target : Entity) -> float:
	var target_dot_count := target.get_total_dot_instance_count()
	if target_dot_count == 0:
		return MIN_VAL
	
	var score := 0.0

	for i in target_dot_count:
		score += 1.0 / (i + 1)

	return minf(MIN_VAL + HIGH_DOT_COUNT_COEFFICIENT * score, MAX_VAL)

static func _high_dot_damage_score(target : Entity) -> float:
	## High if the tick damage of next turn is high, unlike TotalDoTDealt
	## Mostly useful for Current which echoes a % of other DoT ticks 
	
	var active_dots := target.get_active_dots()
	if active_dots.is_empty():
		return MIN_VAL
	
	var ratio := 0.0
	## Relative to their effective health
	for dot_instance_array in active_dots:
		var damage := dot_instance_array.calculate_total_damage()
		var effective_hp := _get_effective_pool(
			target, 
			DamageAndDoT.get_damage_type(dot_instance_array.get_dot_type())
		)
		ratio += damage / maxi(effective_hp, 1)
	
	return MIN_VAL + RANGE * clampf(ratio / HIGH_DOT_DAMAGE_RATIO_CAP, 0.0, 1.0)

static func _has_dot_score(target : Entity) -> float:
	return _boolean(target.has_any_dot())

static func _cooldown_score(cooldown : int) -> float:
	return -_exponential_decay(float(cooldown))

static func _ap_cost_score(actor : Entity, ap_cost : int) -> float:
	return -_lerp(ap_cost, actor.get_max_action_point())

static func _missing_buff_and_debuff_score(target : Entity, buff_and_debuffs : Array[BuffAndDebuff]) -> float:
	if buff_and_debuffs.is_empty():
		return NEUTRAL_VAL
	
	var missing_count := 0
	
	for buff_and_debuff in buff_and_debuffs:
		if not target.has_buff_and_debuff(buff_and_debuff):
			missing_count += 1
	
	return _lerp(missing_count, buff_and_debuffs.size())

static func _excess_ap_score(actor : Entity) -> float:
	var ratio := clampf(
		float(actor.get_current_action_point()) / maxi(actor.get_max_action_point(), 1),
		0.0,
		1.0
	)
	
	return _logistic(ratio)

static func _prevent_ap_overcap_score(actor : Entity, ap_cost : int) -> float:
	var overflow := (
		actor.get_current_action_point()
		+ actor.get_action_point_regen_per_turn()
		- actor.get_max_action_point()
	)

	if overflow <= 0:
		return 0.0

	return _lerp(ap_cost, overflow)
